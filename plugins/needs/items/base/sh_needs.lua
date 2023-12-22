ITEM.name = "Needs Base"
ITEM.description = "A base for a needs item."
ITEM.model = "models/props_lab/crematorcase.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 0
ITEM.thirstAmount = 0
ITEM.hungerAmount = 0
ITEM.consumeTime = 0

ITEM:Hook("drop", function(item)
    local ply = item.player

    if not ( IsValid(ply) ) then
        return
    end
end)

function ITEM:Consume(ply)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    self.hungerAmount = ( self.GetHungerAmount and self:GetHungerAmount(ply) ) or ( self.hungerAmount or 0 )
    self.thirstAmount = ( self.GetThirstAmount and self:GetThirstAmount(ply) ) or ( self.thirstAmount or 0 )
    
    if ( self.hungerAmount ) then
        char:SetHunger(math.Clamp(char:GetHunger() + self.hungerAmount, 0, 100))
    end

    if ( self.thirstAmount ) then
        char:SetThirst(math.Clamp(char:GetThirst() + self.thirstAmount, 0, 100))
    end

    ply.isConsuming = false
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

        if ( item.consumeTime > 0 ) then
            ply.isConsuming = true
            
            item.consumeTime = item:GetConsumeTime(ply) or ( item.consumeTime or 1 )

            ply:SetAction("Consuming...", item.consumeTime, function()
                if not ( IsValid(ply) ) then
                    return true
                end

                item:Consume(ply)

                if ( item.OnConsumed ) then
                    item:OnConsumed(ply)
                end
            end)

            return true
        else
            item:Consume(ply)

            if ( item.OnConsumed ) then
                item:OnConsumed(ply)
            end
            
            return true
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

        if ( ( ply.isConsuming or false ) ) then
            return false
        end

        return true
    end
}