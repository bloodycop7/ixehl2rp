local PLUGIN = PLUGIN

PLUGIN.name = "Lootables"
PLUGIN.author = "eon"
PLUGIN.description = "Adds lootable containers."

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

    if not ( lootableData.lootTime ) then
        lootableData.lootTime = 5
    else
        if ( isfunction(lootableData.lootTime) ) then
            lootableData.lootTime = lootableData:lootTime()
        else
            lootableData.lootTime = lootableData.lootTime
        end
    end

    if not ( lootableData.maxItems ) then
        lootableData.maxItems = 5
    else
        if ( isfunction(lootableData.maxItems) ) then
            lootableData.maxItems = lootableData:maxItems()
        else
            lootableData.maxItems = lootableData.maxItems
        end
    end

    if not ( lootableData.lootDelay ) then
        lootableData.lootDelay = 300
    else
        if ( isfunction(lootableData.lootDelay) ) then
            lootableData.lootDelay = lootableData:lootDelay()
        else
            lootableData.lootDelay = lootableData.lootDelay
        end
    end

    if not ( lootableData.rarity ) then
        lootableData.rarity = 90
    else
        if ( isfunction(lootableData.rarity) ) then
            lootableData.rarity = lootableData:rarity()
        else
            lootableData.rarity = lootableData.rarity
        end
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
    end

    scripted_ents.Register(ENT, "ix_lootable_" .. uniqueID)

    self.stored[uniqueID] = lootableData
end

ix.util.Include("sh_lootables.lua")