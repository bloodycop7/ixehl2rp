local RECIPE = {}

local itemData = ix.item.Get("wep_mp7")

RECIPE.uniqueID = "wep_mp7"
RECIPE.name = itemData.name
RECIPE.category = "Weapons"
RECIPE.model = itemData.model
RECIPE.description = itemData.description
RECIPE.requirements = {
    ["metal_plate"] = 4,
    ["gear"] = 3
}
RECIPE.result = {
    ["wep_mp7"] = 1
}

ix.crafting:RegisterRecipe(RECIPE)