local PANEL = {}
local padding = ScreenScale(8)

function PANEL:Init()
    if ( IsValid(ix.gui.customVendor) ) then
        self:Remove()
    end

    local vendorUse = localPlayer:GetNetVar("ixVendorUse", nil)

    if not ( IsValid(vendorUse) ) then
        self:Remove()
    end

    if not ( localPlayer:GetCharacter() ) then
        self:Remove()
    end

    ix.gui.customVendor = self

    self:SetSize(scrW, scrH)
    self:MakePopup()

    self.leftPanel = self:Add("DScrollPanel")
    self.leftPanel:Dock(LEFT)
    self.leftPanel:SetWide(self:GetWide() * 0.25)
    self.leftPanel.Paint = function(s, w, h)
        surface.SetDrawColor(Color(10, 10, 10, 200))
        surface.DrawRect(0, 0, w, h)
        
        ix.util.DrawBlur(s, 1)
    end

    self.closeButton = self.leftPanel:Add("ixMenuButton")
    self.closeButton:Dock(TOP)
    self.closeButton:SetText("Close")
    self.closeButton:SizeToContents()
    self.closeButton.DoClick = function()
        self:Remove()
    end

    for k, v in pairs(ix.vendor.list[vendorUse:GetVendorID()].items) do
        local itemData = ix.item.Get(k)

        if not ( itemData ) then
            ErrorNoHalt("[Helix] Invalid Vendor Item: " .. k .. "\n")

            continue
        end

        local corePanel = self.leftPanel:Add("DScrollPanel")
        corePanel:Dock(TOP)
        corePanel:DockMargin(0, 3, 0, 0)
        corePanel:SetTall(padding * 8)
        corePanel.Paint = function(s, w, h)
            surface.SetDrawColor(Color(0, 0, 0, 200))
            surface.DrawRect(0, 0, w, h)
        end

        local nameLabel = corePanel:Add("DLabel")
        nameLabel:Dock(TOP)
        nameLabel:DockMargin(0, 5, 0, 0)
        nameLabel:SetWrap(true)
        nameLabel:SetText(itemData.name)
        nameLabel:SetFont("ixMediumLightFont")
        nameLabel:SetAutoStretchVertical(true)

        if ( itemData.description and string.len(itemData.description) != 0 ) then
            local descLabel = corePanel:Add("DLabel")
            descLabel:Dock(TOP)
            descLabel:DockMargin(0, 2, 0, 0)
            descLabel:SetWrap(true)
            descLabel:SetText(itemData.description)
            descLabel:SetFont("ixSmallFont")
            descLabel:SetAutoStretchVertical(true)
        end

        local priceLabel = corePanel:Add("DLabel")
        priceLabel:Dock(TOP)
        priceLabel:DockMargin(0, 10, 0, 0)
        priceLabel:SetWrap(true)
        priceLabel:SetText("Price: " .. (v.price == 0 and "Free" or v.price))
        priceLabel:SetFont("ixMediumLightFont")
        priceLabel:SetAutoStretchVertical(true)

        local button = corePanel:Add("ixMenuButton")
        button:Dock(TOP)
        button:SetText("Purchase")
        button:SizeToContents()
        button.DoClick = function()
            if ( v.canPurchase and not v.canPurchase(localPlayer) ) then
                return
            end

            if ( v.price and v.price > 0 ) then
                if not ( localPlayer:GetCharacter():HasMoney(v.price) ) then
                    localPlayer:Notify("You don't have enough money to purchase this item.")

                    return
                end
            end

            if ( v.onPurchase ) then
                v.onPurchase(localPlayer)
            end

            net.Start("ix.CustomVendor.Purchase")
                net.WriteString(k)
            net.SendToServer()
        end
    end
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