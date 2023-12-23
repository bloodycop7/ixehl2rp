FACTION.name = "Combine Overwatch"
FACTION.description = "The Combine Overwatch, also referred to simply as Overwatch, is the primary military force of The Combine."
FACTION.color = Color(20, 120, 185)

FACTION.models = {
	"models/combine_soldier.mdl"
}

function FACTION:ModifyPlayerStep(client, data)
	if ( data.ladder or data.submerged ) then
		return
	end

	local extraSounds = {}

	data.snd = string.Replace(data.snd, ".stepright", "")
	data.snd = string.Replace(data.snd, ".stepleft", "")

	for i = 1, 4 do
		extraSounds[#extraSounds + 1] = "player/footsteps/" .. data.snd .. i .. ".wav"
	end

	for _, v in ipairs(extraSounds) do
		EmitSound(v, client:GetPos(), client:EntIndex(), CHAN_AUTO, data.volume * (data.running and 0.5 or 0.4))
	end

	data.snd = "npc/combine_soldier/gear" .. math.random(1, 4) .. ".wav"
	data.volume = data.volume * (data.running and 0.5 or 0.4)
end

FACTION_OTA = FACTION.index