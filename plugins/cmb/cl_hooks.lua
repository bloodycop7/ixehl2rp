local PLUGIN = PLUGIN

function PLUGIN:ShouldDrawCombineHUD()
    if not ( IsValid(localPlayer) ) then
        return false
    end

    local char = localPlayer:GetCharacter()

    if not ( char ) then
        return false
    end

    if not ( localPlayer:Alive() ) then
        return false
    end

    if not ( Schema:IsCombine(localPlayer) ) then
        return false
    end

    if ( localPlayer:CanOverrideView() ) then
        return false
    end

    return true
end

function PLUGIN:HUDPaint()
    if not ( self:ShouldDrawCombineHUD() ) then
        return
    end

    local padding = ScreenScale(10)
    local x, y = padding, padding
    local code = ix.cmbSystems.cityCodes[ix.cmbSystems:GetCityCode()]

    if ( code ) then
        surface.SetFont("ixCombineFont08")
        local textWidth, textHeight = surface.GetTextSize("<:: City Code : " .. code.name)

        surface.SetDrawColor(Color(10, 10, 10, 200))
        surface.DrawRect(x - 2, y, textWidth + 6, padding * 0.9)

        if ( ix.option.Get("combineHUDTextGlow", true) ) then
            draw.SimpleText("<:: City Code : " .. code.name, "ixCombineFont08-Blurred", x, y, ColorAlpha(code.color or color_white, 170), TEXT_ALIGN_LEFT)
        end

        draw.SimpleText("<:: City Code : " .. code.name, "ixCombineFont08", x, y, code.color or color_white, TEXT_ALIGN_LEFT)
    end

    for k, v in pairs(ix.cmbSystems.waypoints) do
        local wayPos = v.pos:ToScreen()
        local dist = math.Round(v.pos:Distance(localPlayer:GetPos()) / 16, 1)

        local diff = v.pos - localPlayer:GetShootPos()
        
        if not ( v.drawAlpha ) then
            v.drawAlpha = 255
        end

        if ( localPlayer:GetAimVector():Dot(diff) / diff:Length() >= 0.995 ) then
            v.drawAlpha = Lerp(FrameTime() * 2, v.drawAlpha, 25)
        elseif ( dist <= 40 ) then
            v.drawAlpha = Lerp(FrameTime() * 2, v.drawAlpha, 100)
        else
            v.drawAlpha = Lerp(FrameTime() * 2, v.drawAlpha, 255)
        end

        surface.SetFont("ixCombineFont08")
        textWidth, textHeight = surface.GetTextSize(v.text .. " (" .. dist .. "m)")

        surface.SetDrawColor(ColorAlpha(v.rectColor or Color(0, 0, 0), v.drawAlpha))
        surface.DrawRect(wayPos.x - (textWidth / 2), wayPos.y, textWidth, 30)

        surface.SetDrawColor(v.backColor or Color(0, 100, 255))
        surface.DrawRect(wayPos.x - (textWidth / 2), wayPos.y, textWidth, 1)

        draw.SimpleText(v.text .. " (" .. dist .. "m)", "ixCombineFont08", wayPos.x, wayPos.y, ColorAlpha(v.textColor or color_white, v.drawAlpha), TEXT_ALIGN_CENTER)
        
        // Uncomment this if you want to use sentBy value on the waypoint
        --[[
        surface.SetFont("ixCombineHUDWaypointText")
        textWidth, textHeight = surface.GetTextSize(v.sentBy)

        draw.SimpleText(v.sentBy, "ixCombineHUDWaypointText", wayPos.x, wayPos.y - ScreenScale(9), ColorAlpha(v.textColor or color_white, v.drawAlpha), TEXT_ALIGN_CENTER)
        ]]
    end
end

function PLUGIN:RenderScreenspaceEffects()
    if not ( ix.option.Get("combineOverlay", true) ) then
        return
    end


end

net.Receive("ix.MakeWaypoint", function()
    local data = net.ReadTable() or {}

    ix.cmbSystems:MakeWaypoint(data)
end)