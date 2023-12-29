local PLUGIN = PLUGIN

function PLUGIN:DoPlayerDeath(ply, attacker, dmgInfo)
    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    ix.cmbSystems:SetBOLStatus(ply, false)

    if ( Schema:IsCombine(ply) ) then
        local maxDeathItems = ix.config.Get("maxItemDrops", 3)

        if ( maxDeathItems > 0 ) then
            local inventory = char:GetInventory()

            if ( inventory ) then
                local items = {}

                for _, v in pairs(inventory:GetItems()) do
                    if ( hook.Run("CanPlayerDropItemOnDeath", ply, v) == false ) then
                        continue
                    end

                    table.insert(items, v)
                end

                if ( #items > 0 ) then
                    for i = 1, math.random(1, #items) do
                        local item = table.Random(items)

                        if ( item ) then
                            item:Transfer(nil, nil, nil, ply:GetPos() + Vector(0, 0, 16))
                        end
                    end
                end
            end
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

            if not ( ply:GetCharacter():GetData("passiveChatter", false) ) then
                print("Wha?")
                return
            end

            ix.cmbSystems:PassiveChatter(ply)
        end)
    end
end