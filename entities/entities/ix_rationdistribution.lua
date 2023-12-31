AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Ration Distrubution Machine"
ENT.Category = "ix: HL2RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Dispenser")
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_junk/watermelon01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physics = self:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()

		self.nextUse = 0

        self.dispenser = ents.Create("prop_dynamic")
        self.dispenser:SetModel("models/props_combine/combine_dispenser.mdl")
        self.dispenser:SetPos(self:GetPos())
        self.dispenser:SetAngles(self:GetAngles())
        self.dispenser:SetParent(self)
        self.dispenser:Spawn()
        self.dispenser:Activate()

        self:SetDispenser(self.dispenser)

        Schema:SaveData()
	end

	function ENT:Use(ply)
		if not ( ply:GetEyeTrace().Entity == self or ply:GetEyeTrace().Entity == self:GetDispenser() ) then
			return
		end

		if ( self.nextUse > CurTime() ) then
			return
		end

		self.nextUse = CurTime() + 1

		Schema:PlayGesture(ply, "g_scan_id")
    end

    function ENT:OnRemove()
        if ( IsValid(self:GetDispenser()) ) then
            self:GetDispenser():Remove()
        end
    end
end