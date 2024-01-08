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

function PLUGIN:DrawBox(drawData)
    drawData.x = drawData.x or 0
    drawData.y = drawData.y or 0
    drawData.w = drawData.w or 0
    drawData.h = drawData.h or 0
    drawData.rectWidth = drawData.rectWidth or 10
    drawData.rectHeight = drawData.rectHeight or 1

    drawData.rectColor = drawData.rectColor or Color(255, 255, 255)
    drawData.backColor = drawData.backColor or Color(0, 0, 0)

    surface.SetDrawColor(drawData.backColor)
    surface.DrawRect(drawData.x, drawData.y, drawData.w, drawData.h)

    surface.SetDrawColor(drawData.rectColor)
    surface.DrawRect(drawData.x, drawData.y, drawData.rectWidth, drawData.rectHeight)
    surface.DrawRect((drawData.x + drawData.w) - drawData.rectWidth, drawData.y, drawData.rectWidth, drawData.rectHeight)
    surface.DrawRect((drawData.x + drawData.w) - drawData.rectHeight, drawData.y, drawData.rectHeight, drawData.rectHeight)
    surface.DrawRect(drawData.x + drawData.w - drawData.rectHeight, drawData.y, drawData.rectHeight, drawData.rectWidth)
    
    surface.DrawRect(drawData.x, drawData.y, drawData.rectHeight, drawData.rectWidth)
    surface.DrawRect(drawData.x, (drawData.y + drawData.h) - drawData.rectWidth, drawData.rectHeight, drawData.rectWidth)
    surface.DrawRect(drawData.x, (drawData.y + drawData.h) - drawData.rectHeight, drawData.rectWidth, drawData.rectHeight)

    surface.DrawRect(drawData.x + drawData.w - drawData.rectWidth, (drawData.y + drawData.h) - drawData.rectHeight, drawData.rectWidth, drawData.rectHeight)
    surface.DrawRect(drawData.x + drawData.w - drawData.rectHeight, (drawData.y + drawData.h) - drawData.rectWidth, drawData.rectHeight, drawData.rectWidth)
end

