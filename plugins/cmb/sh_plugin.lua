local PLUGIN = PLUGIN

PLUGIN.name = "Combine Systems"
PLUGIN.author = "eon"
PLUGIN.description = "Self-Explanatory, adds main Combine Functions."

ix.cmbSystems = ix.cmbSystems or {}

ix.char.RegisterVar("bOLStatus", {
    field = "bol_status",
    fieldType = ix.type.bool,
    default = false,
    isLocal = false,
    bNoDisplay = true,
})

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")