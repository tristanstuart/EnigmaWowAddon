WhoQuery = {
	vals = {
		
	}
}

function WhoQuery:New(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.vals = {
		["g"] = "",
		["n"] = "",
		["z"] = "",
		["r"] = "",
		["ll"] = "",
		["hl"] = "",
	}
	return o
end

function WhoQuery:SetValue(var, value, doPrint)
	if (var == "ll" or var == "hl") and not Utility:NumOrBlank(value) then
		Enigma:PrintError("Level filters must be numbers!!")
		return
	elseif self.vals[var] ~= nil then
		if doPrint then
			if value == self:GetValue(var) then
				return
			end
			if value == "" then
				Enigma:Print("Cleared " .. self:GetLabel(var) .. ".")
			else
				Enigma:Print("Set " .. self:GetLabel(var) .. " to " .. value .. ".")
			end
		end
		
		self.vals[var] = value
		Vars:SaveWho()
	end
end

function WhoQuery:GetValue(var)
	if self.vals[var] == "" then
		return nil
	else
		return self.vals[var]
	end
end

function WhoQuery:GetLabel(var)
	if var == "g" then
		return "guild"
	elseif var == "n" then
		return "name"
	elseif var == "z" then
		return "zone"
	elseif var == "r" then
		return "race"
	elseif var == "ll" then
		return "min level"
	elseif var == "hl" then
		return "max level"
	end
	return nil
end

function WhoQuery:GetQuery()
	local vars = {"g", "n", "z", "r"}
	local query = ""
	
	for k,v in pairs(vars) do
		local value = self:GetValue(v)
		if value then
			query = query .. v .. '-"' .. value .. '" '
		end
	end
	
	local minlvl, maxlvl = self:GetValue("ll"), self:GetValue("hl")
	if minlvl and maxlvl then
		query = query .. minlvl .. "-" .. maxlvl
	elseif minlvl and not maxlvl then
		query = query .. minlvl .. "-"
	elseif not minlvl and maxlvl then
		query = query .. "-" .. maxlvl
	end
	
	return query
end

function WhoQuery:SetQuery(text, doPrint)
	self:ClearQuery(false)
	if doPrint then Enigma:Print("Initializing query: '/who " .. text .. "'") end
	local i = 0 
	local j = i + 1 
	local found = false 
	while i < #text do 
		found = false 
		if text:sub(i,i)=='"' then 
			j = text:find('"',i+1) - 1 
			i = i + 1 
			found = true 
		else 
			i = i + 1 
		end		
		if found then 
			local var = text:sub(i-3, i-3)
			local val = text:sub(i,j)
			self:SetValue(var,val, false)
			i = j + 2
		end
	end
		
	local srchStr = "%-"

	while string.find(text, "%d"..srchStr) do
		srchStr = "%d" .. srchStr
	end
	
	if srchStr ~= "%-" then
		local st, ed = string.find(text, srchStr)
		self:SetValue("ll", text:sub(st, ed - 1), false)
	end
	
	srchStr = "%-"

	while string.find(text, srchStr.. "%d") do
		srchStr = srchStr .. "%d"
	end
	
	if srchStr ~= "%-" then
		local st, ed = string.find(text, srchStr)
		self:SetValue("hl", text:sub(st + 1, ed), false)
	end
end

function WhoQuery:ClearQuery(doPrint)
	for k,v in pairs(self.vals) do
		self:SetValue(k, "", false)
	end
	if doPrint then Enigma:Print("Cleared all who fields.") end
end

function WhoQuery:PrintFormattedQuery()
	local vars = {"g", "n", "z", "r", "ll", "hl"}
	local hasFilter = false
	Enigma:Print("Who filters: ")
	
	for i,var in pairs(vars) do
		local val = self:GetValue(var)
		if val then
			Enigma:Print(Enigma_Caps(self:GetLabel(var)) .. ": " .. val)
			hasFilter = true
		end
	end
	if not hasFilter then
		Enigma:Print("No filters.")
	end
end




