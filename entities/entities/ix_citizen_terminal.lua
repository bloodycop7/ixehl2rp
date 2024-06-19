AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Citizen Terminal"
ENT.Category = "Helix: HL2RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Broken")
end

if ( SERVER ) then
	function ENT:Initialize()
		self:SetModel("models/props_combine/breenconsole.mdl")
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

		if ( Schema:IsCombine(ply) ) then
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

            for k, v in player.Iterator() do
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

	function UI:Init()
		if ( IsValid(ix.gui.citizenTerminal) ) then
			ix.gui.citizenTerminal:Remove()
			ix.gui.citizenTerminal = nil
		end

		ix.gui.citizenTerminal = self
        local ply = LocalPlayer()

		self:SetPos(0, ScrH() * 0.25)
		self:SetSize(ScrW() * 0.50, ScrH() * 0.50)
		self:MakePopup()
		self:MoveTo(ScrW() / 2 - ScrW() * 0.25, ScrH() / 2 - ScrH() * 0.25, 0.2, 0, 0.2)

        local progressBar = self:Add("DProgress")
        progressBar:Dock(FILL)
        progressBar:SetFraction(0)
        progressBar:DockMargin(0, ScreenScale(20), 0, ScreenScale(125))
        progressBar.Think = function(this)
            this:SetFraction(this:GetFraction() + FrameTime() * 550)

            if ( this:GetFraction() >= 1000 ) then
                for k, v in ipairs(self:GetChildren()) do
                    v:Remove()
                end

                self:Populate()
            end
        end
        progressBar.Paint = function(this, w, h)
            surface.SetDrawColor(Color(0, 255, 0))
            surface.DrawRect(0, 0, this:GetFraction(), 1)

            surface.SetDrawColor(Color(0, 255, 0, 30))
            surface.SetMaterial(gradient)
            surface.DrawTexturedRect(0, 2, this:GetFraction() * 1.4, h - 1)
        end

        local label = self:Add("DLabel")
        label:Dock(TOP)
        label:SetText("Citizen Terminal")
        label:SetFont("ixMenuButtonFont")
        label:SetContentAlignment(5)
        label:SizeToContents()

        label = self:Add("DLabel")
        label:Dock(TOP)
        label:SetText("Loading...")
        label:SetFont("ixMenuButtonFont")
        label:SetTextColor(color_white)
        label:SetContentAlignment(5)
        label:SizeToContents()
	end

    function UI:Populate()
        local ply = LocalPlayer()
        if not ( IsValid(ply) ) then
            return self:Remove()
        end

        local char = ply:GetCharacter()
        if not ( char ) then
            return self:Remove()
        end

        self.close = self:Add("ixMenuButton")
        self.close:Dock(BOTTOM)
        self.close:SetText("<:: Exit ::>")
        self.close:SetFont("ixMenuButtonFont")
        self.close:SetContentAlignment(5)
        self.close:SizeToContents()
        self.close.DoClick = function()
            self:Remove()
        end
        self.close.paintW = 0
        self.close.Paint = function(this, w, h)
            if ( this:IsHovered() ) then
                this.paintW = Lerp(FrameTime() * 10, this.paintW, w)
            else
                this.paintW = Lerp(FrameTime() * 10, this.paintW, 0)
            end

            surface.SetDrawColor(Color(255, 0, 0))
            surface.DrawRect(0, 0, this.paintW, 2)

            surface.SetDrawColor(Color(255, 0, 0, 30))
            surface.SetMaterial(gradient)
            surface.DrawTexturedRect(0, 0, this.paintW, h)
        end

        local label = self:Add("DLabel")
        label:Dock(TOP)
        label:SetText("<:: Civillian DataBase: " .. ply:SteamID64() .. " ::>")
        label:SetFont("ixSubTitleFont")
        label:SetContentAlignment(5)
        label:DockMargin(0, 0, 0, ScreenScale(10))
        label:SizeToContents()

        label = self:Add("DLabel")
        label:Dock(TOP)
        label:SetText("Name: " .. ply:Name())
        label:SetFont("ixMediumFont")
        label:SetContentAlignment(4)
        label:SizeToContents()

        label = self:Add("DLabel")
        label:Dock(TOP)
        label:SetText("Loyalty Points: " .. char:GetLoyaltyPoints())
        label:SetFont("ixMediumFont")
        label:SetContentAlignment(4)
        label:SizeToContents()

        self.rightPanel = self:Add("DPanel")
        self.rightPanel:Dock(RIGHT)
        self.rightPanel:SetWide(self:GetWide() * 0.5)
        self.rightPanel.Paint = function(this, w, h)
        end

        local modelPanel = self.rightPanel:Add("ixModelPanel")
        modelPanel:Dock(FILL)
        modelPanel:SetModel(ply:GetModel())
        modelPanel:SetFOV(30)
        modelPanel:SetLookAt(Vector(0, 0, 60))
        modelPanel.LayoutEntity = function(this, ent)
            ent:SetAngles(Angle(0, RealTime() * 50, 0))
        end
    end

	function UI:Paint(w, h)
        surface.SetDrawColor(Color(0, 0, 0, 255))
        surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(Color(0, 100, 0, 50))
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