local PLUGIN = PLUGIN
util.AddNetworkString("ix.Crafting.DoCraft")

net.Receive("ix.Crafting.DoCraft", function(len, ply)
    local uniqueID = net.ReadString()

    if not ( uniqueID ) then
        return
    end

    local canCraft, failMessage = PLUGIN:CanCraftRecipe(ply, uniqueID)

    if not ( canCraft ) then
        ply:Notify(failMessage)

        return
    end

    PLUGIN:CraftRecipe(ply, uniqueID)
end)

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

    if not ( IsValid(ply.ixCraftingStation) ) then
        return false
    end

    if not ( uniqueID ) then
        return false
    end

    local recipeData = ix.crafting.recipes[uniqueID]

    if not ( recipeData ) then
        return false
    end

    if ( recipeData.station ) then
        if not ( ply.ixCraftingStation:GetStationID() == recipeData.station ) then
            return false
        end
    end

    if ( recipeData.overrideRequirements ) then
        if ( recipeData:overrideRequirements(ply) ) then
            return true
        end
    end

    local canCraft = true
    local notMissingItems = true
    local failMessage = "You successfully crafted this item!"

    if ( recipeData.canCraft ) then
        if not ( recipeData:canCraft(ply) ) then
            canCraft = false
            failMessage = "You don't have the required items or correct amount of items to craft this."
        end
    end

    if ( ply:GetPos():Distance(ply.ixCraftingStation) > 200 ) then
        canCraft = false
        failMessage = "You must be closer to your crafting station."
    end

    for k, v in pairs(char:GetInventory():GetItems()) do
        for k2, v2 in pairs(recipeData.requirements) do
            local itemCount = char:GetInventory():GetItemCount(k2)
            
            if ( itemCount < v2 ) then
                notMissingItems = false
            end
        end
    end

    if not ( notMissingItems ) then
        canCraft = false
        failMessage = "You don't have the required items or correct amount of items to craft this."
    end
    
    if ( hook.Run("OverrideCraftFailMessage", ply, uniqueID) != nil ) then
        failMessage = hook.Run("OverrideCraftFailMessage", ply, uniqueID)
    end

    return canCraft, failMessage
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

    local canCraft, failMessage = self:CanCraftRecipe(ply, uniqueID)

    if not ( canCraft ) then
        ply:Notify(failMessage)

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