function PLUGIN:HUDPaint()
    if not ( self:ShouldDrawCombineHUD() ) then
        return
    end

    local padding = ScreenScale(10)
    local x, y = padding, padding
    local code = ix.cmbSystems.cityCodes[ix.cmbSystems:GetCityCode()]

    if ( code ) then
        surface.SetFont("ixCombineFont10")
        local textWidth, textHeight = surface.GetTextSize("<:: City Code : " .. code.name)

        self:DrawBox({
            x = x - 2,
            y = y,
            w = textWidth * 1.05,
            h = textHeight * 1.05,
            rectColor = code.color or color_white,
            backColor = Color(0, 20, 25, 225)
        })

        draw.SimpleText("<:: City Code : " .. code.name, "ixCombineFont10", x, y, color_white, TEXT_ALIGN_LEFT)
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

        self:DrawBox({
            x = wayPos.x - (textWidth / 2),
            y = wayPos.y,
            w = textWidth,
            h = 30,
            rectColor = v.rectColor or Color(0, 255, 255),
            backColor = Color(20, 20, 25, v.drawAlpha)
        })

        draw.SimpleText(v.text .. " (" .. dist .. ")", "ixCombineFont08", wayPos.x, wayPos.y, ColorAlpha(v.textColor or color_white, v.drawAlpha), TEXT_ALIGN_CENTER)
        
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

            if ( v:GetPos():Distance(localPlayer:GetPos()) > 400 ) then
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

            if ( localPlayer:GetAimVector():Dot(diff) / diff:Length() >= 0.985 ) then
                v.displayAlpha = Lerp(FrameTime() * 2, v.displayAlpha, 125)
            else
                v.displayAlpha = Lerp(FrameTime() * 2, v.displayAlpha, 255)
            end

            surface.SetFont("ixCombineFont08")
            local textWidth, textHeight = surface.GetTextSize(string.upper("<:: " .. v:Name() .. " ::>"))

            self:DrawBox({
                x = vPos.x - (textWidth / 2) - 2,
                y = vPos.y,
                w = textWidth + 6,
                h = padding * 0.9,
                rectColor = team.GetColor(v:Team()),
                backColor = Color(0, 0, 0, v.displayAlpha)
            })

            draw.SimpleText(string.upper("<:: " .. v:Name() .. " ::>"), "ixCombineFont08", vPos.x, vPos.y, ColorAlpha(color_white, v.displayAlpha), TEXT_ALIGN_CENTER)

            if not ( Schema:IsCP(v) ) then // Remove this line and the end at line 162 if you want to use classes for CPs
                if ( char:GetClass() ) then
                    surface.SetFont("ixCombineFont08")
                    textWidth, textHeight = surface.GetTextSize("<:: " .. ix.class.list[char:GetClass()].name .. " ::>")

                    vPos.y = vPos.y + padding

                    self:DrawBox({
                        x = vPos.x - (textWidth / 2) - 2,
                        y = vPos.y,
                        w = textWidth + 6,
                        h = padding * 0.9,
                        rectColor = team.GetColor(v:Team()),
                        backColor = Color(0, 0, 0, v.displayAlpha)
                    })

                    draw.SimpleText("<:: " .. ix.class.list[char:GetClass()].name .. " ::>", "ixCombineFont08", vPos.x, vPos.y, ColorAlpha(color_white, v.displayAlpha), TEXT_ALIGN_CENTER)
                end
            end

            if ( char:GetRank() ) then
                surface.SetFont("ixCombineFont08")
                textWidth, textHeight = surface.GetTextSize("<:: " .. ix.rank.list[char:GetRank()].name .. " ::>")

                vPos.y = vPos.y + padding

                self:DrawBox({
                    x = vPos.x - (textWidth / 2) - 2,
                    y = vPos.y,
                    w = textWidth + 6,
                    h = padding * 0.9,
                    rectColor = team.GetColor(v:Team()),
                    backColor = Color(0, 0, 0, v.displayAlpha)
                })

                draw.SimpleText("<:: " .. ix.rank.list[char:GetRank()].name .. " ::>", "ixCombineFont08", vPos.x, vPos.y, ColorAlpha(color_white, v.displayAlpha), TEXT_ALIGN_CENTER)
            end
        end
    end

    local wep = localPlayer:GetActiveWeapon()

    if ( IsValid(wep) ) then
        if ( wep:Clip1() != -1 ) then
            surface.SetFont("ixCombineFont14")
            local textWidth, textHeight = surface.GetTextSize(wep:Clip1() .. " / " .. localPlayer:GetAmmoCount(wep:GetPrimaryAmmoType()))

            self:DrawBox({
                x = ScrW() - textWidth - padding * 1.3,
                y = ScrH() - textHeight - padding * 0.5,
                w = textWidth * 1.1,
                h = textHeight * 1.05,
                rectColor = Color(255, 255, 255),
                backColor = Color(30, 20, 25, 200)
            })

            draw.DrawText(wep:Clip1() .. " / " .. localPlayer:GetAmmoCount(wep:GetPrimaryAmmoType()), "ixCombineFont14", scrW - padding * 1.2, scrH - padding * 1.8, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
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

function PLUGIN:SetupOutlines()
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

    if not ( localPlayer:Alive() ) then
        return
    end

    if ( localPlayer.CanOverrideView ) then // Helix Thirdperson Plugin Function
        if ( localPlayer:CanOverrideView() ) then
            return
        end
    end

    if ( ix.option.Get("combineOutlineNPCs", true) ) then
        for k, v in ipairs(ents.GetAll()) do
            if not ( IsValid(v) ) then
                continue
            end

            if not ( v:IsNPC() ) then
                continue
            end

            if not ( v:Health() > 0 ) then
                continue
            end

            if ( v:GetClass():find("generic*") ) then
                continue
            end

            if not ( v:GetNWEntity("deployedBy", nil) == NULL or v:GetNWEntity("deployedBy", nil) == nil ) then
                continue
            end

            if not ( ix.relationships.CombineNPCs[v:GetClass()] ) then
                continue
            end

            local outlineColor = hook.Run("GetFriendlyOutlineColor", v) or nil

            if ( outlineColor == nil ) then
                outlineColor = Color(0, 255, 255)
            end

            ix.outline.Add(v, outlineColor)
        end

        for k, v in ipairs(ents.GetAll()) do
            if not ( IsValid(v) ) then
                continue
            end

            if not ( v:IsNPC() ) then
                continue
            end

            if not ( v:Health() > 0 ) then
                continue
            end

            if ( ix.relationships.CombineNPCs[v:GetClass()] ) then
                continue
            end

            if ( v:GetClass():find("generic*") ) then
                continue
            end

            local outlineColor = hook.Run("GetEnemyOutlineColor", v)

            if ( outlineColor == nil ) then
                outlineColor = Color(255, 0, 0)
            end

            ix.outline.Add(v, outlineColor, 2)
        end
    end

    if ( ix.option.Get("combineOutlineAssets", true) ) then
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

            if ( ix.option.Get("combineOutlineAssetsTeamOnly", false) ) then
                if not ( v:Team() == localPlayer:Team() ) then
                    continue
                end
            else
                if not ( Schema:IsCombine(v) ) then
                    continue
                end
            end

            if ( v == localPlayer ) then
                continue
            end

            local outlineColor = hook.Run("GetPlayerOutlineColor", v)

            if ( outlineColor == nil ) then
                outlineColor = team.GetColor(v:Team())
            end

            ix.outline.Add(v, outlineColor)
        end
    end

    if ( ix.option.Get("combineOutlineDeployables", true) ) then
        if ( #char:GetData("deployedEntities", {}) > 0 ) then
            for k, v in pairs(char:GetData("deployedEntities", {})) do
                local ent = Entity(v)

                if not ( IsValid(ent) ) then
                    continue
                end

                if not ( ent:IsNPC() or ent:GetClass() == "npc_grenade_frag" ) then
                    continue
                end

                if not ( ent:Health() > 0 or ent:GetClass() == "npc_grenade_frag" ) then
                    continue
                end

                if ( ent:GetClass():find("generic*") ) then
                    continue
                end

                local outlineColor = hook.Run("GetEntityOutlineColor", ent)

                if ( outlineColor == nil ) then
                    outlineColor = ix.faction.Get(localPlayer:Team()).color or Color(200, 200, 200, 200)
                end

                if ( ent:GetClass() == "npc_grenade_frag" ) then
                    outlineColor = Color(255, 0, 0)
                end

                ix.outline.Add(ent, outlineColor)
            end
        end
    end
end

function PLUGIN:GetPlayerOutlineColor(target)
    if ( Schema:IsOTA(target) ) then
        local model = string.lower(target:GetModel())
        if ( model == "models/combine_soldier_prisonguard.mdl" and target:GetSkin() == 0 ) then
            return Color(255, 210, 0)
        elseif ( model == "models/combine_soldier_prisonguard.mdl" and target:GetSkin() == 1 ) then
            return Color(255, 65, 0)
        elseif ( model == "models/combine_soldier.mdl" and target:GetSkin() == 0 ) then
            return Color(0, 120, 255)
        elseif ( model == "models/combine_soldier.mdl" and target:GetSkin() == 1 ) then
            return Color(145, 60, 0)
        elseif ( model == "models/combine_super_soldier.mdl" ) then
            return Color(255, 255, 255)
        end
    end
end

function PLUGIN:GetFriendlyOutlineColor(ent)
    if not ( IsValid(ent) ) then
        return nil
    end

    if not ( ent:IsNPC() ) then
        return nil
    end

    if not ( ent:Health() > 0 ) then
        return nil
    end

    if ( ent:GetClass() == "npc_combine_s" ) then
        local model = string.lower(ent:GetModel())
        if ( model == "models/combine_soldier_prisonguard.mdl" and ent:GetSkin() == 0 ) then
            return Color(255, 210, 0)
        elseif ( model == "models/combine_soldier_prisonguard.mdl" and ent:GetSkin() == 1 ) then
            return Color(255, 65, 0)
        elseif ( model == "models/combine_soldier.mdl" and ent:GetSkin() == 0 ) then
            return Color(0, 120, 255)
        elseif ( model == "models/combine_soldier.mdl" and ent:GetSkin() == 1 ) then
            return Color(145, 60, 0)
        elseif ( model == "models/combine_super_soldier.mdl" ) then
            return Color(255, 255, 255)
        end
    end

    if ( ent:GetClass() == "npc_combinegunship" ) then
        return Color(255, 255, 255)
    end

    if ( ent:GetClass() == "npc_helicopter" ) then
        return Color(255, 255, 255)
    end

    if ( ent:GetClass() == "npc_strider" ) then
        return Color(255, 255, 255)
    end

    if ( ent:GetClass() == "npc_turret_ceiling" ) then
        return Color(255, 90, 90)
    end

    if ( ent:GetModel() == "models/ez2npc/police.mdl" and ent:GetSkin() == 1 ) then
        return Color(0, 205, 255)
    elseif ( ent:GetModel() == "models/ez2npc/police.mdl" and ent:GetSkin() == 2 ) then
        return Color(200, 70, 70)
    elseif ( ent:GetClass() == "npc_metropolice" ) then
        return Color(0, 120, 200)
    end
end 

net.Receive("ix.MakeWaypoint", function()
    local data = net.ReadTable() or {}

    ix.cmbSystems:MakeWaypoint(data)
end)

net.Receive("ix.cmbSystems.SyncSquads", function()
    local data = net.ReadTable() or {}

    ix.cmbSystems.squads = data
end)