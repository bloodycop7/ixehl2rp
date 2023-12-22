FACTION.name = "Civil Protection"
FACTION.description = "The Civil Protection Force of the Universal Union."
FACTION.color = Color(20, 120, 185)

FACTION.models = {
	"models/police.mdl"
}

function FACTION:ModifyPlayerStep(client, data)
	if ( data.ladder or data.submerged ) then
		return
	end

	if ( data.running ) then
		data.snd = ""
		data.volume = data.volume * 0.6 
	end
end

FACTION_CP = FACTION.index