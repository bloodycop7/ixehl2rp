local PLUGIN = PLUGIN

function PLUGIN:ShouldDrawCombineHUD()
    if not ( IsValid(LocalPlayer()) ) then -- this might cause chaos
        return false
    end

    local ply = LocalPlayer() -- localize global variable but keep the name

    if not ( IsValid(ply) ) then
        return false
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return false
    end

    if not ( ply:Alive() ) then
        return false
    end

    if not ( Schema:IsCombine(ply) ) then
        return false
    end

    if ( ply.CanOverrideView ) then // Helix Thirdperson Plugin Function
        if ( ply:CanOverrideView() ) then
            return false
        end
    end

    if ( IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_camera" ) then
        return false
    end

    return true
end

local colWhite = Color(255,255,255)
local colWhite2 = Color(200,200,200,200)
local colBlack = Color(0,0,0)
local colRed = Color(255,0,0)
local Color = Color -- this function is quite expensive and gets called A LOT in this script
local surface_DrawRect = surface.DrawRect -- this function gets called a lot so why not to localize it a bit

function PLUGIN:DrawBox(drawData)
    drawData.x = drawData.x or 0
    drawData.y = drawData.y or 0
    drawData.w = drawData.w or 0
    drawData.h = drawData.h or 0
    drawData.rectWidth = drawData.rectWidth or 7
    drawData.rectHeight = drawData.rectHeight or 2

    drawData.rectColor = drawData.rectColor or colWhite
    drawData.backColor = drawData.backColor or colBlack
    drawData.rectBackAlpha = drawData.rectBackAlpha or 50
    drawData.rectBackThickness = drawData.rectBackThickness or 1

    surface.SetDrawColor(drawData.backColor)
    surface_DrawRect(drawData.x, drawData.y, drawData.w, drawData.h)

    surface.SetDrawColor(drawData.rectColor)
    surface_DrawRect(drawData.x, drawData.y, drawData.rectWidth, drawData.rectHeight)
    surface_DrawRect((drawData.x + drawData.w) - drawData.rectWidth, drawData.y, drawData.rectWidth, drawData.rectHeight)
    surface_DrawRect((drawData.x + drawData.w) - drawData.rectHeight, drawData.y, drawData.rectHeight, drawData.rectHeight)
    surface_DrawRect(drawData.x + drawData.w - drawData.rectHeight, drawData.y, drawData.rectHeight, drawData.rectWidth)

    surface_DrawRect(drawData.x, drawData.y, drawData.rectHeight, drawData.rectWidth)
    surface_DrawRect(drawData.x, (drawData.y + drawData.h) - drawData.rectWidth, drawData.rectHeight, drawData.rectWidth)
    surface_DrawRect(drawData.x, (drawData.y + drawData.h) - drawData.rectHeight, drawData.rectWidth, drawData.rectHeight)

    surface_DrawRect(drawData.x + drawData.w - drawData.rectWidth, (drawData.y + drawData.h) - drawData.rectHeight, drawData.rectWidth, drawData.rectHeight)
    surface_DrawRect(drawData.x + drawData.w - drawData.rectHeight, (drawData.y + drawData.h) - drawData.rectWidth, drawData.rectHeight, drawData.rectWidth)

    surface.SetDrawColor(ColorAlpha(drawData.rectColor, drawData.rectBackAlpha))
    surface.DrawOutlinedRect(drawData.x, drawData.y, drawData.w, drawData.h, drawData.rectBackThickness)
end

function PLUGIN:Think()
    if not ( IsValid(LocalPlayer()) ) then
        return
    end

    local ply = LocalPlayer()

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( Schema:IsCombine(ply) ) then
        return
    end

    for k, v in ipairs(PLUGIN.waypoints) do
        if ( v.duration and v.duration < CurTime() ) then
            PLUGIN.waypoints[k] = nil
        end
    end
end

function PLUGIN:HUDPaint()
    if not ( self:ShouldDrawCombineHUD() ) then
        return
    end

    local ply = LocalPlayer()

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    local padding = ScreenScale(8)
    local code = PLUGIN.CityCodes.Stored[PLUGIN.CityCodes:Get()]

    if ( code ) then
        surface.SetFont("ixCombineFont10")
        local textWidth, textHeight = surface.GetTextSize("<:: City Code : " .. code.name)

        self:DrawBox({
            x = padding - textWidth * 0.01,
            y = padding,
            w = textWidth * 1.05,
            h = textHeight * 1.05,
            rectColor = code.color or color_white,
            backColor = colBlack,
        })

        draw.SimpleTextOutlined("<:: City Code : " .. code.name, "ixCombineFont10", padding, padding, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
    end

    if ( ix.option.Get("combineOverlaySquad", true) ) then
        if ( char:GetData("squadID", -1) != -1 ) then
            local squad = PLUGIN.Squads.Stored[char:GetData("squadID", -1)]

            if ( squad ) then
                surface.SetFont("ixCombineFont10")
                local textWidth, textHeight = surface.GetTextSize("<:: " .. squad.name)

                self:DrawBox({
                    x = padding - textWidth * 0.01,
                    y = padding * 2.5,
                    w = textWidth * 1.05,
                    h = textHeight * 1.05,
                    rectColor = color_white,
                    backColor = colBlack
                })

                draw.SimpleText("<:: " .. squad.name, "ixCombineFont10", padding, padding * 2.5, color_white, TEXT_ALIGN_LEFT)

                local paddingOffset = 0
                for k, v in ipairs(squad.members) do
                    if not ( IsValid(v) ) then
                        continue
                    end

                    local vChar = v:GetCharacter()

                    if not ( vChar ) then
                        continue
                    end

                    local playerText = v:Nick()

                    if ( v == squad.leader ) then
                        playerText = v:Nick() .. " (Leader)"
                    end

                    if ( ix.option.Get("combineOverlaySquadHealth", true) ) then
                        playerText = playerText .. " (" .. v:Health() .. "%)"
                    end

                    surface.SetFont("ixCombineFont08")
                    local playerWidth, playerHeight = surface.GetTextSize("<:: " .. playerText)

                    self:DrawBox({
                        x = ( padding * 1.8 ) - textWidth * 0.01,
                        y = padding * 4 + paddingOffset,
                        w = playerWidth + padding * 0.6,
                        h = textHeight * 1.05,
                        rectColor = colWhite,
                        backColor = colBlack
                    })

                    draw.SimpleText("<:: " .. playerText, "ixCombineFont08", padding * 1.8, padding * 4.1 + paddingOffset, ix.option.Get("combineOverlaySquadColor", color_white), TEXT_ALIGN_LEFT)

                    paddingOffset = paddingOffset + padding * 0.5 + playerHeight
                end
            end
        end
    end

    for k, v in ipairs(PLUGIN.waypoints) do
        local wayPos = v.pos:ToScreen()
        local dist = math.Round(v.pos:Distance(ply:GetPos()) / 16, 1)

        local diff = v.pos - ply:GetShootPos()

        if not ( v.drawAlpha ) then
            v.drawAlpha = 255
        end

        if ( ply:GetAimVector():Dot(diff) / diff:Length() >= 0.995 ) then
            v.drawAlpha = Lerp(FrameTime() * 2, v.drawAlpha, 25)
        elseif ( dist <= 40 ) then
            v.drawAlpha = Lerp(FrameTime() * 2, v.drawAlpha, 100)
        else
            v.drawAlpha = Lerp(FrameTime() * 2, v.drawAlpha, 255)
        end

        surface.SetFont("ixCombineFont08")
        textWidth, textHeight = surface.GetTextSize(v.text .. " (" .. dist .. "m)")

        draw.SimpleTextOutlined(v.text .. " (" .. dist .. ")", "ixCombineFont08", wayPos.x, wayPos.y, ColorAlpha(v.textColor or color_white, v.drawAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, ColorAlpha(color_black, v.drawAlpha))

        // Uncomment this if you want to use sentBy value on the waypoint
        --[[
        surface.SetFont("ixCombineHUDWaypointText")
        textWidth, textHeight = surface.GetTextSize(v.sentBy)

        draw.SimpleText(v.sentBy, "ixCombineHUDWaypointText", wayPos.x, wayPos.y - ScreenScale(9), ColorAlpha(v.textColor or color_white, v.drawAlpha), TEXT_ALIGN_CENTER)
        ]]
    end

    if ( ix.option.Get("combineOverlayAssets", true) ) then
        for k, v in player.Iterator() do
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

            if ( v:GetPos():Distance(ply:GetPos()) > 400 ) then
                continue
            end

            if ( v == ply ) then
                continue
            end

            if ( v:GetNoDraw() or v:GetMoveType() == MOVETYPE_NOCLIP ) then
                continue
            end

            local vPos = v:GetPos()
            vPos = vPos - v:GetUp() * -50

            if not ( v.displayAlpha ) then
                v.displayAlpha = 255
            end

            local dist = math.Round(vPos:Distance(ply:GetPos()) / 16, 1)
            local diff = vPos - ply:GetShootPos()

            vPos = vPos:ToScreen()

            if ( ply:GetAimVector():Dot(diff) / diff:Length() >= 0.985 ) then
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

            draw.SimpleText(string.upper("<:: " .. v:Name() .. " ::>"), "ixCombineFont08", vPos.x, vPos.y - padding * 0.1, ColorAlpha(color_white, v.displayAlpha), TEXT_ALIGN_CENTER)

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

                    draw.SimpleText("<:: " .. ix.class.list[char:GetClass()].name .. " ::>", "ixCombineFont08", vPos.x, vPos.y - padding * 0.1, ColorAlpha(color_white, v.displayAlpha), TEXT_ALIGN_CENTER)
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

                draw.SimpleText("<:: " .. ix.rank.list[char:GetRank()].name .. " ::>", "ixCombineFont08", vPos.x, vPos.y - padding * 0.1, ColorAlpha(color_white, v.displayAlpha), TEXT_ALIGN_CENTER)
            end
        end
    end

    local wep = ply:GetActiveWeapon()

    if ( IsValid(wep) ) then
        if ( wep:Clip1() != -1 ) then
            surface.SetFont("ixCombineFont10")
            local textWidth, textHeight = surface.GetTextSize("Verdicts: " .. wep:Clip1() .. " / " .. ply:GetAmmoCount(wep:GetPrimaryAmmoType()))

            self:DrawBox({
                x = ScrW() - textWidth - padding * 1.3,
                y = ScrH() - textHeight - padding * 0.5,
                w = textWidth * 1.1,
                h = textHeight * 1.05,
                rectColor = colWhite,
                backColor = colBlack
            })

            if ( wep:Clip1() <= wep:GetMaxClip1() / 4 ) then
                surface.SetFont("ixCombineFont10")
                local textWidth2, textHeight2 = surface.GetTextSize("RELOAD")

                self:DrawBox({
                    x = ScrW() - padding * 5.7,
                    y = ScrH() - textHeight - padding * 1.9,
                    w = padding * 5,
                    h = padding * 1.3,
                    rectColor = colRed,
                    backColor = colBlack
                })

                draw.DrawText("RELOAD", "ixCombineFont10", ScrW() - padding * 5.7 / 1.75, ScrH() - ( textHeight + textHeight2 ) - padding * 0.7, colRed, TEXT_ALIGN_CENTER)
            end

            draw.DrawText("Verdicts: " .. wep:Clip1() .. " / " .. ply:GetAmmoCount(wep:GetPrimaryAmmoType()), "ixCombineFont10", ScrW() - padding, ScrH() - textHeight - padding * 0.5, color_white, TEXT_ALIGN_RIGHT)
        end
    end
end

local combineOverlayMat = ix.util.GetMaterial("effects/combine_binocoverlay")

function PLUGIN:RenderScreenspaceEffects()
    local ply = LocalPlayer()

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( Schema:IsCombine(ply) ) then
        return
    end

    if not ( ix.option.Get("combineOverlay", true) ) then
        return
    end

    if ( ply.CanOverrideView ) then // Helix Thirdperson Plugin Function
        if ( ply:CanOverrideView() ) then
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
    local ply = LocalPlayer()

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( Schema:IsCombine(ply) ) then
        return
    end

    if not ( ply:Alive() ) then
        return
    end

    if ( ply.CanOverrideView ) then // Helix Thirdperson Plugin Function
        if ( ply:CanOverrideView() ) then
            return
        end
    end

    if ( ix.option.Get("combineOutlineNPCs", true) ) then
        for k, v in ents.Iterator() do
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
                outlineColor = ix.option.Get("combineOutlineColorNPCsFriendlyFallback", Color(0, 175, 255))
            end

            if ( hook.Run("ShouldOutlineEntity", v, "friendly_npcs") == false ) then
                continue
            end

            ix.outline.Add(v, outlineColor)
        end

        for k, v in ents.Iterator() do
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
                outlineColor = ix.option.Get("combineOutlineColorNPCsEnemy", Color(255, 0, 0))
            end

            if ( hook.Run("ShouldOutlineEntity", v, "hostile") == false ) then
                continue
            end

            ix.outline.Add(v, outlineColor, 2)
        end
    end

    if ( ix.option.Get("combineOutlineAssets", true) ) then
        for k, v in player.Iterator() do
            if not ( IsValid(v) ) then
                continue
            end

            local vChar = v:GetCharacter()

            if not ( vChar ) then
                continue
            end

            if not ( v:Alive() ) then
                continue
            end

            if not ( Schema:IsCombine(v) ) then
                continue
            end

            if ( ix.option.Get("combineOutlineAssetsTeamOnly", false) ) then
                if ( hook.Run("CombineOverlayCanDisplayAssetOnly", v) == false ) then
                    continue
                end
            end

            if ( v == ply ) then
                continue
            end

            local outlineColor = hook.Run("GetPlayerOutlineColor", v)

            if ( outlineColor == nil ) then
                outlineColor = team.GetColor(v:Team())
            end

            if ( ix.option.Get("combineOverlaySquadOutline", true) ) then
                if not ( vChar:GetData("squadID", -1) == -1 and char:GetData("squadID", -1) == -1 ) then
                    if ( vChar:GetData("squadID", -1) == char:GetData("squadID", -1) ) then
                        outlineColor = ix.option.Get("combineOverlaySquadOutlineColor", color_white)
                    end
                end
            end

            if ( hook.Run("ShouldOutlineEntity", v, "friendly") == false ) then
                continue
            end

            ix.outline.Add(v, outlineColor)
        end
    end

    if ( ix.option.Get("combineOutlineDeployables", true) ) then
        if ( #char:GetData("deployedEntities", {}) > 0 ) then
            for k, v in ipairs(char:GetData("deployedEntities", {})) do
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
                    outlineColor = ix.faction.Get(ply:Team()).color or colWhite2
                end

                if ( ent:GetClass() == "npc_grenade_frag" ) then
                    outlineColor = colRed
                end

                if ( hook.Run("ShouldOutlineEntity", ent, "deployable") == false ) then
                    continue
                end

                ix.outline.Add(ent, outlineColor)
            end
        end
    end
end

function PLUGIN:GetPlayerOutlineColor(target)
    if ( Schema:IsOW(target) ) then
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

function PLUGIN:CombineOverlayCanDisplayAssetOnly(ply)
    local client = LocalPlayer()

    if not ( IsValid(client) ) then
        return
    end

    local char = client:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( Schema:IsCombine(client) ) then
        return
    end

    if not ( IsValid(ply) ) then
        return
    end

    local plyChar = ply:GetCharacter()

    if not ( plyChar ) then
        return
    end

    if not ( Schema:IsCombine(ply) ) then
        return
    end

    if not ( plyChar:GetData("squadID", -1) == -1 and char:GetData("squadID", -1) == -1 ) then
        if ( plyChar:GetData("squadID", -1) == char:GetData("squadID", -1) ) then
            return true
        end
    end

    if not ( ply:Team() == client:Team() ) then
        return false
    end

    return true
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
            return colWhite
        end
    end

    if ( ent:GetClass() == "npc_combinegunship" ) then
        return colWhite
    end

    if ( ent:GetClass() == "npc_helicopter" ) then
        return colWhite
    end

    if ( ent:GetClass() == "npc_strider" ) then
        return colWhite
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

function PLUGIN:ShouldOutlineEntity(ent, type)
    if not ( IsValid(ent) ) then
        return
    end

    if not ( ent:IsNPC() ) then
        return
    end

    if not ( ent:Health() > 0 ) then
        return
    end

    if ( type == "friendly_npcs" ) then
        if ( ent:GetClass() == "npc_combine_camera" ) then
            return false
        end
    end
end

net.Receive("ix.MakeWaypoint", function()
    local data = net.ReadTable() or {}

    if ( data.sound and string.len(data.sound) > 0 ) then
        Schema:PlaySound(data.sound)
    end

    PLUGIN:MakeWaypoint(data)
end)

net.Receive("PLUGIN.SyncSquads", function()
    local data = net.ReadTable() or {}

    PLUGIN.Squads.Stored = data
end)

net.Receive("PLUGIN.SyncObjectives", function()
    local data = net.ReadTable() or {}

    PLUGIN.Objectives.Stored = data
end)

net.Receive("PLUGIN.SyncDeployments", function()
    local data = net.ReadTable() or {}

    PLUGIN.Deployments.Stored = data
end)
