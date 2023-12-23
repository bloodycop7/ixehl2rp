local PLUGIN = PLUGIN

local HUD = {}

local padding = ScreenScale(8)

function HUD:Init()
    ix.gui.combineHUD = self

    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)

    self:DockPadding(padding, padding * 2, padding, padding * 2)
    
    self.leftPanel = self:Add("Panel")
    self.leftPanel:Dock(LEFT)
    self.leftPanel:SetWide(ScrW() * 0.20)
    self.leftPanel.Paint = function(s, w, h)
    end

    local text = self.leftPanel:Add("DLabel")
    text:Dock(TOP)
    text:SetWrap(true)
    text.health = 100
    text:SetText("<:: Vitals: " .. text.health)
    text:SetFont("ixCombineHUDFont")
    text:SetTall(text:GetTall() * 1)
    text.Think = function(s)
        if ( localPlayer:Health() != s.health ) then
            s.health = localPlayer:Health()
            s:SetText("<:: Vitals: " .. s.health)
        end
    end

    text = self.leftPanel:Add("DLabel")
    text:Dock(TOP)
    text:SetWrap(true)
    text.dir = localPlayer:GetPos()
    text:SetText("<:: Vector: " .. math.Round(text.dir.x, 1) .. ", " .. math.Round(text.dir.y, 1) .. ", " .. math.Round(text.dir.z, 1))
    text:SetFont("ixCombineHUDFont")
    text:SetTall(text:GetTall() * 1.3)
    text.Think = function(s)
        if ( s.dir.x != localPlayer:GetPos().x or s.dir.y != localPlayer:GetPos().y or s.dir.z != localPlayer:GetPos().z ) then
            s.dir = localPlayer:GetPos()
            s:SetText("<:: Vector: " .. math.Round(s.dir.x, 1) .. ", " .. math.Round(s.dir.y, 1) .. ", " .. math.Round(s.dir.z, 1))
        end
    end

    self.rightPanel = self:Add("Panel")
    self.rightPanel:Dock(RIGHT)
    self.rightPanel:SetWide(ScrW() * 0.20)
    self.rightPanel:DockPadding(padding * 10, 0, 0, 0)

    text = self.rightPanel:Add("DLabel")
    text:SetContentAlignment(6)
    text:Dock(TOP)
    text:SetWrap(true)
    text:SetText(ix.cmbSystems.cityCodes[ix.cmbSystems.GetCityCode()].name .. " ::>")
    text:SetTextColor(ix.cmbSystems.cityCodes[ix.cmbSystems.GetCityCode()].color or color_white)
    text:SetFont("ixCombineHUDFont")
    text:SetTall(text:GetTall() * 1.3)
    text.Think = function(s)
        if ( ix.cmbSystems.cityCodes[ix.cmbSystems.GetCityCode()].name != s:GetText() ) then
            s:SetText(ix.cmbSystems.cityCodes[ix.cmbSystems.GetCityCode()].name .. " ::>")
            s:SetTextColor(ix.cmbSystems.cityCodes[ix.cmbSystems.GetCityCode()].color or color_white)
        end
    end
end

vgui.Register("ix.CMB.HUD", HUD, "Panel")

if ( IsValid(ix.gui.combineHUD) ) then
    ix.gui.combineHUD:Remove()
    ix.gui.combineHUD = nil

    ix.gui.combineHUD = vgui.Create("ix.CMB.HUD")
end