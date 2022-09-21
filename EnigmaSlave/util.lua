Enigma = {}

Utility = {
	presenceId = nil,
	events = {},
	eventFrame = CreateFrame("FRAME", "Enigma_Event_Frame")
}

local validArgs = {}

function Utility:RegisterSlashCommand(arg1, arg2, arg3, fn)
	if arg1 and fn then
		local command = arg1
		if arg2 then
			command = command .. " " .. arg2
		end
		
		if arg3 then
			command = command .. " " .. arg3
		end

		validArgs[#validArgs + 1] = {cmd = command, fxn = fn}
		Utility:PrintDebug("Registered slash command: " .. command)
	end
end

function Utility:RunSlashCommand(msg, slash)
	local arg1, arg2, arg3 = strsplit(" ",msg)-- splits the command data by spaces

	for i = 1, #validArgs, 1 do
		local ret = {strsplit(" ", validArgs[i].cmd)}
		local fn1 = nil
		if ret[1] then
			fn1 = ret[1]
			if doDebug then
				Utility:PrintDebug("arg1 = " .. fn1)
			end
		end
		
		local fn2 = nil
		if ret[2] then
			fn2 = ret[2]
			if doDebug then
				Utility:PrintDebug("arg2 = " .. fn2)
			end
		end
		
		local fn3 = nil
		if ret[3] then
			fn3 = ret[3]
			if doDebug then
				Utility:PrintDebug("arg3 = " .. fn3)
			end
		end
		
		if fn1 and arg1 and fn1 == arg1 then
			if doDebug then
				Utility:PrintDebug("fn1,arg1 are equal")
			end
			if fn2 and arg2 and ((fn2:sub(1,1) == "<" and fn2:sub(string.len(fn2), string.len(fn2)) == ">") or fn2 == arg2) then
				if doDebug then
					Utility:PrintDebug("fn2,arg2 are not nil and arg2 is surrounded by <>")
				end
				if fn3 and arg3 and ((fn3:sub(1,1) == "<" and fn3:sub(string.len(fn3), string.len(fn3)) == ">") or fn3 == arg3) then
					validArgs[i].fxn(slash, arg2, arg3)
					if doDebug then
						Utility:PrintDebug("running with 2 args")
					end
					return true
				else
					validArgs[i].fxn(slash, arg2)
					if doDebug then
						Utility:PrintDebug("running with 1 arg")
					end
					return true
				end
			else
				validArgs[i].fxn(slash)
				if doDebug then
					Utility:PrintDebug("running with no args")
				end
				return true
			end
		end
	end
	return false
end

function Utility:SetupCmds()
	self:RegisterSlashCommand("scan", nil, nil, 
		function()
			SetWhoToUI(1)
			SendWho('g-"Ironsworn Regiment"')
		end)
end

function Utility:FindPresenceId(bnet)
	bnet = bnet or Vars:GetBnet()
	if bnet == nil or bnet == "" then
		Utility:Print("Error: no Battle.net selected! Cannot send/recieve data!")
		return nil
	end
	
	for i = 1,BNGetNumFriends(),1 do 
		local _,_,battleTag,_,_, presenceId = BNGetFriendInfo(i)
		if battleTag == bnet then
			Utility.presenceId = presenceId
			return presenceId
		end
	end
	Utility:Print("Error: No matching Battle.net found! If you are seeing this message, something has gone horribly, horribly wrong. :(")
end

function Utility:GetPresenceId()
	return Utility.presenceId or Utility:FindPresenceId()
end


function Utility:Print(msg)
	if msg == nil then
		msg = ""
	end
	print("|cfff4d442Enigma:|r " .. msg)
end

local doDebug = true

function Utility:PrintDebug(msg)
	if doDebug then
		if msg == nil then
			msg = ""
		end
		print("|cfff4d442Enigma (DEBUG):|r " .. msg)
	end
end

function Utility:RegisterCallback(event, fxn)
	if event == nil or fxn == nil then
		Utility:Print("Error: cannot register event with nil name or function!!")
		return
	end
	
	if Utility.events[event] ~= nil then
		Utility:Print("Warning: " .. event .. " has already been registered and will be overwritten.")
	end
	
	--Utility:Print("Registering event " .. event)
	Utility.events[event] = fxn
end

local function DoEvent(_, event, ...)
	if Utility.events[event] then
		Utility.events[event](...)
	end
end

SLASH_ENIGMA1, SLASH_ENIGMA2 = "/enigma", "/ng" --base chat command
SlashCmdList["ENIGMA"] = function(msg)--method that handles the chat command input
	if Utility:RunSlashCommand(msg, true) then
		Utility:PrintDebug("Command ran successfully.")
	else
		Utility:PrintDebug("ERROR RUNNING COMMAND!")
	end
end

Utility.eventFrame:SetScript("OnEvent", DoEvent)
hooksecurefunc(Utility.eventFrame, "RegisterEvent", Utility.RegisterCallback)

Utility.eventFrame:RegisterEvent("ADDON_LOADED", 
	function(addon)
		if addon == "EnigmaSlave" then
			Utility:SetupCmds()
			Enigma:Init()
		end
	end)
	
