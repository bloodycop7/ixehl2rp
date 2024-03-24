local PLUGIN = PLUGIN

function PLUGIN:ScalePlayerDamage(ply, hitGroup, dmgInfo)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    local inv = char:GetInventory()

    for k, v in inv:Iter() do
        if not ( k.base == "base_clothing" ) then
            continue
        end

        if not ( k:GetData("equip", false) ) then
            continue
        end

        if not ( k.damageScale ) then
            continue
        end

        if ( isnumber(k.damageScale) ) then
            dmgInfo:ScaleDamage(k.damageScale)
        else
            if ( k.damageScale[hitGroup] ) then
                dmgInfo:ScaleDamage(k.damageScale[hitGroup])
            end
        end
    end
end