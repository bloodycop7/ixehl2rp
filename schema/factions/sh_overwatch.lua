FACTION.name = "Combine Overwatch"
FACTION.description = "The Combine Overwatch, also referred to simply as Overwatch, is the primary military force of The Combine."
FACTION.color = Color(150, 20, 0)
FACTION.abbreviation = "OTA"

FACTION.models = {
	"models/combine_soldier.mdl"
}

FACTION.taglines = {
	"sword",
    "swift",
}

function FACTION:GetDefaultName(ply)
	return "OTA:OWS:" .. string.upper(self.taglines[math.random(1, #self.taglines)]) .. ":" .. Schema:ZeroNumber(math.random(1000, 9999), 4), true
end

function FACTION:ModifyPlayerStep(ply, data)
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
		EmitSound(v, ply:GetPos(), ply:EntIndex(), CHAN_AUTO, data.volume * (data.running and 0.5 or 0.4))
	end

	data.snd = "npc/combine_soldier/gear" .. math.random(1, 4) .. ".wav"
	data.volume = data.volume * (data.running and 0.5 or 0.4)
end

FACTION_OTA = FACTION.index