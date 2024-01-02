AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Item Crate"
ENT.Category = "ix: HL2RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

if ( SERVER ) then
	function ENT:Initialize()
		self:SetModel("models/items/item_item_crate.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetHealth(50)

		local physics = self:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()

		self.nextUse = 0
	end

    function ENT:OnTakeDamage(dmgInfo)
        self:SetHealth(self:Health() - dmgInfo:GetDamage())

        if (self:Health() <= 0) then

            if ( hook.Run("CanItemCacheDrop", self) == false ) then
                self:Remove()

                return
            end

            local dropCount = hook.Run("GetItemCacheDropCount", self) or ix.config.Get("maxItemCrateDrops", 3)
            local tableBase = {}

            for k, v in pairs(ix.item.list) do
                local itemData = ix.item.Get(v.uniqueID)

                if not ( itemData ) then
                    continue
                end

                if not ( ( itemData.canItemCacheDrop or false ) ) then
                    continue
                end

                table.insert(tableBase, v.uniqueID)
            end

            for i = 1, math.random(0, ix.config.Get("maxItemCrateDrops", 3)) do
                ix.item.Spawn(table.Random(tableBase), self:GetPos() + self:GetUp() * math.random(1, 30) + self:GetRight() * math.random(-30, 30))
            end

            self:Remove()
        end 
    end
end