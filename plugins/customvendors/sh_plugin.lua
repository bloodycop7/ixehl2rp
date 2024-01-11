local PLUGIN = PLUGIN

PLUGIN.name = "Custom Vendors"
PLUGIN.author = "eon"
PLUGIN.license = [[
Copyright 2024 eon (bloodycop)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

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

ix.util.Include("sv_plugin.lua")
ix.util.Include("sh_vendors.lua")