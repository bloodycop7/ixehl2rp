FACTION.name = "Vortigaunt"
FACTION.description = "A xenian species, enslaved by the Combine. They are known for their healing abilities."
FACTION.color = Color(0, 150, 0)
FACTION.models = {"models/vortigaunt.mdl"}
FACTION.weapons = {"swep_vortigaunt_beam_edit", "swep_vortigaunt_heal"}

function FACTION:OnTransfered(client)
	local character = client:GetCharacter()

	character:SetModel(self.models[1])
end

FACTION.painSounds = {
	"vo/npc/vortigaunt/vortigese11.wav",
	"vo/npc/vortigaunt/vortigese07.wav",
	"vo/npc/vortigaunt/vortigese03.wav",
}

function FACTION:GetPainSound(ply)
	if not ( IsValid(ply) ) then
		return
	end

	return self.painSounds[math.random(1, #self.painSounds)]
end

function FACTION:GetDeathSound(ply)
	if not ( IsValid(ply) ) then
		return
	end

	return self.painSounds[math.random(1, #self.painSounds)]
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

	data.snd = "npc/vort/vort_foot" .. math.random(1, 4) .. ".wav"
	data.volume = data.volume * (data.running and 0.5 or 0.4)
end

FACTION_VORTIGAUNT = FACTION.index