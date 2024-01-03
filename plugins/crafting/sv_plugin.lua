local PLUGIN = PLUGIN

function PLUGIN:CanCraftRecipe(ply, uniqueID)
    if not ( IsValid(ply) ) then
        return false
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return false
    end

    if not ( ply:Alive() ) then
        return false
    end

    if not ( uniqueID ) then
        return false
    end

    local recipeData = ix.crafting.recipes[uniqueID]

    if not ( recipeData ) then
        return false
    end

    if ( recipeData.overrideRequirements ) then
        if ( recipeData:overrideRequirements(ply) ) then
            return true
        end
    end

    local canCraft = true

    if ( recipeData.canCraft ) then
        if not ( recipeData:canCraft(ply) ) then
            canCraft = false
        end
    end

    for k, v in pairs(char:GetInventory():GetItems()) do
        for k2, v2 in pairs(recipeData.requirements) do
            local itemCount = char:GetInventory():GetItemCount(k2)
            
            if ( itemCount < v2 ) then
                canCraft = false
            end
        end
    end
    
    return canCraft
end

function PLUGIN:CraftRecipe(ply, uniqueID)
    if not ( IsValid(ply) ) then
        return false
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return false
    end

    if not ( ply:Alive() ) then
        return false
    end

    if not ( uniqueID ) then
        return false
    end

    local recipeData = ix.crafting.recipes[uniqueID]

    if not ( recipeData ) then
        return false
    end

    if not ( self:CanCraftRecipe(ply, uniqueID) ) then
        return
    end

    for k, v in pairs(recipeData.result) do
        if not ( ply:GetCharacter():GetInventory():Add(k) ) then
            ix.item.Spawn(k, ply:GetPos() + ply:GetForward() * 20 + ply:GetUp() * 30)
        end

        if ( recipeData.onCraftItem ) then
            recipeData:onCraftItem(ply, k)
        end
    end

    for k, v in pairs(recipeData.requirements) do
        for i = 1, v do
            local item = char:GetInventory():HasItem(k)

            if ( item ) then
                item:Remove()
            end
        end
    end

    if ( recipeData.onCraft ) then
        recipeData:onCraft(ply)
    end

    return true
end