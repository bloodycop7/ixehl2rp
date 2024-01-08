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

    ix.vendor.list[vendorData.uniqueID] = vendorData

    local ENT = {}

    ENT.Type = "anim"
    ENT.PrintName = k
    ENT.Category = "ix: HL2RP - Vendors"
    ENT.Spawnable = true
    ENT.AdminOnly = true
    ENT.PhysgunDisable = true
    ENT.bNoPersist = true

    if ( SERVER ) then
        function ENT:SetupDataTables()
            self:NetworkVar("String", 0, "VendorID")
        end

        function ENT:Initialize()
            self:SetModel(vendorData.model)
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            self:SetUseType(SIMPLE_USE)
            self:SetVendorID(vendorData.uniqueID)

            local physics = self:GetPhysicsObject()
            physics:EnableMotion(false)
            physics:Sleep()

            self.nextUse = 0
        end

        function ENT:Use(ply)
            if not ( ply:GetEyeTrace().Entity == self ) then
                return
            end

            if ( self.nextUse > CurTime() ) then
                return
            end

            ply:SetNetVar("ixVendorUse", self)
            Schema:OpenUI(ply, "ixCustomVendor")

            self.nextUse = CurTime() + 1
        end
    end
end