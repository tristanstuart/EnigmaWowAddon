local settingsOpen = false

function Settings:InitSettings()
	
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(Vars.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("EnigmaProfiles", profiles)
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Enigma", Settings:GetSlashCmdTable(), {"ng", "engima"})
end

local function refreshSettings(widget, name, group)
	widget:ReleaseChildren()
	if group == "general" then
		Settings:LoadGeneralUI(widget)
	elseif group == "who" then
		Settings:LoadWhoUI(widget)
	elseif group == "profiles" then
		Settings:LoadProfiles(widget)
	end
end

function Settings:GenSettingsFrame()
	local frame = Acegui:Create("ClosableFrame")-- actual window
	frame:SetTitle("Enigma")
	frame:SetCallback("OnClose", function(widget) Acegui:Release(widget); settingsOpen = false end)
	frame:SetWidth(700)
	frame:SetLayout("Flow")
	
	local tabCategories = Acegui:Create("TreeGroup")-- categories on the left
	local tree = {
		{
			value = "general",
			text = "General",
		},
		{
			value = "who",
			text = "Who Parameters",
		},
		{
			value = "profiles",
			text = "Profiles",
		},
	}

	tabCategories:SetTree(tree)
	tabCategories:EnableButtonTooltips(false)
	tabCategories:SetFullHeight(true)
	tabCategories:SetFullWidth(true)
	tabCategories:SetLayout("Flow")
	
	local bnetId = Acegui:Create("Dropdown")
	bnetId:SetText(Vars:GetPartnerBnet())
	bnetId:SetWidth(150)
	bnetId:SetList(Utility:GetBnetList())
	bnetId:SetCallback("OnValueChanged", 
		function(widget, name, val) 
			local bnet = Utility:GetBnetList()[val]
			bnetId:SetText(bnet)
			Vars:SetPartnerBnet(bnet)
		end)
	
	local a = Acegui:Create("Label")-- spacer for connect button
	a:SetText("")
	a:SetWidth(15)
	a:SetHeight(10)
	
	local connectButton = Acegui:Create("Button")-- id button
	connectButton:SetText(SlaveController:GetConnectButtonText())
	connectButton:SetWidth(100)
	connectButton:SetCallback("OnClick", 
	function(widget, name) 
		if not SlaveController.isConnected then
			SlaveController:ConnectToSlave()  
		else
			SlaveController:Disconnect()
		end
	end)
	
	SlaveController:SetDisconnectCallback(function() connectButton:SetText("Connect")end)
	SlaveController:SetConnectCallback(function() connectButton:SetText("Disonnect")end)
	
	frame:AddChild(bnetId)
	frame:AddChild(a)
	frame:AddChild(connectButton)
	--frame:AddChild(idButton)

	frame:AddChild(tabCategories)
	
	tabCategories:SelectByValue("general")
	self:LoadGeneralUI(tabCategories)
	
	tabCategories:SetCallback("OnGroupSelected", function(widget, name, group) refreshSettings(widget, name, group); end)
	tabCategories:DoLayout()
	settingsOpen = true
	return frame
end

function Settings:LoadProfiles(frame)

	local group = Acegui:Create("SimpleGroup")
	group:SetFullWidth(true)
	group:SetFullHeight(true)
	LibStub("AceConfigDialog-3.0"):Open("EnigmaProfiles", group)
	frame:AddChild(group)

end

function Settings:LoadGeneralUI(frame)
	local innerFrame = Acegui:Create("SimpleGroup")
	innerFrame:SetLayout("List")
	innerFrame:SetRelativeWidth(1.0)
	frame:AddChild(innerFrame)
		
	local chatPst = Acegui:Create("CheckBox")-- chat notifications checkbox
	chatPst:SetValue(Vars:GetChatNotify())
	chatPst:SetLabel("Extra Chat Notifications")
	chatPst:SetCallback("OnValueChanged", function(widget, name, val) Vars:SetChatNotify(val) end)
	innerFrame:AddChild(chatPst)
		
	local bottomFrame = Acegui:Create("SimpleGroup")
	bottomFrame:SetLayout("Flow")
	bottomFrame:SetRelativeWidth(0.8)
	--bottomFrame:SetTitle("Bar Display")
	frame:AddChild(bottomFrame)
		
	local statusbars = Enigma.media:List("statusbar")
	
	local titleBarTexture = Acegui:Create("Dropdown")-- delete zone
	titleBarTexture:SetLabel("Title Bar Texture")
	titleBarTexture:SetWidth(150)
	titleBarTexture:SetList(statusbars)
	titleBarTexture:SetText(Vars:GetTitleTexture())
	titleBarTexture:SetCallback("OnValueChanged", function(widget, name, val) 
		Vars:SetTitleTexture(statusbars[val])
		Bars:SetTitleTexture()
	end)
	bottomFrame:AddChild(titleBarTexture)
	
	local a = Acegui:Create("Label")
	a:SetWidth(31)
	a:SetHeight(20)
	a:SetText("")
	bottomFrame:AddChild(a)
	
	local infoBarTexture = Acegui:Create("Dropdown")-- delete zone
	infoBarTexture:SetLabel("Info Bars Texture")
	infoBarTexture:SetText(Vars:GetBarTexture())
	infoBarTexture:SetWidth(150)
	infoBarTexture:SetList(statusbars)
	infoBarTexture:SetCallback("OnValueChanged", function(widget, name, val) 
		Vars:SetBarTexture(statusbars[val])
		Bars:SetInfoBarTexture()
	end)
	bottomFrame:AddChild(infoBarTexture)
	
	local colorText = {}
	table.insert(colorText, {k = Vars.BarColors.TITLE, v = "Title Bar"})
	table.insert(colorText, {k = Vars.BarColors.HIGH_POP, v = "High Pop Zone"})
	table.insert(colorText, {k = Vars.BarColors.TITLE_FULL, v = "Full Scan Warning"})
	table.insert(colorText, {k = Vars.BarColors.MED_POP, v = "Medium Pop Zone"})
	table.insert(colorText, {k = Vars.BarColors.IMPORTANT, v = "Important Zone"})
	table.insert(colorText, {k = Vars.BarColors.LOW_POP, v = "Low Pop Zone"})
	local colors = {}
	
	for i = 1, #colorText, 1 do
		local colorPicker = Acegui:Create("ColorPicker")
		colorPicker:SetColor(Vars:GetBarColor(colorText[i].k))
		colorPicker:SetHasAlpha(false)
		colorPicker:SetLabel(colorText[i].v)
		colorPicker:SetHeight(27)
		colorPicker:SetWidth(180)
		colorPicker:SetCallback("OnValueConfirmed", function(widget, name, r,g,b,a)
			Vars:SetBarColor(colorText[i].k, r, g, b)
			Bars:SetTitleTexture()
			Bars:SetInfoBarTexture()
		end)
		bottomFrame:AddChild(colorPicker)
	end
	

	frame:DoLayout()
	bottomFrame:DoLayout()
	innerFrame:DoLayout()
end

function Settings:LoadWhoUI(mainFrame)
	local frame = Acegui:Create("SimpleGroup")
	frame:SetFullHeight(true)
	frame:SetFullWidth(true)
	frame:SetLayout("Flow")
	mainFrame:AddChild(frame)
	
	
	local filterFrame = Acegui:Create("SimpleGroup") -- groups /who filters and clear all button
	filterFrame:SetLayout("Flow")
	filterFrame:SetRelativeWidth(.5)
	filterFrame:SetFullHeight(true)
	frame:AddChild(filterFrame)
	
	local labels = {"g", "z", "n", "r", "ll", "hl"}-- who filters
	local whoBoxes = {}
	for i = 1, #labels, 1 do
		whoBoxes[i] = Acegui:Create("EditBox")
		whoBoxes[i]:SetLabel(Utility:Caps(Vars.query:GetLabel(labels[i])))
		whoBoxes[i]:SetText(Vars.query:GetValue(labels[i]))
		whoBoxes[i]:SetCallback("OnEnterPressed", function(widget, name, val) 
			Vars.query:SetValue(labels[i], val, true); 
			SlaveController:UpdateScanList(); 
			Acegui:ClearFocus() 
		end)
		whoBoxes[i]:SetWidth(200)
		filterFrame:AddChild(whoBoxes[i])
	end
	
	local a = Acegui:Create("Label")-- spacer for clear all button
	a:SetText("")
	a:SetHeight(10)
	filterFrame:AddChild(a)
	
	local clearAll = Acegui:Create("Button")-- clear all
	clearAll:SetText("Clear All")
	clearAll:SetWidth(120)
	clearAll:SetCallback("OnClick", function(widget, name) Vars.query:ClearQuery(true); for i = 1, #whoBoxes, 1 do whoBoxes[i]:SetText("") end end)
	filterFrame:AddChild(clearAll)

	-------------------------zones-------------------------
		
	local zoneGroup = Acegui:Create("SimpleGroup")-- groups zone stuff
	zoneGroup:SetRelativeWidth(.5)
	zoneGroup:SetFullHeight(true)
	zoneGroup:SetLayout("Flow")
	frame:AddChild(zoneGroup)
	
	local numScans = Acegui:Create("Dropdown")-- delete zone
	numScans:SetLabel("Num Scans")
	numScans:SetText("")
	numScans:SetWidth(70)
	local validScans = {"1","2","3","4","6"}
	numScans:SetList(validScans)
	numScans:SetValue(Vars:GetNumScansDropdown())
	numScans:SetCallback("OnValueChanged", function(widget, name, val) 
		Vars:SetNumScans(validScans[val]); 
		SlaveController:UpdateScanList() 
	end)
	zoneGroup:AddChild(numScans)
	
	
	
	local b = Acegui:Create("Label")-- spacer for clear all button
	b:SetText("")
	b:SetHeight(20)
	zoneGroup:AddChild(b)
	
	
	-------------------------important zones-------------------------
	
	local iZoneFrame = Acegui:Create("InlineGroup")-- groups important zone stuff
	local addIZone = Acegui:Create("EditBox")-- add zone
	local delIZone = Acegui:Create("Dropdown")-- delete zone
	iZoneFrame:SetLayout("List")
	iZoneFrame:SetWidth(230)
	iZoneFrame:SetTitle("Important Zones")
	zoneGroup:AddChild(iZoneFrame)
	
	addIZone:SetLabel("Add Important Zone")-- add zone
	addIZone:SetWidth(200)
	addIZone:SetCallback("OnEnterPressed", 
		function(widget, name, val)
			Vars.iZones:AddZone(val, 0)
			if Bars.bars[val .. "I"] == nil then
				Bars:AddBar(val, 0, true, "")
			end
			delIZone:SetList(Vars.iZones:ZoneList())
			widget:SetText("") 
			Vars:SaveiZones()
		end)
	iZoneFrame:AddChild(addIZone)
	
	delIZone:SetLabel("Delete Important Zone") -- delete zone
	delIZone:SetText("")
	delIZone:SetWidth(200)
	delIZone:SetList(Vars.iZones:ZoneList())
	delIZone:SetCallback("OnValueChanged", 
		function(widget, name, val) 
			local zone = Vars.iZones:GetZoneName(val)
			delIZone:SetValue(false)
			if Bars.bars[zone .. "I"] then
				Bars:RemoveBar(zone .. "I")
			end
			
			Vars.iZones:RemoveZone(zone)
			delIZone:SetList(Vars.iZones:ZoneList())
			delIZone:SetText("")  
			Vars:SaveiZones()
		end)
	iZoneFrame:AddChild(delIZone)
	
	iZoneFrame:DoLayout()
	filterFrame:DoLayout()
	zoneGroup:DoLayout()
	frame:DoLayout()
end

function Settings:GetSlashCmdTable()
local options = {
	name = "Enigma",
	handler = Enigma,
	type = 'group',
	args = {
		options  = {
			type = 'execute',
			name = "Shows Options",
			desc = "Show options panel",
			func = function() if not settingsOpen then Settings:GenSettingsFrame() end end,
			guiHidden = true,
		},
		show  = {
			type = 'execute',
			name = "Shows Bar Panel",
			desc = "Show bar panel",
			func = function() Bars.barGroup:Show() end,
			guiHidden = true,
		},
		hide  = {
			type = 'execute',
			name = "Hide Bar Panel",
			desc = "Hide bar panel",
			func = function() Bars.barGroup:Hide() end,
			guiHidden = true,
		},
		print = {
			type = 'execute',
			name = 'Print /who',
			desc = 'prints current /who request',
			func = function() Vars.query:PrintFormattedQuery() end,
			guiHidden = true,
		},
	},
}
	return options
end