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

    if ( localPlayer.CanOverrideView ) then // Helix Thirdperson Plugin Function
        if ( localPlayer:CanOverrideView() ) then
            return false
        end
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

    if ( ix.option.Get("combineOverlayAssets", true) ) then
        for k, v in ipairs(player.GetAll()) do
            if not ( IsValid(v) ) then
                continue
            end

            local char = v:GetCharacter()

            if not ( char ) then
                continue
            end

            if not ( v:Alive() ) then
                continue
            end

            if not ( Schema:IsCombine(v) ) then
                continue
            end

            if ( v:GetPos():Distance(localPlayer:GetPos()) > 300 ) then
                continue
            end

            if ( v == localPlayer ) then
                continue
            end

            local vPos = v:GetPos()
            vPos = vPos - v:GetUp() * -50

            if not ( v.displayAlpha ) then
                v.displayAlpha = 255
            end

            local dist = math.Round(vPos:Distance(localPlayer:GetPos()) / 16, 1)

            local diff = vPos - localPlayer:GetShootPos()

            vPos = vPos:ToScreen()


            if ( localPlayer:GetAimVector():Dot(diff) / diff:Length() >= 0.97 ) then
                v.displayAlpha = Lerp(FrameTime() * 2, v.displayAlpha, 125)
            else
                v.displayAlpha = Lerp(FrameTime() * 2, v.displayAlpha, 255)
            end

            surface.SetFont("ixCombineFont08")
            local textWidth, textHeight = surface.GetTextSize(string.upper("<:: " .. v:Name() .. " ::>"))

            surface.SetDrawColor(Color(10, 10, 10, v.displayAlpha))
            surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, textWidth + 6, padding * 0.9)

            surface.SetDrawColor(ColorAlpha(team.GetColor(v:Team()), v.displayAlpha))
            surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, 2, padding * 0.9)

            draw.SimpleText(string.upper("<:: " .. v:Name() .. " ::>"), "ixCombineFont08", vPos.x, vPos.y, ColorAlpha(team.GetColor(v:Team()), v.displayAlpha), TEXT_ALIGN_CENTER)

            if ( char:GetClass() ) then
                surface.SetFont("ixCombineFont08")
                textWidth, textHeight = surface.GetTextSize("<:: " .. ix.class.list[char:GetClass()].name .. " ::>")

                vPos.y = vPos.y + padding

                surface.SetDrawColor(Color(10, 10, 10, v.displayAlpha))
                surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, textWidth + 6, padding * 0.9)

                surface.SetDrawColor(ColorAlpha(team.GetColor(v:Team()), v.displayAlpha))
                surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, textWidth + 6, 2)

                draw.SimpleText("<:: " .. ix.class.list[char:GetClass()].name .. " ::>", "ixCombineFont08", vPos.x, vPos.y, ColorAlpha(team.GetColor(v:Team()), v.displayAlpha), TEXT_ALIGN_CENTER)
            end

            if ( char:GetRank() ) then
                surface.SetFont("ixCombineFont08")
                textWidth, textHeight = surface.GetTextSize("<:: " .. ix.rank.list[char:GetRank()] .. " ::>")

                vPos.y = vPos.y + padding

                surface.SetDrawColor(Color(10, 10, 10, v.displayAlpha))
                surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, textWidth + 6, padding * 0.9)

                surface.SetDrawColor(ColorAlpha(team.GetColor(v:Team()), v.displayAlpha))
                surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, textWidth + 6, 2)

                draw.SimpleText("<:: " .. ix.rank.list[char:GetRank()] .. " ::>", "ixCombineFont08", vPos.x, vPos.y, ColorAlpha(team.GetColor(v:Team()), v.displayAlpha), TEXT_ALIGN_CENTER)
            end
        end
    end
end

local combineOverlayMat = ix.util.GetMaterial("effects/combine_binocoverlay")

function PLUGIN:RenderScreenspaceEffects()
    if not ( IsValid(localPlayer) ) then
        return
    end

    local char = localPlayer:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( Schema:IsCombine(localPlayer) ) then
        return
    end

    if not ( ix.option.Get("combineOverlay", true) ) then
        return
    end

    if ( localPlayer.CanOverrideView ) then // Helix Thirdperson Plugin Function
        if ( localPlayer:CanOverrideView() ) then
            return
        end
    end

    render.UpdateScreenEffectTexture()

    combineOverlayMat:SetFloat("$alpha", 0.4)
    combineOverlayMat:SetInt("$ignorez", 1)

    render.SetMaterial(combineOverlayMat)
    render.DrawScreenQuad()
end

net.Receive("ix.MakeWaypoint", function()
    local data = net.ReadTable() or {}

    ix.cmbSystems:MakeWaypoint(data)
end)