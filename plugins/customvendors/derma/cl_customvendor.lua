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

    if not ( IsValid(localPlayer) ) then
        self:Remove()
    end

    if not ( localPlayer:GetCharacter() ) then
        self:Remove()
    end

    if not ( ix.vendor.list[vendorUse:GetVendorID()] ) then
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

    if ( ix.vendor.list[vendorUse:GetVendorID()].sell ) then
        self.rightPanel = self:Add("DScrollPanel")
        self.rightPanel:Dock(RIGHT)
        self.rightPanel:SetWide(self:GetWide() * 0.25)
        self.rightPanel.Paint = function(s, w, h)
            surface.SetDrawColor(Color(10, 10, 10, 200))
            surface.DrawRect(0, 0, w, h)
            
            ix.util.DrawBlur(s, 1)
        end

        local availableLabel = self.rightPanel:Add("DLabel")
        availableLabel:Dock(TOP)
        availableLabel:DockMargin(0, 5, 0, 0)
        availableLabel:SetText("Available Items")
        availableLabel:SetFont("ixBigFont")
        availableLabel:SetContentAlignment(5)
        availableLabel:SetAutoStretchVertical(true)

        for k, v in pairs(ix.vendor.list[vendorUse:GetVendorID()].sell) do
            local itemData = ix.item.Get(k)

            if not ( itemData ) then
                ErrorNoHalt("[Helix] Invalid Vendor Item: " .. k .. "\n")

                continue
            end

            if ( v.canSell and not v["canSell"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) ) then
                continue
            end

            local inv = localPlayer:GetCharacter():GetInventory()

            if not ( inv:HasItem(k) ) then
                continue
            end

            local corePanel = self.rightPanel:Add("DScrollPanel")
            corePanel:Dock(TOP)
            corePanel:DockMargin(0, 3, 0, 0)
            corePanel:SetTall(padding * 7)
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
            priceLabel:SetText("Price: " .. ( ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 ) == 0 and "Free" or ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 )))
            priceLabel:SetFont("ixMediumLightFont")
            priceLabel:SetAutoStretchVertical(true)

            local button = corePanel:Add("ixMenuButton")
            button:Dock(TOP)
            button:SetText("Sell")
            button:SizeToContents()
            button.DoClick = function()
                net.Start("ix.CustomVendor.Sell")
                    net.WriteString(k)
                net.SendToServer()
            end
        end

        local unavailableLabel = self.rightPanel:Add("DLabel")
        unavailableLabel:Dock(TOP)
        unavailableLabel:DockMargin(0, 5, 0, 0)
        unavailableLabel:SetText("Unavailable Items")
        unavailableLabel:SetFont("ixBigFont")
        unavailableLabel:SetContentAlignment(5)
        unavailableLabel:SetAutoStretchVertical(true)

        for k, v in pairs(ix.vendor.list[vendorUse:GetVendorID()].sell) do
            local itemData = ix.item.Get(k)

            if not ( itemData ) then
                ErrorNoHalt("[Helix] Invalid Vendor Item: " .. k .. "\n")

                continue
            end

            if ( v.canSell and v["canSell"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) ) then
                continue
            end

            local inv = localPlayer:GetCharacter():GetInventory()

            if ( inv:HasItem(k) ) then
                continue
            end

            local corePanel = self.rightPanel:Add("DScrollPanel")
            corePanel:Dock(TOP)
            corePanel:DockMargin(0, 3, 0, 0)
            corePanel:SetTall(padding * 7)
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
            priceLabel:SetText("Price: " .. ( ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 ) == 0 and "Free" or ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 )))
            priceLabel:SetFont("ixMediumLightFont")
            priceLabel:SetAutoStretchVertical(true)

            local button = corePanel:Add("ixMenuButton")
            button:Dock(TOP)
            button:SetText("Sell")
            button:SizeToContents()
            button.DoClick = function()
                net.Start("ix.CustomVendor.Sell")
                    net.WriteString(k)
                net.SendToServer()
            end

            button:SetDisabled(true)
        end
    end

    self.closeButton = self.leftPanel:Add("ixMenuButton")
    self.closeButton:Dock(TOP)
    self.closeButton:SetText("Close")
    self.closeButton:SetContentAlignment(5)
    self.closeButton:SizeToContents()
    self.closeButton.DoClick = function()
        self:Remove()
    end

    local availableLabel = self.leftPanel:Add("DLabel")
    availableLabel:Dock(TOP)
    availableLabel:DockMargin(0, 5, 0, 0)
    availableLabel:SetText("Available Items")
    availableLabel:SetFont("ixBigFont")
    availableLabel:SetContentAlignment(5)
    availableLabel:SetAutoStretchVertical(true)

    for k, v in pairs(ix.vendor.list[vendorUse:GetVendorID()].items) do
        local itemData = ix.item.Get(k)

        if not ( itemData ) then
            ErrorNoHalt("[Helix] Invalid Vendor Item: " .. k .. "\n")

            continue
        end

        if ( v.canPurchase and not v["canPurchase"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) ) then
            continue
        end

        if ( ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 ) > 0 ) then
            if ( localPlayer:GetCharacter():HasMoney( ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 ) ) ) then
                continue
            end
        end

        local corePanel = self.leftPanel:Add("DScrollPanel")
        corePanel:Dock(TOP)
        corePanel:DockMargin(0, 3, 0, 0)
        corePanel:SetTall(padding * 7)
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
        priceLabel:SetText("Price: " .. ( ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 ) == 0 and "Free" or ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 )))
        priceLabel:SetFont("ixMediumLightFont")
        priceLabel:SetAutoStretchVertical(true)

        local button = corePanel:Add("ixMenuButton")
        button:Dock(TOP)
        button:SetText("Purchase")
        button:SizeToContents()
        button.DoClick = function()
            net.Start("ix.CustomVendor.Purchase")
                net.WriteString(k)
            net.SendToServer()
        end
    end

    local unavailableLabel = self.leftPanel:Add("DLabel")
    unavailableLabel:Dock(TOP)
    unavailableLabel:DockMargin(0, 5, 0, 0)
    unavailableLabel:SetText("Unavailable Items")
    unavailableLabel:SetFont("ixBigFont")
    unavailableLabel:SetContentAlignment(5)
    unavailableLabel:SetAutoStretchVertical(true)

    for k, v in pairs(ix.vendor.list[vendorUse:GetVendorID()].items) do
        local itemData = ix.item.Get(k)

        if not ( itemData ) then
            ErrorNoHalt("[Helix] Invalid Vendor Item: " .. k .. "\n")

            continue
        end

        if ( v.canPurchase and v["canPurchase"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) ) then
            continue
        end

        if ( ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 ) > 0 ) then
            if ( localPlayer:GetCharacter():HasMoney( ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 ) ) ) then
                continue
            end
        end

        local corePanel = self.leftPanel:Add("DScrollPanel")
        corePanel:Dock(TOP)
        corePanel:DockMargin(0, 3, 0, 0)
        corePanel:SetTall(padding * 7)
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
        priceLabel:SetText("Price: " .. ( ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 ) == 0 and "Free" or ( v.GetPrice and v["GetPrice"](localPlayer, localPlayer:GetNetVar("ixVendorUse", nil)) or 0 )))
        priceLabel:SetFont("ixMediumLightFont")
        priceLabel:SetAutoStretchVertical(true)

        local button = corePanel:Add("ixMenuButton")
        button:Dock(TOP)
        button:SetText("Purchase")
        button:SizeToContents()
        button.DoClick = function()
            net.Start("ix.CustomVendor.Purchase")
                net.WriteString(k)
            net.SendToServer()
        end

        button:SetDisabled(true)
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