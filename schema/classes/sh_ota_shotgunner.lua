CLASS.name = "Shotgunner"
CLASS.faction = FACTION_OTA
CLASS.isDefault = false

function CLASS:OnSet(ply)
    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    ply:SetModel("models/combine_soldier.mdl")
    ply:SetSkin(1)
end

CLASS_OTA_SHOTGUNNER = CLASS.index