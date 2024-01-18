local PLUGIN = PLUGIN

util.AddNetworkString("ix.CustomVendor.CloseMenu")
util.AddNetworkString("ix.CustomVendor.Purchase")
util.AddNetworkString("ix.CustomVendor.Sell")

net.Receive("ix.CustomVendor.Sell", function(len, ply)
    if ( ( ix.nextVendorSell or 0 ) > CurTime() ) then
        return
    end

    ix.nextVendorSell = CurTime() + 0.5

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( IsValid(ply:GetNetVar("ixVendorUse", nil)) ) then
        return
    end

    local itemID = net.ReadString()

    if not ( itemID ) then
        return
    end

    local itemData = ix.item.Get(itemID)

    if not ( itemData ) then
        return
    end

    if ( ix.vendor.list[ply:GetNetVar("ixVendorUse", nil):GetVendorID()].canUse and not ix.vendor.list[ply:GetNetVar("ixVendorUse", nil):GetVendorID()]["canUse"](ply) ) then
        return
    end

    local vendorItemData = ix.vendor.list[ply:GetNetVar("ixVendorUse", nil):GetVendorID()].sell[itemID]

    if not ( vendorItemData ) then
        return
    end

    if ( vendorItemData.canSell and not vendorItemData["canSell"](ply, ply:GetNetVar("ixVendorUse", nil)) ) then
        return
    end

    local inv = char:GetInventory()

    if not ( inv:HasItem(itemID) ) then
        ply:Notify("You don't have this item")

        return
    end

    if ( ( vendorItemData.GetPrice and vendorItemData["GetPrice"](ply, ply:GetNetVar("ixVendorUse", nil)) or 0 ) > 0 ) then
        ply:GetCharacter():GiveMoney(vendorItemData["GetPrice"](ply, ply:GetNetVar("ixVendorUse", nil)))
    end

    if ( vendorItemData.onSell ) then
        vendorItemData["onSell"](ply, ply:GetNetVar("ixVendorUse", nil))
    end

    inv:Remove(inv:HasItem(itemID):GetID())
end)

net.Receive("ix.CustomVendor.CloseMenu", function(len, ply)
    if ( ( ix.nextVendorCloseMenu or 0 ) > CurTime() ) then
        return
    end

    ix.nextVendorCloseMenu = CurTime() + 0.5

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( IsValid(ply:GetNetVar("ixVendorUse", nil)) ) then
        return
    end

    ply:SetNetVar("ixVendorUse", nil)
end)

net.Receive("ix.CustomVendor.Purchase", function(len, ply)
    if ( ( ix.nextVendorPurchase or 0 ) > CurTime() ) then
        return
    end

    ix.nextVendorPurchase = CurTime() + 0.5
    
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( IsValid(ply:GetNetVar("ixVendorUse", nil)) ) then
        return
    end

    local itemID = net.ReadString()

    if not ( itemID ) then
        return
    end

    local itemData = ix.item.Get(itemID)

    if not ( itemData ) then
        return
    end
    
    if ( ix.vendor.list[ply:GetNetVar("ixVendorUse", nil):GetVendorID()].canUse and not ix.vendor.list[ply:GetNetVar("ixVendorUse", nil):GetVendorID()]["canUse"](ply) ) then
        return
    end

    local vendorItemData = ix.vendor.list[ply:GetNetVar("ixVendorUse", nil):GetVendorID()].items[itemID]

    if not ( vendorItemData ) then
        return
    end

    if ( vendorItemData.canPurchase and not vendorItemData["canPurchase"](ply, ply:GetNetVar("ixVendorUse", nil)) ) then
        return
    end

    if ( ( vendorItemData.GetPrice and vendorItemData["GetPrice"](ply, ply:GetNetVar("ixVendorUse", nil)) or 0 ) > 0  ) then
        if not ( ply:GetCharacter():HasMoney(( vendorItemData.GetPrice and vendorItemData["GetPrice"](ply, ply:GetNetVar("ixVendorUse", nil)) or 0 )) ) then
            ply:Notify("You don't have enough money to purchase this item.")

            return
        end

        ply:GetCharacter():TakeMoney(vendorItemData["GetPrice"](ply, ply:GetNetVar("ixVendorUse", nil)))
    end

    local inv = char:GetInventory()

    if not ( inv:Add(itemID) ) then
        ix.item.Spawn(itemID, ply)
    end

    if ( vendorItemData.onPurchase ) then
        vendorItemData["onPurchase"](ply, ply:GetNetVar("ixVendorUse", nil))
    end
end)