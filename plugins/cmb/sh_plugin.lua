local PLUGIN = PLUGIN

PLUGIN.name = "Combine Systems"
PLUGIN.author = "eon"
PLUGIN.description = "Self-Explanatory, adds main Combine Functions."

ix.cmbSystems = ix.cmbSystems or {}
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
	optCombineOverlay = "Combine Overlay"
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

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")

ix.cmbSystems.cityCodes = {
    {
        name = "Preserved",
        color = Color(0, 255, 0),
        onStart = function()
            print("PReserved")
        end
    },
    {
        name = "Marginal",
        color = Color(255, 255, 0),
        onStart = function()
            print("PReserved")
        end
    },
    {
        name = "Judgment Waiver",
        color = Color(255, 0, 0),
        onStart = function()
            Schema:PlaySound(player.GetAll(), "ambient/alarms/citadel_alert_loop2.wav", 75, 100, 0.7)
            Schema:PlaySound(player.GetAll(), "ambient/alarms/manhack_alert_pass1.wav", 75, 100, 0.6)
            Schema:PlaySound(player.GetAll(), "ambient/alarms/apc_alarm_pass1.wav", 75, 100, 0.6)

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
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/heli_distant1.wav", 75, 100, 0.7)
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
                    v:StopSound("ambient/levels/streetwar/heli_distant1.wav")
                end
            end
        end
    },
    {
        name = "Autonomous Judgment",
        color = Color(255, 0, 0),
        onStart = function()
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
                    Schema:PlaySound(player.GetAll(), "ambient/levels/streetwar/heli_distant1.wav", 75, 100, 0.7)
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
                    v:StopSound("ambient/levels/streetwar/heli_distant1.wav")
                end
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
            chat.AddText(Color(0, 100, 170), "*[CMB] " .. speaker:GetChar():GetName() .. ": " .. text .. "*")
        end,
        prefix = {"/cmbradio", "/cmbr"},
        font = "ixGenericFont",
    })

    ix.chat.Register("cmb_dispatch", {
        CanHear = function(self, speaker, listener)
            if not ( IsValid(listener) ) then
                return false
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

        char:SetData("passiveChatter", (!char:GetData("passiveChatter", false)))

        if ( char:GetData("passiveChatter", false) ) then
            ply:Notify("You have enabled passive chatter.")
        else
            ply:Notify("You have disabled passive chatter.")
        end
    end
})

ix.cmbSystems.otaWepWhitelist = {
    ["ix_hands"] = true,
    ["ix_keys"] = true,
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

	if not ( Schema:IsOTA(ply) ) then
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