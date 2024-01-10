ITEM.name = "Needs Base"
ITEM.description = "A base for a needs item."
ITEM.model = "models/props_lab/crematorcase.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 0

function ITEM:GetHungerAmount(ply)
    return 0
end

function ITEM:GetThirstAmount(ply)
    return 0
end

function ITEM:GetConsumeTime(ply)
    return 0
end

function ITEM:OnInstanced(index, x, y, item)
    local ply = item.player
    local itemData = ix.item.instances[item.id]

    if not ( itemData ) then
        return
    end

    local ply

    if ( item.playerID ) then
        ply = player.GetBySteamID64(item.playerID)
    end

    if ( IsValid(ply) ) then
        itemData:SetData("uses", ( itemData.GetUses and itemData:GetUses(ply) or 1 ) or 1)
    else
        itemData:SetData("uses", ( itemData.GetUses and itemData:GetUses() or 1 ) or 1)
    end
end

function ITEM:PopulateTooltip(tooltip)
    local uses = self:GetData("uses", 1)

    if ( uses > 0 ) then
        local uses = tooltip:AddRow("uses")
        uses:SetText(self:GetData("uses", 1))
        uses:SizeToContents()
    end
end

ITEM:Hook("drop", function(item)
    local ply = item.player

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( char:GetData("isConsuming", false) ) then
        char:SetData("isConsuming", false)
    end
end)

function ITEM:Consume(ply)
    if not ( IsValid(ply) ) then
        return
    end

    if not ( ply:Alive() ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    self.hungerAmount = ( self.GetHungerAmount and self:GetHungerAmount(ply) or 10 ) or 10
    self.thirstAmount = ( self.GetThirstAmount and self:GetThirstAmount(ply) or 10 ) or 10
    
    if ( self.hungerAmount ) then
        char:SetHunger(math.Clamp(char:GetHunger() + self.hungerAmount, 0, 100))
    end

    if ( self.thirstAmount ) then
        char:SetThirst(math.Clamp(char:GetThirst() + self.thirstAmount, 0, 100))
    end

    char:SetData("isConsuming", false)
end

ITEM.functions.Consume = {
    name = "Consume",
    tip = "useTip",
    icon = "icon16/cup.png",
    OnRun = function(item)
        local ply = item.player

        if not ( IsValid(ply) ) then
            return false
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return false
        end

        if ( char:GetData("isConsuming", false) ) then
            return
        end

        item.consumeTime = ( item.GetConsumeTime and item:GetConsumeTime(ply) or 0 ) or 0

        if ( item.consumeTime > 0 ) then
            char:SetData("isConsuming", true)

            ply:SetAction("Consuming...", item.consumeTime, function()
                if not ( IsValid(ply) ) then
                    return true
                end

                item:Consume(ply)

                if ( item.OnConsumed ) then
                    item:OnConsumed(ply) // Can be used for emitting sounds, particles, etc.
                end
            end)
        else
            item:Consume(ply)

            if ( item.OnConsumed ) then
                item:OnConsumed(ply) // Can be used for emitting sounds, particles, etc.
            end
        end

        item:SetData("uses", item:GetData("uses", 1) - 1)

        if ( item:GetData("uses", 1) > 0 ) then
            return false
        end

        return true
    end,
    OnCanRun = function(item)
        local ply = item.player

        if not ( IsValid(ply) ) then
            return false
        end

        if not ( ply:Alive() ) then
            return false
        end

        local char = ply:GetCharacter()
        
        if not ( char ) then
            return
        end

        if ( char:GetData("isConsuming", false) ) then
            return false
        end

        if ( item.CanConsume ) then
            if not ( item:CanConsume(ply) ) then
                return false
            end
        end

        return true
    end
}