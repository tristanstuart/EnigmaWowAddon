Enigma = LibStub("AceAddon-3.0"):NewAddon("Enigma", "AceConsole-3.0", "AceEvent-3.0")
Vars = {}
Settings = {}
SlaveController = {
	playerCount = 0,
	lastScan = 0
}
Bars = Enigma:NewModule("EnimgaBars", "SpecializedLibBars-1.0")
Acegui = LibStub("AceGUI-3.0")

local scanning = false
local id = ""

function Enigma:OnInitialize()
	-- run on addon first load	
	Vars:Init()
	Settings:InitSettings()
	Bars:Init()
	SlaveController:Init()
	self.zones = ZoneList:New()
	self.zones:SetName("All Zones")
end
 

function Enigma:OnEnable()
	-- run on addon enable???
end

function Enigma:OnDisable()
	-- run on addon disable???
end

function Enigma:PrintToDo(msg)
	Enigma:Print("|cfff4d442TODO:|r " .. msg)
end

function Enigma:PrintError(msg)
	Enigma:Print("|cffcc1818ERROR:|r " .. msg)
end

function Enigma:PrintDebug(msg)
	if Vars:GetChatNotify() then
		Enigma:Print("|cffd142f4DEBUG:|r " .. msg)
	end
end

function Enigma:GetScanning()
	return scanning
end

function Enigma:SetScanning(val)
	scanning = val
	SlaveController:SetScanning(val)
end

