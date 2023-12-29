
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Citizen Terminal"
ENT.Category = "ix: HL2RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Broken")
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_interface001.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetBroken(false)
		self:SetHealth(50)

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

		self.nextUse = CurTime() + 1

		if ( Schema:IsCombine(ply) ) then
			self:EmitSound("buttons/combine_button_locked.wav")

			return
		end

		Schema:OpenUI(ply, "ixCitizenTerminal")
	end

	function ENT:OnRemove()
		if not ( ix.shuttingDown ) then
			Schema:SaveData()
		end
	end

	function ENT:OnTakeDamage(dmgInfo)
		if ( self:GetBroken() ) then
			return
		end

		self:SetHealth(self:Health() - dmgInfo:GetDamage())

		if ( self:Health() <= 0 ) then
			self:SetBroken(true)
			self:EmitSound("ambient/energy/spark"..math.random(1, 6)..".wav")
		end
	end
else
	function ENT:Draw()
		self:DrawModel()
    end

	local UI = {}

	local gradient = Material("vgui/gradient-l")
	local padding = 8

	function UI:Init()
		if ( IsValid(ix.gui.citizenTerminal) ) then
			ix.gui.citizenTerminal:Remove()
			ix.gui.citizenTerminal = nil
		end

		ix.gui.citizenTerminal = self

		self:SetPos(0, scrH * 0.25)
		self:SetSize(scrW * 0.50, scrH * 0.50)

		self:MakePopup()

		self:MoveTo(scrW / 2 - scrW * 0.25, scrH / 2 - scrH * 0.25, 0.2, 0, 0.2)

        
	end

	function UI:Paint(w, h)
		surface.SetDrawColor(Color(0, 205, 205, 200))
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	vgui.Register("ixCitizenTerminal", UI, "Panel")

	if ( IsValid(ix.gui.citizenTerminal) ) then
		ix.gui.citizenTerminal:Remove()
		ix.gui.citizenTerminal = nil

		ix.gui.citizenTerminal = vgui.Create("ixCitizenTerminal")
	end
end