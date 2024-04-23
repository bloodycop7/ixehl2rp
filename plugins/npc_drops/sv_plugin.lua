local PLUGIN = PLUGIN

PLUGIN:Define("npc_metropolice", {
    items = {
        "wep_mp7"
    },
    rareItems = {},
    GetRarityChance = function(self, ply)
        return math.random(1, 100)
    end,
    GetDropCount = function(self, ply)
        return 1
    end,
    OnDrop = function(self, ply, item)
        if not ( ply:IsPlayer() ) then
            return
        end
    end
})

function PLUGIN:OnNPCKilled(npc, attacker, wep)
    if not ( IsValid(npc) ) then
        return
    end

    if not ( self.stored[npc:GetClass()] ) then
        return
    end

    local dropData = self.stored[npc:GetClass()]

    if not ( dropData ) then
        return
    end

    if ( npc.GetWeapons ) then
        for k, v in ipairs(npc:GetWeapons()) do
            if not ( IsValid(v) ) then
                continue
            end
            
            v:Remove()
        end
    end

    for i = 1, ( dropData:GetDropCount(attacker) or 1 ) do
        local item = dropData.items[math.random(1, #dropData.items)]
        
        if not ( #dropData.rareItems <= 0 ) then
            if ( ( dropData:GetRarityChance(attacker) or math.random(1, 100) ) >= math.random(1, 100) ) then
                item = dropData.rareItems[math.random(1, #dropData.rareItems)]
            end
        end

        if not ( ix.item.Get(item) ) then
            continue
        end

        ix.item.Spawn(item, npc:GetPos() + npc:GetUp() * 10)

        if ( dropData.OnDrop ) then
            dropData:OnDrop(attacker, item)
        end
    end
end