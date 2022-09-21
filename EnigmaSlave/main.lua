function Enigma:Init()
	Utility:Print("Initializing addon...")
	Comm:Init()
	Vars:Init()
	
	Enigma:SetupUI()
end

local lastScan = nil
local shouldReturnData = false
local scanRequested = false

function Enigma:DecodeParamAndScan(msg, doSend)
	Utility:PrintDebug("scanning with request: '" .. msg .. "'")
	if lastScan == nil then
		Utility:PrintDebug("first scan")
		lastScan = GetTime()
	else
		local newTime = GetTime()
		local timeDiff = newTime - lastScan
		Utility:PrintDebug("last scan was " .. timeDiff .. " seconds ago")
		lastScan = newTime
	end
	
	scanRequested = true
	SetWhoToUI(1)
	SendWho(msg)
	
	shouldReturnData = doSend
end

function Enigma:SetupUI() -- setup settings frame
	if Enigma.UI == nil then
		Enigma.UI = {}
	end
	local ui = {} -- add tab to interface\addons menu
	ui.panel = CreateFrame( "Frame", "Enigma_Interface_Pane", UIParent);
	ui.panel.name = "EnigmaSlave";
	InterfaceOptions_AddCategory(ui.panel); 
	
	
	--create ui for interface\addons menu
	local dropdownLabel = ui.panel:CreateFontString("Enigma_Connected_Bnet_Label", "OVERLAY", "GameFontNormalSmall")
	dropdownLabel:SetPoint("TOPLEFT", ui.panel, "TOPLEFT", 25, -8)
	dropdownLabel:SetFont('Fonts\\FRIZQT__.ttf', 12)
	--dropdownLabel:SetTextColor(0.9, 0.9, 0.9, 1)
	dropdownLabel:SetText("Partnered Battle.net")
	
	local dropdown = CreateFrame("Button", "Enigma_Connected_Bnet_Dropdown", ui.panel, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", ui.panel, "TOPLEFT", 5, -25)
	
	
	UIDropDownMenu_Initialize(dropdown, 
	function()
		local info = UIDropDownMenu_CreateInfo()
		for i = 1,BNGetNumFriends(),1 do 
			local _,_,battleTag,_,_, presenceId = BNGetFriendInfo(i)		
			info = UIDropDownMenu_CreateInfo()
			info.text = battleTag
			info.value = presenceId
			info.arg1 = presenceId
			info.arg2 = battleTag
			info.notCheckable = 1
			info.keepShownOnClick = nil
			info.func = function(self, arg1, arg2)
				Vars:SetBnet(arg2)
				UIDropDownMenu_SetText(dropdown, arg2)
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	UIDropDownMenu_SetWidth(dropdown, 175);
	UIDropDownMenu_SetButtonWidth(dropdown, 124)
	UIDropDownMenu_SetSelectedID(dropdown, 1)
	UIDropDownMenu_JustifyText(dropdown, "LEFT")
	UIDropDownMenu_ClearAll(dropdown)
	local bnet = Vars:GetBnet()
	if bnet and bnet ~= "" then
		UIDropDownMenu_SetText(dropdown, bnet)
	end
end

local zoneData = ZoneList:New()
local playerData = {}
zoneData:SetName("All Zones")

local function OnWhoDataRecieved()
	if not scanRequested then
		Utility:Print("ERROR!! Unrequested who scan performed, data will not be recorded!")
	end

	local results = select(1, GetNumWhoResults());
	if results then
		if results < 50 then
			Utility:PrintDebug("Found ".. results .. " players!") -- print num players found
		else 
			Utility:Print("Found |cffcc1818" .. results .. "|r players! |cffcc1818!!Who result limit reached, possible missed data!!|r")
			Comm:SendBnetData(Comm.DataCodes.FULL_SCAN)
		end
		--add all zones to temporary buffer (used for more than one scan)
		for i = 1, results, 1 do
			local name, _, _, _, class, zone = GetWhoInfo(i)
			
			zoneData:AddZone(zone)
			
			if playerData[zone] == nil then
				playerData[zone] = PlayerList:New()
			end
			playerData[zone]:AddPlayer(class, name)
		end
		
		zoneData:Sort()
		
		local zones, pops = zoneData:GetZoneData()
		for i = 1, #zones, 1 do
			Utility:Print(zones[i] .. ": " .. pops[i])
		end
		
		Utility:Print("Found " .. zoneData:Length() .. " zones")
		
		if shouldReturnData then
			Comm:PackAndSend(zoneData, playerData)
			zoneData:ClearList()
			for k,_ in pairs(playerData) do
				playerData[k]:Clear()
				playerData[k] = nil
			end
		end
	end
end

Utility.eventFrame:RegisterEvent("WHO_LIST_UPDATE", 
	function(prefix, msg, _, sender) 
		OnWhoDataRecieved() 
	end)





