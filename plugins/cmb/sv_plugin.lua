local PLUGIN = PLUGIN

util.AddNetworkString("ix.Combine.SetCityCode")
util.AddNetworkString("ix.Combine.ToggleBOL")
util.AddNetworkString("ix.Combine.GiveLP")
util.AddNetworkString("ix.Combine.TakeLP")
util.AddNetworkString("ix.Combine.RemoveObjective")

net.Receive("ix.Combine.RemoveObjective", function(len, ply)
    if ( ( ix.cmbSystems.nextRemoveObjectiveCountdown or 0 ) > CurTime() ) then
        return
    end

    ix.cmbSystems.nextRemoveObjectiveCountdown = CurTime() + 0.5
    
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

    if not ( Schema:IsCPRankLeader(ply) or Schema:IsOWElite(ply) or ply:IsAdmin() ) then
        return
    end

    local id = net.ReadUInt(8)

    if not ( id ) then
        return
    end

    if not ( ix.cmbSystems.Objectives.Stored[id] ) then
        return
    end

    ix.cmbSystems.Objectives:RemoveObjective(id)
end)

net.Receive("ix.Combine.GiveLP", function(len, ply)
    if ( ( ix.cmbSystems.giveLPCountdown or 0 ) > CurTime() ) then
        return
    end

    ix.cmbSystems.giveLPCountdown = CurTime() + 0.5

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
    if ( ( ix.cmbSystems.nextTakeLPCountdown or 0 ) > CurTime() ) then
        return
    end

    ix.cmbSystems.nextTakeLPCountdown = CurTime() + 0.5

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
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( ( ix.nextCityCodeChange or 0 ) > CurTime() ) then
        ply:Notify("You must wait " .. math.Round(ix.nextCityCodeChange - CurTime()) .. " more second(s) before changing the city code again.")

        return
    end

    local id = net.ReadUInt(8)
    local codeData = ix.cmbSystems.CityCodes.Stored[id]    

    if not ( codeData ) then
        return
    end

    if not ( Schema:IsCombine(ply) ) then
        return
    end

    if not ( Schema:IsCPRankLeader(ply) or Schema:IsOWElite(ply) or ply:IsAdmin() ) then
        return
    end

    ix.cmbSystems.CityCodes:Set(id)
    ix.nextCityCodeChange = CurTime() + (ply:IsAdmin() and 2 or 10)
end)

net.Receive("ix.Combine.ToggleBOL", function(len, ply)
    if ( ( ix.cmbSystems.nextBOLSet or 0 ) > CurTime() ) then
        return
    end

    ix.cmbSystems.nextBOLSet = CurTime() + 0.5

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

function ix.cmbSystems.CityCodes:Set(id)
    local codeData = ix.cmbSystems.CityCodes.Stored[ix.cmbSystems.CityCodes:Get()]

    if ( codeData.onEnd ) then
        codeData:onEnd()
    end

    SetGlobalInt("ixCityCode", id)

    codeData = ix.cmbSystems.CityCodes.Stored[ix.cmbSystems.CityCodes:Get()]

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
            return ( ix.cmbSystems.CityCodes:Get() >= 2 )
        end
    }
}

