local PLUGIN = PLUGIN

function PLUGIN:DoPlayerDeath(ply, attacker, dmgInfo)
    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

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

        sounds[#sounds + 1] = "npc/combine_soldier/vo/off1.wav"

        ix.util.EmitQueuedSounds(ply, sounds, 0, 0.1, 35, 90)
    end

    ix.cmbSystems:MakeWaypoint({
        pos = ply:GetPos(),
        text = "Lost Biosignal for Unit " .. char:GetName() .. ".",
        color = Color(255, 0, 0),
        duration = 40
    })
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

            if not ( ply:GetCharacter():GetData("passiveChatter", false) ) then
                return
            end

            ix.cmbSystems:PassiveChatter(ply)
        end)
    end
end