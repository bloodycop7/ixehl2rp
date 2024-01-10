ITEM.name = "Milk"
ITEM.desc = "A bottle filled with milk."
ITEM.price = 5
ITEM.model = "models/props_junk/garbage_milkcarton002a.mdl"
ITEM.category = "Consumables"

function ITEM:GetThirstAmount()
    if ( self:GetData("uses", 1) < 2 ) then
        return 10
    end

    return 2
end

function ITEM:GetHungerAmount()
    if ( self:GetData("uses", 1) < 2 ) then
        return 10
    end

    return 2
end

function ITEM:GetUses()
    return 4
end

function ITEM:OnConsumed(ply)
    ply:RestoreStamina(5)
end

function ITEM:GetConsumeTime(ply)
    return 4
end