timer.Remove("ix.DispatchPassive")
timer.Create("ix.DispatchPassive", ix.config.Get("passiveDispatchCooldown", 120), 0, function()
    local cityCode = ix.cmbSystems.CityCodes.Stored[ix.cmbSystems.CityCodes:Get()]

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
    [FACTION_OW] = {
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
    elseif ( Schema:IsOW(ply) ) then
        sounds = {"ambient/levels/prison/radio_random" .. math.random(1, 15) .. ".wav"}
    end

    sounds[#sounds + 1] = line

    if ( Schema:IsCP(ply) ) then
        sounds[#sounds + 1] = "npc/metropolice/vo/off" .. math.random(1, 4) .. ".wav"
    elseif ( Schema:IsOW(ply) ) then
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

util.AddNetworkString("ix.cmbSystems.SyncSquads")
function ix.cmbSystems.Squads:CreateSquad(ply, squadData)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( istable(squadData) ) then
        ErrorNoHalt("Attempted to create a squad with invalid data!")
        
        return
    end

    if not ( squadData.name ) then
        squadData.name = "PT-" .. #ix.cmbSystems.Squads.Stored
        
        return
    end

    squadData.leader = ply
    squadData.members = squadData.members or {ply}
    squadData.limit = squadData.limit or ix.config.Get("squadLimit", 4)

    table.insert(ix.cmbSystems.Squads.Stored, squadData)

    local filter = RecipientFilter()
    filter:AddAllPlayers()

    char:SetData("squadID", #ix.cmbSystems.Squads.Stored, false, filter)

    net.Start("ix.cmbSystems.SyncSquads")
        net.WriteTable(ix.cmbSystems.Squads.Stored)
    net.Broadcast()
end

function ix.cmbSystems.Squads:InsertMember(ply, id)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( ix.cmbSystems.Squads.Stored[id] ) then
        return
    end

    if not ( ix.cmbSystems.Squads.Stored[id].members ) then
        return
    end

    if ( table.HasValue(ix.cmbSystems.Squads.Stored[id].members, ply) ) then
        return
    end

    if ( #ix.cmbSystems.Squads.Stored[id].members >= ix.cmbSystems.Squads.Stored[id].limit ) then
        return
    end

    table.insert(ix.cmbSystems.Squads.Stored[id].members, ply)


    local filter = RecipientFilter()
    filter:AddAllPlayers()

    char:SetData("squadID", id, false, filter)

    net.Start("ix.cmbSystems.SyncSquads")
        net.WriteTable(ix.cmbSystems.Squads.Stored)
    net.Broadcast()
end

function ix.cmbSystems.Squads:RemoveMember(ply, id)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( ix.cmbSystems.Squads.Stored[id] ) then
        return
    end

    if not ( ix.cmbSystems.Squads.Stored[id].members ) then
        return
    end

    if ( table.HasValue(ix.cmbSystems.Squads.Stored[id].members, ply) ) then
        if ( ply == ix.cmbSystems.Squads.Stored[id].leader ) then
            local sortedTable = ix.cmbSystems.Squads.Stored[id].members

            table.RemoveByValue(sortedTable, ply)

            table.sort(sortedTable, function(a, b)
                return ( a:GetCharacter():GetRank() or 0 ) > ( b:GetCharacter():GetRank() or 0 )
            end)

            ix.cmbSystems.Squads.Stored[id].leader = sortedTable[1]
        end

        table.RemoveByValue(ix.cmbSystems.Squads.Stored[id].members, ply)

        local filter = RecipientFilter()
        filter:AddAllPlayers()

        char:SetData("squadID", -1, false, filter)

        if ( #ix.cmbSystems.Squads.Stored[id].members <= 0 ) then
            ix.cmbSystems.Squads:RemoveSquad(id)
        end

        net.Start("ix.cmbSystems.SyncSquads")
            net.WriteTable(ix.cmbSystems.Squads.Stored)
        net.Broadcast()
    end
end

function ix.cmbSystems.Squads:RemoveSquad(id)
    if not ( id ) then
        return
    end

    if not ( ix.cmbSystems.Squads.Stored[id] ) then
        return
    end

    for k, v in ipairs(ix.cmbSystems.Squads.Stored[id].members) do
        if not ( IsValid(v) ) then
            continue
        end

        local char = v:GetCharacter()

        if not ( char ) then
            continue
        end

        local filter = RecipientFilter()
        filter:AddAllPlayers()

        char:SetData("squadID", -1, false, filter)
    end

    table.remove(ix.cmbSystems.Squads.Stored, id)

    net.Start("ix.cmbSystems.SyncSquads")
        net.WriteTable(ix.cmbSystems.Squads.Stored)
    net.Broadcast()
end

util.AddNetworkString("ix.cmbSystems.SyncObjectives")
function ix.cmbSystems.Objectives:NewObjective(objectiveData)
    if not ( istable(objectiveData) ) then
        ErrorNoHalt("Attempted to create an objective with invalid data!")
        
        return
    end

    if not ( objectiveData.text ) then
        ErrorNoHalt("Attempted to create an objective without text!")
        return
    end

    objectiveData.sentBy = objectiveData.sentBy or "Dispatch"

    ix.cmbSystems.Objectives.Stored[#ix.cmbSystems.Objectives.Stored + 1] = objectiveData

    net.Start("ix.cmbSystems.SyncObjectives")
        net.WriteTable(ix.cmbSystems.Objectives.Stored)
    net.Broadcast()
end

function ix.cmbSystems.Objectives:SetPriorityObjective(id, bPriority)
    if not ( ix.cmbSystems.Objectives.Stored[id] ) then
        return
    end

    bPriority = bPriority or false

    ix.cmbSystems.Objectives.Stored[id].priority = bPriority

    net.Start("ix.cmbSystems.SyncObjectives")
        net.WriteTable(ix.cmbSystems.Objectives.Stored)
    net.Broadcast()
end

function ix.cmbSystems.Objectives:RemoveObjective(id)
    if not ( ix.cmbSystems.Objectives.Stored[id] ) then
        return
    end

    ix.cmbSystems.Objectives.Stored[id] = nil

    net.Start("ix.cmbSystems.SyncObjectives")
        net.WriteTable(ix.cmbSystems.Objectives.Stored)
    net.Broadcast()
end

util.AddNetworkString("ix.cmbSystems.SyncDeployments")
function ix.cmbSystems.Deployments:InsertMember(ply, uID)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    local deploymentData = ix.cmbSystems.Deployments.Stored[uID]

    if not ( deploymentData ) then
        return
    end

    if not ( deploymentData.units ) then
        deploymentData.units = {}
    end

    if ( deploymentData.map and not deploymentData.map == game.GetMap() ) then
        return
    end

    if ( table.HasValue(deploymentData.units, ply:GetChar():GetID()) ) then
        return
    end

    if ( deploymentData.limit and #deploymentData.units >= deploymentData.limit ) then
        return
    end

    table.insert(deploymentData.units, ply:GetChar():GetID())
    
    net.Start("ix.cmbSystems.SyncDeployments")
        net.WriteTable(ix.cmbSystems.Deployments.Stored)
    net.Broadcast()
end

function ix.cmbSystems.Deployments:RemoveMember(ply, uID)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    local deploymentData = ix.cmbSystems.Deployments.Stored[uID]

    if not ( deploymentData ) then
        return
    end

    if ( deploymentData.map and not deploymentData.map == game.GetMap() ) then
        return
    end

    if not ( deploymentData.units ) then
        deploymentData.units = {}
    end

    if ( table.HasValue(deploymentData.units, ply:GetChar():GetID()) ) then
        table.RemoveByValue(deploymentData.units, ply:GetChar():GetID())
    end

    net.Start("ix.cmbSystems.SyncDeployments")
        net.WriteTable(ix.cmbSystems.Deployments.Stored or {})
    net.Broadcast()
end

function ix.cmbSystems.Deployments:Start(uID)
    local deploymentData = ix.cmbSystems.Deployments.Stored[uID]

    if not ( deploymentData ) then
        return
    end

    if ( deploymentData.map and not deploymentData.map == game.GetMap() ) then
        return
    end

    if not ( deploymentData.units or not table.IsEmpty(self.units) ) then
        return
    end

    for k, v in ipairs(deploymentData.units) do
        v = ix.char.loaded[v]

        if not ( v ) then
            table.RemoveByValue(deploymentData.units, v:GetID())
        end

        local charPly = v:GetPlayer()

        if not ( IsValid(charPly) ) then
            table.RemoveByValue(deploymentData.units, v:GetID())
        end
    end

    deploymentData.id = uID
        local runID = deploymentData.funcID or uID
        if ( ix.cmbSystems.Deployments.Functions[runID] ) then
            ix.cmbSystems.Deployments.Functions[runID](deploymentData)
        end
    deploymentData.id = nil
end