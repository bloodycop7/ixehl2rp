local RECIPE = {}

local itemData = ix.item.Get("wep_spas12")

RECIPE.uniqueID = "wep_spas12"
RECIPE.name = itemData.name
RECIPE.category = "Weapons"
RECIPE.model = itemData.model
RECIPE.description = itemData.description
RECIPE.requirements = {
    ["metal_plate"] = 7,
    ["gear"] = 5
}
RECIPE.result = {
    ["wep_spas12"] = 1
}

ix.crafting:RegisterRecipe(RECIPE)