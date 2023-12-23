function Schema:GetPlayerDeathSound(client)
	local char = client:GetCharacter()

	if not ( char ) then
		return
	end

	if ( Schema:IsCP(client) ) then
		return "npc/metropolice/die" .. math.random(1, 4) .. ".wav"
	elseif ( Schema:IsOTA(client) ) then
		return "npc/combine_soldier/die" .. math.random(1, 3) .. ".wav"
	end
end

function Schema:GetPlayerPainSound(client)
	local char = client:GetCharacter()

	if not ( char ) then
		return
	end

	if ( Schema:IsCP(client) ) then
		return "npc/metropolice/pain" .. math.random(1, 4) .. ".wav"
	elseif ( Schema:IsOTA(client) ) then
		return "npc/combine_soldier/pain" .. math.random(1, 3) .. ".wav"
	end
end

function Schema:PlayerSpray(ply)
	return true
end