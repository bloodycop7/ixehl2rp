local PLUGIN = PLUGIN

PLUGIN.name = "Music Kits"
PLUGIN.author = "Riggs, eon, vingard"
PLUGIN.schema = "Any"
PLUGIN.license = [[
Copyright 2024 Riggs Mackay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

PLUGIN.passiveMusic = {
    {"music/HL2_song0.mp3", 39},
    {"music/HL2_song1.mp3", 98},
    {"music/HL2_song10.mp3", 29},
    {"music/HL2_song13.mp3", 53},
    {"music/HL2_song17.mp3", 61},
    {"music/HL2_song19.mp3", 115},
    {"music/HL2_song26.mp3", 69},
    {"music/HL2_song26_trainstation1.mp3", 90},
    {"music/HL2_song33.mp3", 84},
    {"music/HL2_song8.mp3", 59}
}

PLUGIN.combatMusic = {
    {"music/HL2_song12_long.mp3", 73},
    {"music/HL2_song14.mp3", 159},
    {"music/HL2_song15.mp3", 69},
    {"music/HL2_song16.mp3", 170},
    {"music/HL2_song20_submix0.mp3", 103},
    {"music/HL2_song20_submix4.mp3", 139},
    {"music/HL2_song29.mp3", 135},
    {"music/HL2_song3.mp3", 90},
    {"music/HL2_song31.mp3", 98},
    {"music/HL2_song4.mp3", 65},
    {"music/HL2_song6.mp3", 45}
}

PLUGIN.passiveMusicEpisodic = {
    {"music/vlvx_song8.mp3", 22},
    {"music/vlvx_song19b.mp3", 30},
    {"music/vlvx_song2.mp3", 25},
    {"music/vlvx_song20.mp3", 35}
}

PLUGIN.combatMusicEpisodic = {
    {"music/vlvx_song11.mp3", 39},
    {"music/vlvx_song12.mp3", 53},
    {"music/vlvx_song21.mp3", 84},
    {"music/vlvx_song18.mp3", 82}
}

PLUGIN.passiveMusicEP2 = {
    {"music/vlvx_song0.mp3", 27},
    {"music/vlvx_song15.mp3", 53},
    {"music/vlvx_song20.mp3", 55},
    {"music/vlvx_song3.mp3", 27}
}

PLUGIN.combatMusicEP2 = {
    {"music/vlvx_song22.mp3", 86},
    {"music/vlvx_song23.mp3", 74},
    {"music/vlvx_song27.mp3", 93},
    {"music/vlvx_song24.mp3", 42}
}

ix.lang.AddTable("english", {
    optMusicKit = "Kit",
    optMusicKitEnabled = "Kit Enabled",
    optdMusicKitEnabled = "Should Kits be Enabled?",
    optdMusicKit = "What Music Kit do you want to be played?",
    optMusicAmbientVol = "Kit Ambient Volume",
    optdMusicAmbientVol = "How much Ambient Kit Volume do you prefer?",
    optMusicCombatVol = "Kit Combat Volume",
    optdMusicCombatVol = "How much Combat Kit Volume do you prefer?",
})

local lastSongs = lastSongs or {}
CUSTOM_MUSICKITS = CUSTOM_MUSICKITS or {}

file.CreateDir("helix/musickits")

CreateClientConVar("ix_music_forcecombat", "0", false, false, "If we should force the combat state for music. Used for debugging.", 0, 1)
CreateClientConVar("ix_music_debug", "0", false, false, "Prints details about the currently playing music to console. Used for debugging.", 0, 1)

local function DebugPrint(msg)
    if GetConVar("ix_music_debug"):GetBool() then
        print("[Helix] [musicdebug] "..msg)
    end
end

local function ReadMusicKit(name)
    local txt = file.Read("helix/musickits/"..name)

    if not txt then
        return "Failed to read music kit file."
    end

    local json = util.JSONToTable(txt)
    local antiCrash = {}

    if not json or not istable(json) then
        return "Corrupted music kit file. Check formatting."
    end

    if not json.Name or not isstring(json.Name) then
        return "Missing name value, or name value is not a string."
    end

    if not json.Combat or not istable(json.Combat) or not json.Ambient or not istable(json.Ambient) then
        return "Missing combat and ambient tracks."
    end

    if table.Count(json.Combat) < 4 then
        return "At least 4 tracks are required in the combat track list."
    end

    if table.Count(json.Ambient) < 4 then
        return "At least 4 tracks are required in the ambient track list."
    end

    for v,k in pairs(json.Ambient) do
        if not istable(k) or not k.Sound or not k.Length or not isstring(k.Sound) or not isnumber(k.Length) then
            return "Ambient track "..v.." is missing required data."
        end

        if antiCrash[k.Sound] then
            return "Same sound is used more than once, this is not allowed."
        end

        antiCrash[k.Sound] = true
    end

    for v,k in pairs(json.Combat) do
        if not istable(k) or not k.Sound or not k.Length or not isstring(k.Sound) or not isnumber(k.Length) then
            return "Combat track "..v.." is missing required data."
        end

        if antiCrash[k.Sound] then
            return "Same sound is used more than once, this is not allowed."
        end

        antiCrash[k.Sound] = true
    end

    if json.DeathSound and not isstring(json.DeathSound) then
        return "DeathSound must be a string."
    end

    // comment: compile it
    local comp = {}

    comp.Ambient = {}
    comp.Combat = {}

    for v,k in pairs(json.Ambient) do
        table.insert(comp.Ambient, {k.Sound, k.Length})
    end

    for v,k in pairs(json.Combat) do
        table.insert(comp.Combat, {k.Sound, k.Length})
    end

    if json.DeathSound then
        comp.DeathSound = json.DeathSound
    end

    CUSTOM_MUSICKITS[json.Name] = comp

    print("[Helix] [musickits] Loaded "..json.Name.." ("..name..") music kit.")
end

local function GetMusicKits()
    local kits = file.Find("helix/musickits/*.json", "DATA")
    local comp = {}

    for v,k in pairs(kits) do
        local err = ReadMusicKit(k)

        if err then
            print("[Helix] [musickits] Failed to load "..k.." | "..err)
            continue
        end
    end
end

GetMusicKits()

local names = {"Default"}
for v,k in pairs(CUSTOM_MUSICKITS) do
    table.insert(names, v)
end

ix.option.Add("musicKitEnabled", ix.type.bool, true, {
    category = "Music Kits"
})

local function createCommand()
    ix.option.Add("musicKit", ix.type.array, "Default", {
        category = "Music Kits",
        bNetworked = true,
        populate = function()
            local entries = {}

            for _, v in SortedPairs(names) do
                local name = v

                entries[v] = name
            end

            local hasEP1 = true
            local hasEP2 = true

            for k, v in ipairs(PLUGIN.passiveMusicEpisodic) do
                if not ( file.Exists("sound/" .. v[1], "GAME") ) then
                    hasEP1 = false

                    break
                end
            end

            for k, v in ipairs(PLUGIN.combatMusicEpisodic) do
                if not ( file.Exists("sound/" .. v[1], "GAME") ) then
                    hasEP1 = false

                    break
                end
            end

            for k, v in ipairs(PLUGIN.passiveMusicEP2) do
                if not ( file.Exists("sound/" .. v[1], "GAME") ) then
                    hasEP2 = false

                    break
                end
            end

            for k, v in ipairs(PLUGIN.combatMusicEP2) do
                if not ( file.Exists("sound/" .. v[1], "GAME") ) then
                    hasEP2 = false

                    break
                end
            end

            if ( IsMounted("episodic") or hasEP1 ) then
                entries["EpisodeOne"] = "Half-Life 2 Episode One"
            end

            if ( IsMounted("ep2") or hasEP2 ) then
                entries["EpisodeTwo"] = "Half-Life 2 Episode Two"
            end

            return entries
        end
    })
end

createCommand()

concommand.Add("ix_reloadmusickits", function()
    print("[Helix] Reloading music kits...")
    CUSTOM_MUSICKITS = {}

    GetMusicKits()

    local names = {"Default"}
    for v,k in pairs(CUSTOM_MUSICKITS) do
        table.insert(names, v)
    end

    createCommand()
end)

local nextThink = 0
local currentPassive = currentPassive or nil
local currentCombat = currentCombat or nil
local currentPassiveFading = currentPassiveFading or nil
local currentCombatFading = currentCombatFading or nil

if ( currentPassive ) then
    timer.Remove("ixMusicPassiveTrackTime")
    currentPassive:Stop()
end

if ( currentCombat ) then
    timer.Remove("ixMusicCombatTrackTime")
    currentCombat:Stop()
end

ix.option.Add("musicAmbientVol", ix.type.number, 0.2, {
    category = "Music Kits",
    decimals = 1,
    min = 0,
    max = 1,
    OnChanged = function(oldVal, newVal)
        if ( currentPassive ) then
            currentPassive:ChangeVolume(newVal, 0)
        end
    end
})

ix.option.Add("musicCombatVol", ix.type.number, 0.4, {
    category = "Music Kits",
    decimals = 1,
    min = 0,
    max = 1,
    OnChanged = function(oldVal, newVal)
        if ( currentCombat ) then
            currentCombat:ChangeVolume(newVal, 0)
        end
    end
})

if ( SERVER ) then
    function PLUGIN:PlayerHurt(ply, attacker, health, damage)
        if ( IsValid(ply) and ply:GetChar() and IsValid(attacker) ) then
            local uID = "ixMusicKit.CombatTimer." .. ply:SteamID64()

            if not ( timer.Exists(uID) ) then
                ply:SetNetVar("bInCombat", true)

                timer.Create(uID, 60, 1, function()
                    if not ( IsValid(ply) or ply:GetChar() ) then
                        ply:SetNetVar("bInCombat", false)
                        timer.Remove(uID)

                        return
                    end

                    ply:SetNetVar("bInCombat", false)
                end)
            else
                if ( timer.TimeLeft(uID) <= 5 ) then
                    timer.Adjust(uID, 20)
                end
            end
        end

        if ( IsValid(attacker) and attacker:IsPlayer() and attacker:GetChar() ) then
            uID = "ixMusicKit.CombatTimer." .. attacker:SteamID64()
            if not ( timer.Exists(uID) ) then
                attacker:SetNetVar("bInCombat", true)

                timer.Create(uID, 60, 1, function()
                    if not ( IsValid(attacker) or attacker:GetChar() ) then
                        attacker:SetNetVar("bInCombat", false)
                        timer.Remove(uID)

                        return
                    end

                    attacker:SetNetVar("bInCombat", false)
                end)
            else
                if ( timer.TimeLeft(uID) <= 5 ) then
                    timer.Adjust(uID, 20)
                end
            end
        end
    end

    function PLUGIN:PlayerDeath(ply, inflictor, attacker)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetChar()

        if not ( char ) then
            return
        end

        local uID = "ixMusicKit.CombatTimer." .. ply:SteamID64()

        if ( timer.Exists(uID) ) then
            ply:SetNetVar("bInCombat", false)
            timer.Remove(uID)
        end

        if ( IsValid(attacker) and attacker:IsPlayer() and attacker:GetChar() ) then
            uID = "ixMusicKit.CombatTimer." .. attacker:SteamID64()

            if ( timer.Exists(uID) ) then
                attacker:SetNetVar("bInCombat", false)
                timer.Remove(uID)
            end
        end
    end

    return
end

local default = {
    ["Default"] = true,
    ["EpisodeOne"] = true,
    ["EpisodeTwo"] = true,
}

local songLinks = {
    ["Default"] = {PLUGIN.passiveMusic, PLUGIN.combatMusic},
    ["EpisodeOne"] = {PLUGIN.passiveMusicEpisodic, PLUGIN.combatMusicEpisodic},
    ["EpisodeTwo"] = {PLUGIN.passiveMusicEP2, PLUGIN.combatMusicEP2},
}

local function GetRandomSong(style)
    local x = PLUGIN.passiveMusic
    if style == "combat" then
        x = PLUGIN.combatMusic
    end

    local kitName = ix.option.Get("musicKit")
    local linkData = songLinks[kitName]

    if ( linkData ) then
        x = linkData[1]

        if style == "combat" then
            x = linkData[2]
        end
    end

    if kitName and not default[kitName] and CUSTOM_MUSICKITS[kitName] then
        if style == "combat" then
            x = CUSTOM_MUSICKITS[kitName].Combat
        else
            x = CUSTOM_MUSICKITS[kitName].Ambient
        end
    end

    local t = x[math.random(1, #x)]
    local r = t[1]

    if lastSongs[r] then
        return GetRandomSong(style)
    end

    local highest = -1
    local lowest = 999999
    local key = ""
    for v,k in pairs(lastSongs) do
        if k < lowest then
            lowest = k
            key = v
        end

        if k > highest then
            highest = k
        end
    end

    if table.Count(lastSongs) > 2 then
        lastSongs[key] = nil
    end

    lastSongs[r] = highest + 1

    DebugPrint("Selected track "..r.." (length: "..t[2]..")")

    return r, t[2]
end

local function InCombat() // comment: simple for now
    local forcedCombat = GetConVar("ix_music_forcecombat"):GetBool()

    if forcedCombat then
        return true
    end

    if ( LocalPlayer():GetNetVar("bInCombat", false) ) then
        return true
    end

    hook.Run("IsPlayerInCombat", LocalPlayer())
end

function PLUGIN:GetPlayerDeathSound()
    local kitName = ix.option.Get("musicKit")

    if kitName and CUSTOM_MUSICKITS[kitName] and CUSTOM_MUSICKITS[kitName].DeathSound then
        return CUSTOM_MUSICKITS[kitName].DeathSound
    end
end

function PLUGIN:Think()
    local ctime = CurTime()
    if nextThink > ctime then
        return
    end

    nextThink = ctime + 1

    local kitName = ix.option.Get("musicKit")
    local swap = false

    if lastKitName and kitName != lastKitName then
        swap = true
    end

    lastKitName = kitName

    if swap or LocalPlayer():Team() == 0 or ((ix) and (IsValid(ix.gui.characterMenu) and not ix.gui.characterMenu.popup and ix.gui.characterMenu:IsVisible())) then
        if currentPassive then
            timer.Remove("ixMusicPassiveTrackTime")
            currentPassive:Stop()
        end

        if currentCombat then
            timer.Remove("ixMusicCombatTrackTime")
            currentCombat:Stop()
        end

        return
    end

    if not ix.option.Get("musicKitEnabled", false) or not LocalPlayer():Alive() then
        if currentPassive and currentPassive:IsPlaying() then
            timer.Remove("ixMusicPassiveTrackTime")
            currentPassive:FadeOut(1.5)

            timer.Simple(1.5, function()
                if currentPassive then
                    currentPassive:Stop()
                end
            end)
        end

        if currentCombat and currentCombat:IsPlaying() then
            timer.Remove("ixMusicCombatTrackTime")
            currentCombat:FadeOut(1.5)

            timer.Simple(1.5, function()
                if currentCombat then
                    currentCombat:Stop()
                end
            end)
        end

        return
    end

    local inCombat = InCombat()

    if inCombat then
        if currentPassive and currentPassive:IsPlaying() then
            if not currentPassiveFading then
                timer.Remove("ixMusicPassiveTrackTime")
                currentPassive:FadeOut(6)
                currentPassiveFading = true
                DebugPrint("Fading out ambient to move to combat...")

                timer.Simple(6, function()
                    currentPassive:Stop()
                    currentPassiveFading = false
                    DebugPrint("Stopped ambient track")
                end)
            end
        end

        if not currentCombat or not currentCombat:IsPlaying() then
            local s, l = GetRandomSong("combat")

            currentCombat = CreateSound(LocalPlayer(), s)
            currentCombat:SetSoundLevel(0)
            currentCombat:PlayEx(0, 100)
            currentCombat:ChangeVolume(ix.option.Get("musicCombatVol"), 6)

            DebugPrint("Playing combat track...")

            timer.Remove("ixMusicCombatTrackTime")
            timer.Create("ixMusicCombatTrackTime", l + 2, 1, function()
                if currentCombat then
                    currentCombat:FadeOut(2)
                    DebugPrint("Stopping combat track (track complete)...")
                end
            end)
        end

        return
    elseif currentCombat and currentCombat:IsPlaying() then
        if not currentCombatFading then
            timer.Remove("ixMusicCombatTrackTime")
            currentCombat:ChangeVolume(0, 120)
            currentCombatFading = true
            DebugPrint("Fading out combat to move to ambient...")

            timer.Simple(8, function()
                currentCombat:Stop()
                currentCombatFading = false
                DebugPrint("Stopped combat track")
            end)
        end

        return
    end

    if not currentPassive or not currentPassive:IsPlaying() then
        local s, l = GetRandomSong("passive")

        currentPassive = CreateSound(LocalPlayer(), s)
        currentPassive:SetSoundLevel(0)
        currentPassive:PlayEx(0, 100)
        currentPassive:ChangeVolume(ix.option.Get("musicAmbientVol"), 12)

        DebugPrint("Playing ambient track...")

        timer.Remove("ixMusicPassiveTrackTime")
        timer.Create("ixMusicPassiveTrackTime", l + 2, 1, function()
            if currentPassive then
                currentPassive:FadeOut(2)
                DebugPrint("Stopping ambient track (track complete)...")
            end
        end)
    end
end