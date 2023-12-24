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

    return true
end

function PLUGIN:HUDPaint()
    if not ( self:ShouldDrawCombineHUD() ) then
        return
    end

    local padding = ScreenScale(10)
    local x, y = padding, padding

    surface.SetDrawColor(Color(0, 0, 0, 255))
    surface.DrawRect(x, y, padding * 12, padding * 3)

    local hp = localPlayer:Health()
    draw.SimpleText("<:: Vitals: " .. hp, "ixCombineHUDFont", x, y, color_white, TEXT_ALIGN_LEFT)

    y = y + ScreenScale(10)

    local vec = localPlayer:GetPos()

    draw.SimpleText("<:: Vector: " .. math.Round(vec.x, 1) .. ", " .. math.Round(vec.y, 1) .. ", " .. math.Round(vec.z, 1), "ixCombineHUDFont", x, y, color_white, TEXT_ALIGN_LEFT)

    local code = ix.cmbSystems.cityCodes[ix.cmbSystems:GetCityCode()]

    if ( code ) then
        local lastCityCode = code.name
        y = y + ScreenScale(10)

        draw.SimpleText("<:: City Code: " .. code.name, "ixCombineHUDFont", x, y, code.color or color_white, TEXT_ALIGN_LEFT)
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

        surface.SetFont("ixCombineHUDWaypointText")
        local textWidth, textHeight = surface.GetTextSize(v.text .. " (" .. dist .. "m)")

        surface.SetDrawColor(ColorAlpha(v.rectColor or Color(0, 0, 0), v.drawAlpha))
        surface.DrawRect(wayPos.x - (textWidth / 2), wayPos.y, textWidth, 30)

        surface.SetDrawColor(v.backColor or Color(0, 100, 255))
        surface.DrawRect(wayPos.x - (textWidth / 2), wayPos.y, textWidth, 1)

        draw.SimpleText(v.text .. " (" .. dist .. "m)", "ixCombineHUDWaypointText", wayPos.x, wayPos.y, ColorAlpha(v.textColor or color_white, v.drawAlpha), TEXT_ALIGN_CENTER)
        
        surface.SetFont("ixCombineHUDWaypointText")
        textWidth, textHeight = surface.GetTextSize(v.sentBy)

        draw.SimpleText(v.sentBy, "ixCombineHUDWaypointText", wayPos.x, wayPos.y - ScreenScale(9), ColorAlpha(v.textColor or color_white, v.drawAlpha), TEXT_ALIGN_CENTER)
    end
end