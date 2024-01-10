ITEM.name = "Health Vial"
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