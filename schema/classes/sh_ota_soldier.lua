CLASS.name = "Soldier"
CLASS.faction = FACTION_OTA
CLASS.isDefault = true

function CLASS:OnSet(ply)
    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    ply:SetSkin(0)
end


CLASS_OTA_SOLDIER = CLASS.index