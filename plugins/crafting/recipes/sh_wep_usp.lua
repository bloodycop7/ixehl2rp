local RECIPE = {}

local itemData = ix.item.Get("wep_usp")

RECIPE.uniqueID = "wep_usp"
RECIPE.name = itemData.name
RECIPE.category = "Weapons"
RECIPE.model = itemData.model
RECIPE.description = itemData.description
RECIPE.requirements = {
    ["water"] = 2,
    ["viscerator"] = 2
}
RECIPE.result = {
    ["wep_usp"] = 1
}

ix.crafting:RegisterRecipe(RECIPE)