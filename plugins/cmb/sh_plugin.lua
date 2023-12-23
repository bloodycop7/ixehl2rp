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

ix.cmbSystems.CityCodes = {
    {
        name = "Preserved",
        color = Color(0, 255, 0),
        onStart = function()
            print("PReserved")
        end
    },
    {
        name = "Marginal",
        color = Color(255, 255, 0),
        onStart = function()
            print("PReserved")
        end
    },
    {
        name = "Judgment Waiver",
        color = Color(255, 0, 0),
        onStart = function()
            print("PReserved")
        end
    },
    {
        name = "Autonomous Judgment",
        color = Color(255, 0, 0),
        onStart = function()
            print("PReserved")
        end
    }
}

function ix.cmbSystems.GetCityCode()
    return GetGlobalInt("ixCityCode", 1)
end