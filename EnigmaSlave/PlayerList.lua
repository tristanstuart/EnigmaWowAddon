PlayerList = {players = {}}

local classColors = {
	["Hunter"] = "ffabd473",
	["Warlock"] = "ff8788ee",
	["Priest"] = "ffffffff",
	["Paladin"] = "fff58cba",	
	["Mage"] = "ff3fc7eb",
	["Rogue"] = "fffff569",
	["Druid"] = "ffff7d0a",
	["Shaman"] = "ff0070de",
	["Warrior"] = "ffc79c6e",
	["Death Knight"] = "ffc41f3b",
	["Monk"] = "ff00ff96",
	["Demon Hunter"] = "ffa330c9"
}

local function GetClassColor(c)
	if classColors[c] then
		return classColors[c]
	end
		return nil
end

function PlayerList:New()
      o = {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
	  o.players = {}
      return o
end

function PlayerList:Length()
	return table.getn(self.players)
end

function PlayerList:GetPlayerAt(index)
	if index > 0 and index <= self:Length() then
		return self.players[index]
	end
	return nil
end

function PlayerList:AddPlayer(c, n)
	if self:PlayerExists(n) then
		return
	end
	
	local colorCode = GetClassColor(c)
	if colorCode == nil then
		Utility:Print("ERROR IN PLAYERLIST.LUA: Cannot find class color for class '" .. c "'. Player '" .. n .. "'will not be appended to list!")
		return
	end
	
	table.insert(self.players, "|c" .. colorCode .. n .. "|r")
end

function PlayerList:PlayerExists(n)
	for i=1,self:Length(),1 do
		local p = self:GetPlayerAt(i)
		if string.len(p) - 12 == string.len(n) and string.find(p, n) then
			return i
		end
	end
	
	return nil
end

function PlayerList:Clear()
	while self:Length() > 0 do
		table.remove(self.players, 1)
	end
end

function PlayerList:RemovePlayer(n)
	local ind = self:PlayerExists(n)
	if ind ~= nil then
		return table.remove(self.players, ind)
	end
	
	return nil
end

function PlayerList:DumpToString()
	local out = ""
	while self:Length() > 0 do
		out = out .. self.players[i] .. ", "
	end
	out = out string.sub(out, 1, string.len(out) - 2)
	return out
end

function PlayerList:FormatForMsg()
	local out = ""
	for i = 1, self:Length(),1 do
		out = out .. self:GetPlayerAt(i) .. "|n"
	end
	out = string.sub(out, 1, string.len(out) - 2)
	return out
end

