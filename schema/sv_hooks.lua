function Schema:GetPlayerDeathSound(client)
	local character = client:GetCharacter()

	if ( Schema:IsCP(client) ) then
		return "NPC_MetroPolice.Die"
	end
end

function Schema:PlayerSpray(ply)
	return true
end