local PLUGIN = PLUGIN

PLUGIN.name = "Ammo Crates"
PLUGIN.author = "eon"
PLUGIN.description = "Adds ammo crates that can be used to refill ammo."
PLUGIN.license = [[
Copyright 2024 eon (bloodycop)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.config.Add("ammoCrateInfinite", false, "Whether or not ammo crates should be infinite.", nil, {
    category = "Ammo Crates"
})

ix.config.Add("ammoCrateCooldown", (60 * 10), "On how much time should the ammo crates be refilled.", function(oldV, newV)
    for k, v in pairs(ents.FindByClass("ix_ammo_crate_*")) do
        local uID = "ix_ammo_crate_" .. string.lower(v:GetAmmoType()) .. "_" .. v:EntIndex() .. "_refill_timer"

        if ( timer.Exists(uID) ) then
            timer.Adjust(uID, newV)
        end
    end
end, {
    data = {min = 1, max = 3600},
    category = "Ammo Crates"
})

ix.util.Include("sv_plugin.lua")

PLUGIN.ammoTypes = {
    // AMMO TYPE = {"CRATE MODEL", "MAX AMMO FROM CRATE", "AMOUNT OF AMMO TO GIVE TO THE PLAYER PER USE", "ITEM AMMO (OPTIONAL)"}

    ["AR2"] = {"models/items/ammocrate_ar2.mdl", 1500, 30, "ammo_ar2"},
    ["SMG1"] = {"models/items/ammocrate_smg1.mdl", 1000, 90, "ammo_smg1"},
    ["Buckshot"] = {"models/items/ammocrate_buckshot.mdl", 90, 8, "ammo_buckshot"},
    ["Pistol"] = {"models/items/ammocrate_pistol.mdl", 400, 60, "ammo_pistol"},
    ["357"] = {"models/items/ammocrate_pistol.mdl", 400, 12, "ammo_357"},
}

function PLUGIN:CreateCrates()
    for k, v in pairs(PLUGIN.ammoTypes) do
        local ENT = {}

        ENT.Type = "anim"
        ENT.PrintName = k .. " Ammo Crate"
        ENT.Category = "ix: HL2RP - Ammo Crates"
        ENT.Spawnable = true
        ENT.AdminOnly = true
        ENT.PhysgunDisable = true
        ENT.bNoPersist = true

        function ENT:SetupDataTables()
            self:NetworkVar("String", 0, "AmmoType")
            self:NetworkVar("Int", 0, "RemainingAmmo")
        end

        if ( SERVER ) then
            function ENT:Initialize()
                self:SetModel(v[1])
                self:PhysicsInit(SOLID_VPHYSICS)
                self:SetSolid(SOLID_VPHYSICS)
                self:SetUseType(SIMPLE_USE)

                local physObj = self:GetPhysicsObject()

                if ( IsValid(physObj) ) then
                    physObj:Wake()
                end

                self:SetAmmoType(k)
                self:SetRemainingAmmo(v[2])

                local uID = "ix_ammo_crate_" .. string.lower(k) .. "_" .. self:EntIndex() .. "_refill_timer"

                if not ( timer.Exists(uID) ) then
                    timer.Create(uID, ix.config.Get("ammoCrateCooldown", (60 * 10)), 1, function()
                        if not ( IsValid(self) ) then
                            timer.Remove(uID)

                            return
                        end

                        self:SetRemainingAmmo(v[2])
                        Schema:SaveData() // To update remaining ammo
                    end)
                end

                PLUGIN:SaveData()
            end

            function ENT:Use(ply)
                if not ( ply:GetEyeTrace().Entity == self ) then
                    return 
                end

                local char = ply:GetCharacter()

                if not ( char ) then
                    return
                end

                ply:SetAction("Refilling...", 1)
                ply:DoStaredAction(self, function()
                    if ( ix.config.Get("ammoCrateInfinite", false) ) then
                        local wep = ply:GetActiveWeapon()

                        if not ( IsValid(wep) ) then
                            return
                        end

                        local ammoType = wep:GetPrimaryAmmoType()

                        if ( v[4] and ix.item.Get(v[4]) ) then
                            if not ( char:GetInventory():Add(v[4], 1, {["rounds"] = v[3]}) ) then
                                ply:Notify("You don't have enough space in your inventory!")
                            end                            
                        else
                            self:EmitSound("items/ammo_pickup.wav")
                            ply:GiveAmmo(v[3], k, true)
                        end
                    else
                        if ( self:GetRemainingAmmo() <= 0 ) then
                            ply:Notify("This ammo crate doesn't have any remaining ammo!")

                            return
                        end

                        if ( v[4] and ix.item.Get(v[4]) ) then
                            if not ( char:GetInventory():Add(v[4], 1, {["rounds"] = v[3]}) ) then
                                ply:Notify("You don't have enough space in your inventory!")

                                return
                            end
                        else
                            self:SetRemainingAmmo(math.Clamp(self:GetRemainingAmmo() - v[3], 0, 99999))
                            
                            self:EmitSound("items/ammo_pickup.wav")
                            ply:GiveAmmo(v[3], k, true)
                        end
                    end
                end, 1, function()
                    if ( IsValid(ply) ) then
                        ply:SetAction()
                    end
                end)
            end

            function ENT:OnRemove()
                if not ( ix.shuttingDown ) then
                    PLUGIN:SaveData()
                end
            end
        else
            ENT.PopulateEntityInfo = true

            function ENT:OnPopulateEntityInfo(container)
                local text = container:AddRow("name")
                text:SetImportant()
                text:SetText(self.PrintName)
                text:SizeToContents()

                local desc = container:AddRow("description")
                desc:SetText("An ammunition crate containing " .. k .. " ammo.")
                desc:SizeToContents()

                if not ( ix.config.Get("ammoCrateInfinite", false) ) then
                    local ammo = container:AddRow("ammo")
                    ammo:SetText("Remaining Ammo: " .. math.Clamp(self:GetRemainingAmmo(), 0, 99999) .. " (" .. math.Round(self:GetRemainingAmmo() / v[3], 0) .. " uses)")
                    ammo:SetBackgroundColor(Color(175, 130, 0))
                    ammo:SizeToContents()
                end
            end
        end

        scripted_ents.Register(ENT, "ix_ammo_crate_" .. string.lower(k))
    end

    // Infinite Ammo Box

    local ENT = {}

    ENT.Type = "anim"
    ENT.PrintName = "Infinite Ammo Crate"
    ENT.Category = "ix: HL2RP - Ammo Crates"
    ENT.Spawnable = true
    ENT.AdminOnly = true
    ENT.PhysgunDisable = true
    ENT.bNoPersist = true

    function ENT:SetupDataTables()
        self:NetworkVar("String", 0, "AmmoType")
    end

    if ( SERVER ) then
        function ENT:Initialize()
            self:SetModel("models/items/ammocrate_smg1.mdl")
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            self:SetUseType(SIMPLE_USE)

            local physObj = self:GetPhysicsObject()

            if ( IsValid(physObj) ) then
                physObj:Wake()
            end

            self:SetAmmoType("infinite")
        end

        function ENT:Use(ply)
            if not ( ply:GetEyeTrace().Entity == self ) then
                return 
            end

            local char = ply:GetCharacter()

            if not ( char ) then
                return
            end

            local wep = ply:GetActiveWeapon()

            if not ( IsValid(wep) ) then
                return
            end

            local ammoType = wep:GetPrimaryAmmoType()

            if not ( PLUGIN.ammoTypes[game.GetAmmoName(ammoType)] ) then
                return
            end
            
            ply:SetAction("Refilling...", 1)
            ply:DoStaredAction(self, function()
                if ( PLUGIN.ammoTypes[game.GetAmmoName(ammoType)][4] and ix.item.Get(PLUGIN.ammoTypes[game.GetAmmoName(ammoType)][4]) ) then
                    if not ( char:GetInventory():Add(PLUGIN.ammoTypes[game.GetAmmoName(ammoType)][4], 1, {["rounds"] = PLUGIN.ammoTypes[game.GetAmmoName(ammoType)][3]}) ) then
                        ply:Notify("You don't have enough space in your inventory!")
                    end                            
                else
                    self:EmitSound("items/ammo_pickup.wav")
                    ply:GiveAmmo(PLUGIN.ammoTypes[game.GetAmmoName(ammoType)][3], ammoType, true)
                end

            end, 1, function()
                if ( IsValid(ply) ) then
                    ply:SetAction()
                end
            end)
        end

        function ENT:OnRemove()
            if not ( ix.shuttingDown ) then
                Schema:SaveData()
            end
        end
    else
        ENT.PopulateEntityInfo = true

        function ENT:OnPopulateEntityInfo(container)
            local text = container:AddRow("name")
            text:SetImportant()
            text:SetText(self.PrintName)
            text:SizeToContents()

            local desc = container:AddRow("description")
            desc:SetText("An ammunition crate containing all types of ammo.")
            desc:SizeToContents()

            local ammo = container:AddRow("ammo")
            ammo:SetText("Remaining Ammo: Infinite")
            ammo:SetBackgroundColor(Color(175, 130, 0))
            ammo:SizeToContents()
        end
    end

    scripted_ents.Register(ENT, "ix_ammo_crate_infinite")
end

PLUGIN:CreateCrates()

function PLUGIN:OnReloaded()
    self:CreateCrates()
end