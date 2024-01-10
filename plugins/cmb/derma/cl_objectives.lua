local PLUGIN = PLUGIN

local PANEL = {}
local padding = ScreenScale(8)

function PANEL:Init()
    if ( IsValid(ix.gui.cmbObjective) ) then
        self:Remove()
    end

    ix.gui.cmbObjective = self

    self:SetSize(scrW * 0.5, scrH * 0.5)
    self:Center()
    self:MakePopup()

    self.title = self:Add("DLabel")
    self.title:Dock(TOP)
    self.title:DockMargin(padding * 15, 5, padding * 15, 0)
    self.title:SetFont("ixCombineFont14")
    self.title:SetText("Objectives")
    self.title:SetContentAlignment(5)
    self.title:SizeToContents()
    self.title.Paint = function(s, w, h)
        PLUGIN:DrawBox({
            x = 0,
            y = 0,
            w = w,
            h = h,
            rectColor = Color(0, 255, 255),
            backColor = Color(0, 55, 60)
        })
    end

    self.closeButton = self:Add("ixMenuButton")
    self.closeButton:Dock(BOTTOM)
    self.closeButton:DockMargin(5, 5, 5, 0)
    self.closeButton:SetText("Close")
    self.closeButton:SetFont("ixCombineFont12")
    self.closeButton:SetContentAlignment(5)
    self.closeButton:SizeToContents()
    self.closeButton.DoClick = function()
        self:Remove()
    end

    self.scroll = self:Add("DScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(5, 20, 0, 30)
    self.scroll.Paint = function(s, w, h)
        surface.SetDrawColor(Color(30, 30, 30, 240))
        surface.DrawRect(0, 0, w, h)
    end
    
    self:PopulateObjectives()
end

function PANEL:PopulateObjectives()
    self.scroll:Clear()

    for k, v in SortedPairsByMemberValue(ix.cmbSystems.objectives, "priority") do
        local objective = self.scroll:Add("DScrollPanel")
        objective:Dock(TOP)
        objective:SetTall(padding * 6)
        objective:DockMargin(0, 5, 0, 0)

        objective.Paint = function(s, w, h)
            PLUGIN:DrawBox({
                x = 0,
                y = 0,
                w = w,
                h = h,
                rectColor = ( v.priority and Color(255, 165, 0) or color_white ),
                backColor = Color(20, 20, 20, 255)
            })
        end

        local sentBy = objective:Add("DLabel")
        sentBy:Dock(TOP)
        sentBy:DockMargin(5, 5, 5, 0)
        sentBy:SetWrap(true)
        sentBy:SetText("Sent by: " .. v.sentBy)
        sentBy:SetFont("ixCombineFont12")
        sentBy:SetAutoStretchVertical(true)

        local objectiveText = objective:Add("DLabel")
        objectiveText:Dock(TOP)
        objectiveText:DockMargin(5, 5, 5, 0)
        objectiveText:SetWrap(true)
        objectiveText:SetText("Objective: " .. v.text)
        objectiveText:SetFont("ixCombineFont10")
        objectiveText:SetAutoStretchVertical(true)

        local removeButton = objective:Add("ixMenuButton")
        removeButton:Dock(TOP)
        removeButton:SetText("Remove")
        removeButton:SetFont("ixCombineFont08")
        removeButton:SizeToContents()
        removeButton.DoClick = function()
            net.Start("ix.Combine.RemoveObjective")
                net.WriteUInt(k, 8)
            net.SendToServer()

            timer.Simple(0.1, function()
                self:PopulateObjectives()
            end)
        end
    end
end

function PANEL:Paint(w, h)
    PLUGIN:DrawBox({
        x = 0,
        y = 0,
        w = w,
        h = h,
        rectColor = color_white,
        rectWidth = 10,
        backColor = color_black
    })
end

vgui.Register("ix.CMB.Objectives", PANEL, "Panel")

if ( IsValid(ix.gui.cmbObjective) ) then
    ix.gui.cmbObjective:Remove()

    ix.gui.cmbObjective = vgui.Create("ix.CMB.Objectives")
end