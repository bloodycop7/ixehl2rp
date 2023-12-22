
-- Since this faction is not a default, any player that wants to become part of this faction will need to be manually
-- whitelisted by an administrator.

FACTION.name = "Police"
FACTION.description = "Very angry policemen that have a tendency to injure people."
FACTION.color = Color(20, 120, 185)
FACTION.pay = 10 -- How much money every member of the faction gets paid at regular intervals.
FACTION.weapons = {"weapon_pistol"} -- Weapons that every member of the faction should start with.
FACTION.isGloballyRecognized = true -- Makes it so that everyone knows the name of the characters in this faction.

-- Note that FACTION.models is optional. If it is not defined, it will use all the standard HL2 citizen models.
FACTION.models = {
	"models/police.mdl"
}

FACTION_POLICE = FACTION.index
