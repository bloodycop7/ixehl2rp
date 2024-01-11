local PLUGIN = PLUGIN

PLUGIN.name = "Usergroups Handler"
PLUGIN.author = "Ceryx"
PLUGIN.description = "Handles usergroups by SteamID on player spawn"

PLUGIN.Users = {
	["STEAM_0:1:37486791"] = "superadmin",
}

ix.util.Include("sv_plugin.lua")
