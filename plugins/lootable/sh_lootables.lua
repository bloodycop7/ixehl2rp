local PLUGIN = PLUGIN

local lootable = {}

lootable.name = "Barrel"
lootable.model = "models/props_c17/oildrum001.mdl"
lootable.items = {
    "wep_mp7"
}

lootable.rareItems = {
    "wep_usp"
}

function lootable:lootTime()
    return math.random(1, 3) 
end

ix.lootable:Register(lootable)

lootable = {}

lootable.name = "Large Crate"
lootable.model = "models/props_junk/wood_crate002a.mdl"

function lootable:lootTime()
    return math.random(1, 3) 
end

ix.lootable:Register(lootable)

lootable = {}

lootable.name = "Trash Can"
lootable.model = "models/props_trainstation/trashcan_indoor001a.mdl"

function lootable:lootTime()
    return 4
end

ix.lootable:Register(lootable)

lootable = {}

lootable.name = "Dumpster"
lootable.model = "models/props_junk/trashdumpster01a.mdl"

function lootable:lootTime()
    return 4
end

ix.lootable:Register(lootable)

lootable = {}

lootable.name = "Crate"
lootable.model = "models/props_junk/wood_crate001a.mdl"

function lootable:lootTime()
    return 4
end

ix.lootable:Register(lootable)