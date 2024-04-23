local PANEL = {}
local padding = ScreenScale(8)

function PANEL:Init()
    if ( IsValid(ix.gui.customVendor) ) then
        self:Remove()
    end

    local ply = LocalPlayer()

    if not ( IsValid(ply) ) then
        self:Remove()
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    self.vendorUse = ply:GetNetVar("ixVendorUse", nil)

    if not ( IsValid(self.vendorUse) ) then
        self:Remove()
    end

    self.vendorData = PLUGIN.list[self.vendorUse:GetVendorID()]

    if not ( self.vendorData ) then
        self:Remove()
    end

    ix.gui.customVendor = self

    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self:DockPadding(padding * 0.7, padding * 0.5, padding * 0.7, padding * 0.5)

    self.sysTime = SysTime()

    self.topPanel = self:Add("Panel")
    self.topPanel:Dock(TOP)
    self.topPanel:SetTall(ScrH() * 0.045)

    self.closeButton = self.topPanel:Add("ixMenuButton")
    self.closeButton:Dock(RIGHT)
    self.closeButton:SetWide(self:GetWide() * 0.03)
    self.closeButton:SetText("X")
    self.closeButton:SetFont("ixMenuButtonFont")
    self.closeButton:SetContentAlignment(5)
    self.closeButton.DoClick = function()
        self:Remove()
    end

    self.title = self.topPanel:Add("DLabel")
    self.title:Dock(LEFT)
    self.title:SetContentAlignment(5)
    self.title:SetFont("ixSubTitleFont")
    self.title:SetText(self.vendorData.name)
    self.title:SizeToContents()
    self.title.Paint = function(s, w, h)
        surface.SetMaterial(ix.gui.gradients["left"])
        surface.SetDrawColor(ix.config.Get("color"))

        surface.DrawTexturedRect(0, 0, w * 1.2, 2)
        surface.DrawTexturedRect(0, h - 2, w * 1.2, 2)

        surface.SetMaterial(ix.gui.gradients["left"])
        surface.SetDrawColor(Color(10, 10, 10, 150))
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.categories = {}
    self.categories["All"] = {}

    for k, v in SortedPairs(self.vendorData.items) do
        self.categories["All"][k] = v

        if not ( v.category ) then 
            continue 
        end

        if not ( self.categories[v.category] ) then
            self.categories[v.category] = {}
        end

        if not ( self.categories[v.category][k] ) then
            self.categories[v.category][k] = v
        end
    end

    self.categoryList = self:Add("DHorizontalScroller")
    self.categoryList:Dock(TOP)
    self.categoryList:SetTall(ScrH() * 0.045)
    self.categoryList:SetOverlap(-padding * 0.5)
    self.categoryList:DockMargin(0, 2, 0, 0)

    for k, v in SortedPairs(self.categories) do
        local category = self.categoryList:Add("DButton")
        category:SetWide(ScrW() * 0.1)
        category:SetText(k)
        category:SetFont("ixMenuButtonFont")
        category:SetTextColor(Color(255, 255, 255))
        category:SetContentAlignment(5)
        category.Paint = function(s, w, h)
            surface.SetMaterial(ix.gui.gradients["left"])
            surface.SetDrawColor(Color(10, 10, 10, 150))
            surface.DrawTexturedRect(0, 0, w, h)

            if ( s:IsHovered() or s:IsDown() ) then
                surface.SetDrawColor(ix.config.Get("color"))
                surface.DrawTexturedRect(0, 0, w, h)
            end
        end

        category.DoClick = function()
            self:PopulateCategory(k)
        end

        category:SizeToContents()

        self.categoryList:AddPanel(category)
        self.categoryList:SizeToContents()
    end

    self.leftPanel = self:Add("DScrollPanel")
    self.leftPanel:Dock(LEFT)
    self.leftPanel:SetWide(ScrW() * 0.3)
    self.leftPanel:DockMargin(0, 5, 0, 0)
    self.leftPanel.Paint = function(s, w, h)
        surface.SetMaterial(ix.gui.gradients["left"])
        surface.SetDrawColor(Color(10, 10, 10, 150))
        surface.DrawTexturedRect(0, 0, w, h)
    end

    if ( self.vendorData.sell ) then
        self.rightPanel = self:Add("DScrollPanel")
        self.rightPanel:Dock(RIGHT)
        self.rightPanel:SetWide(ScrW() * 0.3)
        self.rightPanel:DockMargin(0, 5, 0, 0)
        self.rightPanel.Paint = function(s, w, h)
            surface.SetMaterial(ix.gui.gradients["right"])
            surface.SetDrawColor(Color(10, 10, 10, 150))
            surface.DrawTexturedRect(0, 0, w, h)
        end

        for k, v in SortedPairs(self.vendorData.sell) do
            local vendorItemData = self.vendorData.items[k]

            if not ( vendorItemData ) then
                return
            end

            local itemData = ix.item.list[k]

            if not ( itemData ) then
                return
            end

            local item = self.rightPanel:Add("DScrollPanel")
            item:Dock(TOP)
            item:SetTall(padding * 5)
            item:DockMargin(0, 5, 0, 0)
            item.Paint = function(s, w, h)
                surface.SetMaterial(ix.gui.gradients["right"])
                surface.SetDrawColor(Color(10, 10, 10, 150))
                surface.DrawTexturedRect(0, 0, w, h)
            end

            local itemLabelName = item:Add("DLabel")
            itemLabelName:Dock(TOP)
            itemLabelName:DockMargin(2, 0, 0, 0)
            itemLabelName:SetContentAlignment(5)
            itemLabelName:SetFont("ixMenuButtonFont")
            itemLabelName:SetWrap(true)
            itemLabelName:SetText(itemData.name)
            itemLabelName:SetAutoStretchVertical(true)

            local itemLabelDesc = item:Add("DLabel")
            itemLabelDesc:Dock(TOP)
            itemLabelDesc:DockMargin(2, 0, 0, 0)
            itemLabelDesc:SetContentAlignment(5)
            itemLabelDesc:SetFont("ixMenuButtonFontSmall")
            itemLabelDesc:SetWrap(true)
            itemLabelDesc:SetText(itemData.description)
            itemLabelDesc:SetAutoStretchVertical(true)

            local purchase = item:Add("ixMenuButton")
            purchase:Dock(TOP)
            purchase:SetTall(padding * 1.5)
            purchase:SetText("Sell")
            purchase:SetFont("ixMenuButtonFontSmall")
            purchase:DockMargin(0, 13, 0, 0)
            purchase.DoClick = function()
                net.Start("ix.CustomVendor.Sell")
                    net.WriteString(k)
                net.SendToServer()
            end
        end
    end

    self:PopulateCategory("All")
