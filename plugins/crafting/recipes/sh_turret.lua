local RECIPE = {}

RECIPE.uniqueID = "turret"
RECIPE.name = ix.item.Get("turret").name
RECIPE.category = "Deployables"
RECIPE.model = ix.item.Get("turret").model
RECIPE.description = "A turret that can be deployed on the ground and commit funny suicide."
RECIPE.requirements = {
    ["water"] = 2,
    ["viscerator"] = 2
}
RECIPE.result = {
    ["turret"] = 1
}

ix.crafting:RegisterRecipe(RECIPE)