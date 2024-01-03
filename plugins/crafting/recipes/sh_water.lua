local RECIPE = {}

local itemData = ix.item.Get("water")

RECIPE.uniqueID = "water"
RECIPE.name = ix.item.Get("water").name
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