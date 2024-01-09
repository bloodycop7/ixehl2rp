local RECIPE = {}

local itemData = ix.item.Get("wep_357")

RECIPE.uniqueID = "wep_357"
RECIPE.name = itemData.name
RECIPE.category = "Weapons"
RECIPE.model = itemData.model
RECIPE.description = itemData.description
RECIPE.requirements = {
    ["metal_plate"] = 8,
    ["gear"] = 6
}
RECIPE.result = {
    ["wep_357"] = 1
}

ix.crafting:RegisterRecipe(RECIPE)