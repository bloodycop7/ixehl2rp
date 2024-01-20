
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Forcefield"
ENT.Category = "ix: HL2RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PhysgunDisabled = true
ENT.bNoPersist = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Mode")
	self:NetworkVar("Entity", 0, "Dummy")
end

local MODE_ALLOW_ALL = 1
local MODE_ALLOW_CID = 2
local MODE_ALLOW_NONE = 3

if (SERVER) then
	function ENT:SpawnFunction(ply, trace)
		local angles = (ply:GetPos() - trace.HitPos):Angle()
		angles.p = 0
		angles.r = 0
		angles:RotateAroundAxis(angles:Up(), 270)

		local entity = ents.Create("ix_cmb_forcefield")
		entity:SetPos(trace.HitPos + Vector(0, 0, 40))
		entity:SetAngles(angles:SnapTo("y", 90))
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_fence01b.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)

		local data = {}
			data.start = self:GetPos() + self:GetRight() * -16
			data.endpos = self:GetPos() + self:GetRight() * -480
			data.filter = self
		local trace = util.TraceLine(data)

		local angles = self:GetAngles()
		angles:RotateAroundAxis(angles:Up(), 90)

		self.dummy = ents.Create("prop_physics")
		self.dummy:SetModel("models/props_combine/combine_fence01a.mdl")
		self.dummy:SetPos(trace.HitPos)
		self.dummy:SetAngles(self:GetAngles())
		self.dummy:Spawn()
		self.dummy.PhysgunDisabled = true
		self:DeleteOnRemove(self.dummy)

		local verts = {
			{pos = Vector(0, 0, -25)},
			{pos = Vector(0, 0, 150)},
			{pos = self:WorldToLocal(self.dummy:GetPos()) + Vector(0, 0, 150)},
			{pos = self:WorldToLocal(self.dummy:GetPos()) + Vector(0, 0, 150)},
			{pos = self:WorldToLocal(self.dummy:GetPos()) - Vector(0, 0, 25)},
			{pos = Vector(0, 0, -25)}
		}

		self:PhysicsFromMesh(verts)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end

		self:SetCustomCollisionCheck(true)
		self:EnableCustomCollisions(true)
        self:CollisionRulesChanged()
        
		self:SetDummy(self.dummy)

		physObj = self.dummy:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end

		self:SetMoveType(MOVETYPE_NOCLIP)
		self:SetMoveType(MOVETYPE_PUSH)
		self:MakePhysicsObjectAShadow()
		self:SetMode(MODE_ALLOW_ALL)

		Schema:SaveData()
	end

	function ENT:StartTouch(entity)
		if (!self.buzzer) then
			self.buzzer = CreateSound(entity, "ambient/machines/combine_shield_touch_loop1.wav")
			self.buzzer:Play()
			self.buzzer:ChangeVolume(0.8, 0)
		else
			self.buzzer:ChangeVolume(0.8, 0.5)
			self.buzzer:Play()
		end

		self.entities = (self.entities or 0) + 1
	end

	function ENT:EndTouch(entity)
		self.entities = math.max((self.entities or 0) - 1, 0)

		if (self.buzzer and self.entities == 0) then
			self.buzzer:FadeOut(0.5)
		end
	end

	function ENT:OnRemove()
		if (self.buzzer) then
			self.buzzer:Stop()
			self.buzzer = nil
		end

		if (!ix.shuttingDown and !self.ixIsSafe) then
			Schema:SaveData()
		end
	end

	local MODES = {
		{ // Return false to allow going through.
			function(ply)
				return false
			end,
			"Off.",
            onSet = function(self, ply, ent)
				ent:SetSkin(1)
				ent.dummy:SetSkin(1)
				ent:EmitSound("npc/turret_floor/die.wav")
            end
		},
		{
			function(ply)
				local character = ply:GetCharacter()

				if (character and character:GetInventory() and !character:GetInventory():HasItem("cid")) then
					return true
				else
					return false
				end
			end,
			"Only allow with valid CID.",
            onSet = function(self, ply, ent)
                ent:SetSkin(0)
                ent.dummy:SetSkin(0)

                ent:EmitSound("buttons/combine_button5.wav", 140, 100 + (ent:GetMode() - 1) * 15)
            end
		},
		{
			function(ply)
				return true
			end,
			"Never allow citizens.",
            onSet = function(self, ply, ent)
                ent:SetSkin(0)
				ent.dummy:SetSkin(0)

                ent:EmitSound("buttons/combine_button5.wav", 140, 100 + (ent:GetMode() - 1) * 15)
            end
		}
	}

	function ENT:Use(activator)
		if ((self.nextUse or 0) < CurTime()) then
			self.nextUse = CurTime() + 1.5
		else
			return
		end

		if ( Schema:IsCombine(activator) ) then
            local oldMode = self:GetMode()

			self:SetMode(self:GetMode() + 1)

			if (self:GetMode() > #MODES) then
				self:SetMode(1)
			end

            if ( MODES[self:GetMode()].onSet ) then
                MODES[self:GetMode()]:onSet(activator, self)
            end

            self:SetCustomCollisionCheck(true)
            self:EnableCustomCollisions(true)
            self:CollisionRulesChanged()

			activator:ChatNotify("Changed barrier mode to: " .. MODES[self:GetMode()][2])
            hook.Run("OnPlayerChangeForcefieldMode", activator, self, oldMode, self:GetMode())
		else
            hook.Run("OnPlayerTriggerForcefield", activator, self)

			self:EmitSound("buttons/combine_button3.wav")
		end
	end

	hook.Add("ShouldCollide", "ix_cmb_forcefield", function(a, b)
		local ply = a
		local entity = b
        local realEnt = b

		if (a:GetClass() != "ix_cmb_forcefield") then
			ply = a
			entity = b
		elseif (b:GetClass() != "ix_cmb_forcefield") then
			ply = b
			entity = a
		end
        
        if ( IsValid(entity) and entity:GetClass() == "ix_cmb_forcefield" ) then
            if ( IsValid(b) ) then
                if ( hook.Run("CanGoThroughForcefield", b, entity) == false ) then
                    return true
                end
            end
        end

		if (IsValid(entity) and entity:GetClass() == "ix_cmb_forcefield") then
			if (IsValid(ply) and ply:IsPlayer() ) then
				if ( Schema:IsCombine(ply) ) then
					return false
				end

				local mode = entity:GetMode() or 1

                if ( istable(MODES[mode]) and MODES[mode][1](ply) == true ) then
                    if ( hook.Run("CanGoThroughForcefield", b, entity) == true ) then
                        return false
                    end
                end

				return istable(MODES[mode]) and MODES[mode][1](ply)
			else
				return true
			end
		end
	end)
else
	local SHIELD_MATERIAL = ix.util.GetMaterial("effects/combineshield/comshieldwall3")

	function ENT:Initialize()
		local data = {}
			data.start = self:GetPos() + self:GetRight()*-16
			data.endpos = self:GetPos() + self:GetRight()*-480
			data.filter = self
		local trace = util.TraceLine(data)

		self:EnableCustomCollisions(true)
		self:PhysicsInitConvex({
			vector_origin,
			Vector(0, 0, 150),
			trace.HitPos + Vector(0, 0, 150),
			trace.HitPos
		})
	end

	function ENT:Draw()
		self:DrawModel()

		if (self:GetMode() == 1) then
			return
		end

		local angles = self:GetAngles()
		local matrix = Matrix()
		matrix:Translate(self:GetPos() + self:GetUp() * -40)
		matrix:Rotate(angles)

		render.SetMaterial(SHIELD_MATERIAL)

		local dummy = self:GetDummy()

		if (IsValid(dummy)) then
			local vertex = self:WorldToLocal(dummy:GetPos())
			self:SetRenderBounds(vector_origin, vertex + self:GetUp() * 150)

			cam.PushModelMatrix(matrix)
				self:DrawShield(vertex)
			cam.PopModelMatrix()

			matrix:Translate(vertex)
			matrix:Rotate(Angle(0, 180, 0))

			cam.PushModelMatrix(matrix)
				self:DrawShield(vertex)
			cam.PopModelMatrix()
		end
	end

	function ENT:DrawShield(vertex)
		mesh.Begin(MATERIAL_QUADS, 1)
			mesh.Position(vector_origin)
			mesh.TexCoord(0, 0, 0)
			mesh.AdvanceVertex()

			mesh.Position(self:GetUp() * 190)
			mesh.TexCoord(0, 0, 3)
			mesh.AdvanceVertex()

			mesh.Position(vertex + self:GetUp() * 190)
			mesh.TexCoord(0, 3, 3)
			mesh.AdvanceVertex()

			mesh.Position(vertex)
			mesh.TexCoord(0, 3, 0)
			mesh.AdvanceVertex()
		mesh.End()
	end
end