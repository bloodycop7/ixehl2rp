local PLUGIN = PLUGIN

function PLUGIN:DoPlayerDeath(ply, attacker, dmgInfo)
    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    timer.Adjust("ix.Characters.Needs.Hunger." .. char:GetID(), ix.config.Get("hungerRate", 60))
    timer.Adjust("ix.Characters.Needs.Thirst." .. char:GetID(), ix.config.Get("thirstRate", 60))

    char:SetData("isConsuming", false)
end

function PLUGIN:PlayerLoadedCharacter(ply, newChar, oldChar)
    if ( newChar ) then
        newChar:SetData("isConsuming", false)

        if not ( timer.Exists("ix.Characters.Needs.Hunger." .. newChar:GetID()) ) then
            timer.Create("ix.Characters.Needs.Hunger." .. newChar:GetID(), ix.config.Get("hungerRate", 60), 0, function()
                if ( newChar ) then
                    if not ( ix.config.Get("needsEnabled", true) ) then
                        return
                    end

                    local hunger = newChar:GetHunger()

                    newChar:SetHunger(math.Clamp(hunger - 1, 0, 100))
                end
            end)
        end

        if not ( timer.Exists("ix.Characters.Needs.Thirst." .. "." .. ply:SteamID64() .. "." .. newChar:GetID()) ) then
            timer.Create("ix.Characters.Needs.Thirst." .. "." .. ply:SteamID64() .. "." .. newChar:GetID(), ix.config.Get("thirstRate", 60), 0, function()
                if ( newChar ) then
                    if not ( ix.config.Get("needsEnabled", true) ) then
                        return
                    end

                    local thirst = newChar:GetThirst()
                    
                    newChar:SetThirst(math.Clamp(thirst - 1, 0, 100))
                end
            end)
        end

        if ( newChar:GetThirst() <= 10 ) then
            if not ( timer.Exists("ix.Characters.Needs.Damage." .. "." .. ply:SteamID64() .. "." .. newChar:GetID()) ) then
                timer.Create("ix.Characters.Needs.Damage." .. "." .. ply:SteamID64() .. "." .. newChar:GetID(), 1, 1, function()
                    if ( newChar ) then
                        if not ( ix.config.Get("needsEnabled", true) ) then
                            return
                        end

                        local hunger = newChar:GetHunger()
                        local thirst = newChar:GetThirst()

                        if ( thirst <= 0 or hunger <= 0 ) then
                            if ( ply:Health() > 10 ) then
                                newChar:GetPlayer():TakeDamage(1)
                            end
                        end
                    end
                end)
            end
        end

        if ( oldChar ) then        
            if ( timer.Exists("ix.Characters.Needs.Thirst." .. "." .. ply:SteamID64() .. "." .. oldChar:GetID()) ) then
                timer.Remove("ix.Characters.Needs.Thirst." .. "." .. ply:SteamID64() .. "." .. oldChar:GetID())
            end

            if ( timer.Exists("ix.Characters.Needs.Thirst." .. "." .. ply:SteamID64() .. "." .. oldChar:GetID()) ) then
                timer.Remove("ix.Characters.Needs.Thirst." .. "." .. ply:SteamID64() .. "." .. oldChar:GetID())
            end

            if ( timer.Exists("ix.Characters.Needs.Damage." .. "." .. ply:SteamID64() .. "." .. oldChar:GetID()) ) then
                timer.Remove("ix.Characters.Needs.Damage." .. "." .. ply:SteamID64() .. "." .. oldChar:GetID())
            end
        end
    end
end