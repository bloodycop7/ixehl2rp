local PLUGIN = PLUGIN

PLUGIN.name = "Development HUD"
PLUGIN.author = "eon"
PLUGIN.license = [[
Copyright 2024 eon (bloodycop)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

if not ( CLIENT ) then
    return
end

local enabled = enabled or false
local colWhite = Color(165,165,165)

concommand.Add("ix_dev_hud", function()
    local ply = LocalPlayer()

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    enabled = !enabled
end)

function PLUGIN:HUDPaint()
    local ply = LocalPlayer()

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( enabled ) then
        return
    end

    local plyInfo = tostring(ply) .. " | " .. ply:SteamID64() .. " | " .. char:GetName() .. " (ID: " .. char:GetID() .. ")"
    local gameInfo = game.GetMap() .. " | " .. os.date("%X") .. " | " .. os.date("%x") .. " | " .. ply:Ping() .. " | " .. player.GetCount() .. " / " .. game.MaxPlayers()

    local trace = ply:GetEyeTrace().Entity
    local padding = ScrH() * 0.09

    draw.SimpleText("Helix: Enhanced Half-Life 2 Roleplay", "ixGenericFont", 10, ScrH() - padding, ix.config.Get("color", colWhite))

    surface.SetFont("ixGenericFont")
    local w, h = surface.GetTextSize("Helix: Enhanced Half-Life 2 Roleplay")
    padding = padding - (h - ScreenScale(0.3))

    draw.SimpleText(plyInfo, "ixSmallFont", 10, ScrH() - padding, colWhite)

    surface.SetFont("ixSmallFont")
    local w, h = surface.GetTextSize(plyInfo)
    padding = padding - (h - ScreenScale(0.3))

    draw.SimpleText(gameInfo, "ixSmallFont", 10, ScrH() - padding, colWhite)

    if ( IsValid(trace) ) then
        local traceInfo = tostring(trace) .. " | " .. trace:GetModel() .. " | " .. tostring(trace:GetPos()) .. " | " .. tostring(trace:GetAngles())

        surface.SetFont("ixSmallFont")
        local w, h = surface.GetTextSize(traceInfo)
        padding = padding - (h - ScreenScale(0.3))

        draw.SimpleText(traceInfo, "ixSmallFont", 10, ScrH() - padding, colWhite)
    end

    if ( IsValid(ply:GetActiveWeapon()) ) then
        local weapon = ply:GetActiveWeapon()
        local weaponInfo = "Weapon: " .. weapon:GetClass() .. " | Clip: " .. weapon:Clip1() .. " | Ammo: " .. ply:GetAmmoCount(weapon:GetPrimaryAmmoType())

        surface.SetFont("ixSmallFont")
        local w, h = surface.GetTextSize(weaponInfo)
        padding = padding - (h - ScreenScale(0.3))

        draw.SimpleText(weaponInfo, "ixSmallFont", 10, ScrH() - padding, colWhite)
    end
end
