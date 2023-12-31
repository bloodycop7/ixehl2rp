
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Combine Terminal"
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
		self.ixHealth = 50

		local physics = self:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()

		self.nextUse = 0

		local uID = "ixAmbient." .. self:GetClass() .. "." .. self:EntIndex()

		if not ( timer.Exists(uID) ) then
			timer.Create(uID, math.random(2, 10), 0, function()
				if not ( IsValid(self) ) then
					timer.Remove(uID)

					return
				end

				if ( self:GetBroken() ) then
					timer.Remove(uID)

					return
				end

				self:EmitSound("ambient/machines/combine_terminal_idle" .. math.random(1, 4) .. ".wav", 75, 100, 0.25)
			end)
		end

		Schema:SaveData()
	end

	function ENT:Use(ply)
		if not ( ply:GetEyeTrace().Entity == self ) then
			return
		end

		if ( self.nextUse > CurTime() ) then
			return
		end

		self.nextUse = CurTime() + 1

		if not ( Schema:IsCombine(ply) ) then
			self:EmitSound("buttons/combine_button_locked.wav")

			return
		end

		if ( self:GetBroken() ) then
			self:EmitSound("buttons/combine_button_locked.wav")

			local sparks = EffectData()
            sparks:SetOrigin(self:GetPos() + self:GetUp() * 41 + self:GetRight() * 5)
            sparks:SetNormal(self:GetAngles():Right())
            sparks:SetMagnitude(2)
            sparks:SetEntity(self)
            
            util.Effect("ElectricSpark", sparks, true, true)
			
			return
		end

		if ( Schema:IsOTA(ply) ) then
			ply:SetLocalVelocity(Vector(0, 0, 0))
			ply:ForceSequence("console_type")
		end

		Schema:OpenUI(ply, "ixCombineTerminal")
	end

	function ENT:OnRemove()
		if not ( ix.shuttingDown ) then
			Schema:SaveData()
		end

		if ( timer.Exists("ixAmbient." .. self:GetClass() .. "." .. self:EntIndex()) ) then
			for i = 1, 3 do
				for i = 1, 4 do
					self:StopSound("ambient/machines/combine_terminal_idle" .. i .. ".wav")
				end
			end
			
			timer.Remove("ixAmbient." .. self:GetClass() .. "." .. self:EntIndex())
		end
	end

	function ENT:OnTakeDamage(dmgInfo)
		if ( self:GetBroken() ) then
			return
		end

		self:SetHealth(self:Health() - dmgInfo:GetDamage())

		if ( self:Health() <= 0 ) then
			for k, v in ipairs(player.GetAll()) do
				if not ( IsValid(v) ) then
					continue
				end

				if not ( v:GetCharacter() ) then
					continue
				end

				if not ( v:Alive() ) then
					continue
				end

				v:SendLua([[
					if ( IsValid(ix.gui.combineTerminal) ) then
						ix.gui.combineTerminal:Remove()
						ix.gui.combineTerminal = nil
					end
				]])
			end

			self:SetBroken(true)
			self:EmitSound("ambient/energy/spark"..math.random(1, 6)..".wav")

			local uID = "ixSparks." .. self:GetClass() .. "." .. self:EntIndex()

			if not ( timer.Exists(uID) ) then
				timer.Create(uID, math.random(2, 10), 0, function()
					if not ( IsValid(self) ) then
						timer.Remove(uID)

						return
					end

                    if not ( self:GetBroken() ) then
                        timer.Remove(uID)

                        return
                    end

					local sparks = EffectData()
					sparks:SetOrigin(self:GetPos() + self:GetUp() * 41 + self:GetRight() * 5)
					sparks:SetNormal(self:GetAngles():Right())
					sparks:SetMagnitude(2)
					sparks:SetEntity(self)
					
					util.Effect("ElectricSpark", sparks, true, true)
				end)
			end

			local electricianCount = 0

            for k, v in ipairs(player.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end

                if not ( v:GetCharacter() ) then
                    continue
                end

                if not ( v:Alive() ) then
                    continue
                end

                if not ( Schema:IsCitizenElectrician() ) then
                    continue
                end

                if ( v == dmgInfo:GetAttacker() ) then
                    continue
                end

                electricianCount = electricianCount + 1
            end

            if ( electricianCount == 0 ) then
                uID = "ix.Repair." .. self:GetClass() .. "." .. self:EntIndex()
                if not ( timer.Exists(uID) ) then
                    timer.Create(uID, 300, 1, function()
                        if not ( IsValid(self) ) then
							timer.Remove(uID)

							return
						end

						if not ( self:GetBroken() ) then
							timer.Remove(uID)

							return
						end

                        self:SetBroken(false)
                        self:SetHealth(self.ixHealth or 50)
                    end)
                end
            end
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
		if ( IsValid(ix.gui.combineTerminal) ) then
			ix.gui.combineTerminal:Remove()
			ix.gui.combineTerminal = nil
		end

		ix.gui.combineTerminal = self

		self:SetPos(0, scrH * 0.25)
		self:SetSize(scrW * 0.50, scrH * 0.50)

		self:MakePopup()

		self:MoveTo(scrW / 2 - scrW * 0.25, scrH / 2 - scrH * 0.25, 0.2, 0, 0.2)

		self.topPanel = self:Add("Panel")
		self.topPanel:Dock(TOP)
		self.topPanel:SetTall(30)
		self.topPanel:DockPadding(padding * 2, padding * 0.25, 0, 0)
		self.topPanel.Paint = function(s, w, h)
			surface.SetDrawColor(Color(0, 0, 0, 190))
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(Color(0, 255, 255))
			surface.DrawRect(0, 0, 10, h)
		end

		local title = self.topPanel:Add("DLabel")
		title:Dock(LEFT)
		title:SetFont("ixCombineFont14")
		title:SetText("Combine Terminal")
		title:SetTextColor(Color(0, 255, 255))
		title:SetContentAlignment(4)
		title:SizeToContents()

		self.topPanel:SizeToContents()

		self.leftPanel = self:Add("Panel")
		self.leftPanel:Dock(LEFT)
		self.leftPanel:SetWide(padding * 40)
		self.leftPanel:DockMargin(0, padding * 0.3, 0, 0)
		self.leftPanel.Paint = function(pnl, w, h)
			ix.util.DrawBlur(pnl)

			surface.SetDrawColor(Color(0, 0, 0, 190))
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(Color(0, 255, 255))
			surface.DrawRect(0, 0, 10, h)
		end

		self.rightPanel = self:Add("DScrollPanel")
		self.rightPanel:Dock(RIGHT)
		self.rightPanel:SetWide(padding * 79.5)
		self.rightPanel:DockMargin(0, padding * 0.3, 0, 0)
		self.rightPanel.Paint = function(pnl, w, h)
			ix.util.DrawBlur(pnl)

			surface.SetDrawColor(Color(0, 0, 0, 190))
			surface.DrawRect(0, 0, w, h)
		end

		self.cityCodesButton = self.leftPanel:Add("ixMenuButton")
		self.cityCodesButton:Dock(TOP)
		self.cityCodesButton:SetText("City Codes")
		self.cityCodesButton:SetFont("ixCombineFont10")
		self.cityCodesButton:SetTextColor(color_white)
		self.cityCodesButton:DockMargin(11, 10, 3, 0)
		self.cityCodesButton:SetContentAlignment(5)
		self.cityCodesButton.DoClick = function(this)
			self.rightPanel:Clear()

			for k, v in pairs(ix.cmbSystems.cityCodes) do
				local button = self.rightPanel:Add("ixMenuButton")
				button:Dock(TOP)
				button:SetText(v.name)
				button:SetFont("ixCombineFont10")
				button:SetContentAlignment(5)
				button:SetTall(40)
				button:DockMargin(0, 10, 0, 0)
				button.DoClick = function(this)
					net.Start("ix.Combine.SetCityCode")
						net.WriteUInt(k, 8)
					net.SendToServer()
				end
				button.paintW = 0
				button.Paint = function(pnl, w, h)
					--[[surface.SetDrawColor(ColorAlpha(v.color, 10))
					surface.SetMaterial(gradient)
					surface.DrawTexturedRect(0, 0, w, h)]]

					surface.SetDrawColor(ColorAlpha(v.color, 100))
					surface.DrawOutlinedRect(0, 0, w, h, 2)

					if ( pnl:IsHovered() ) then
						pnl.paintW = Lerp(FrameTime() * 10, pnl.paintW, w)
					else
						pnl.paintW = Lerp(FrameTime() * 10, pnl.paintW, 0)
					end

					surface.SetDrawColor(ColorAlpha(v.color, 50))
					surface.SetMaterial(gradient)
					surface.DrawTexturedRect(0, 0, pnl.paintW, h)
				end
			end
		end
		self.cityCodesButton.Paint = function(s, w, h)
			surface.SetDrawColor(Color(0, 65, 65))
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(Color(0, 255, 255))
			surface.DrawOutlinedRect(0, 0, w, h, 2)
		end
		self.cityCodesButton:SizeToContents()

		self.citizenIndexButton = self.leftPanel:Add("ixMenuButton")
		self.citizenIndexButton:Dock(TOP)
		self.citizenIndexButton:SetText("Citizen Index")
		self.citizenIndexButton:SetFont("ixCombineFont10")
		self.citizenIndexButton:SetTextColor(color_white)
		self.citizenIndexButton:DockMargin(11, 5, 3, 0)
		self.citizenIndexButton:SetContentAlignment(5)
		self.citizenIndexButton.DoClick = function(this)
			self.rightPanel:Clear()

			for k, v in ipairs(player.GetAll()) do
				if not ( IsValid(v) ) then
					continue
				end

				local char = v:GetCharacter()

				if not ( char ) then
					continue
				end

				if ( Schema:IsCombine(v) ) then
					continue
				end

				if ( v == localPlayer ) then
					continue
				end

				local button = self.rightPanel:Add("Panel")
				button:Dock(TOP)
				button:SetContentAlignment(5)
				button:SetTall(40)
				button:DockMargin(0, 10, 0, 0)
				button.paintW = 0
				button.Paint = function(pnl, w, h)
					surface.SetDrawColor(ColorAlpha(ix.faction.Get(char:GetFaction()).color, 100))
					surface.DrawOutlinedRect(0, 0, w, h, 2)

					if ( pnl:IsHovered() ) then
						pnl.paintW = Lerp(FrameTime() * 10, pnl.paintW, w)
					else
						pnl.paintW = Lerp(FrameTime() * 10, pnl.paintW, 0)
					end

					surface.SetDrawColor(ColorAlpha(ix.faction.Get(char:GetFaction()).color, 50))
					surface.SetMaterial(gradient)
					surface.DrawTexturedRect(0, 0, pnl.paintW, h)
				end

				local name = button:Add("DLabel")
				name:Dock(LEFT)
				name:DockMargin(10, 0, 0, 0)
				name:SetFont("ixCombineFont10")
				name:SetText(char:GetName())
				name:SetContentAlignment(5)
				name:SizeToContents()

				local button = button:Add("ixMenuButton")
				button:Dock(RIGHT)
				button:SetWide(50)
				button:SetText((char:GetBOLStatus() and "Enable" or "Disable") .. " BOL")
				button:SetFont("ixCombineFont10")
				button:SetContentAlignment(5)
				button.DoClick = function(this)
					net.Start("ix.Combine.ToggleBOL")
						net.WriteEntity(v)
					net.SendToServer()

					this:SetText((char:GetBOLStatus() and "Enable" or "Disable") .. " BOL")
				end
				button:SizeToContents()
			end
		end
		self.citizenIndexButton.Paint = function(s, w, h)
			surface.SetDrawColor(Color(0, 65, 65))
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(Color(0, 255, 255))
			surface.DrawOutlinedRect(0, 0, w, h, 2)
		end
		self.citizenIndexButton:SizeToContents()

		local closeButton = self.topPanel:Add("ixMenuButton")
		closeButton:Dock(RIGHT)
		closeButton:SetText("Log out")
		closeButton:SetTextColor(Color(0, 255, 255))
		closeButton:SetFont("ixCombineFont10")
		closeButton.DoClick = function(this)
			self:MoveTo(0 - scrW * 0.50, scrH / 2 - scrH * 0.25, 0.2, 0, 0.2, function()
				self:Remove()
			end)
		end
		closeButton:SetContentAlignment(5)
		closeButton:SizeToContents()
	end

	function UI:Paint(w, h)
		surface.SetDrawColor(Color(0, 255, 255))
		surface.DrawRect(0, 0, 10, h)

		surface.SetDrawColor(Color(39, 143, 143, 200))
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(10, 0, w, h)
	end

	vgui.Register("ixCombineTerminal", UI, "Panel")

	if ( IsValid(ix.gui.combineTerminal) ) then
		ix.gui.combineTerminal:Remove()
		ix.gui.combineTerminal = nil

		ix.gui.combineTerminal = vgui.Create("ixCombineTerminal")
	end
end