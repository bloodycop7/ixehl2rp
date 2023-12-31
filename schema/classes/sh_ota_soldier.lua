CLASS.name = "Soldier"
CLASS.faction = FACTION_OTA
CLASS.isDefault = true

function CLASS:OnSet(ply)
    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    ply:SetModel("models/combine_soldier.mdl")
    ply:SetSkin(0)
end


CLASS_OTA_SOLDIER = CLASS.index