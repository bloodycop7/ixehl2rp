local PANEL = {}

local padding = 8

function PANEL:Init()
    if ( IsValid(ix.gui.changelogs) ) then
        ix.gui.changelogs:Remove()
        ix.gui.changelogs = nil
    end

    self.sysTime = SysTime()
    ix.gui.changelogs = self

    self:Dock(FILL)
    self:DockMargin(padding * 36, padding, padding * 36, padding)

    local returnButton = self:Add("ixMenuButton")
    returnButton:Dock(BOTTOM)
    returnButton:SetText("Return")
    returnButton:SetFont("ixMenuButtonFont")
    returnButton:SetTextColor(color_white)
    returnButton:SetTall(32)
    returnButton:DockMargin(0, 0, 0, 8)
    returnButton.DoClick = function()
        self:Remove()
    end
    returnButton:SizeToContents()

    local text = self:Add("RichText")
    text:Dock(FILL)
    text:DockMargin(0, 0, 0, 8)
    text:SetVerticalScrollbarEnabled(true)
    text:InsertColorChange(255, 255, 255, 255)
    text:SetText("HELLO WORLDy")
end

function PANEL:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.sysTime)
end

vgui.Register("ixChangelogs", PANEL, "EditablePanel")

if ( IsValid(ix.gui.changelogs) ) then
    ix.gui.changelogs:Remove()
    ix.gui.changelogs = nil

    ix.gui.changelogs = vgui.Create("ixChangelogs")
end