end

function PANEL:PopulateCategory(category)
    local ply = LocalPlayer()

    if not ( IsValid(ply) ) then
        self:Remove()
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( IsValid(self.vendorUse) ) then
        self:Remove()
    end

    if not ( self.vendorData ) then
        self:Remove()
    end

    if not ( self.leftPanel ) then
        return
    end

    self.leftPanel:Clear()

    timer.Simple(0.1, function()
        for k, v in SortedPairs(self.categories[category]) do
            local vendorItemData = self.vendorData.items[k]

            if not ( vendorItemData ) then
                return
            end

            local itemData = ix.item.list[k]

            if not ( itemData ) then
                return
            end

            local item = self.leftPanel:Add("DScrollPanel")
            item:Dock(TOP)
            item:SetTall(padding * 5)
            item:DockMargin(0, 5, 0, 0)
            item.Paint = function(s, w, h)
                surface.SetMaterial(ix.gui.gradients["left"])
                surface.SetDrawColor(Color(10, 10, 10, 150))
                surface.DrawTexturedRect(0, 0, w, h)
            end

            local itemLabelName = item:Add("DLabel")
            itemLabelName:Dock(TOP)
            itemLabelName:DockMargin(10, 0, 0, 0)
            itemLabelName:SetContentAlignment(5)
            itemLabelName:SetFont("ixMenuButtonFont")
            itemLabelName:SetWrap(true)
            itemLabelName:SetText(itemData.name)
            itemLabelName:SetAutoStretchVertical(true)

            local itemLabelDesc = item:Add("DLabel")
            itemLabelDesc:Dock(TOP)
            itemLabelDesc:DockMargin(10, 0, 0, 0)
            itemLabelDesc:SetContentAlignment(5)
            itemLabelDesc:SetFont("ixMenuButtonFontSmall")
            itemLabelDesc:SetWrap(true)
            itemLabelDesc:SetText(itemData.description)
            itemLabelDesc:SetAutoStretchVertical(true)

            local itemLabelPrice = item:Add("DLabel")
            itemLabelPrice:Dock(TOP)
            itemLabelPrice:DockMargin(10, 0, 0, 0)
            itemLabelPrice:SetContentAlignment(5)
            itemLabelPrice:SetFont("ixMenuButtonFontSmall")
            itemLabelPrice:SetWrap(true)
            itemLabelPrice:SetText("Cost: " .. ( vendorItemData.GetPrice and vendorItemData["GetPrice"](ply, self.vendorUse) or 0 ))
            itemLabelPrice:SetAutoStretchVertical(true)


            local purchase = item:Add("ixMenuButton")
            purchase:Dock(TOP)
            purchase:SetTall(padding * 1.5)
            purchase:SetText("Purchase")
            purchase:SetFont("ixMenuButtonFontSmall")
            purchase:DockMargin(0, 13, 0, 0)
            purchase.DoClick = function()
                net.Start("ix.CustomVendor.Purchase")
                    net.WriteString(k)
                net.SendToServer()
            end
        end
    end)
end

function PANEL:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.sysTime)
end

function PANEL:OnRemove()
    net.Start("ix.CustomVendor.CloseMenu")
    net.SendToServer()
end

vgui.Register("ixCustomVendor", PANEL, "Panel")

if ( IsValid(ix.gui.customVendor) ) then
    ix.gui.customVendor:Remove()

    ix.gui.customVendor = vgui.Create("ixCustomVendor")
end