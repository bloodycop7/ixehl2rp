local RECIPE = {}

local itemData = ix.item.Get("wep_mp7")

RECIPE.uniqueID = "wep_mp7"
RECIPE.name = itemData.name
RECIPE.category = "Weapons"
RECIPE.model = itemData.model
RECIPE.description = itemData.description
RECIPE.requirements = {
    ["water"] = 2,
    ["viscerator"] = 2
}
RECIPE.result = {
    ["wep_mp7"] = 1
}

ix.crafting:RegisterRecipe(RECIPE)