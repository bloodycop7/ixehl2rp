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
end