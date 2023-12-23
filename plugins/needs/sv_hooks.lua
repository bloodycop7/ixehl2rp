local PLUGIN = PLUGIN

function PLUGIN:DoPlayerDeath(ply, attacker, dmgInfo)
    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    char:SetData("isConsuming", false)
end

function PLUGIN:PlayerLoadedCharacter(ply, newChar, oldChar)
    if ( ply:GetCharacter() ) then
        ply:GetCharacter():SetData("isConsuming", false)

        if not ( timer.Exists("ix.Characters.Needs.Hunger." .. newChar:GetID()) ) then
            timer.Create("ix.Characters.Needs.Hunger." .. newChar:GetID(), ix.config.Get("hungerRate", 60), 0, function()
                if ( ply:GetCharacter() ) then
                    local char = ply:GetCharacter()
                    local hunger = char:GetHunger()

                    if ( hunger > 10 ) then
                        char:SetHunger(hunger - 1)
                    end
                end
            end)
        end

        if not ( timer.Exists("ix.Characters.Needs.Thirst." .. oldChar:GetID()) ) then
            timer.Create("ix.Characters.Needs.Thirst." .. oldChar:GetID(), ix.config.Get("thirstRate", 60), 0, function()
                if ( ply:GetCharacter() ) then
                    local char = ply:GetCharacter()
                    local thirst = char:GetThirst()
                    
                    if ( thirst > 10 ) then
                        char:SetThirst(thirst - 1)
                    end
                end
            end)
        end

        if ( timer.Exists("ix.Characters.Needs.Hunger" .. oldChar:GetID()) ) then
            timer.Remove("ix.Characters.Needs.Hunger" .. oldChar:GetID())
        end

        if ( timer.Exists("ix.Characters.Needs.Thirst" .. oldChar:GetID()) ) then
            timer.Remove("ix.Characters.Needs.Thirst" .. oldChar:GetID())
        end
    end
end