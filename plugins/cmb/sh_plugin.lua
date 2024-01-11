local PLUGIN = PLUGIN

PLUGIN.name = "Combine Systems"
PLUGIN.author = "eon"
PLUGIN.description = "Self-Explanatory, adds main Combine Functions."
PLUGIN.license = [[
Copyright 2024 eon (bloodycop)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.cmbSystems = ix.cmbSystems or {}
ix.cmbSystems.squads = ix.cmbSystems.squads or {}
ix.cmbSystems.objectives = ix.cmbSystems.objectives or {}
ix.cmbSystems.dispatchNumbers = {
    [1] = "npc/overwatch/radiovoice/one.wav",
    [2] = "npc/overwatch/radiovoice/two.wav",
    [3] = "npc/overwatch/radiovoice/three.wav",
    [4] = "npc/overwatch/radiovoice/four.wav",
    [5] = "npc/overwatch/radiovoice/five.wav",
    [6] = "npc/overwatch/radiovoice/six.wav",
    [7] = "npc/overwatch/radiovoice/seven.wav",
    [8] = "npc/overwatch/radiovoice/eight.wav",
    [9] = "npc/overwatch/radiovoice/nine.wav",
    [10] = "npc/overwatch/radiovoice/ten.wav",
}

ix.cmbSystems.dispatchTaglines = {
    ["union"] = "npc/overwatch/radiovoice/union.wav",
    ["defender"] = "npc/overwatch/radiovoice/defender.wav",
    ["hero"] = "npc/overwatch/radiovoice/hero.wav",
    ["jury"] = "npc/overwatch/radiovoice/jury.wav",
    ["king"] = "npc/overwatch/radiovoice/king.wav",
    ["line"] = "npc/overwatch/radiovoice/line.wav",
    ["quick"] = "npc/overwatch/radiovoice/quick.wav",
    ["roller"] = "npc/overwatch/radiovoice/roller.wav",
    ["stick"] = "npc/overwatch/radiovoice/stick.wav",
    ["tap"] = "npc/overwatch/radiovoice/tap.wav",
    ["victor"] = "npc/overwatch/radiovoice/victor.wav",
    ["xray"] = "npc/overwatch/radiovoice/xray.wav"
}

ix.config.Add("passiveDispatchCooldown", 120, "How long should the passive dispatch cooldown be?", function(oldV, newV)
    if ( SERVER ) then
        timer.Adjust("ix.DispatchPassive", newV)
    end
end, {
    category = "Combine Systems",
    data = {min = 1, max = 3600},
})

ix.lang.AddTable("english", {
	optCombineOverlay = "Combine Overlay",
    optCombineOverlayAssets = "Combine Overlay - Assets",
    optCombineOutlineDeployables = "Combine Outline - Deployables",
    optCombineOutlineAssets = "Combine Outline - Assets",
    optCombineOutlineAssetsTeamOnly = "Combine Outline Assets - Team Only",
    optCombineOutlineNPCs = "Combine Outline - NPCs",
    optCombineOutlineColorNPCsEnemy = "Combine Outline Color - Enemy NPCs",
    optCombineOutlineColorNPCsFriendlyFallback = "Combine Outline Color - Friendly NPCs Fallback",
    optCombineOverlaySquad = "Combine Overlay - Squad",
    optCombineOverlaySquadHealth = "Combine Overlay - Squad Health",
    optCombineOverlaySquadColor = "Combine Overlay - Squad Color",
    optCombineOverlaySquadOutline = "Combine Overlay - Squad Outline",
    optCombineOverlaySquadOutlineColor = "Combine Overlay - Squad Outline Color",
    optDispatchAnnouncementType = "Dispatch Announcement Type",

    optdCombineOverlay = "Should the combine overlay be enabled",
    optdCombineOverlayAssets = "Should there be an overlay on close assets",
    optdCombineOutlineDeployables = "Should your deployed entities be outlined",
    optdCombineOutlineAssets = "Should your teammates be outlined",
    optdCombineOutlineAssetsTeamOnly = "Should Outline Assets only apply to teammates.",
    optdCombineOutlineNPCs = "Should combine npcs be outlined.",
    optdCombineOutlineColorNPCsEnemy = "What color should enemy npcs be outlined as.",
    optdCombineOutlineColorNPCsFriendlyFallback = "What color should friendly npcs be outlined as.",
    optdCombineOverlaySquad = "Should the combine overlay display squad member(s).",
    optdCombineOverlaySquadHealth = "Should the combine overlay display squad member(s) health.",
    optdCombineOverlaySquadColor = "What color should the combine overlay display squad member(s) as.",
    optdCombineOverlaySquadOutline = "Should the combine overlay display squad member(s) outline.",
    optdCombineOverlaySquadOutlineColor = "What color should the combine overlay display squad member(s) outline as.",
    optdDispatchAnnouncementType = "What type of announcement should dispatch make.",
})

ix.option.Add("dispatchAnnouncementType", ix.type.array, "chat_sound", {
    category = "Combine Systems",
    bNetworked = true,
	populate = function()
        local types = {}

        types["chat_sound"] = "Chat + Sound"
        types["chat"] = "Chat"
        types["sound"] = "Sound"

        return types
    end,
})

ix.config.Add("passiveChatterCooldown", 120, "How long should the passive chatter cooldown be?", function(oldV, newV)
    if ( SERVER ) then
        for k, v in ipairs(player.GetAll()) do
            if not ( IsValid(v) ) then 
                continue
            end

            local char = v:GetCharacter()

            if not ( char ) then
                continue
            end

            if not ( Schema:IsCombine(v) ) then
                continue
            end
            
            timer.Adjust("ix.PassiveChatter." .. char:GetID(), newV)
        end
    end
end, {
    category = "Combine Systems",
    data = {min = 1, max = 3600},
})

ix.config.Add("grenadeCooldown", 30, "How long should the grenade cooldown be?", nil, {
    category = "Combine Systems",
    data = {min = 1, max = 3600},
})

ix.config.Add("squadLimit", 4, "How many units can be in a squad?", nil, {
    category = "Combine Systems",
    data = {min = 1, max = 40},
})

ix.char.RegisterVar("bOLStatus", {
    field = "bol_status",
    fieldType = ix.type.bool,
    default = false,
    isLocal = false,
    bNoDisplay = true,
})

ix.char.RegisterVar("loyaltyPoints", {
    field = "loyalty_points",
    fieldType = ix.type.number,
    default = 0,
    isLocal = false,
    bNoDisplay = true,
})

ix.char.RegisterVar("sterilizationCredits", {
    field = "sterilization_credits",
    fieldType = ix.type.number,
    default = 0,
    isLocal = false,
    bNoDisplay = true,
})

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")

local heliSounds = {
    "ambient/machines/heli_pass_distant1.wav",
    "ambient/machines/heli_pass1.wav",
    "ambient/machines/heli_pass2.wav",
    "ambient/levels/streetwar/heli_distant1.wav"
}

local extraExplosions = {
    "ambient/explosions/explode_5.wav",
    "ambient/explosions/explode_8.wav"
}

function PLUGIN:InitPostEntity()
    if ( SERVER ) then
        ix.cmbSystems:SetCityCode(1)
    end
end

ix.cmbSystems.cityCodes = {
    {
        name = "Preserved",
        color = Color(0, 255, 0),
        onStart = function()
            timer.Create("ixPreserved.HeliFlyBy", math.random(10, 80), 0, function()
                for k, v in ipairs(player.GetAll()) do
                    if not ( IsValid(v) ) then
                        continue
                    end

                    if not ( v:GetCharacter() ) then
                        continue
                    end

                    if not ( v:Alive() ) then
                        continue
                    end

                    if ( Schema:IsOutside(v) ) then
                        Schema:PlaySound(v, heliSounds[math.random(1, #heliSounds)], 75, 100, 0.7)
                    else
                        Schema:PlaySound(v, heliSounds[math.random(1, #heliSounds)], 75, 100, 0.4)
                    end
                end
            end)
        end,
        onEnd = function()
            timer.Remove("ixPreserved.HeliFlyBy")
        end,
        dispatchPassive = function()
            local dispatchData = ix.cmbSystems.dispatchPassive[math.random(1, #ix.cmbSystems.dispatchPassive)]

            if not ( dispatchData ) then
                return
            end

            for k, v in ipairs(player.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end

                if not ( v:GetCharacter() ) then
                    continue
                end

                if not ( v:Alive() ) then
                    continue
                end

                if ( ix.option.Get(v, "dispatchAnnouncementType", "chat_sound") == "chat_sound" or ix.option.Get(v, "dispatchAnnouncementType", "chat_sound") == "sound" ) then
                    if ( Schema:IsOutside(v) ) then
                        Schema:PlaySound(v, dispatchData.soundDir, 75, 100, 0.7)
                    else
                        Schema:PlaySound(v, dispatchData.soundDir, 75, 100, 0.4)
                    end
                end
            end

            ix.useDispatchHearCheck = true
            ix.chat.Send(nil, "cmb_dispatch", dispatchData.text)
        end
    },
    {
        name = "Marginal",
        color = Color(255, 255, 0),
        onStart = function()
            ix.chat.Send(nil, "cmb_dispatch", "Attention community: unrest procedure code is now in effect. Inoculate, shield, pacify. Code: pressure, sword, sterilize.")
            
            for k, v in ipairs(player.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end

                if ( Schema:IsOutside(v) ) then
                    Schema:PlaySound(v, "ambient/alarms/apc_alarm_pass1.wav", 75, 100, 0.6)
                else
                    Schema:PlaySound(v, "ambient/alarms/apc_alarm_pass1.wav", 75, 100, 0.4)
                end

                if ( Schema:IsOutside(v) ) then
                    Schema:PlaySound(v, "ambient/alarms/manhack_alert_pass1.wav", 75, 100, 0.5)
                else
                    Schema:PlaySound(v, "ambient/alarms/manhack_alert_pass1.wav", 75, 100, 0.4)
                end

                if ( Schema:IsOutside(v) ) then
                    Schema:PlaySound(v, "ambient/alarms/scanner_alert_pass1.wav", 75, 100, 0.5)
                else
                    Schema:PlaySound(v, "ambient/alarms/scanner_alert_pass1.wav", 75, 100, 0.4)
                end

                if ( Schema:IsOutside(v) ) then
                    Schema:PlaySound(v, "npc/overwatch/cityvoice/f_unrestprocedure1_spkr.wav", 75, 100, 0.7)
                else
                    Schema:PlaySound(v, "npc/overwatch/cityvoice/f_unrestprocedure1_spkr.wav", 75, 100, 0.5)
                end
            
                if not ( timer.Exists("ixMarginal.HeliFlyBy") ) then
                    timer.Create("ixMarginal.HeliFlyBy", math.random(40, 80), 0, function()
                        if ( Schema:IsOutside(v) ) then
                            Schema:PlaySound(v, heliSounds[math.random(1, #heliSounds)], 75, 100, 0.7)
                        else
                            Schema:PlaySound(v, heliSounds[math.random(1, #heliSounds)], 75, 100, 0.4)
                        end
                    end)
                end
            end
        end,
        onEnd = function()
            timer.Remove("ixMarginal.HeliFlyBy")
        end
    },
    {
        name = "Autonomous Judgment",
        color = Color(255, 0, 0),
        onStart = function()
            ix.chat.Send(nil, "cmb_dispatch", "Attention all Ground Protection Teams: Autonomous judgment is now in effect. Sentencing is now discretionary. Code: amputate, zero, confirm.")
            
            for k, v in ipairs(player.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end
                
                if ( Schema:IsOutside(v) ) then
                    Schema:PlaySound(v, "npc/overwatch/cityvoice/f_protectionresponse_4_spkr.wav", 75, 100, 0.8)
                else
                    Schema:PlaySound(v, "npc/overwatch/cityvoice/f_protectionresponse_4_spkr.wav", 75, 100, 0.5)
                end
            end

            Schema:PlaySound(player.GetAll(), "ambient/alarms/citadel_alert_loop2.wav", 75, 100, 0.7)
            Schema:PlaySound(player.GetAll(), "ambient/alarms/manhack_alert_pass1.wav", 75, 100, 0.6)
            Schema:PlaySound(player.GetAll(), "ambient/alarms/apc_alarm_pass1.wav", 75, 100, 0.6)

            timer.Create("ix.AutonomousJudgment.hit1", SoundDuration("ambient/alarms/citadel_alert_loop2.wav") - 10, 0, function()
                Schema:PlaySound(player.GetAll(), "ambient/levels/citadel/citadel_hit1_adpcm.wav", 75, 100, 0.6)

                timer.Adjust("ix.AutonomousJudgment.hit1", math.random(120, 400))
            end)

            timer.Create("ix.AutonomousJudgment.SecondSequence", SoundDuration("ambient/alarms/citadel_alert_loop2.wav") - 5, 0, function()
                Schema:PlaySound(player.GetAll(), "ambient/explosions/battle_loop1.wav", 75, 100, 1)

                timer.Create("ix.AutonomousJudgment.StreetWar1", SoundDuration("ambient/explosions/battle_loop1.wav") + math.random(20, 40), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/explosions/battle_loop1.wav", 75, 100, 0.7)
                end)

                timer.Create("ix.AutonomousJudgment.StreetWar2", SoundDuration("ambient/explosions/battle_loop2.wav") + math.random(20, 40), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/explosions/battle_loop2.wav", 75, 100, 0.5)

                    Schema:PlaySound(player.GetAll(), extraExplosions[math.random(1, #extraExplosions)], 75, 100, 0.5)
                end)

                timer.Create("ix.AutonomousJudgment.APCDistant", SoundDuration("ambient/levels/streetwar/apc_distant1.wav"), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/apc_distant" .. math.random(1, 3) .. ".wav", 75, 100, 0.5)
                end)

                timer.Create("ix.AutonomousJudgment.CityBattle", math.random(10, 30), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/city_battle" .. math.random(1, 19) .. ".wav", 75, 100, 0.7)
                end)

                timer.Create("ix.AutonomousJudgment.StriderDistant", math.random(10, 25), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/strider_distant" .. math.random(1, 3) .. ".wav", 75, 100, 0.7)
                end)

                timer.Create("ix.AutonomousJudgment.CityScream", math.random(20, 30), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/city_scream3.wav", 75, 100, 0.7)
                end)

                timer.Create("ix.AutonomousJudgment.GunshipDistant", math.random(10, 30), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/gunship_distant" .. math.random(1, 2) .. ".wav", 75, 100, 0.7)
                end)
                
                timer.Create("ix.AutonomousJudgment.BuildingRubble", math.random(10, 20), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/building_rubble" .. math.random(1, 5) .. ".wav", 75, 100, 0.7)
                end)

                timer.Create("ix.AutonomousJudgment.CitadelScreams", math.random(100, 200), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/citadel/citadel_ambient_scream_loop1.wav", 75, 100, 0.3)
                end)

                timer.Create("ix.AutonomousJudgment.HeliDistant", math.random(10, 25), 0, function()
                    Schema:PlaySound(player.GetAll(), heliSounds[math.random(1, #heliSounds)], 75, 100, 0.7)
                end)
            end)
        end,
        onEnd = function()
            timer.Remove("ix.AutonomousJudgment.hit1")
            timer.Remove("ix.AutonomousJudgment.SecondSequence")
            timer.Remove("ix.AutonomousJudgment.StreetWar1")
            timer.Remove("ix.AutonomousJudgment.StreetWar2")
            timer.Remove("ix.AutonomousJudgment.APCDistant")
            timer.Remove("ix.AutonomousJudgment.CityBattle")
            timer.Remove("ix.AutonomousJudgment.StriderDistant")
            timer.Remove("ix.AutonomousJudgment.CityScream")
            timer.Remove("ix.AutonomousJudgment.GunshipDistant")
            timer.Remove("ix.AutonomousJudgment.BuildingRubble")
            timer.Remove("ix.AutonomousJudgment.CitadelScreams")
            timer.Remove("ix.AutonomousJudgment.HeliDistant")

            for k, v in ipairs(player.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end

                for i = 1, 3 do
                    v:StopSound("ambient/alarms/citadel_alert_loop2.wav")
                    v:StopSound("ambient/alarms/manhack_alert_pass1.wav")
                    v:StopSound("ambient/alarms/apc_alarm_pass1.wav")
                    v:StopSound("ambient/levels/citadel/citadel_hit1_adpcm.wav")

                    for i = 1, 2 do
                        v:StopSound("ambient/explosions/battle_loop1.wav")
                        v:StopSound("ambient/explosions/battle_loop2.wav")
                    end

                    for i = 1, 3 do
                        v:StopSound("ambient/levels/streetwar/apc_distant" .. i .. ".wav")
                    end

                    for i = 1, 19 do
                        v:StopSound("ambient/levels/streetwar/city_battle" .. i .. ".wav")
                    end

                    for i = 1, 3 do
                        v:StopSound("ambient/levels/streetwar/strider_distant" .. i .. ".wav")
                    end

                    v:StopSound("ambient/levels/streetwar/city_scream3.wav")

                    for i = 1, 2 do
                        v:StopSound("ambient/levels/streetwar/gunship_distant" .. i .. ".wav")
                    end

                    for i = 1, 5 do
                        v:StopSound("ambient/levels/streetwar/building_rubble" .. i .. ".wav")
                    end

                    v:StopSound("ambient/levels/citadel/citadel_ambient_scream_loop1.wav")
                    v:StopSound(heliSounds[math.random(1, #heliSounds)])
                end
            end
        end,
        dispatchPassive = function()    
            for k, v in ipairs(player.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end
                
                if ( ix.option.Get(v, "dispatchAnnouncementType", "chat_sound") == "chat_sound" or ix.option.Get(v, "dispatchAnnouncementType", "chat_sound") == "sound" ) then
                    if ( Schema:IsOutside(v) ) then
                        Schema:PlaySound(v, "npc/overwatch/cityvoice/f_protectionresponse_4_spkr.wav", 75, 100, 0.8)
                    else
                        Schema:PlaySound(v, "npc/overwatch/cityvoice/f_protectionresponse_4_spkr.wav", 75, 100, 0.5)
                    end
                end

                ix.useDispatchHearCheck = true
                ix.chat.Send(nil, "cmb_dispatch", "Attention all Ground Protection Teams: Autonomous judgment is now in effect. Sentencing is now discretionary. Code: amputate, zero, confirm.")
            end
        end
    },
    {
        name = "Judgment Waiver",
        color = Color(255, 0, 0),
        onStart = function()
            ix.chat.Send(nil, "cmb_dispatch", "Attention all Ground Protection teams: Judgement waiver now in effect. Capital prosecution is discretionary.")
            
            for k, v in ipairs(player.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end
                
                if ( Schema:IsOutside(v) ) then
                    Schema:PlaySound(v, "npc/overwatch/cityvoice/f_protectionresponse_5_spkr.wav", 75, 100, 0.8)
                else
                    Schema:PlaySound(v, "npc/overwatch/cityvoice/f_protectionresponse_5_spkr.wav", 75, 100, 0.5)
                end
            end

            Schema:PlaySound(player.GetAll(), "ambient/alarms/citadel_alert_loop2.wav", 75, 100, 0.7)
            Schema:PlaySound(player.GetAll(), "ambient/alarms/manhack_alert_pass1.wav", 75, 100, 0.6)
            Schema:PlaySound(player.GetAll(), "ambient/alarms/apc_alarm_pass1.wav", 75, 100, 0.6)
            Schema:PlaySound(player.GetAll(), "ambient/alarms/scanner_alert_pass1.wav", 75, 100, 0.6)            

            timer.Create("ix.JudgmentWaiver.hit1", SoundDuration("ambient/alarms/citadel_alert_loop2.wav") - 10, 0, function()
                Schema:PlaySound(player.GetAll(), "ambient/levels/citadel/citadel_hit1_adpcm.wav", 75, 100, 0.6)

                timer.Adjust("ix.JudgmentWaiver.hit1", math.random(120, 400))
            end)

            timer.Create("ix.JudgmentWaiver.SecondSequence", SoundDuration("ambient/alarms/citadel_alert_loop2.wav") - 5, 0, function()
                Schema:PlaySound(player.GetAll(), "ambient/explosions/battle_loop1.wav", 75, 100, 1)

                timer.Create("ix.JudgmentWaiver.StreetWar1", SoundDuration("ambient/explosions/battle_loop1.wav") + math.random(20, 40), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/explosions/battle_loop1.wav", 75, 100, 0.7)
                end)

                timer.Create("ix.JudgmentWaiver.StreetWar2", SoundDuration("ambient/explosions/battle_loop2.wav") + math.random(20, 40), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/explosions/battle_loop2.wav", 75, 100, 0.5)

                    Schema:PlaySound(player.GetAll(), extraExplosions[math.random(1, #extraExplosions)], 75, 100, 0.5)
                end)

                timer.Create("ix.JudgmentWaiver.APCDistant", SoundDuration("ambient/levels/streetwar/apc_distant1.wav"), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/apc_distant" .. math.random(1, 3) .. ".wav", 75, 100, 0.5)
                end)

                timer.Create("ix.JudgmentWaiver.CityBattle", math.random(10, 30), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/city_battle" .. math.random(1, 19) .. ".wav", 75, 100, 0.7)
                end)

                timer.Create("ix.JudgmentWaiver.StriderDistant", math.random(10, 25), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/strider_distant" .. math.random(1, 3) .. ".wav", 75, 100, 0.7)
                end)

                timer.Create("ix.JudgmentWaiver.CityScream", math.random(20, 30), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/city_scream3.wav", 75, 100, 0.7)
                end)

                timer.Create("ix.JudgmentWaiver.GunshipDistant", math.random(10, 30), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/gunship_distant" .. math.random(1, 2) .. ".wav", 75, 100, 0.7)
                end)
                
                timer.Create("ix.JudgmentWaiver.BuildingRubble", math.random(10, 20), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/building_rubble" .. math.random(1, 5) .. ".wav", 75, 100, 0.7)
                end)

                timer.Create("ix.JudgmentWaiver.CitadelScreams", math.random(100, 200), 0, function()
                    Schema:PlaySound(player.GetAll(), "ambient/levels/citadel/citadel_ambient_scream_loop1.wav", 75, 100, 0.3)
                end)

                timer.Create("ix.JudgmentWaiver.HeliDistant", math.random(10, 25), 0, function()
                    Schema:PlaySound(player.GetAll(), heliSounds[math.random(1, #heliSounds)], 75, 100, 0.7)
                end)

                timer.Create("ix.JudgmentWaiver.Earthquakes", math.random(10, 20), 0, function()
                    for k, v in ipairs(player.GetAll()) do
                        if not ( IsValid(v) ) then
                            continue
                        end

                        if not ( v:GetCharacter() ) then
                            continue
                        end

                        if not ( v:Alive() ) then
                            continue
                        end

                        util.ScreenShake(v:GetPos(), math.random(1, 10), math.random(1, 10), math.random(1, 7), 1000)
                    end
                end)
            end)
        end,
        onEnd = function()
            timer.Remove("ix.JudgmentWaiver.hit1")
            timer.Remove("ix.JudgmentWaiver.SecondSequence")
            timer.Remove("ix.JudgmentWaiver.StreetWar1")
            timer.Remove("ix.JudgmentWaiver.StreetWar2")
            timer.Remove("ix.JudgmentWaiver.APCDistant")
            timer.Remove("ix.JudgmentWaiver.CityBattle")
            timer.Remove("ix.JudgmentWaiver.StriderDistant")
            timer.Remove("ix.JudgmentWaiver.CityScream")
            timer.Remove("ix.JudgmentWaiver.GunshipDistant")
            timer.Remove("ix.JudgmentWaiver.BuildingRubble")
            timer.Remove("ix.JudgmentWaiver.CitadelScreams")
            timer.Remove("ix.JudgmentWaiver.HeliDistant")
            timer.Remove("ix.JudgmentWaiver.Earthquakes")

            for k, v in ipairs(player.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end

                for i = 1, 3 do
                    v:StopSound("ambient/alarms/citadel_alert_loop2.wav")
                    v:StopSound("ambient/alarms/manhack_alert_pass1.wav")
                    v:StopSound("ambient/alarms/apc_alarm_pass1.wav")
                    v:StopSound("ambient/levels/citadel/citadel_hit1_adpcm.wav")

                    for i = 1, 2 do
                        v:StopSound("ambient/explosions/battle_loop1.wav")
                        v:StopSound("ambient/explosions/battle_loop2.wav")
                    end

                    for i = 1, 3 do
                        v:StopSound("ambient/levels/streetwar/apc_distant" .. i .. ".wav")
                    end

                    for i = 1, 19 do
                        v:StopSound("ambient/levels/streetwar/city_battle" .. i .. ".wav")
                    end

                    for i = 1, 3 do
                        v:StopSound("ambient/levels/streetwar/strider_distant" .. i .. ".wav")
                    end

                    v:StopSound("ambient/levels/streetwar/city_scream3.wav")

                    for i = 1, 2 do
                        v:StopSound("ambient/levels/streetwar/gunship_distant" .. i .. ".wav")
                    end

                    for i = 1, 5 do
                        v:StopSound("ambient/levels/streetwar/building_rubble" .. i .. ".wav")
                    end

                    v:StopSound("ambient/levels/citadel/citadel_ambient_scream_loop1.wav")
                    v:StopSound(heliSounds[math.random(1, #heliSounds)])
                end
            end
        end,
        dispatchPassive = function()    
            for k, v in ipairs(player.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end
                
                if ( ix.option.Get(v, "dispatchAnnouncementType", "chat_sound") == "chat_sound" or ix.option.Get(v, "dispatchAnnouncementType", "chat_sound") == "sound" ) then
                    if ( Schema:IsOutside(v) ) then
                        Schema:PlaySound(v, "npc/overwatch/cityvoice/f_protectionresponse_5_spkr.wav", 75, 100, 0.8)
                    else
                        Schema:PlaySound(v, "npc/overwatch/cityvoice/f_protectionresponse_5_spkr.wav", 75, 100, 0.5)
                    end
                end

                ix.useDispatchHearCheck = true
                ix.chat.Send(nil, "cmb_dispatch", "Attention all Ground Protection teams: Judgement waiver now in effect. Capital prosecution is discretionary.")
            end
        end
    }
}

function ix.cmbSystems:GetCityCode()
    return GetGlobalInt("ixCityCode", 1)
end

function PLUGIN:InitializedChatClasses()
    ix.chat.Register("cmb_global", {
        CanHear = function(self, speaker, listener)
            if not ( IsValid(listener) ) then
                return false
            end

            local char = listener:GetCharacter()

            if not ( char ) then
                return false
            end

            if not ( listener:Alive() ) then
                return false
            end

            if not ( Schema:IsCombine(listener) ) then
                return false
            end

            if ( ix.chat.classes["ic"]:CanHear(speaker, listener) ) then
                return true
            end
            
            return true
        end,
        CanSay = function(self, speaker, text)
            if not ( IsValid(speaker) ) then
                return false
            end

            local char = speaker:GetCharacter()

            if not ( char ) then
                return false
            end

            if not ( speaker:Alive() ) then
                return false
            end

            if not ( Schema:IsCombine(speaker) ) then
                return false
            end
            
            return true
        end,
        OnChatAdd = function(self, speaker, text)
            chat.AddText(Color(0, 100, 170), "[CMB] " .. speaker:GetChar():GetName() .. ": " .. text)
        end,
        prefix = {"/cmbradio", "/cmbr"},
        font = "ixMonoMediumFont",
    })

    ix.chat.Register("cmb_ow", {
        CanHear = function(self, speaker, listener)
            if not ( IsValid(listener) ) then
                return false
            end

            local char = listener:GetCharacter()

            if not ( char ) then
                return false
            end

            if not ( listener:Alive() ) then
                return false
            end

            if ( ix.chat.classes["ic"]:CanHear(speaker, listener) ) then
                return true
            end

            if not ( Schema:IsOW(listener) ) then
                return false
            end

            return true
        end,
        CanSay = function(self, speaker, text)
            if not ( IsValid(speaker) ) then
                return false
            end

            local char = speaker:GetCharacter()

            if not ( char ) then
                return false
            end

            if not ( speaker:Alive() ) then
                return false
            end

            if not ( Schema:IsOW(speaker) ) then
                return false
            end
            
            return true
        end,
        OnChatAdd = function(self, speaker, text)
            chat.AddText(Color(170, 0, 0), "*[CMB-OTA] " .. speaker:GetChar():GetName() .. ": " .. text .. "*")
        end,
        prefix = {"/otaradio", "/otar"},
        font = "ixMonoMediumFont",
    })

    ix.chat.Register("cmb_dispatch", {
        CanHear = function(self, speaker, listener)
            if not ( IsValid(listener) ) then
                return false
            end

            if ( ( ix.useDispatchHearCheck or false ) ) then
                if not ( ix.option.Get(listener, "dispatchAnnouncementType", "chat_sound") == "chat_sound" or ix.option.Get(listener, "dispatchAnnouncementType", "chat_sound") == "chat" ) then
                    return false
                end

                ix.useDispatchHearCheck = false
            end

            return true
        end,
        CanSay = function(self, speaker, text)
            if not ( IsValid(speaker) ) then
                return true
            end
            
            return false
        end,
        OnChatAdd = function(self, speaker, text)
            chat.AddText(Color(185, 40, 0), "*Dispatch: " .. text .. "*")
        end,
        font = "ixGenericFont",
    })
end

function PLUGIN:OnReloaded()
    self:InitializedChatClasses()
end

ix.command.Add("CreateSquad", {
    description = "Creates a new squad",
    arguments = {
        ix.type.string,
        bit.bor(ix.type.number, ix.type.optional)
    },
    OnRun = function(self, ply, name, limit)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( ply:Alive() ) then
            return
        end

        if not ( Schema:IsCombine(ply) ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        if not ( limit ) then
            limit = ix.config.Get("squadLimit", 4)
        end

        if not ( isnumber(limit) ) then
            ply:Notify("The squad limit must be a number.")

            return
        end

        if ( limit < 2 ) then
            ply:Notify("The squad limit must be at least 2.")

            return
        end

        if ( limit > ix.config.Get("squadLimit", 4) ) then
            ply:Notify("The squad limit cannot be higher than " .. ix.config.Get("squadLimit", 4) .. ".")

            return
        end

        if not ( char:GetData("squadID", -1) == -1 ) then
            ply:Notify("You are already in a squad.")

            return
        end

        for k, v in pairs(ix.cmbSystems.squads) do
            if ( v.name == name ) then
                ply:Notify("A squad with that name already exists.")

                return
            end
        end

        ix.cmbSystems:CreateSquad(ply, {
            name = name,
            limit = limit
        })
    end
})

ix.command.Add("JoinSquad", {
    description = "Joins a squad.",
    arguments = {
        ix.type.string
    },
    OnRun = function(self, ply, name)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( ply:Alive() ) then
            return
        end

        if not ( Schema:IsCombine(ply) ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        if not ( char:GetData("squadID", -1) == -1 ) then
            ply:Notify("You are already in a squad.")

            return
        end

        local squadData

        for k, v in pairs(ix.cmbSystems.squads) do
            if ( v.name == name ) then
                squadData = v

                break
            end
        end

        if not ( squadData ) then
            ply:Notify("A squad with that name does not exist.")

            return
        end

        if ( #squadData.members >= squadData.limit ) then
            ply:Notify("That squad is full.")

            return
        end

        ix.cmbSystems:InsertMember(ply, #squadData + 1)
    end

})

ix.command.Add("KickSquadMember", {
    description = "Kicks a squad member.",
    arguments = {
        ix.type.character
    },
    OnRun = function(self, ply, target)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( target ) then
            return
        end

        if not ( ply:Alive() ) then
            return
        end

        local targetPly = target:GetPlayer()

        if not ( IsValid(targetPly) ) then
            return
        end

        if not ( Schema:IsCombine(ply) ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        if not ( Schema:IsCombine(targetPly) ) then
            ply:Notify("You can only kick Combine Units.")

            return
        end

        if ( char:GetData("squadID", -1) == -1 ) then
            ply:Notify("You are not in a squad.")

            return
        end

        if ( target:GetData("squadID", -1) == -1 ) then
            ply:Notify("This unit is not in a squad.")

            return
        end

        if not ( char:GetData("squadID", -1) == target:GetData("squadID", -1) ) then
            ply:Notify("You are not in the same squad as this unit.")

            return
        end

        local squadData = ix.cmbSystems.squads[char:GetData("squadID", -1)]

        if not ( squadData ) then
            ply:Notify("Your squad is invalid, your squad id has been reset.")
            char:SetData("squadID", -1)

            return
        end

        if not ( squadData.leader == ply or ( Schema:IsCPRankLeader(ply) or Schema:IsOWElite(ply) ) ) then
            ply:Notify("You don't have the authority to kick a squad member.")

            return
        end

        ix.cmbSystems:RemoveMember(targetPly, char:GetData("squadID", -1))
    end

})

ix.command.Add("LeaveSquad", {
    description = "Leaves your current squad.",
    OnRun = function(self, ply)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( ply:Alive() ) then
            return
        end

        if not ( Schema:IsCombine(ply) ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        if ( char:GetData("squadID", -1) == -1 ) then
            ply:Notify("You are not in a squad.")

            return
        end

        if not ( ix.cmbSystems.squads[char:GetData("squadID", -1)] ) then
            char:SetData("squadID", -1)
            ply:Notify("Squad invalid, your squad id has been reset.")

            return
        end

        ix.cmbSystems:RemoveMember(ply, char:GetData("squadID", -1))
    end
})

ix.command.Add("TogglePassiveChatter", {
    description = "Toggles passive chatter.",
    OnRun = function(self, ply)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( Schema:IsCombine(ply) ) then
            ply:Notify("You are not a combine.")

            return
        end

        char:SetData("passiveChatter", (!char:GetData("passiveChatter", true)))

        if ( char:GetData("passiveChatter", true) ) then
            ply:Notify("You have enabled passive chatter.")
        else
            ply:Notify("You have disabled passive chatter.")
        end
    end
})

ix.command.Add("Grenade", {
    description = "Throw a grenade.",
    OnRun = function(self, ply)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( Schema:IsOW(ply) ) then
            ply:Notify("Only Transhuman Arm units can use this command.")

            return
        end

        if ( timer.Exists("ix.Char.GrenadeCooldown." .. ply:SteamID64() .. "." .. char:GetID()) ) then
            ply:Notify("You cannot throw another grenade for another " .. math.ceil(timer.TimeLeft("ix.Char.GrenadeCooldown." .. ply:SteamID64())) .. " second(s).")

            return
        end

        if ( ply:GetSequenceInfo(ply:LookupSequence("grenthrow")) ) then
            ply:SetLocalVelocity(Vector(0, 0, 0))
            ply:ForceSequence("grenthrow")
        end

        timer.Simple(0.7, function()
            if not ( IsValid(ply) ) then // AKA Run the command and leave :skull:
                return
            end

            if not ( ply:GetCharacter() ) then
                return
            end

            local grenade = ents.Create("npc_grenade_frag")
            grenade:SetPos(ply:EyePos() + ply:GetRight() * -8 + ply:GetForward() * 20 + ply:GetUp() * 4)
            grenade:SetAngles(ply:GetForward():Angle())
            grenade:Spawn()
            grenade:Activate()
            grenade:Fire("SetTimer", 2.90)
            grenade:GetPhysicsObject():AddVelocity(ply:GetAimVector() * 950)
            grenade:SetNWEntity("deployedBy", ply)
            grenade:CallOnRemove("GrenadeRemove", function(this)
                if ( IsValid(ply) ) then
                    if not ( ply:GetCharacter() ) then
                        return
                    end

                    if ( ply.ixDeployedEntities ) then
                        if ( table.HasValue(ply.ixDeployedEntities, this:EntIndex()) ) then
                            table.RemoveByValue(ply.ixDeployedEntities, this:EntIndex())
                        end
                    end

                    this:SetNWEntity("deployedBy", nil)
                end
            end)

            if not ( ply.ixDeployedEntities ) then
                ply.ixDeployedEntities = {}
            end

            ply.ixDeployedEntities[#ply.ixDeployedEntities + 1] = grenade:EntIndex()

            char:SetData("deployedEntities", ply.ixDeployedEntities)
        end)

        if not ( timer.Exists("ix.Char.GrenadeCooldown." .. ply:SteamID64()) ) then
            timer.Create("ix.Char.GrenadeCooldown." .. ply:SteamID64() .. "." .. char:GetID(), ix.config.Get("grenadeCooldown", 30), 1, function() end)
        end
    end
})

ix.command.Add("NewObjective", {
    description = "Create a new objective.",
    arguments = {
        ix.type.text
    },
    OnRun = function(self, ply, text)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( Schema:IsCombine(ply) ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        ix.cmbSystems:NewObjective({
            sentBy = ply:Nick(),
            text = text
        })
    end
})

ix.command.Add("ViewObjectives", {
    description = "View objectives.",
    OnRun = function(self, ply)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( Schema:IsCombine(ply) ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        Schema:OpenUI(ply, "ix.CMB.Objectives")
    end
})

ix.command.Add("ToggleVoiceRadio", {
    description = "Toggle voice radio.",
    OnRun = function(self, ply)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( Schema:IsCombine(ply) ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        if ( timer.Exists("ix.Char.VoiceRadioTimeout." .. ply:SteamID64() .. "." .. char:GetID()) ) then
            ply:Notify("You have a voice radio timeout for " .. string.NiceTime(timer.TimeLeft("ix.Char.VoiceRadioTimeout." .. ply:SteamID64() .. "." .. char:GetID()) .. "."))
            
            return
        end

        char:SetData("radioVoice", not char:GetData("radioVoice", false))

        if ( char:GetData("radioVoice", false) ) then
            ply:Notify("You have enabled voice radio.")
        else
            ply:Notify("You have disabled voice radio.")
        end
    end
})

ix.command.Add("SetPriorityObjective", {
    description = "Set a priority objective.",
    arguments = {
        ix.type.string
    },
    OnRun = function(self, ply, text)
        if not ( IsValid(ply) ) then
            return
        end

        if not ( Schema:IsCombine(ply) ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        if not ( Schema:IsCPRankLeader(ply) or Schema:IsOWElite(ply) ) then
            ply:Notify("Only Combine Unit Leaders can use this command.")

            return
        end

        local objectiveID

        for k, v in pairs(ix.cmbSystems.objectives) do
            if not ( ix.util.StringMatches(v.text, text) ) then
                continue
            end

            objectiveID = k
            break
        end

        if not ( objectiveID ) then
            ply:Notify("You must specify a valid objective.")

            return
        end

        ix.cmbSystems:SetPriorityObjective(objectiveID, true)
    end
})

ix.command.Add("RemovePriorityObjective", {
    description = "Removes a priority objective.",
    arguments = {
        ix.type.string
    },
    OnRun = function(self, ply, text)
        if not ( IsValid(ply) ) then
            return
        end

        if not ( Schema:IsCombine(ply) ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        if not ( Schema:IsCPRankLeader(ply) or Schema:IsOWElite(ply) ) then
            ply:Notify("Only Combine Unit Leaders can use this command.")

            return
        end

        local objectiveID

        for k, v in pairs(ix.cmbSystems.objectives) do
            if not ( ix.util.StringMatches(v.text, text) ) then
                continue
            end

            objectiveID = k
            break
        end

        if not ( objectiveID ) then
            ply:Notify("You must specify a valid objective.")

            return
        end

        ix.cmbSystems:SetPriorityObjective(objectiveID, false)
    end
})

ix.command.Add("ToggleTeamVoiceRadio", {
    description = "Toggle team voice radio.",
    OnRun = function(self, ply)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( Schema:IsCombine(ply) ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        if ( timer.Exists("ix.Char.VoiceRadioTimeout." .. ply:SteamID64() .. "." .. char:GetID()) ) then
            ply:Notify("You have a voice radio timeout for " .. string.NiceTime(timer.TimeLeft("ix.Char.VoiceRadioTimeout." .. ply:SteamID64() .. "." .. char:GetID()) .. "."))
            
            return
        end

        char:SetData("radioVoiceTeam", not char:GetData("radioVoiceTeam", false))

        if ( char:GetData("radioVoiceTeam", false) ) then
            ply:Notify("You have enabled team voice radio.")
        else
            ply:Notify("You have disabled team voice radio.")
        end
    end
})

ix.command.Add("TimeoutVoiceRadio", {
    description = "Timeout voice radio for a certain amount of time.",
    arguments = {
        ix.type.character,
        ix.type.number
    },
    OnRun = function(self, ply, targetChar, time)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( Schema:IsCombine(ply) or ply:IsAdmin() ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        if not ( Schema:IsCPRankLeader(ply) or Schema:IsOWElite(ply) or ply:IsAdmin() ) then
            ply:Notify("Only Combine Unit Leaders can use this command.")

            return
        end

        local target = targetChar:GetPlayer()

        if not ( IsValid(target) ) then
            ply:Notify("You must specify a valid character.")

            return
        end

        if not ( target:GetCharacter() ) then
            ply:Notify("You must specify a valid character.")

            return
        end

        if not ( Schema:IsCombine(target) ) then
            ply:Notify("This person is not on a combine faction.")

            return
        end

        if not ( isnumber(time) ) then
            ply:Notify("You must specify a valid number.")

            return
        end

        if ( time < 1 ) then
            ply:Notify("You must specify a number greater than 0.")

            return
        end

        if not ( timer.Exists("ix.Char.VoiceRadioTimeout." .. ply:SteamID64() .. "." .. char:GetID()) ) then
            timer.Create("ix.Char.VoiceRadioTimeout." .. ply:SteamID64() .. "." .. char:GetID(), time, 1, function()
            end)

            targetChar:SetData("radioVoice", false)
            targetChar:SetData("radioVoiceTeam", false)
        end

        ply:Notify("You have timed out " .. targetChar:GetName() .. " from using voice radio for " .. string.NiceTime(time) .. ".")
    end
})

ix.command.Add("RemoveVoiceRadioTimeout", {
    description = "Remove a voice radio timeout from a character.",
    arguments = {
        ix.type.character
    },
    OnRun = function(self, ply, targetChar)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( Schema:IsCombine(ply) or ply:IsAdmin() ) then
            ply:Notify("Only Combine Units can use this command.")

            return
        end

        if not ( Schema:IsCPRankLeader(ply) or Schema:IsOWElite(ply) or ply:IsAdmin() ) then
            ply:Notify("Only Combine Unit Leaders can use this command.")

            return
        end

        local target = targetChar:GetPlayer()

        if not ( IsValid(target) ) then
            ply:Notify("You must specify a valid character.")

            return
        end

        if not ( target:GetCharacter() ) then
            ply:Notify("You must specify a valid character.")

            return
        end

        if not ( Schema:IsCombine(target) ) then
            ply:Notify("This person is not on a combine faction.")

            return
        end

        if not ( timer.Exists("ix.Char.VoiceRadioTimeout." .. ply:SteamID64() .. "." .. char:GetID()) ) then
            ply:Notify("This person does not have a voice radio timeout.")

            return
        end

        timer.Remove("ix.Char.VoiceRadioTimeout." .. ply:SteamID64() .. "." .. char:GetID())

        ply:Notify("You have removed " .. targetChar:GetName() .. "'s voice radio timeout.")
    end
})

ix.command.Add("KickDoor", {
    description = "Kick a door.",
    OnRun = function(self, ply)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if not ( Schema:IsCP(ply) ) then
            ply:Notify("Only Civil Protection Units can use this command.")

            return
        end

        local door = ply:GetEyeTrace().Entity

        if not ( IsValid(door) ) then
            ply:Notify("You must be looking at a door to kick it.")

            return
        end

        if not ( door:GetClass() == "prop_door_rotating" or door:GetClass() == "func_door_rotating" ) then
            ply:Notify("You must be looking at a door to kick it.")

            return
        end

        if ( door:GetPos():Distance(ply:GetPos()) > 100 ) then
            ply:Notify("You must be closer to the door to kick it.")

            return
        end

        if ( ply:GetSequenceInfo(ply:LookupSequence("kickdoorbaton")) ) then
            ply:SetLocalVelocity(Vector(0, 0, 0))
            ply:ForceSequence("kickdoorbaton")

            door.kickedBy = ply

            if not ( timer.Exists("ix.DoorOpen." .. door:EntIndex()) ) then
                timer.Create("ix.DoorOpen." .. door:EntIndex(), 0.8, 1, function()
                    if not ( IsValid(door) ) then
                        return
                    end

                    door:EmitSound("physics/wood/wood_furniture_break2.wav")

                    local oldDoorSpeed = door:GetKeyValues()["speed"]

                    if not ( oldDoorSpeed ) then
                        oldDoorSpeed = 100
                    end

                    local tempEnt = ents.Create("info_target")
                    tempEnt:SetPos(ply:GetPos())
                    tempEnt:Spawn()
                    tempEnt:Activate()
                    tempEnt:SetName("ix.OpenAwayFromDoor." .. ply:SteamID64())

                    door:Fire("unlock")
                    door:Fire("SetSpeed", 400)
                    door:Fire("OpenAwayFrom", "ix.OpenAwayFromDoor." .. ply:SteamID64())

                    if not ( timer.Exists("ix.DoorClose." .. door:EntIndex()) ) then
                        timer.Create("ix.DoorClose." .. door:EntIndex(), 0.2, 1, function()
                            if not ( IsValid(door) ) then
                                return
                            end

                            if ( IsValid(tempEnt) ) then
                                tempEnt:Remove()
                                tempEnt = nil
                            end
                        
                            door:Fire("SetSpeed", oldDoorSpeed)

                            if not ( timer.Exists("ix.DoorSetKickedBy." .. door:EntIndex()) ) then
                                timer.Create("ix.DoorSetKickedBy." .. door:EntIndex(), 0.5, 1, function()
                                    if not ( IsValid(door) ) then
                                        return
                                    end

                                    if ( IsValid(tempEnt) ) then
                                        tempEnt:Remove()
                                        tempEnt = nil
                                    end

                                    door.kickedBy = nil
                                end)
                            end
                        end)
                    end
                end)
            end
        else
            ply:Notify("WARNING! KICK DOOR ANIMATION MISSING, ALERT OWNER!")
        end
    end
})

local function FacingWall(client)
	local data = {}
	data.start = client:EyePos()
	data.endpos = data.start + client:GetForward() * 20
	data.filter = client

	if (!util.TraceLine(data).Hit) then
		return "@faceWall"
	end
end

local function FacingWallBack(client)
	local data = {}
	data.start = client:LocalToWorld(client:OBBCenter())
	data.endpos = data.start - client:GetForward() * 20
	data.filter = client

	if (!util.TraceLine(data).Hit) then
		return "@faceWallBack"
	end
end

ix.act.Register("LeanWallLeft", {"overwatch"}, {
    sequence = {
        {"leanwall_left_idle", offset = function(ply)
            return ply:GetRight() * -2
        end},
    },
    untimed = true,
    idle = true
})

ix.act.Register("LeanWallRight", {"overwatch"}, {
    sequence = {
        {"leanwall_right_idle"},
    },
    untimed = true,
    idle = true
})

timer.Create("ix.DeployedEnts.Update", 1, 0, function()
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

        if not ( v.ixDeployedEntities ) then
            v.ixDeployedEntities = {}
        end

        if not ( v.ixDeployedEntities or char:GetData("deployedEntities", {}) ) then
            continue
        end

        if ( #v.ixDeployedEntities < 1 or #char:GetData("deployedEntities", {}) < 1 ) then
            continue
        end

        if ( #v.ixDeployedEntities > 0 ) then
            for i = 1, #v.ixDeployedEntities do
                if not ( IsValid(Entity(v.ixDeployedEntities[i])) ) then
                    if ( table.HasValue(v.ixDeployedEntities, v.ixDeployedEntities[i]) ) then
                        table.RemoveByValue(v.ixDeployedEntities, v.ixDeployedEntities[i])
                    end
                end
            end
        end

        if ( #char:GetData("deployedEntities", {}) > 0 ) then
            for i = 1, #char:GetData("deployedEntities", {}) do
                if not ( IsValid(Entity(char:GetData("deployedEntities", {})[i])) ) then
                    if ( table.HasValue(char:GetData("deployedEntities", {}), char:GetData("deployedEntities", {})[i]) ) then
                        table.RemoveByValue(char:GetData("deployedEntities", {}), char:GetData("deployedEntities", {})[i])
                    end
                end
            end
        end
    end
end)

function PLUGIN:AdjustStaminaOffset(ply)
    if ( Schema:IsOW(ply) ) then
        return 0
    end
end

ix.cmbSystems.otaWepWhitelist = {
    ["ix_hands"] = true,
    ["ix_keys"] = true,
    ["ix_rappel_gear"] = true,
}

function PLUGIN:CalcMainActivity(ply, vel)
	if not ( IsValid(ply) ) then
		return
	end

	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	if not ( ply:IsOnGround() ) then
		return
	end

	if not ( Schema:IsOW(ply) ) then
		return
	end

	if ( ply:IsWepRaised() ) then
		return
	end

	if ( ply:Crouching() ) then
		return
	end

    if ( ply:InVehicle() ) then
        return
    end

    if ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then
        return
    end

    if ( ply:GetMoveType() == MOVETYPE_LADDER ) then
        return
    end

    if ( IsValid(ply:GetActiveWeapon()) ) then
        if not ( ix.cmbSystems.otaWepWhitelist[ply:GetActiveWeapon():GetClass()] ) then
            return
        end
    end

	if not ( ply:IsRunning() ) then
		local playAnim = "idle_unarmed"

		if ( vel:Length2D() > 0.1 ) then
			playAnim = "walkunarmed_all"
		end
		
		ply.CalcSeqOverride = ply:LookupSequence(playAnim) or ply.CalcSeqOverride
	end
end