ITEM.name = "Medical Base"
ITEM.description = "A medical base."
ITEM.model = "models/healthvial.mdl"
ITEM.category = "Medical"

ITEM.functions.HealSelf = {
    name = "Heal",
    OnRun = function(item)
        local ply = item.player

        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        local health = ply:Health()
        local maxHealth = ply:GetMaxHealth()

        if ( health >= maxHealth ) then
            return false
        end

        if ( item.GetHealTime ) then
            local healTime = item:GetHealTime() or 2

            if ( item.OnHealStart ) then
                item:OnHealStart(ply)
            end

            ply:SetAction("Healing...", healTime, function()
                if not ( IsValid(ply) ) then
                    return
                end

                if not ( ply:Alive() ) then
                    return
                end

                if not ( ply:GetCharacter() ) then
                    return
                end

                health = ply:Health()

                ply:SetHealth(math.Clamp(health + (item:GetHealAmount(ply) or 10), 0, 100))

                if ( item.OnHeal ) then
                    item:OnHeal(ply)
                end
            end)
        else
            ply:SetHealth(math.Clamp(health + (item:GetHealAmount(ply) or 10), 0, 100))

            if ( item.OnHeal ) then
                item:OnHeal(ply)
            end
        end

        return true
    end,
    OnCanRun = function(item)
        local ply = item.player

        if not ( IsValid(ply) ) then
            return false
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return false
        end

        local health = ply:Health()
        local maxHealth = ply:GetMaxHealth()

        if ( health >= maxHealth ) then
            return false
        end

        return true
    end
}

ITEM.functions.HealOther = {
    name = "Heal Target",
    OnRun = function(item)
        local ply = item.player
        
        if not ( IsValid(ply) ) then
            return false
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return false
        end

        local trace = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:GetAimVector() * ( item.GetHealDistance and item:GetHealDistance(ply, target) or 96 ) or 96,
            filter = ply
        })

        local target = trace.Entity

        if not ( IsValid(target) and target:IsPlayer() ) then
            return false
        end

        if not ( ply:GetPos():Distance(target:GetPos()) <= ( item.GetHealDistance and item:GetHealDistance(ply, target) or 96 ) or 96 ) then
            return false
        end

        local targetChar = target:GetCharacter()

        if not ( targetChar ) then
            return false
        end

        local health = target:Health()
        local maxHealth = target:GetMaxHealth()

        if ( health >= maxHealth ) then
            return false
        end

        if ( item.GetHealTime ) then
            local healTime = item:GetHealTime() or 2

            ply:SetAction("Healing...", healTime, function()
                if not ( IsValid(ply) ) then
                    return
                end

                if not ( ply:Alive() ) then
                    return
                end

                if not ( IsValid(target) ) then
                    return
                end

                if not ( target:Alive() ) then
                    return
                end

                if not ( target:GetCharacter() ) then
                    return
                end

                health = target:Health()

                target:SetHealth(math.Clamp(health + (item:GetHealAmount(target) or 10), 0, 100))

                if ( item.OnHeal ) then
                    item:OnHeal(target)
                end
            end)
        else
            target:SetHealth(math.Clamp(health + (item:GetHealAmount(target) or 10), 0, 100))

            if ( item.OnHeal ) then
                item:OnHeal(target)
            end
        end

        return true
    end,
    OnCanRun = function(item)
        local ply = item.player
        
        if not ( IsValid(ply) ) then
            return false
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return false
        end

        local trace = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:GetAimVector() * 96,
            filter = ply
        })

        local target = trace.Entity

        if not ( IsValid(target) and target:IsPlayer() ) then
            return false
        end

        if not ( ply:GetPos():Distance(target:GetPos()) <= 100 ) then
            return false
        end

        local targetChar = target:GetCharacter()

        if not ( targetChar ) then
            return false
        end

        local health = target:Health()
        local maxHealth = target:GetMaxHealth()

        if ( health >= maxHealth ) then
            return false
        end

        return true
    end
}