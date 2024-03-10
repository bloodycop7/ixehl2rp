local PLUGIN = PLUGIN

util.AddNetworkString("ix.Crafting.DoCraft")
util.AddNetworkString("ix.Crafting.ClosePanel")

net.Receive("ix.Crafting.ClosePanel", function(len, ply)
    if ( ( ix.crafting.nextCraftPanelClose or 0 ) > CurTime() ) then
        return
    end

    ix.crafting.nextCraftPanelClose = CurTime() + 0.5

    if not ( IsValid(ply) ) then
        return
    end

    if not ( ply:GetCharacter() ) then
        return
    end

    if ( IsValid(ply:GetNetVar("ixCraftingStation", nil)) ) then
        ply:SetNetVar("ixCraftingStation", nil)
    end
end)

net.Receive("ix.Crafting.DoCraft", function(len, ply)
    if ( ( ix.crafting.nextCraftDoCraft or 0 ) > CurTime() ) then
        return
    end

    ix.crafting.nextCraftDoCraft = CurTime() + 0.5

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
        if ( failMessage ) then
            ply:Notify(failMessage)
        end

        return
    end

    PLUGIN:CraftRecipe(ply, uniqueID)
end)

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
            ply:DoStaredAction(ply:GetNetVar("ixCraftingStation", nil), function()
                 for k, v in ipairs(recipeData.result) do
                    if not ( ply:GetCharacter():GetInventory():Add(k) ) then
                        ix.item.Spawn(k, ply:GetPos() + ply:GetForward() * 20 + ply:GetUp() * 30)
                    end

                    if ( recipeData.onCraftItem ) then
                        recipeData:onCraftItem(ply, k)
                    end
                end

                for k, v in ipairs(recipeData.requirements) do
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
                if ( IsValid(ply) ) then
                    ply:SetAction()
                end
            end)
        else
            for k, v in ipairs(recipeData.result) do
                if not ( ply:GetCharacter():GetInventory():Add(k) ) then
                    ix.item.Spawn(k, ply:GetPos() + ply:GetForward() * 20 + ply:GetUp() * 30)
                end

                if ( recipeData.onCraftItem ) then
                    recipeData:onCraftItem(ply, k)
                end
            end

            for k, v in ipairs(recipeData.requirements) do
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
