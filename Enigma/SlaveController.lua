local timer = LibStub("AceTimer-3.0")
local hooks = {}

local scanList = {}
local CLASS_LIST = {"Demon Hunter", "Hunter", "Warlock", "Druid", "Priest", "Paladin", "Mage", "Rogue", "Monk", "Warrior", "Death knight", "Shaman"}

local maxPop = nil
local zones = {}

local connectCallback = nil
local disconnectCallback = nil

local function ClearZoneData()
	maxVal = nil
	for k,v in pairs(zones) do
		zones[k] = nil
	end
end

function SlaveController:SetConnectCallback(fxn)
	connectCallback = fxn
end

function SlaveController:SetDisconnectCallback(fxn)
	disconnectCallback = fxn
end

local function doConnectCallback()
	if connectCallback ~= nil then
		connectCallback()
	end
end

local function doDisconnectCallback()
	if disconnectCallback ~= nil then
		disconnectCallback()
	end
end

local function RegisterHook(name, fxn)
	hooks[name] = fxn
end

local function OnSlaveIdle(msg)
	if not SlaveController.isConnected then 
		Enigma:Print("Connected to slave client!")
		doConnectCallback()
		SlaveController.isConnected = true
		Enigma:Print("Running scan(s)...")
		SlaveController:UpdateScanList()
		SlaveController.scanCt = 1
		ClearZoneData()
		SlaveController:CreateRepeatingTimer()
		SlaveController:DoScan("new connect call")
	end
end

local function OnSlaveDisconnect(msg)
	if SlaveController.isConnected then
		if SlaveController.timer ~= nil then
			SlaveController:CreateCdTimer("slave dc")
			doDisconnectCallback()
			SlaveController.isConnected = false
			Enigma:PrintError("Slave client has disconnected!! Please reconnect to continue scanning!!!")
		end
	end
end

local function ParseData(msg)
	local numZones = tonumber(string.sub(msg, 1, string.find(msg, "~") - 1))
	msg = string.sub(msg, string.find(msg, "~") + 1, string.len(msg))
	Enigma:PrintDebug("found " .. numZones .. " zones")
	
	for i=1,numZones,1 do
		--parse info
		--[[
			explanation:
			sample data string would look something like this: 
				"zoneName~zonePopulation~{player1~player2~...}"
			
			This is parsed by looking for the closest ~ to the front of the string and
			cutting the data off. So it would look something like this:
						
				closest ~ is the one immediately following zoneName
				
				so pull the data from the start of the string to the ~, which would be "zoneName"
				
				"zoneName" is stored in a variable, so now we can cut off "zoneName~" and 
				repeat for population and player list
				
				cut string would look like this: "zonePopulation~{player1~player2~...}"
		
		]]
		local zone = string.sub(msg, 1, string.find(msg, "~") - 1) 
			msg = string.sub(msg, string.find(msg, "~") + 1, string.len(msg))
		
		local p = tonumber(string.sub(msg, 1, string.find(msg, "~") - 1))
			msg = string.sub(msg, string.find(msg, "~") + 1, string.len(msg))		
		local plyrs = string.sub(msg, 1, string.find(msg, "~") - 1)
			msg = string.sub(msg, string.find(msg, "~") + 1, string.len(msg))
	
		--done parsing info, actually do stuff
		if i == 1 and maxVal == nil then --update the maximum value a bar can be
			maxVal = p
		end
		
		zones[zone] = {
			pop = p,
			players = plyrs
		}
		
		Enigma:PrintDebug(zone .. ", " .. p .. ", " .. zones[zone].players)
	end
end

local function OnDataRecieved(msg)
	ParseData(msg)
	Bars:Update(maxVal, zones)
	
	local pop = 0
	for _,v in pairs(zones) do
		pop = pop + v.pop
	end
	SlaveController.playerCount = pop
	local curTime = date("*t", time())
	SlaveController.lastScan = string.format("%02.f", ((curTime.hour + 1) % 12 - 1)) .. ":" .. string.format("%02.f", curTime.min) .. ":" .. string.format("%02.f", curTime.sec)
	Bars:SetTitleText()
	
	--clear maxVal and zones
	ClearZoneData()
end

function SlaveController:Init()
	self.isConnected = false

	RegisterHook(DataCodes.IDLE, OnSlaveIdle)
	RegisterHook(DataCodes.DISCONNECT, OnSlaveDisconnect)
	RegisterHook(DataCodes.DATA, OnDataRecieved)
	RegisterHook(DataCodes.INCOMPLETE_DATA, ParseData)
	
	Enigma:RegisterEvent("BN_CHAT_MSG_ADDON", SlaveController.DoResponse)
	
	self.timer = nil
	self.scanCt = 1
	self.canScan = true
	self.repeating = nil
	
	SlaveController:UpdateScanList()
end

function SlaveController:GetLastScan()
	return self.lastScan or 0
end

