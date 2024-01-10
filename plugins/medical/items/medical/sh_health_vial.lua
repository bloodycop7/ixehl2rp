ITEM.name = "Health Vial"
ITEM.model = "models/healthvial.mdl"
ITEM.category = "Medical"
ITEM.width = 1
ITEM.height = 1

function ITEM:GetHealTime(ply)
    return 1
end

function ITEM:GetHealAmount(ply)
    return 10
end

function ITEM:OnHeal(ply)
    Schema:PlaySound(ply, "items/medshot4.wav")
end