Vars = {
}

function Vars:Init()

end

function Vars:GetBnet()
	return Enigma_PartnerBnet or ""
end

function Vars:SetBnet(e)
	Enigma_PartnerBnet = e
	Utility:FindPresenceId()
end

