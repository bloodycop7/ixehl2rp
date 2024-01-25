ITEM.name = "Health Kit"
ITEM.model = "models/items/healthkit.mdl"
ITEM.category = "Medical"
ITEM.width = 1
ITEM.height = 1

function ITEM:GetHealTime(ply)
    return 3
end

function ITEM:GetHealAmount(ply)
    return 30
end

function ITEM:OnHeal(ply)
    Schema:PlaySound(ply, "items/medshot4.wav")
end