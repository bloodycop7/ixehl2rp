local PLUGIN = PLUGIN

ix.lootable:Register({
    name = "Barrel",
    model = "models/props_c17/oildrum001.mdl",
    items = {
        "wep_mp7"
    },
    rareItems = {
        "wep_usp"
    },
    lootTime = function()
        return math.random(1, 3) 
    end
})

ix.lootable:Register({
    name = "Large Crate",
    model = "models/props_junk/wood_crate002a.mdl",
    lootTime = function()
        return math.random(1, 3) 
    end
})

ix.lootable:Register({
    name = "Trash Can",
    model = "models/props_junk/TrashDumpster01a.mdl",
    lootTime = 4
})

ix.lootable:Register({
    name = "Dumpster",
    model = "models/props_junk/trashdumpster01a.mdl",
    lootTime = 4
})

ix.lootable:Register({
    name = "Crate",
    model = "models/props_junk/wood_crate001a.mdl",
    lootTime = 4
})