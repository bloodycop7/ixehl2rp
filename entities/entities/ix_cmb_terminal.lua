
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Combine Terminal"
ENT.Category = "ix: HL2RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_interface001.mdl")
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

		self.nextUse = CurTime() + 1

		Schema:OpenUI(ply, "ixCombineTerminal")
	end

	function ENT:OnRemove()
		if (!ix.shuttingDown) then
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
		self.topPanel:DockPadding(0, padding * 0.25, 0, 0)
		self.topPanel.Paint = function(s, w, h)
			surface.SetDrawColor(Color(0, 0, 0, 190))
			surface.DrawRect(0, 0, w, h)
		end

		local title = self.topPanel:Add("DLabel")
		title:Dock(LEFT)
		title:SetFont("ixCombineTerminalFont")
		title:SetText("Combine Terminal")
		title:SetContentAlignment(5)
		title:SetTextColor(color_white)
		title:SizeToContents()

		self.leftPanel = self:Add("Panel")
		self.leftPanel:Dock(LEFT)
		self.leftPanel:SetWide(padding * 40)
		self.leftPanel:DockMargin(0, padding * 0.3, 0, 0)
		self.leftPanel.Paint = function(pnl, w, h)
			ix.util.DrawBlur(pnl)

			surface.SetDrawColor(Color(0, 0, 0, 190))
			surface.DrawRect(0, 0, w, h)
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
		self.cityCodesButton:SetFont("ixCombineHUDFont")
		self.cityCodesButton:SetTextColor(color_white)
		self.cityCodesButton.DoClick = function(this)
			self.rightPanel:Clear()

			for k, v in pairs(ix.cmbSystems.cityCodes) do
				local button = self.rightPanel:Add("ixMenuButton")
				button:Dock(TOP)
				button:SetText(v.name)
				button:SetFont("ixCombineHUDFont")
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
		self.cityCodesButton:SizeToContents()

		local closeButton = self.topPanel:Add("ixMenuButton")
		closeButton:SetWide(50)
		closeButton:Dock(RIGHT)
		closeButton:SetText("X")
		closeButton:SetFont("ixCombineHUDFont")
		closeButton.DoClick = function(this)
			self:MoveTo(0 - scrW * 0.50, scrH / 2 - scrH * 0.25, 0.2, 0, 0.2, function()
				self:Remove()
			end)
		end
	end

	function UI:Paint(w, h)
		surface.SetDrawColor(Color(0, 255, 255, 200))
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	vgui.Register("ixCombineTerminal", UI, "Panel")

	if ( IsValid(ix.gui.combineTerminal) ) then
		ix.gui.combineTerminal:Remove()
		ix.gui.combineTerminal = nil

		ix.gui.combineTerminal = vgui.Create("ixCombineTerminal")
	end
end