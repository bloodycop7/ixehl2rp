local PLUGIN = PLUGIN

PLUGIN.name = "Lootables"
PLUGIN.author = "eon"
PLUGIN.description = "Adds lootable containers."

ix.lootable = ix.lootable or {}
ix.lootable.stored = ix.lootable.stored or {}

ix.lootable.defaultConfig = {
    ["items"] = {
        "gunpowder",
        "gear",
        "metal_plate",
    },
    ["rareItems"] = {
        "wep_mp7",
        "wep_usp"
    }
}

function ix.lootable:Register(lootableData)
    if not ( lootableData.name ) then
        error("Attempt to register lootable without a name!") 
    end

    if not ( lootableData.items ) then
        lootableData.items = self.defaultConfig.items
    end

    if not ( lootableData.rareItems ) then
        lootableData.rareItems = self.defaultConfig.rareItems
    end

    local uniqueID = string.lower(lootableData.name)
    uniqueID = string.Replace(uniqueID, " ", "_")

    self.stored[uniqueID] = lootableData
end

ix.util.Include("sh_lootables.lua")