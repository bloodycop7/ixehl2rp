AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Item Cache"
ENT.Category = "ix: HL2RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

function ENT:SetupDataTables()
end

if (SERVER) then
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

            for i = 1, ix.config.Get("maxItemCacheDrops", 3) do
                local item, uniqueID = table.Random(ix.item.list)

                local itemData = ix.item.Get(uniqueID)

                if not ( itemData ) then
                    continue
                end

                if not ( ( itemData.canItemCacheDrop or false ) ) then
                    continue
                end

                ix.item.Spawn(uniqueID, self:GetPos() + self:GetUp() * math.random(1, 30) + self:GetRight() * math.random(-30, 30))
            end

            self:Remove()
        end 
    end
end