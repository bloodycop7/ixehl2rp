local PLUGIN = PLUGIN

function PLUGIN:DoPlayerDeath(ply, attacker, dmgInfo)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    self.Squads:RemoveMember(ply, char:GetData("squadID", -1))

    if ( Schema:IsCombine(ply) ) then
        local numbers = {}

        for k, v in pairs(string.ToTable(char:GetName())) do
            if not ( isnumber(tonumber(v)) ) then
                continue
            end

            if ( self.dispatchNumbers[tonumber(v)] ) then
                numbers[#numbers + 1] = PLUGIN.dispatchNumbers[tonumber(v)]
            end
        end

        local tagline = "union"

        for k, v in pairs(self.dispatchTaglines) do
            if ( string.find(string.lower(char:GetName()), k) ) then
                tagline = k
            end
        end

        if ( Schema:IsCP(ply) ) then
            for k, v in player.Iterator() do
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

                local sounds = {
                    "npc/overwatch/radiovoice/on3.wav",
                    "npc/overwatch/radiovoice/attention.wav",
                    "npc/overwatch/radiovoice/_comma.wav",
                    "npc/overwatch/radiovoice/lostbiosignalforunit.wav"
                }

                sounds[#sounds + 1] = "npc/overwatch/radiovoice/" .. tagline .. ".wav"

                for k2, v2 in ipairs(numbers) do
                    sounds[#sounds + 1] = v2
                end

                sounds[#sounds + 1] = "npc/overwatch/radiovoice/off2.wav"

                ix.util.EmitQueuedSounds(v, sounds, 0, 0.1, 40)
            end
        end

        self:MakeWaypoint({
            pos = ply:GetPos(),
            text = "BSL " .. char:GetName() .. ".",
            color = Color(255, 0, 0),
            duration = 60,
            sound = "buttons/button17.wav"
        })
    end
end

function PLUGIN:PlayerUse(ply, ent)
    if not ( IsValid(ent) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( ent:IsDoor() and ent.kickedBy ) then
        return false
    end

    if (!ply:IsRestricted() and ent:IsPlayer() and ent:IsRestricted() and !ent:GetNetVar("untying")) then
		ent:SetAction("@beingUntied", 5)
		ent:SetNetVar("untying", true)

		ply:SetAction("@unTying", 5)

		ply:DoStaredAction(ent, function()
			ent:SetRestricted(false)
			ent:SetNetVar("untying")
		end, 5, function()
			if (IsValid(ent)) then
				ent:SetNetVar("untying")
				ent:SetAction()
			end

			if (IsValid(ply)) then
				ply:SetAction()
			end
		end)
	end
end

function PLUGIN:PlayerUseDoor(ply, door)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( IsValid(door) ) then
        return
    end

    if ( door.kickedBy ) then
        return false
    end

    if ( ( Schema:IsCombine(ply) ) and door:IsDoor() and IsValid(door.ixLock) and door:KeyDown(IN_SPEED) ) then
		entity.ixLock:Toggle(client)

		return false
	end

    if ( Schema:IsCombine(ply) ) then
        if ( door:GetClass("func_door") or door:GetClass() == "prop_dynamic" ) then
            if ( door.ixIsCombineDoor ) then
                door:Fire("unlock")
                door:Fire("open")

                if ( door:GetClass() == "prop_dynamic" ) then
                    door:Fire("setanimation", "open")
                end

                return false
            end
        end
    end
end

function PLUGIN:InitializedPlugins()
    local data = ix.data.Get("combineDoors", {})

    for k, v in pairs(data) do
        for k2, v2 in pairs(ents.FindInSphere(v[1], 64)) do
            if not ( IsValid(v2) ) then
                continue
            end

            if not ( v2:GetClass() == "func_door" or v2:GetClass() == "prop_dynamic" ) then
                continue
            end

            v2.ixIsCombineDoor = true
        end
    end
end

function PLUGIN:PlayerLoadedCharacter(ply, newChar, oldChar)
    if ( oldChar ) then
        timer.Remove("ix.PassiveChatter." .. oldChar:GetID())
    end

    if ( Schema:IsCombine(ply) ) then
        local uID = "ix.PassiveChatter." .. newChar:GetID()
        timer.Create("ix.PassiveChatter." .. newChar:GetID(), ix.config.Get("passiveChatterCooldown", 120), 0, function()
            if not ( IsValid(ply) ) then
                timer.Remove(uID)

                return
            end

            if not ( ply:GetCharacter() ) then
                timer.Remove(uID)

                return
            end

            if not ( ply:GetCharacter():GetData("passiveChatter", true) ) then
                return
            end

            self:PassiveChatter(ply)
        end)
    end
end

function PLUGIN:PlayerStartVoice(ply)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( ( ply.nextCombineVoiceSound or 0 ) < CurTime() ) then
        if ( Schema:IsCP(ply) ) then
            Schema:PlaySound(ply, "npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav", 75, 100, 0.6)

            ply.nextCombineVoiceSound = CurTime() + 1
        elseif ( Schema:IsOW(ply) ) then
            Schema:PlaySound(ply, "npc/combine_soldier/vo/on" .. math.random(1, 2) .. ".wav", 75, 100, 0.6)

            ply.nextCombineVoiceSound = CurTime() + 1
        end
    end

    if ( char:GetData("radioVoice", false) ) then
        for k, v in player.Iterator() do
            if not ( IsValid(v) ) then
                continue
            end

            local vChar = v:GetCharacter()

            if not ( vChar ) then
                continue
            end

            if not ( Schema:IsCombine(v) ) then
                continue
            end

            if ( v == ply ) then
                continue
            end

            local sound = "npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav"

            if ( Schema:IsOW(ply) ) then
                sound = "npc/combine_soldier/vo/on" .. math.random(1, 2) .. ".wav"
            end

            Schema:PlaySound(v, sound, 75, 100, 0.6)
        end
    elseif ( char:GetData("radioVoiceTeam", false) ) then
        for k, v in player.Iterator() do
            if not ( IsValid(v) ) then
                continue
            end

            local vChar = v:GetCharacter()

            if not ( vChar ) then
                continue
            end

            if not ( Schema:IsCombine(v) ) then
                continue
            end

            if not ( v:Team() == ply:Team() ) then
                continue
            end

            local sound = "npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav"

            if ( Schema:IsOW(ply) ) then
                sound = "npc/combine_soldier/vo/on" .. math.random(1, 2) .. ".wav"
            end
        end
    end
end

function PLUGIN:PlayerEndVoice(ply)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( ( ply.nextCombineVoiceSoundOff or 0 ) < CurTime() ) then
        if ( Schema:IsCP(ply) ) then
            Schema:PlaySound(ply, "npc/metropolice/vo/off" .. math.random(1, 4) .. ".wav", 75, 100, 0.6)

            ply.nextCombineVoiceSoundOff = CurTime() + 1
        elseif ( Schema:IsOW(ply) ) then
            Schema:PlaySound(ply, "npc/combine_soldier/vo/off" .. math.random(1, 3) .. ".wav", 75, 100, 0.6)

            ply.nextCombineVoiceSoundOff = CurTime() + 1
        end
    end

    if ( char:GetData("radioVoice", false) ) then
        for k, v in player.Iterator() do
            if not ( IsValid(v) ) then
                continue
            end

            local vChar = v:GetCharacter()

            if not ( vChar ) then
                continue
            end

            if not ( Schema:IsCombine(v) ) then
                continue
            end

            if ( v == ply ) then
                continue
            end

            local sound = "npc/metropolice/vo/off" .. math.random(1, 4) .. ".wav"

            if ( Schema:IsOW(ply) ) then
                sound = "npc/combine_soldier/vo/off" .. math.random(1, 3) .. ".wav"
            end

            Schema:PlaySound(v, sound, 75, 100, 0.6)
        end
    elseif ( char:GetData("radioVoiceTeam", false) ) then
        for k, v in player.Iterator() do
            if not ( IsValid(v) ) then
                continue
            end

            local vChar = v:GetCharacter()

            if not ( vChar ) then
                continue
            end

            if not ( Schema:IsCombine(v) ) then
                continue
            end

            if not ( v:Team() == ply:Team() ) then
                continue
            end

            local sound = "npc/metropolice/vo/off" .. math.random(1, 4) .. ".wav"

            if ( Schema:IsOW(ply) ) then
                sound = "npc/combine_soldier/vo/off" .. math.random(1, 3) .. ".wav"
            end
        end
    end
end

function PLUGIN:PlayerCanHearPlayersVoice(listener, talker)
    if not ( IsValid(listener) or IsValid(talker) ) then
        return
    end

    local charListener = listener:GetCharacter()

    if not ( charListener ) then
        return
    end

    local charTalker = talker:GetCharacter()

    if not ( charTalker ) then
        return
    end

    if not ( talker:Alive() ) then
        return
    end

    if ( listener == talker ) then
        return
    end

    if ( charTalker:GetData("radioVoice", false) ) then
        if ( Schema:IsCombine(talker) and Schema:IsCombine(listener) ) then
            return true
        end
    elseif ( charTalker:GetData("radioVoiceTeam", false) ) then
        if ( Schema:IsCombine(talker) and listener:Team() == talker:Team() ) then
            return true
        end
    end
end

function PLUGIN:OnEntityCreated(ent)
    if not ( IsValid(ent) ) then
        return
    end

    if ( ent:GetClass() == "npc_combine_camera" ) then
        if ( IsValid(ent.ixCamDetector) ) then
            ent.ixCamDetector:Remove()
        end

        ent.ixCamDetector = ents.Create("base_entity")
        ent.ixCamDetector:SetName("ix." .. ent:GetClass() .. "." .. ent:EntIndex() .. ".ixCamDetector")
        ent.ixCamDetector.AcceptInput = function(s, name, ply, camera, data)
            if not ( ply:IsPlayer() or ply:IsNPC() ) then
                return false
            end

            if ( data == "OnFoundPlayer" or data == "OnFoundEnemy" ) then
                if ( timer.Exists("ix.Cam." .. ent:GetClass() .. "." .. ent:EntIndex() .. "Detected." .. tostring(ply)) ) then
                    return false
                end

                camera:SetTarget(ply)
                camera:Fire("SetAngry")

                if not ( timer.Exists("ix.Cam." .. camera:GetClass() .. "." .. camera:EntIndex() .. ".Reset") ) then
                    timer.Create("ix.Cam." .. camera:GetClass() .. "." .. camera:EntIndex() .. ".Reset", 2, 1, function()
                        if not ( IsValid(camera) ) then
                            return
                        end

                        camera:Fire("SetIdle")
                    end)
                end

                if not ( timer.Exists("ix.Cam." .. ent:GetClass() .. "." .. ent:EntIndex() .. "Detected." .. tostring(ply)) ) then
                    timer.Create("ix.Cam." .. ent:GetClass() .. "." .. ent:EntIndex() .. "Detected." .. tostring(ply), 2, 1, function()
                    end)
                end

                self:MakeWaypoint({
                    pos = ply:GetPos(),
                    text = "CAMERA /// " .. camera:EntIndex(),
                    color = Color(255, 0, 0),
                    duration = 5
                })
            end
        end

        ent.ixCamDetector:Spawn()
        ent.ixCamDetector:Activate()

        ent:Fire("addoutput", "OnFoundPlayer ix." .. ent:GetClass() .. "." .. ent:EntIndex() .. ".ixCamDetector:ixCamDetect." .. ent:EntIndex() .. ":OnFoundPlayer:0:-1")
        ent:Fire("addoutput", "OnFoundEnemy ix." .. ent:GetClass() .. "." .. ent:EntIndex() .. ".ixCamDetector:ixCamDetect." .. ent:EntIndex() .. ":OnFoundEnemy:0:-1")
        ent:DeleteOnRemove(ent.ixCamDetector)
    elseif ( ent:GetClass() == "npc_cscanner" or ent:GetClass() == "npc_clawscanner" ) then
        if ( IsValid(ent.scannerOutputDetector) ) then
            ent.scannerOutputDetector:Remove()
        end

        ent.scannerOutputDetector = ents.Create("base_entity")
        ent.scannerOutputDetector:SetName("ix." .. ent:GetClass() .. "." .. ent:EntIndex() .. ".scannerOutputDetector")
        ent.scannerOutputDetector.AcceptInput = function(s, name, ply, scanner, data)
            if not ( ply:IsPlayer() or ply:IsNPC() ) then
                return false
            end

            if ( data == "OnPhotographPlayer" or data == "OnPhotographNPC" ) then
                self:MakeWaypoint({
                    pos = ply:GetPos(),
                    text = "AIRWATCH /// " .. ent:EntIndex(),
                    color = Color(255, 0, 0),
                    duration = 5
                })
            end
        end

        ent.scannerOutputDetector:Spawn()

        ent:Fire("addoutput", "OnPhotographPlayer ix." .. ent:GetClass() .. "." .. ent:EntIndex() .. ".scannerOutputDetector:scannerOutputDetect." .. ent:EntIndex() .. ":OnPhotographPlayer:0:-1")
        ent:Fire("addoutput", "OnPhotographNPC ix." .. ent:GetClass() .. "." .. ent:EntIndex() .. ".scannerOutputDetector:scannerOutputDetect." .. ent:EntIndex() .. ":OnPhotographNPC:0:-1")
        ent:DeleteOnRemove(ent.scannerOutputDetector)
    end
end

local whitelistEnts = {
    ["lvs_wheeldrive_wheel"] = true,
    ["lvs_wheeldrive_hl2_combine_apc"] = true,
}

function PLUGIN:CanGoThroughForcefield(ent, forcefield)
    if not ( IsValid(ent) or IsValid(forcefield) ) then
        return
    end

    --[[
    if ( ent:GetClass() == "ix_item" ) then
        local dissolver = ents.Create("env_entity_dissolver")
        dissolver:SetKeyValue("dissolvetype", 3)
        dissolver:SetName("ix." .. ent:GetClass() .. "." .. ent:EntIndex() .. ".dissolver.base")
        dissolver:Spawn()

        ent:SetName("ix." .. ent:GetClass() .. "." .. ent:EntIndex() .. ".dissolver")
        dissolver:Fire("Dissolve", ent:GetName(), 0)
        dissolver:Remove()

        return true
    end
    ]]

    local combineNPCClass = ent:GetClass()

    if ( combineNPCClass:find("zbase*") ) then
        combineNPCClass = ent:GetNWString("NPCName", ent.NPCName)
    end

    if ( whitelistEnts[ent:GetClass()] or ix.relationships.CombineNPCs[combineNPCClass] ) then
        return true
    end
end