local PLUGIN = PLUGIN
util.AddNetworkString("ix.Combine.SetCityCode")
util.AddNetworkString("ix.Combine.ToggleBOL")
util.AddNetworkString("ix.Combine.GiveLP")
util.AddNetworkString("ix.Combine.TakeLP")

net.Receive("ix.Combine.GiveLP", function(len, ply)
    if not ( IsValid(ply) ) then
        return
    end

    local plyChar = ply:GetCharacter()

    if not ( plyChar ) then
        return
    end

    local target = net.ReadEntity()

    if not ( IsValid(target) ) then
        return
    end

    local char = target:GetCharacter()

    if not ( char ) then
        return
    end

    local amount = net.ReadString()

    if not ( amount ) then
        ply:Notify("Invalid amount!")
        return
    end

    if not ( Schema:IsCombine(ply) ) then
        return
    end

    amount = tonumber(amount)

    if not ( isnumber(amount) ) then
        return
    end

    if ( amount < 1 ) then
        return
    end

    if not ( Schema:IsCitizen(target) ) then
        return
    end

    char:SetLoyaltyPoints(char:GetLoyaltyPoints() + amount)
end)

net.Receive("ix.Combine.TakeLP", function(len, ply)
    if not ( IsValid(ply) ) then
        return
    end

    local plyChar = ply:GetCharacter()

    if not ( plyChar ) then
        return
    end

    local target = net.ReadEntity()

    if not ( IsValid(target) ) then
        return
    end

    local char = target:GetCharacter()

    if not ( char ) then
        return
    end

    local amount = net.ReadString()

    if not ( amount ) then
        return
    end

    if not ( Schema:IsCombine(ply) ) then
        return
    end

    amount = tonumber(amount)

    if not ( isnumber(amount) ) then
        return
    end

    if ( amount < 1 ) then
        return
    end

    if not ( Schema:IsCitizen(target) ) then
        return
    end

    char:SetLoyaltyPoints(char:GetLoyaltyPoints() - amount)
end)

net.Receive("ix.Combine.SetCityCode", function(len, ply)
    local id = net.ReadUInt(8)
    local codeData = ix.cmbSystems.cityCodes[id]

    if ( ( ix.nextCityCodeChange or 0 ) > CurTime() ) then
        ply:Notify("You must wait " .. math.Round(ix.nextCityCodeChange - CurTime()) .. " more second(s) before changing the city code again.")

        return
    end

    if not ( codeData ) then
        return
    end

    if not ( Schema:IsCombine(ply) ) then
        return
    end

    ix.cmbSystems:SetCityCode(id)
    ix.nextCityCodeChange = CurTime() + (ply:IsAdmin() and 2 or 10)
end)

net.Receive("ix.Combine.ToggleBOL", function(len, ply)
    local target = net.ReadEntity()

    if not ( IsValid(target) ) then
        return
    end

    local char = target:GetChar()

    if not ( char ) then
        return
    end

    if not ( Schema:IsCombine(ply) ) then
        return
    end

    local plyChar = ply:GetChar()

    if not ( plyChar ) then
        return
    end

    ix.cmbSystems:SetBOLStatus(target, !target:GetCharacter():GetBOLStatus())
end)

function ix.cmbSystems:SetBOLStatus(ply, bolStatus, callback)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    char:SetBOLStatus(bolStatus)

    if ( callback ) then
        callback(ply, bolStatus)
    end
end

function ix.cmbSystems:SetCityCode(id)
    local codeData = ix.cmbSystems.cityCodes[ix.cmbSystems:GetCityCode()]

    if ( codeData.onEnd ) then
        codeData:onEnd()
    end

    SetGlobalInt("ixCityCode", id)

    codeData = ix.cmbSystems.cityCodes[ix.cmbSystems:GetCityCode()]

    timer.Simple(0.1, function()
        if ( codeData.onStart ) then
            codeData:onStart()
        end
    end)
    
    hook.Run("OnCityCodeChanged", id, oldCode)
end

local baseRadioVoiceDir = "npc/overwatch/cityvoice/"

ix.cmbSystems.dispatchPassive = {
    {
        soundDir = baseRadioVoiceDir .. "f_innactionisconspiracy_spkr.wav",
        text = "Citizen reminder: inaction is conspiracy. Report counter-behavior to a Civil Protection team immediately.",
    },
    {
        soundDir = baseRadioVoiceDir .. "f_trainstation_offworldrelocation_spkr.wav",
        text = "Citizen notice: Failure to cooperate will result in permanent off-world relocation.",
    },
    {
        soundDir = baseRadioVoiceDir .. "fprison_missionfailurereminder.wav",
        text = "Attention ground units. Mission failure will result in permanent offworld assignment. Code reminder: sacrifice, coagulate, clamp.",
        customCheck = function()
            return ( ix.cmbSystems:GetCityCode() >= 2 )
        end
    }
}