function SlaveController:GetPlayerCount()
	return self.playerCount or "n/a"
end

function SlaveController:DoResponse(addonPrefix, msg, whisper, presenceId)
	if presenceId == Utility:getPresenceIdForBtag() then
		--print("msg has valid presenceId")
		if hooks[addonPrefix] ~= nil then
			Enigma:PrintDebug("hook found for " .. addonPrefix)
			hooks[addonPrefix](msg)
		end
	end
end

function SlaveController:Disconnect()
	self.isConnected = false
	doDisconnectCallback()
	self:CreateCdTimer("master dc")
	ClearZoneData()
	SlaveController:SendBnetData(DataCodes.DISCONNECT)
end

function SlaveController:ConnectToSlave()
	if Vars:GetPartnerBnet() == nil then
		Enigma:Print("Cannot connect to slave, no Battle.net selected.")
		return
	end
	SlaveController:SendBnetData(DataCodes.CONNECT)
	Enigma:Print("Connecting...")
end

function SlaveController:UpdateScanList()
    while #scanList > 0 do
		table.remove(scanList)
	end

    local numScans = Vars:GetNumScans()
	if numScans == 1 then
	    table.insert(scanList, Vars.query:GetQuery())
			Enigma:PrintDebug("Added scan " .. Vars.query:GetQuery() .. " to scan list")
	else
	    local base = Vars.query:GetQuery()
        local classesPerScan = 12 / numScans
	    for a=1,numScans,1 do
            local startScan = (a - 1) * classesPerScan + 1
        	local classesAdded = " "
        	for i = startScan, startScan + classesPerScan - 1,1 do
        		classesAdded = classesAdded .. 'c-"' .. CLASS_LIST[i] .. '" '
        	end
			table.insert(scanList, base .. classesAdded)
			Enigma:PrintDebug("Added scan " .. base .. classesAdded .. " to scan list")
	    end
	end
	
	self.scanCt = 1
	ClearZoneData()
	Bars:SetTitleText()
	Bars:Clear()
end

function SlaveController:SendScan()
	Enigma:PrintDebug("Doing scan " .. self.scanCt .. " of " .. Vars:GetNumScans() .. " with " .. #scanList .. " scans in scanlist")
	if self.scanCt == #scanList then --this whole if/else should deal with all numbers of scans
		Enigma:PrintDebug("Scan: " .. scanList[self.scanCt])
		Enigma:PrintDebug("Requesting return of data")
		SlaveController:SendBnetData(DataCodes.SCAN_AND_RETURN, scanList[self.scanCt])
		self.scanCt = 1
	else
		Enigma:PrintDebug("Scan: " .. scanList[self.scanCt])
		SlaveController:SendBnetData(DataCodes.SCAN, scanList[self.scanCt])
		self.scanCt = self.scanCt + 1
	end
end

function SlaveController:DoScan(call)
	if self.isConnected then
		if self.canScan then-- if the cooldown timer has ticked over, do a scan
			self:SendScan()
			self.canScan = false
			if not self.repeating then--we know we're supposed to be scanning so if we arent repeat scanning, start
				self:CreateRepeatingTimer()
			end
		end
	else--if not connected or not scanning
		if self.repeating then --if we've still got the repeat scan timer going
			SlaveController:CreateCdTimer("scan loop") -- stop it but keep track of when we can scan next
			self.repeating = false
		end
	end
end

function SlaveController:CreateRepeatingTimer()
	if timer:TimeLeft(self.timer) > 0 then
		Enigma:PrintDebug("Could not create repeating scan timer, another timer is already in effect.")
		return
	end
	
	if not self.repeating then
		Enigma:PrintDebug("Successfully created reapeating timer!")
		self.timer = timer:ScheduleRepeatingTimer(
			function()
				SlaveController.canScan = true;
				SlaveController.repeating = true
				SlaveController:DoScan("repeat timer")
			end, 11)
		self.repeating = true
	end
end

function SlaveController:SendBnetData(pre, msg)
	local presenceId = Utility:getPresenceIdForBtag()
	if presenceId then
		pre = pre or "Enigma"
		msg = msg or ""
		--print("sending message: pre: " .. pre .. " msg: " .. msg)
		BNSendGameData(presenceId, pre, msg)
	end
end

function SlaveController:CreateCdTimer(call)
	if self.timer ~= nil and timer:TimeLeft(self.timer) > 0 then
		local cdLeft = timer:TimeLeft(self.timer)
		Enigma:PrintDebug("Creating scan cd timer for " .. cdLeft .. " seconds")
		timer:CancelTimer(self.timer)
		self.repeating = false
		self.timer = timer:ScheduleTimer(
		    function() 
			    SlaveController.canScan = true; 
				SlaveController:DoScan("cd timer") 
	        end, cdLeft)
	end
end

function SlaveController:GetConnectButtonText()
	if self.isConnected then
		return "Disconnect"
	else
		return "Connect"
	end
end



