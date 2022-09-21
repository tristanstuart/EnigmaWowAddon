Enigma.media = LibStub("LibSharedMedia-3.0")
local libwindow = LibStub("LibWindow-1.1")
local callbacks = nil
local bars = {}
local numBars = 1

local ct = 0

Bars.fullScan = false
Bars.statusBars = {}

function Bars:Init()
	Enigma.media:Register("statusbar", "Armory", "Interface\\AddOns\\Enigma\\Textures\\Armory.tga")
	Enigma.media:Register("statusbar", "Minimalist", "Interface\\AddOns\\Enigma\\Textures\\Minimalist.tga")

	self.bars = {}
	self.barinfo = {}
	self:CreateInitialGroup()
	self:CreateCallback()
	self:SetupTitle()
	self:SetTitleText()
	Enigma:Print("Running initial bar setup...")
	
	for i=1,Vars.iZones:Length(),1 do
		local name = Vars.iZones:GetZoneName(i)
		self:AddBar(name, 0, true, "")
	end
	self:SetTitleText()
	
	Settings.barOptions = Enigma.media:List("statusbar")
end

function Bars:UpdateBar(name, pop, tooltip)
	self.bars[name]:SetValue(pop)
	self.bars[name].timerLabel:SetText(pop)
	if tooltip then
		self.bars[name].impNameList = tooltip
	end
	self.barGroup:SortBars()
end

function Bars:RemoveBar(name)
	self.barGroup:RemoveBar(self.bars[name])
	self.bars[name] = nil
	self.barGroup:SortBars()
	numBars = numBars - 1
end

function Bars:GetTooltip(zone)
	if Bars.bars[zone] then
		return Bars.bars[zone].impNameList
	end
	return ""
end

function Bars:Update(maxVal, zones)
	--if zone doesnt exist in bars, add it
	--if it does, update the pop and player list
	--loop all bars and check if any need to be removed

	for k,v in pairs(zones) do
		if self.bars[k] then --update population
			self:UpdateBar(k, v.pop, v.players)
		elseif not self.bars[k] then
			self:AddBar(k, v.pop, false, v.players)
		end
		
		local kI = k.."I"
		if self.bars[kI] then --add new bar
			self:UpdateBar(kI, v.pop, v.players)
		elseif not self.bars[kI] and Vars.iZones:GetZone(k) then
			self:AddBar(kI,v.pop, true, v.players)
		end
	end
	
	for k,_ in pairs(self.bars) do
		local imp = string.sub(k, string.len(k) - 1, string.len(k))
		if zones[k] == nil and not imp == "I" then --remove bar
			self:RemoveBar(k)
		end
	end
	
	Bars:SetMaxVal(maxVal)
	self.barGroup:SortBars()
end

local function OnMouseWheel(widget, change)
	local off = Bars.barGroup:GetBarOffset()
	local shownBars = math.ceil((Bars.barGroup:GetHeight() / 20) - 0.5)
	if change == 1 and off > 0 then
		Bars.barGroup:SetBarOffset(off - 1)
	elseif change == -1 and 0 < (numBars - off - shownBars) then
		Bars.barGroup:SetBarOffset(off + 1)
	end
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR") --Set our button as the tooltip's owner and attach it to the top right corner of the button.
	GameTooltip:SetText(self.impNameList, nil, nil, nil, nil, true) --Set the tooltip's text using the default RGBA values (fully opaque gold text) with text wrapping on.
	GameTooltip:Show() --Show the tooltip
end

local function OnLeave(self)
	GameTooltip:Hide()
end

function Bars:AddBar(zone, pop, important, tooltip)
	local name = "" .. ct
	for i = string.len(name), 5, 1 do
		name = "0" .. name
	end
	if important then 
		name = "a" .. ct
	else 
		name = "b" .. ct
	end
	ct = ct + 1
	
	local ba = self.barGroup:NewCounterBar(name, zone, pop, Bars.barinfo.maxVal, nil, nil, self.barGroup:GetWidth(), self.barGroup:GetThickness())
	ba.timerLabel:SetText(pop)
	ba:EnableMouseWheel(true)
	ba:SetScript("OnMouseWheel", OnMouseWheel)
	
	ba.impNameList = tooltip
	ba.important = important
	ba:SetScript("OnEnter", OnEnter)
	ba:SetScript("OnLeave", OnLeave)
	
	ba:UnsetAllColors()
	if important then
		local r,g,b = Vars:GetBarColor(Vars.BarColors.IMPORTANT)
		ba:SetColorAt(1, r,g,b,1)
		ba:SetColorAt(0, r,g,b,1)
	else
		local hr, hg, hb = Vars:GetBarColor(Vars.BarColors.HIGH_POP)
		local mr, mg, mb = Vars:GetBarColor(Vars.BarColors.MED_POP)
		local lr, lg, lb = Vars:GetBarColor(Vars.BarColors.LOW_POP)
		
		ba:SetColorAt(1.0, hr, hg, hb, 1)
		ba:SetColorAt(0.5, mr, mg, mb, 1)
		ba:SetColorAt(0, lr, lg, lb, 1)
	end
	
	if Bars.barinfo.clearBg then
		ba.bgtexture:SetVertexColor(0,0,0,0)--clear background
	end
	
	ba:Show()
	if important then
		self.bars[zone .. "I"] = ba
	else
		self.bars[zone] = ba
	end
	
	self.barGroup:SortBars()
	numBars = numBars + 1
end

