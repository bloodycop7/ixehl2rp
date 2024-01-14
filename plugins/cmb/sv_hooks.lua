local PLUGIN = PLUGIN

function PLUGIN:DoPlayerDeath(ply, attacker, dmgInfo)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( char:GetData("squadID", -1) != -1 ) then
        ix.cmbSystems:RemoveMember(ply, char:GetData("squadID", -1))
    end

    if ( Schema:IsCombine(ply) ) then
        local numbers = {}

        for k, v in pairs(string.ToTable(char:GetName())) do
            if not ( isnumber(tonumber(v)) ) then
                continue
            end

            if ( ix.cmbSystems.dispatchNumbers[tonumber(v)] ) then
                numbers[#numbers + 1] = ix.cmbSystems.dispatchNumbers[tonumber(v)]
            end
        end

        local tagline = "union"

        for k, v in pairs(ix.cmbSystems.dispatchTaglines) do
            if ( string.find(string.lower(char:GetName()), k) ) then
                tagline = k
            end
        end

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

        ix.cmbSystems:MakeWaypoint({
            pos = ply:GetPos(),
            text = "BSL " .. char:GetName() .. ".",
            color = Color(255, 0, 0),
            duration = 5
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

    if ( ent.kickedBy ) then
        return false
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

            ix.cmbSystems:PassiveChatter(ply)
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
        for k, v in ipairs(player.GetAll()) do
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
        for k, v in ipairs(player.GetAll()) do
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
        for k, v in ipairs(player.GetAll()) do
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
        for k, v in ipairs(player.GetAll()) do
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

PLUGIN["LVS.CanPlayerDrive"] = function(self, ply, car)
    if ( car:GetModel():find("combine_apc") ) then
        if not ( Schema:IsCombine(ply) ) then
            car:EmitSound("buttons/combine_button_locked.wav")
            return false
        end
    end
end