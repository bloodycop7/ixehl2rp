CLASS.name = "Soldier"
CLASS.faction = FACTION_OTA
CLASS.isDefault = true

function CLASS:OnSet(ply)
    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    char:SetModel("models/combine_soldier.mdl")
    ply:SetSkin(0)
    char:SetData("skin", 0)
end


CLASS_OW_SOLDIER = CLASS.index