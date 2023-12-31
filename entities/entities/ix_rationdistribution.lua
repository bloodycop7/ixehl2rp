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
	self:NetworkVar("Bool", 0, "Using")
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_junk/watermelon01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetNoDraw(true)

		local physics = self:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()

		self.nextUse = 0
		self:SetUsing(false)

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
	
		if ( self:GetUsing() ) then
			return
		end

		if ( self.nextUse > CurTime() ) then
			return
		end

		local char = ply:GetCharacter()

		if not ( char ) then
			return
		end

		self.nextUse = CurTime() + 1

		Schema:PlayGesture(ply, "g_scan_id")		

		self:SetUsing(true)

		local uID = "ixRationDispenser." .. self:EntIndex() .. ".Scan." .. ply:SteamID64()

		if not ( timer.Exists(uID) ) then
			self:GetDispenser():EmitSound("ambient/machines/combine_terminal_idle2.wav")
			timer.Create(uID, 1, 1, function()
				if not ( IsValid(self) or IsValid(ply) or char ) then
					timer.Remove(uID)

					return
				end

				if ( ply:GetCharacter():GetBOLStatus() ) then
					self:GetDispenser():EmitSound("buttons/combine_button_locked.wav")
					self:SetUsing(false)

					return
				end

				if ( timer.Exists("ixRationDispenser." .. self:EntIndex() .. ".Reset." .. ply:SteamID64() .. "." .. char:GetID()) ) then
					self:GetDispenser():EmitSound("buttons/combine_button_locked.wav")
					self:SetUsing(false)

					ply:Notify("You can take your next ration in " .. string.NiceTime(timer.TimeLeft("ixRationDispenser." .. self:EntIndex() .. ".Reset." .. ply:SteamID64() .. "." .. char:GetID())) .. ".")

					return
				end

				self:GetDispenser():EmitSound("ambient/machines/combine_terminal_idle3.wav")

				uID = "ixRationDispenser." .. self:EntIndex() .. ".Dispense." .. ply:SteamID64()
				
				if not ( timer.Exists(uID) ) then
					timer.Create(uID, SoundDuration("ambient/machines/combine_terminal_idle3.wav") + 1, 1, function()
						if not ( IsValid(self) or IsValid(ply) or char ) then
							timer.Remove(uID)

							return
						end

						self:GetDispenser():EmitSound("buttons/combine_button1.wav")
						self:GetDispenser():Fire("SetAnimation", "dispense_package", 0)

						local pos = self:GetDispenser():GetPos()

						pos = pos + self:GetForward() * 20

						ix.item.Spawn("ration_package", pos)

						timer.Create("ixRationDispenser." .. self:EntIndex() .. ".Reset." .. ply:SteamID64() .. "." .. char:GetID(), ix.config.Get("rationInterval", 1800), 1, function()
						end)

						self:SetUsing(false)
					end)
				end
			end)
		end
    end

    function ENT:OnRemove()
        if ( IsValid(self:GetDispenser()) ) then
            self:GetDispenser():Remove()
        end

		if not ( ix.shuttingDown ) then
			Schema:SaveData()
		end
    end
end