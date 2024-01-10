local PLUGIN = PLUGIN

PLUGIN.name = "NPC Drops"
PLUGIN.author = "eon"
PLUGIN.description = "NPCs drop items when killed."

ix.npcDrops = ix.npcDrops or {}
ix.npcDrops.stored = ix.npcDrops.stored or {}

function ix.npcDrops:Define(class, data)
    self.stored[class] = data
end

ix.util.Include("sv_plugin.lua")