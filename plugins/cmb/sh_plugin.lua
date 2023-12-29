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
            print("PReserved")
        end
    },
    {
        name = "Autonomous Judgment",
        color = Color(255, 0, 0),
        onStart = function()
            print("PReserved")
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

		if ( vel:Length2D() > 0.5 ) then
			playAnim = "walkunarmed_all"
		end
		
		ply.CalcSeqOverride = ply:LookupSequence(playAnim) or ply.CalcSeqOverride
	end
end