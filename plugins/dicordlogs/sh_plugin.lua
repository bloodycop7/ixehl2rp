local PLUGIN = PLUGIN

PLUGIN.name = "Discord Logs"
PLUGIN.author = "eon"
PLUGIN.description = "Discord Logs"

ix.config.Add("discordLogs", true, "Enable discord logs", nil, {
    category = "Discord Logs"
})

ix.util.Include("sv_plugin.lua")