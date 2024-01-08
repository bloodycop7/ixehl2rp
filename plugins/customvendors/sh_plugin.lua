local PLUGIN = PLUGIN

PLUGIN.name = "Custom Vendors"
PLUGIN.author = "eon"

ix.vendor = ix.vendor or {}
ix.vendor.list = ix.vendor.list or {}

function ix.vendor:Register(vendorData)
    if not ( vendorData.name ) then
        ErrorNoHalt("[Helix] Attempted to register a vendor without a name!\n")
        return
    end

    if not ( vendorData.model ) then
        ErrorNoHalt("[Helix] Attempted to register a vendor without a model!\n")
        return
    end

    if not ( vendorData.items ) then
        ErrorNoHalt("[Helix] Attempted to register a vendor without items!\n")
        return
    end

    self.list[vendorData.uniqueID] = vendorData

    local ENT = {}

    ENT.Type = "anim"
    ENT.PrintName = vendorData.name
    ENT.Category = "ix: HL2RP - Vendors"
    ENT.Spawnable = true
    ENT.AdminOnly = true
    ENT.PhysgunDisable = true
    ENT.bNoPersist = true

    function ENT:SetupDataTables()
        self:NetworkVar("String", 0, "VendorID")
    end

    if ( SERVER ) then
        function ENT:Initialize()
            self:SetModel(vendorData.model)
            self:SetSolid(SOLID_BBOX)
            self:PhysicsInit(SOLID_BBOX)
            self:SetUseType(SIMPLE_USE)
            self:SetMoveType(MOVETYPE_NONE)
            self:DropToFloor()
            self:SetPos(self:GetPos() - self:GetUp() * 6)

            self:SetVendorID(vendorData.uniqueID)

            local physics = self:GetPhysicsObject()
            physics:EnableMotion(false)
            physics:Sleep()

            if ( vendorData.onInit ) then
                vendorData:onInit(self)
            end

            self.nextUse = 0
        end

        function ENT:Use(ply)
            if not ( ply:GetEyeTrace().Entity == self ) then
                return
            end

            if ( self.nextUse > CurTime() ) then
                return
            end

            if ( ply:GetNetVar("ixVendorUse", nil) ) then
                return
            end

            if ( vendorData.canUse and not vendorData:canUse(ply, self) ) then
                return
            end

            ply:SetNetVar("ixVendorUse", self)
            
            timer.Simple(0.1, function()
                Schema:OpenUI(ply, "ixCustomVendor")
            end)

            self.nextUse = CurTime() + 1
        end
    end

    scripted_ents.Register(ENT, "ix_custom_vendor_" .. vendorData.uniqueID)
end

ix.util.Include("sh_vendors.lua")

if ( SERVER ) then
    util.AddNetworkString("ix.CustomVendor.CloseMenu")
    util.AddNetworkString("ix.CustomVendor.Purchase")

    net.Receive("ix.CustomVendor.CloseMenu", function(len, ply)
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
        
        local vendorItemData = ix.vendor.list[ply:GetNetVar("ixVendorUse", nil):GetVendorID()].items[itemID]

        if not ( vendorItemData ) then
            return
        end

        if ( vendorItemData.canPurchase and not vendorItemData:canPurchase(ply, ply:GetNetVar("ixVendorUse", nil)) ) then
            return
        end

        if ( isfunction(vendorItemData.price) ) then
            vendorItemData.price = vendorItemData:price(ply, ply:GetNetVar("ixVendorUse", nil)) or 0
        else
            vendorItemData.price = vendorItemData.price
        end

        if ( vendorItemData.price and vendorItemData.price > 0 ) then
            if not ( ply:GetCharacter():HasMoney(vendorItemData.price) ) then
                ply:Notify("You don't have enough money to purchase this item.")

                return
            end

            ply:GetCharacter():TakeMoney(vendorItemData.price)
        end

        local inv = char:GetInventory()

        if not ( inv:Add(itemID) ) then
            ix.item.Spawn(itemID, ply)
        end

        if ( vendorItemData.onPurchase ) then
            vendorItemData:onPurchase(ply, ply:GetNetVar("ixVendorUse", nil))
        end
    end)
end