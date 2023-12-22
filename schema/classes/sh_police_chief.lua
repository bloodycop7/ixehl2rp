
CLASS.name = "Police Chief"
CLASS.faction = FACTION_POLICE

-- This function will be called whenever the client wishes to become part of this class. If you'd rather have it so this class
-- has to be set manually by an administrator, you can simply return false to disallow regular users switching to this class.
-- Note that CLASS.isDefault does not add a whitelist like FACTION.isDefault does, which is why we need to use CLASS:OnCanBe.
function CLASS:OnCanBe(client)
	return false
end

CLASS_POLICE_CHIEF = CLASS.index
