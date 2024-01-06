ITEM.name = "Can of Water"
ITEM.model = Model("models/props_junk/popcan01a.mdl")
ITEM.description = "A blue can filled with some carbonated flavoured water. Delicious."
ITEM.category = "Consumables"
ITEM.category = "Consumables"
ITEM.thirstAmount = 20
ITEM.hungerAmount = 5
ITEM.consumeTime = 3

local RECIPE = {}

RECIPE.uniqueID = "water"
RECIPE.name = ITEM.name
RECIPE.category = "Needs"
RECIPE.model = "models/props_combine/combine_mine01.mdl"
RECIPE.description = "A turret that can be deployed on the ground."
RECIPE.requirements = {
    ["turret"] = 2,
    ["viscerator"] = 2
}
RECIPE.result = {
    ["water"] = 1
}

ix.crafting:RegisterRecipe(RECIPE)