function Bars:Clear()
	for k,v in pairs(self.bars) do
		if self.bars[k].important then
			self.bars[k]:SetValue(0)
			self.bars[k].timerLabel:SetText(0)
			self.bars[k].impNameList = ""
		else
			self.barGroup:RemoveBar(self.bars[k])
			self.bars[k] = nil
		end
	end
	Bars:SetFullScan(false)
end

function Bars:SetMaxVal(val)
	if self.barinfo.maxVal ~= val then
		self.barinfo.maxVal = val
		for k,v in pairs(self.bars) do
			self.bars[k]:SetMaxValue(val)
		end
	end
end

function Bars:GetMaxVal()
	return Bars.barinfo.maxVal
end

function Bars:CreateCallback()
	self.barGroup.callbacks = LibStub("CallbackHandler-1.0"):New(self.barGroup)
	self.barGroup.RegisterCallback(Bars, "WindowResized", "UpdateWindowSize")
	self.barGroup.RegisterCallback(Bars, "AnchorMoved", "UpdateWindowPos")
	self.barGroup.RegisterCallback(Bars, "LibSharedMedia_Registered", function() print("adfasdf") end)
end

function Bars:UpdateWindowPos()
	libwindow.SavePosition(self.barGroup)
end

function Bars:UpdateWindowSize()
	self:UpdateWindowPos()
	Vars:SetBarWindowSize(self.barGroup:GetWidth(), self.barGroup:GetHeight())
end

function Bars:CreateInitialGroup()
	local width, height = Vars:GetBarWindowSize()
	
	self.barGroup = Bars:NewBarGroup("Enigma", nil, height, width, 20, "Engima_BarFrame")
	self.barGroup:SetTexture(self:GetBarMedia(Vars:GetBarTexture()))
	self.barGroup:SetSortFunction(
		function(a, b) 
			if string.sub(a.name, 1, 1) ~= string.sub(b.name, 1, 1) then return a.name < b.name
			elseif a.value ~= b.value then return a.value > b.value
			else return a.label:GetText() < b.label:GetText() end
		end)
	self.barGroup:HideIcon()
	
	self.barGroup.button:EnableMouseWheel(true)
	self.barGroup.button:SetScript("OnMouseWheel", OnMouseWheel)
	
	libwindow.RegisterConfig(self.barGroup, Vars.db)
	libwindow.RestorePosition(self.barGroup)
end

function Bars:SetupTitle()
	self.barGroup.button:SetHeight(35)
	if Vars:GetTitleTexture() == nil then
	
	end
	self:SetTitleTexture()
	self.barGroup.button:SetPushedTextOffset(0,0)
	self.barGroup.button:GetFontString():ClearAllPoints()
	self.barGroup.button:GetFontString():SetPoint("LEFT", self.barGroup.button, "LEFT", 5, 0)
	self.barGroup.button:GetFontString():SetJustifyH("LEFT")
end

function Bars:SetTitleText()
	self.barGroup.button:SetText("Passes: " .. Vars:GetNumScans() .. "  Who: '" .. Vars.query:GetQuery() .. "'|nLast Scan: " .. SlaveController:GetLastScan() .. "      Total Players: " .. SlaveController:GetPlayerCount())
end

function Bars:SetTitleTexture()
	local texture = self.barGroup.button:CreateTexture()
	texture:SetTexture(self:GetBarMedia(Vars:GetTitleTexture()))
	texture:SetAllPoints()
	local r,g,b = Vars:GetBarColor(Vars.BarColors.TITLE)
	if self.fullScan then
		r,g,b = Vars:GetBarColor(Vars.BarColors.TITLE_FULL)
	end
	texture:SetVertexColor(r, g, b)
	self.barGroup.button:SetNormalTexture(texture)
end

function Bars:SetInfoBarTexture()
	local tex = self:GetBarMedia(Vars:GetBarTexture())
	self.barGroup:SetTexture(tex)
	for k,v in pairs(self.bars) do
		self.bars[k]:SetTexture(tex)
			if self.bars[k].important then
				local r,g,b = Vars:GetBarColor(Vars.BarColors.IMPORTANT)
				self.bars[k]:SetColorAt(1, r,g,b,1)
				self.bars[k]:SetColorAt(0, r,g,b,1)
			else
				local hr, hg, hb = Vars:GetBarColor(Vars.BarColors.HIGH_POP)
				local mr, mg, mb = Vars:GetBarColor(Vars.BarColors.MED_POP)
				local lr, lg, lb = Vars:GetBarColor(Vars.BarColors.LOW_POP)
				
				self.bars[k]:SetColorAt(1.0, hr, hg, hb, 1)
				self.bars[k]:SetColorAt(0.5, mr, mg, mb, 1)
				self.bars[k]:SetColorAt(0, lr, lg, lb, 1)
		end
	end
end

function Bars:Hide()
	if self.barGroup then
		self.barGroup:Hide()
	end
end

function Bars:Hide()
	if self.barGroup then
		self.barGroup:Show()
	end
end

function Bars:Shown()
	if self.barGroup then
		return self.barGroup:IsShown()
	end
	return false
end

function Bars:SetFullScan(scan)
	self.fullScan = scan
	local r,g,b = Vars:GetBarColor(Vars.BarColors.TITLE)
	if self.fullScan then
		r,g,b = Vars:GetBarColor(Vars.BarColors.TITLE_FULL)
	end
	self.barGroup.button:GetNormalTexture():SetVertexColor(r,g,b)
end

function Bars:GetBarMedia(name)
	return Enigma.media:Fetch("statusbar", name, true) or "Interface\\AddOns\\Enigma\\Textures\\" .. name .. ".tga"
end




