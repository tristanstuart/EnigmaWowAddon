Vars.BarColors = {
	IMPORTANT = "importantColor",
	HIGH_POP = "highPop",
	LOW_POP = "lowPop",
	MED_POP = "medPop",
	TITLE = "title",
	TITLE_FULL = "titleFull",
}

function Vars:Init()
	self:RegisterIdDialog()
	
	self.query = WhoQuery:New()	
	self.iZones = ZoneList:New()
	self.iZones.name = "Important Zones"
	
	self:InitDBAndVars()
	
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
end

function Vars:SaveWho()
	self.db.profile.who = self.query:GetQuery()
end

function Vars:SaveiZones()
	print("saving important zones")
	self.db.profile.importantZones = self.iZones:ZoneList()
end

function Vars:RefreshConfig()
	self.query:SetQuery(self.db.profile.who, self:GetChatNotify())
	
	self.iZones:LoadProfile(self.db.profile.importantZones, self:GetChatNotify())
	
	print("refreshing config!")
	
	Enigma:Print("Loaded profile: '" .. self.db:GetCurrentProfile() .. "'")
	SlaveController:Disconnect()
	SlaveController:UpdateScanList()
end

function Vars:InitDBAndVars()
	local defaults = {
		profile = {
			who = "",
			importantZones = {},
			numScans = "1"
		},
		global = {
			chatNotify = false,
			partnerBnet = "",
			barwindow = {
				width = 400,
				height = 300,
				importantColor = {r = 204 / 255, g = 24 / 255, b = 24 / 255},
				lowPop = {r = 0, g = 179 / 255, b = 0},
				medPop = {r = 230 / 255, g = 230 / 255, b = 0},
				highPop = {r = 230 / 255, g = 92 / 255, b = 0},
				title = {r = 0, g = 102 / 255, b = 204 / 255},
				titleFull = {r = 204 / 255, g = 24 / 255, b = 24 / 255},
				titleTexture = "Armory",
				barTexture = "Minimalist",
			},
		},
	}
	
	self.db = LibStub("AceDB-3.0"):New("EnigmaDB", defaults)
	
	if self.db.profile.who ~= "" then
		self.query:SetQuery(self.db.profile.who)
	end
	
	if self.db.profile.importantZones and #self.db.profile.importantZones > 0 then
		self.iZones:AddAllZones(self.db.profile.importantZones, 0)
	end
end

function Vars:GetPartnerBnet()
	local id = self.db.global.partnerBnet
	if id == "" or id == nil then
		id = "None"
	end
	
	return id
end

function Vars:SetPartnerBnet(text)
	self.db.global.partnerBnet = text
end

function Vars:GetChatNotify()
	return self.db.global.chatNotify
end

function Vars:SetChatNotify(input)
	self.db.global.chatNotify = input
end

function Vars:GetNumScans()
	return self.db.profile.numScans
end

function Vars:GetNumScansDropdown()
	local val = tonumber(self.db.profile.numScans)
	
	if val > 4 then
		val = 5
	end
	
	return val
end

function Vars:SetNumScans(input) 
	local num = tonumber(input) 
	if num ~= nil and (num > 0 and num < 7 and num ~= 5) then 
		self.db.profile.numScans = input 
		if self:GetChatNotify() then
			Enigma:Print("Set num scans to " .. input)
		end
	else 
		Enigma:Print("Scans per update must be the number 1, 2, 3, 4, or 6!") 
	end 
end

function Vars:RegisterIdDialog()	
	
end


------------Bar vars get/set--------------------

function Vars:GetBarWindowSize()
	return self.db.global.barwindow.width, self.db.global.barwindow.height
end

function Vars:SetBarWindowSize(width, height)
	self.db.global.barwindow.width, self.db.global.barwindow.height = width, height
end

local function packColor(r, g, b)
	local color = {}
	color.r = r
	color.g = g
	color.b = b
	return color
end

local function unpackColor(color)
	return color.r, color.g, color.b
end

function Vars:SetBarColor(bar, r, g, b)
	local bardb = self.db.global.barwindow
	local barRef = bardb[bar]
	if barRef == nil then
		Enigma:PrintError("Attempted to save color for unknown bar!")
		return
	end
	
	bardb[bar] = packColor(r, g, b)
end

function Vars:GetBarColor(bar)
	local bardb = self.db.global.barwindow
	local barRef = bardb[bar]
	if barRef == nil then
		Enigma:PrintError("Attempted to retrieve color for unknown bar!")
		return nil
	end
	return unpackColor(barRef)
end

function Vars:GetBarTexture()
	return self.db.global.barwindow.barTexture
end

function Vars:SetBarTexture(tex)
	self.db.global.barwindow.barTexture = tex
end

function Vars:GetTitleTexture()
	return self.db.global.barwindow.titleTexture
end

function Vars:SetTitleTexture(tex)
	self.db.global.barwindow.titleTexture = tex
end





