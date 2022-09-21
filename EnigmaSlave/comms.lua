Comm = {
	callbacks = {
	},
	
	DataCodes = {
		SCAN = "1", --tells slave to do scan, but not return data (used for multiple passes)
		DATA = "2", --tells master all data from scan has returned
		FULL_SCAN = "3", --tells master a scan has reached the /who limit of 50 results
		SCAN_AND_RETURN = "4", --tells slave to scan and return data
		IDLE = "5", --tells master slave is idle
		CONNECT = "6", --initiates connection between clients
		DISCONNECT = "7", --tells master/slave that one or the other has disconnected
		INCOMPLETE_DATA = "8", --tells master theres still more /who data being sent by slave
	}
}

local frame = Utility.eventFrame

function Comm:Init()
	frame:RegisterEvent("BN_CHAT_MSG_ADDON", 
		function(prefix, msg, _, sender) 
			Comm:MsgRecieved(prefix, msg, sender) 
		end)
		
	frame:RegisterEvent("PLAYER_LOGOUT", 
		function(prefix, msg, _, sender) 
			Comm:DisconnectClient() 
		end)
		
	Comm:RegisterCallback(Comm.DataCodes.SCAN, 
		function(msg) 
			Enigma:DecodeParamAndScan(msg, false)
		end)
		
	Comm:RegisterCallback(Comm.DataCodes.SCAN_AND_RETURN, 
		function(msg) 
			Enigma:DecodeParamAndScan(msg, true)
		end)
		
	Comm:RegisterCallback(Comm.DataCodes.CONNECT, 
		function(msg) 
			Comm:SendBnetData(Comm.DataCodes.IDLE)
		end)
end

function Comm:MsgRecieved(prefix, msg, sender)
	if Utility:GetPresenceId() == sender then
		--Utility:Print("recieved valid message with prefix '" .. prefix .. "' and content '" .. msg .. "'")
		Comm:Callback(prefix, msg)
	end
end

function Comm:RegisterCallback(code, fxn)
	if code == nil or fxn == nil then
		Utility:Print("Error: cannot register message callback with nil code or function!!")
		return
	end
	
	if Comm.callbacks[code] ~= nil then
		Utility:Print("Warning: Message callback code " .. code .. " has already been registered and will be overwritten.")
	end
	
	Utility:Print("Registering bnet callback " .. code)
	Comm.callbacks[code] = fxn
end

function Comm:Callback(code, ...)
	if Comm.callbacks[code] then
		Comm.callbacks[code](...)
	end
end

function Comm:DisconnectClient()
	Comm:SendBnetData(Comm.DataCodes.DISCONNECT)
end

function Comm:PackAndSend(zoneList, playerList)
	local msgLim = 4093
	local curMsgSize = 0
	local msg = ""
	msg = msg..zoneList:Length() .. "~"
	for i = 1, zoneList:Length(),1 do
		local zone = zoneList:GetZone(i)		
		local addition = zone.name .. "~" .. zone.pop .. "~" .. playerList[zone.name]:FormatForMsg() .. "~"
		if string.len(addition) + curMsgSize <= msgLim then
			msg = msg .. addition
			curMsgSize = curMsgSize + string.len(addition)
		else -- msg size limit reached, send what we can and make new msg
			self:SendBnetData(self.DataCodes.INCOMPLETE_DATA, msg)
			msg = addition
			curMsgSize = string.len(addition)
		end
	end
	self:SendBnetData(self.DataCodes.DATA, msg)
end

function Comm:SendBnetData(pre, msg)
	local presenceId = Utility:GetPresenceId()
		if presenceId then
			pre = pre or "Enigma"
			msg = msg or ""
			print("sending message: pre: " .. pre .. " msg: " .. msg)
			BNSendGameData(presenceId, pre, msg)
		end
end