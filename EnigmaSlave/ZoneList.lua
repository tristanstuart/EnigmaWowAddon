ZoneList = {zoneList = {}, name = ""}

function ZoneList:New(o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
	  o.zoneList = {}
      return o
end

function ZoneList:Length()
	return table.getn(self.zoneList)
end
	
function ZoneList:AddZone(zName, zPop)
	if self:GetPop(zName) then
		self:IncrementZone(zName)
	else
		local zone = {
			name = zName, 
			pop = zPop or 1
		}
		table.insert(self.zoneList, zone)
	end
end

function ZoneList:IncrementZone(zone)
	for i = 1, self:Length(), 1 do
		if self.zoneList[i].name == zone then
			self.zoneList[i].pop = self.zoneList[i].pop + 1
		end
	end
end

function ZoneList:RemoveZone(name)
	for i = 1, self:Length(), 1 do
		if self.zoneList[i].name == name then
			return table.remove(self.zoneList, i)
		end
	end
end

function ZoneList:GetZone(index)
	if self.zoneList[index] then
		return self.zoneList[index]
	end
	return nil
end

function ZoneList:GetPop(name)
	for i = 1, self:Length(), 1 do
		if self.zoneList[i].name == name then
			return self.zoneList[i].pop
		end
	end
	return nil
end

function ZoneList:SetPop(name, pop)
	for i = 1, self:Length(), 1 do
		if self.zoneList[i].name == name then
			self.zoneList[i].pop = pop
			return true
		end
	end
end

function ZoneList:GetZoneName(index)
	if index <= self:Length() then
		return self.zoneList[index].name
	end
	return nil
end

function ZoneList:GetName()
	return self.name
end

function ZoneList:SetName(name)
	self.name = name
end

function ZoneList:ZeroPops()
	for i = 1, self:Length(), 1 do
		self.zoneList[i].pop = 0
	end
end

function ZoneList:ClearList()
	while self:Length() > 0 do
		table.remove(self.zoneList)
	end
end

function ZoneList:CopyZones(ZoneObj)
	for i = 1, ZoneObj:Length(), 1 do
		self.zoneList[self:Length() + 1] = ZoneObj:GetZone(i)
	end
end

function ZoneList:CopyPops(ZoneObj)
	for i = 1,self:Length(), 1 do
		local name = self:GetZoneName(i)
		local pop = ZoneObj:GetPop(name) or 0
		if pop then
			self:SetPop(name, pop)
		end
	end
end

function ZoneList:Sort()
	table.sort(self.zoneList, function(arg1, arg2)
		if arg1.pop ~= arg2.pop then
			return arg1.pop > arg2.pop
		else
			return arg1.name < arg2.name
		end
	end)
end

function ZoneList:PrintZones()
	for i = 1, self:Length(), 1 do
		local zone = self.zoneList[i]
		local msg = self.zoneList[i].name .. ": " .. self.zoneList[i].pop
		if self.name then
			msg = self.name .. ": " .. msg
		else
			msg = "nil: " .. msg
		end
		Enigma_Notify(msg)
	end
end

function ZoneList:GetZoneData(pop)
	local zoneNames = {}
	local zonePops = {}
	
	for i = 1, self:Length(), 1 do
		local zoneName = self:GetZoneName(i)
		local zonePop = self:GetPop(zoneName)
		if pop and zonePop >= pop then
			zoneNames[#zoneNames + 1] = zoneName
			zonePops[#zonePops + 1] = zonePop
		elseif not pop then
			zoneNames[#zoneNames + 1] = zoneName
			zonePops[#zonePops + 1] = zonePop
		end
	end
	
	return zoneNames, zonePops
end










