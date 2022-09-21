Utility = {}

function Utility:StrStarts(str, part)
	return string.sub(str, 1, string.len(part)) == part
end

function Utility:StrEnds(str, part)
	return part=='' or string.sub(str,-string.len(part))==part
end


function Utility:NumOrBlank(input)
	return input == "" or tonumber(input)~=nil
end

local bnetList = {}

function Utility:GetBnetList()
	if #bnetList == 0 then 
		for i = 1, BNGetNumFriends(),1 do
			local _,_,battleTag,_,_, presenceId = BNGetFriendInfo(i)
			table.insert(bnetList, battleTag)
		end
	end
	return bnetList
end

function Utility:GenerateUniqueID()
	local chars = "abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()"
	local id = ""
	for i = 0, 11, 1 do
		local index = math.ceil(math.random() * 46)
		id = id .. string.sub(chars, index, index)
	end
	
	return id
end

function Utility:Caps(val)
	local a = string.sub(val, 1, 1)
	a = string.upper(a)
	return a .. string.sub(val, 2)
end

local enigma_presenceId = nil

function Utility:getPresenceIdForBtag()
	if enigma_presenceId ~= nil then
		return enigma_presenceId
	end
	if Vars:GetPartnerBnet() == "None" then
		Enigma:PrintError("Cannot send/recieve data from slave!! No Partner Battle.net selected!")
		return nil
	end
	
	for i = 1,BNGetNumFriends(),1 do 
		local _,_,battleTag,_,_, presenceId = BNGetFriendInfo(i)
		if battleTag == Vars:GetPartnerBnet() then
			enigma_presenceId = presenceId
			return presenceId
		end
	end
	Enigma:PrintError("Cannot send/recieve data from slave!! Invalid Battle.net provided!")
	return nil
end

function Utility:GetBtagFromToonId(toonId)
	for i = 1,BNGetNumFriends(),1 do 
		local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, tId = BNGetFriendInfo(i)
		if toonId == tId then
			return battleTag
		end
	end
	return nil
end

function Utility:ThrowErrorBox(msg, yesFxn, noFxn)
	local frame = Acegui:Create("Frame")


end