timer.Remove("ix.DispatchPassive")
timer.Create("ix.DispatchPassive", ix.config.Get("passiveDispatchCooldown", 120), 0, function()
    local cityCode = ix.cmbSystems.cityCodes[ix.cmbSystems:GetCityCode()]

    if ( cityCode ) then
        if ( cityCode.dispatchPassive ) then
            cityCode:dispatchPassive()

            return
        end
    end

    local tableExtra = {}

    for k, v in pairs(ix.cmbSystems.dispatchPassive) do
        if ( v.customCheck and not v:customCheck() ) then
            continue
        end

        if ( v.lastUsed ) then
            v.lastUsed = false
            continue
        end

        tableExtra[#tableExtra + 1] = v
    end

    local dispatchData = tableExtra[math.random(1, #tableExtra)]

    ix.chat.Send(nil, "cmb_dispatch", dispatchData.text)
    dispatchData.lastUsed = true

    for k, v in ipairs(player.GetAll()) do
        if ( Schema:IsOutside(v) ) then
            Schema:PlaySound(v, dispatchData.soundDir, 75, 100, 0.8)
        else
            Schema:PlaySound(v, dispatchData.soundDir, 75, 100, 0.4)
        end
    end
end)

ix.cmbSystems.passiveChatterLines = {
    [FACTION_CP] = {
        "npc/metropolice/vo/blockisholdingcohesive.wav",
        "npc/metropolice/vo/citizensummoned.wav",
        "npc/metropolice/vo/dispupdatingapb.wav",
        "npc/metropolice/vo/holdingon10-14duty.wav",
        "npc/metropolice/vo/investigating10-103.wav",
        "npc/metropolice/vo/loyaltycheckfailure.wav",
        "npc/metropolice/vo/pickingupnoncorplexindy.wav",
        "npc/metropolice/vo/unitisonduty10-8.wav",
        "npc/metropolice/vo/ihave10-30my10-20responding.wav",
        "npc/overwatch/radiovoice/politistablizationmarginal.wav",
        "npc/overwatch/radiovoice/remindermemoryreplacement.wav",
        "npc/overwatch/radiovoice/rewardnotice.wav"
    },
    [FACTION_OTA] = {
        "npc/combine_soldier/vo/prison_soldier_activatecentral.wav",
        "npc/combine_soldier/vo/prison_soldier_boomersinbound.wav",
        "npc/combine_soldier/vo/prison_soldier_bunker1.wav",
        "npc/combine_soldier/vo/prison_soldier_bunker2.wav",
        "npc/combine_soldier/vo/prison_soldier_bunker3.wav",
        "npc/combine_soldier/vo/prison_soldier_containd8.wav",
        "npc/combine_soldier/vo/prison_soldier_fallback_b4.wav",
        "npc/combine_soldier/vo/prison_soldier_fullbioticoverrun.wav",
        "npc/combine_soldier/vo/prison_soldier_prosecuted7.wav",
        "npc/combine_soldier/vo/prison_soldier_sundown3dead.wav",
        "npc/combine_soldier/vo/prison_soldier_tohighpoints.wav",
        "npc/combine_soldier/vo/prison_soldier_visceratorsa5.wav"
    }
}

function ix.cmbSystems:PassiveChatter(ply)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( ply:IsAdmin() and ply:GetNoDraw() and ply:GetMoveType() == MOVETYPE_NOCLIP ) then
        return
    end

    local chatterLines = ix.cmbSystems.passiveChatterLines[char:GetFaction()]

    if not ( chatterLines ) then
        return
    end

    if not ( ( ply.isReadyForChatter or true ) ) then
        return
    end

    local line = chatterLines[math.random(1, #chatterLines)]

    local sounds = {}

    if ( Schema:IsCP(ply) ) then
        sounds = {"npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav"}
    elseif ( Schema:IsOTA(ply) ) then
        sounds = {"ambient/levels/prison/radio_random" .. math.random(1, 15) .. ".wav"}
    end

    sounds[#sounds + 1] = line

    if ( Schema:IsCP(ply) ) then
        sounds[#sounds + 1] = "npc/metropolice/vo/off" .. math.random(1, 4) .. ".wav"
    elseif ( Schema:IsOTA(ply) ) then
        sounds[#sounds + 1] = "ambient/levels/prison/radio_random" .. math.random(1, 15) .. ".wav"
    end

    if ( hook.Run("GetPlayerChatterSounds", ply, sounds) != nil ) then
        sounds = hook.Run("GetPlayerChatterSounds", ply, sounds) or sounds
    end

    if ( hook.Run("CanPlayerEmitChatter", ply, sounds) != false ) then
        local length = ix.util.EmitQueuedSounds(ply, sounds, 0, 0.1, 35, math.random(90, 105))
        ply.isReadyForChatter = false

        if not ( timer.Exists("ix.ChatterCooldown" .. ply:SteamID64()) ) then
            timer.Create("ix.CmbChatterCooldown" .. ply:SteamID64(), length, 1, function()
                if ( IsValid(ply) ) then
                    ply.isReadyForChatter = true
                end
            end)
        end
    end
end

util.AddNetworkString("ix.MakeWaypoint")
function ix.cmbSystems:MakeWaypoint(data)
    if not ( istable(data) ) then
        ErrorNoHalt("Attempted to create a waypoint with invalid data!")
        
        return
    end

    if not ( data.text ) then
        ErrorNoHalt("Attempted to create a waypoint without text!")
        return
    end

    data.sentBy = data.sentBy or "Dispatch"

    if not ( data.duration ) then
        data.duration = 5
    end

    data.duration = CurTime() + data.duration

    if not ( data.pos ) then
        ErrorNoHalt("Attempted to create a waypoint with no Pos (Vector)!")

        return
    end

    net.Start("ix.MakeWaypoint")
        net.WriteTable(data or {})
    net.Broadcast()
end