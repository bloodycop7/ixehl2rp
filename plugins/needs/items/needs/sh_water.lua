ITEM.name = "Can of Water"
ITEM.model = Model("models/props_junk/popcan01a.mdl")
ITEM.description = "A blue can filled with some carbonated flavoured water. Delicious."
ITEM.category = "Consumables"

function ITEM:GetThirstAmount(ply)
    if ( self:GetData("uses", 1) < 2 ) then
        return 10
    end

    return 2
end

function ITEM:GetHungerAmount(ply)
    if ( self:GetData("uses", 1) < 2 ) then
        return 10
    end

    return 2
end

function ITEM:GetConsumeTime(ply)
    return 3
end

function ITEM:GetUses()
    return 4
end

local RECIPE = {}

RECIPE.uniqueID = "water"
RECIPE.name = ITEM.name
RECIPE.category = ITEM.category
RECIPE.model = ITEM.model
RECIPE.description = "A turret that can be deployed on the ground."
RECIPE.requirements = {
    ["turret"] = 2,
    ["viscerator"] = 2
}
RECIPE.result = {
    ["water"] = 1
}

ix.crafting:RegisterRecipe(RECIPE)