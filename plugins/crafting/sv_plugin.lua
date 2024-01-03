local PLUGIN = PLUGIN
util.AddNetworkString("ix.Crafting.DoCraft")
util.AddNetworkString("ix.Crafting.ClosePanel")

net.Receive("ix.Crafting.ClosePanel", function(len, ply)
    if not ( IsValid(ply) ) then
        return
    end

    if not ( ply:GetCharacter() ) then
        return
    end

    if ( IsValid(ply:GetData("ixCraftingStation", nil)) ) then
        ply:SetData("ixCraftingStation", nil)
    end
end)

net.Receive("ix.Crafting.DoCraft", function(len, ply)
    if not ( IsValid(ply) ) then
        return
    end

    if not ( ply:GetCharacter() ) then
        return
    end

    if not ( ply:Alive() ) then
        return
    end

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

    if not ( IsValid(ply:GetData("ixCraftingStation", nil)) ) then
        return false
    end

    if not ( uniqueID ) then
        return false
    end

    local recipeData = ix.crafting.recipes[uniqueID]

    if not ( recipeData ) then
        return false
    end

    if ( recipeData.stations ) then
        if not ( recipeData.stations[ply:GetData("ixCraftingStation", nil):GetStationID()] ) then
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

    if not ( Schema:IsCitizen(ply) ) then
        canCraft = false
        failMessage = "You must be on the Citizen faction to craft items!"
    end

    if ( recipeData.canCraft ) then
        if not ( recipeData:canCraft(ply) ) then
            canCraft = false
            failMessage = "You don't have the required items or correct amount of items to craft this!"
        end
    end

    if ( ply:GetPos():Distance(ply:GetData("ixCraftingStation", nil):GetPos()) > 200 ) then
        canCraft = false
        failMessage = "You must be closer to the crafting station!"
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
        failMessage = "You don't have the required items or correct amount of items to craft this!"
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

    if ( recipeData.craftTime ) then
        recipeData.craftTime = (isfunction(recipeData.craftTime) and recipeData:craftTime(ply) or recipeData.craftTime)

        if ( recipeData.craftTime > 0 ) then
            ply:SetAction("Crafting...", recipeData.craftTime)
            ply:DoStaredAction(ply:GetData("ixCraftingStation", nil), function()
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
            end, recipeData.craftTime, function()
                ply:SetAction()
            end)
        else
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
        end
    else
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
    end

    return true
end