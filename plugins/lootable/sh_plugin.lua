local PLUGIN = PLUGIN

PLUGIN.name = "Lootables"
PLUGIN.author = "eon"
PLUGIN.description = "Adds lootable containers."
PLUGIN.license = [[
Copyright 2024 eon (bloodycop)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.lootable = ix.lootable or {}
ix.lootable.stored = ix.lootable.stored or {}

ix.lootable.defaultConfig = {
    ["items"] = {
        "gunpowder",
        "gear",
        "metal_plate",
    },
    ["rareItems"] = {
        "wep_mp7",
        "wep_usp"
    }
}

function ix.lootable:Register(lootableData)
    if not ( lootableData.name ) then
        error("Attempt to register lootable without a name!") 
    end

    if not ( lootableData.model ) then
        error("Attempt to register lootable without a model!") 
    end

    if not ( lootableData.items ) then
        lootableData.items = self.defaultConfig.items
    end

    if not ( lootableData.rareItems ) then
        lootableData.rareItems = self.defaultConfig.rareItems
    end

    local uniqueID = string.lower(lootableData.name)
    uniqueID = string.Replace(uniqueID, " ", "_")

    local ENT = {}

    ENT.Type = "anim"
    ENT.PrintName = lootableData.name
    ENT.Category = "ix: HL2RP - Lootables"
    ENT.Spawnable = true
    ENT.AdminOnly = true
    ENT.PhysgunDisable = true
    ENT.bNoPersist = true

    if ( SERVER ) then
        function ENT:Initialize()
            self:SetModel(lootableData.model)
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            self:SetUseType(SIMPLE_USE)

            local physics = self:GetPhysicsObject()
            physics:EnableMotion(false)
            physics:Sleep()

            self.nextUse = 0
            PLUGIN:SaveData()
        end

        function ENT:Use(ply)
            if not ( ply:GetEyeTrace().Entity == self ) then
                return
            end

            if ( self.nextUse > CurTime() ) then
                return
            end

            local char = ply:GetCharacter()

            if not ( char ) then
                return
            end

            if ( timer.Exists("ixLootableTimer_" .. self:GetClass() .. "_" .. self:EntIndex()) ) then
                ply:Notify("You can loot this again in " .. math.Round(timer.TimeLeft("ixLootableTimer_" .. self:GetClass() .. "_" .. self:EntIndex())) .. " seconds.")
            
                return
            end

            lootableData.lootTime = ( lootableData["lootTime"] and lootableData["lootTime"](ply) or math.random(2, 5) )
            lootableData.lootDelay = ( lootableData["lootDelay"] and lootableData["lootDelay"](ply) or math.random(60, 120) )
            lootableData.maxItems = ( lootableData["maxItems"] and lootableData["maxItems"](ply) or math.random(1, 3) )
            lootableData.rarity = ( lootableData["rarity"] and lootableData["rarity"](ply) or math.random(1, 100) )

            if ( lootableData.lootTime > 0 ) then
                ply:SetAction("Looting...", lootableData.lootTime)
                ply:DoStaredAction(self, function()
                    for i = 1, lootableData.maxItems do
                        local item = lootableData.items[math.random(1, #lootableData.items)]

                        local rarity = math.random(1, 100)

                        if ( rarity > lootableData.rarity ) then
                            item = lootableData.rareItems[math.random(1, #lootableData.rareItems)]
                        end

                        local itemTable = ix.item.Get(item)

                        if ( itemTable ) then
                            if not ( ply:GetCharacter():GetInventory():Add(item) ) then
                                ix.item.Spawn(item, self:GetPos() + self:GetUp() * math.random(10, 40) + self:GetRight() * math.random(-10, 10) + self:GetForward() * math.random(-10, 10))
                            end
                        else
                            ErrorNoHalt("Attempt to spawn invalid item '" .. item .. "' in lootable '" .. lootableData.name .. "'\n")
                        end
                    end

                    if not ( timer.Exists("ixLootableTimer_" .. self:GetClass() .. "_" .. self:EntIndex()) ) then
                        timer.Create("ixLootableTimer_" .. self:GetClass() .. "_" .. self:EntIndex(), lootableData.lootDelay, 1, function()
                        end)
                    end
                end, lootableData.lootTime, function()
                    if ( IsValid(ply) ) then
                        ply:SetAction()
                    end
                end)
            end

            self.nextUse = CurTime() + 1
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
            text:SetText(lootableData.name)
            text:SizeToContents()
        end
    end

    scripted_ents.Register(ENT, "ix_lootable_" .. uniqueID)

    self.stored[uniqueID] = lootableData
end

ix.util.Include("sv_plugin.lua")
ix.util.Include("sh_lootables.lua")