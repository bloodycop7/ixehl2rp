local PLUGIN = PLUGIN

PLUGIN.name = "Development HUD"
PLUGIN.author = "eon"

if not ( CLIENT ) then
    return
end

local enabled = enabled or false

concommand.Add("ix_dev_hud", function()
    if not ( IsValid(localPlayer) ) then
        return
    end

    local char = localPlayer:GetCharacter()

    if not ( char ) then
        return
    end

    enabled = !enabled
end)

function PLUGIN:HUDPaint()
    if not ( IsValid(localPlayer) ) then
        return
    end

    local char = localPlayer:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( enabled ) then
        return
    end

    local plyInfo = tostring(localPlayer) .. " | " .. localPlayer:SteamID64() .. " | " .. char:GetName() .. " (ID: " .. char:GetID() .. ")"
    local gameInfo = game.GetMap() .. " | " .. os.date("%X") .. " | " .. os.date("%x") .. " | " .. math.Round(1 / RealFrameTime()) .. " | " .. localPlayer:Ping() .. " | " .. player.GetCount() .. " / " .. game.MaxPlayers()

    local trace = localPlayer:GetEyeTrace().Entity

    // local padding = ScreenScale(60)
    local padding = scrH * 0.09

    draw.SimpleText("ix: Enhanced Half-Life 2 Roleplay", "ixGenericFont", 10, scrH - padding, Color(165, 165, 165))

    surface.SetFont("ixGenericFont")
    local w, h = surface.GetTextSize("ix: Enhanced Half-Life 2 Roleplay")
    padding = padding - (h - ScreenScale(0.3))

    draw.SimpleText(plyInfo, "ixSmallFont", 10, scrH - padding, Color(165, 165, 165))

    surface.SetFont("ixSmallFont")
    local w, h = surface.GetTextSize(plyInfo)
    padding = padding - (h - ScreenScale(0.3))

    draw.SimpleText(gameInfo, "ixSmallFont", 10, scrH - padding, Color(165, 165, 165))

    if ( IsValid(trace) ) then
        local traceInfo = tostring(trace) .. " | " .. trace:GetModel() .. " | " .. tostring(trace:GetPos()) .. " | " .. tostring(trace:GetAngles())

        surface.SetFont("ixSmallFont")
        local w, h = surface.GetTextSize(traceInfo)
        padding = padding - (h - ScreenScale(0.3))

        draw.SimpleText(traceInfo, "ixSmallFont", 10, scrH - padding, Color(165, 165, 165))
    end

    if ( IsValid(localPlayer:GetActiveWeapon()) ) then
        local weapon = localPlayer:GetActiveWeapon()
        local weaponInfo = "Weapon: " .. weapon:GetClass() .. " | Clip: " .. weapon:Clip1() .. " | Ammo: " .. localPlayer:GetAmmoCount(weapon:GetPrimaryAmmoType())

        surface.SetFont("ixSmallFont")
        local w, h = surface.GetTextSize(weaponInfo)
        padding = padding - (h - ScreenScale(0.3))

        draw.SimpleText(weaponInfo, "ixSmallFont", 10, scrH - padding, Color(165, 165, 165))
    end
end