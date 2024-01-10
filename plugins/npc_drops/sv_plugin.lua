local PLUGIN = PLUGIN

ix.npcDrops:Define("npc_metropolice", {
    items = {},
    rareItems = {},
    rarity = function(ply)
        return 50
    end,
    rarityChance = function(ply)
        return math.random(1, 100)
    end
})