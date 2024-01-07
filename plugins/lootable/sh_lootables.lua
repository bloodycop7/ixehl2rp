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