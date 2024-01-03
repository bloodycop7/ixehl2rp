local RECIPE = {}

local itemData = ix.item.Get("turret")

RECIPE.uniqueID = "turret"
RECIPE.name = itemData.name
RECIPE.category = itemData.category
RECIPE.model = itemData.model
RECIPE.description = itemData.description
RECIPE.requirements = {
    ["water"] = 2,
    ["viscerator"] = 2
}
RECIPE.result = {
    ["turret"] = 1
}

ix.crafting:RegisterRecipe(RECIPE)