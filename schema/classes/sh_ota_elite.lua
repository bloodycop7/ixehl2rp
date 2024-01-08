CLASS.name = "Elite"
CLASS.faction = FACTION_OTA
CLASS.isDefault = false

function CLASS:OnSet(ply)
    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    char:SetModel("models/combine_super_soldier.mdl")
    char:SetData("skin", 0)
end

CLASS_OTA_ELITE = CLASS.index