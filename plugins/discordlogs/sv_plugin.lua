// Get a Steam Web API: https://steamcommunity.com/dev/apikey
// Requires: https://github.com/WilliamVenner/gmsv_reqwest/releases
// Originally took from another server I'm working on, but I decided to make it public for everyone to use.

local PLUGIN = PLUGIN

ix.DiscordLogs = ix.DiscordLogs or {}
ix.DiscordLogs.SteamAPI = "AB04D7C0E9FAC87E6814E8BA753B1EA8"
ix.DiscordLogs.StoredAvatars = {}

function ix.DiscordLogs:Format(ent)
    if not ( IsValid(ent) ) then
        return
    end

    if ( ent:IsPlayer() ) then
        return ent:Nick() .. " (" .. ent:SteamID64() .. ")"
    end

    return tostring(ent)
end

function PLUGIN:PlayerAuthed(ply, steamid, uniqueID)
    http.Fetch("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. ix.DiscordLogs.SteamAPI .. "&steamids=" .. ply:SteamID64(), function(body, len, headers, code)
        ix.DiscordLogs.StoredAvatars[ply:SteamID64()] = util.JSONToTable(body).response.players[1].avatarfull
    end)
end

function PLUGIN:OnReloaded()
    for k, v in player.Iterator() do
        http.Fetch("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. ix.DiscordLogs.SteamAPI .. "&steamids=" .. v:SteamID64(), function(body, len, headers, code)
            ix.DiscordLogs.StoredAvatars[v:SteamID64()] = util.JSONToTable(body).response.players[1].avatarfull
        end)
    end
end

ix.DiscordLogs.Webhooks = {
    ["chat"] = "https://discord.com/api/webhooks/XXXXXXXX/XXXXX",
    ["joinleave"] = "https://discord.com/api/webhooks/XXXXXXXX/XXXXX",
    ["admin"] = "https://discord.com/api/webhooks/XXXXXXXX/XXXXX",
}

require("reqwest")

function ix.DiscordLogs:SendWebhook(webhook, bodyData)
    if not ( ix.config.Get("discordLogs", true) ) then
        return
    end
    
    bodyData.username = bodyData.userName or "Helix: Enhanced Half-Life 2 Roleplay"
    bodyData.avatar_url = bodyData.avatarURL or "https://cdn.discordapp.com/icons/1069473418195501086/4f6c7bfbccad06c24be5fb8aba497950.webp?size=96"
    bodyData.content = bodyData.content or "`TestMessage`"

    if ( bodyData.useTime ) then
        bodyData.content = bodyData.content .. " (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T> " .. ")"
    end

    reqwest({
        method = "POST",
        url = ix.DiscordLogs.Webhooks[webhook] or webhook,
        timeout = 1,
        body = util.TableToJSON(bodyData),
        type = "application/json",
        headers = {
            ["User-Agent"] = "My User Agent"
        }
    })
end

gameevent.Listen("player_connect")
hook.Add("player_connect", "ix.DiscordLogs.PlayerConnect", function(data)
    ix.DiscordLogs:SendWebhook("joinleave", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Connect (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = data.name .. " is connecting to the server!",
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[util.SteamIDTo64(data.networkid)]
                }
            }
        }
    })
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "ix.DiscordLogs.PlayerLeave", function(data)
    ix.DiscordLogs:SendWebhook("joinleave", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Disconnect (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = data.name .. " has disconnected from the server!" .. "(" .. data.reason .. ")",
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[util.SteamIDTo64(data.networkid)]
                }
            }
        }
    })
end)

function PLUGIN:PlayerSay(ply, text, teamChat)
    ix.DiscordLogs:SendWebhook("admin", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Chat (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = ply:SteamName() .. " (" .. ply:SteamID64() .. ") " .. "(" .. ply:GetChar():GetName() .. ") said: " .. text,
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[ply:SteamID64()]
                }
            }
        }
    })
end

function PLUGIN:PlayerSpawnedProp(ply, model, ent)
    if not ( IsValid(ply) or IsValid(ent) ) then
        return
    end

    ix.DiscordLogs:SendWebhook("admin", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Spawned Prop (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = ply:SteamName() .. " (" .. ply:SteamID64() .. ") " .. "(" .. ply:GetChar():GetName() .. ") spawned " .. model .. " (" .. ix.DiscordLogs:Format(ent) .. ")",
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[ply:SteamID64()]
                }
            }
        }
    })
end

function PLUGIN:PlayerSpawnedRagdoll(ply, model, ent)
    if not ( IsValid(ply) or IsValid(ent) ) then
        return
    end

    ix.DiscordLogs:SendWebhook("admin", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Spawned Ragdoll (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = ply:SteamName() .. " (" .. ply:SteamID64() .. ") " .. "(" .. ply:GetChar():GetName() .. ") spawned " .. model .. " (" .. ix.DiscordLogs:Format(ent) .. ")",
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[ply:SteamID64()]
                }
            }
        }
    })
end

function PLUGIN:PlayerSpawnedEffect(ply, model, ent)
    if not ( IsValid(ply) or IsValid(ent) ) then
        return
    end

    ix.DiscordLogs:SendWebhook("admin", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Spawned Effect (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = ply:SteamName() .. " (" .. ply:SteamID64() .. ") " .. "(" .. ply:GetChar():GetName() .. ") spawned " .. model .. " (" .. ix.DiscordLogs:Format(ent) .. ")",
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[ply:SteamID64()]
                }
            }
        }
    })
end

function PLUGIN:PlayerSpawnedVehicle(ply, ent)
    if not ( IsValid(ply) or IsValid(ent) ) then
        return
    end

    ix.DiscordLogs:SendWebhook("admin", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Spawned Vehicle (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = ply:SteamName() .. " (" .. ply:SteamID64() .. ") " .. "(" .. ply:GetChar():GetName() .. ") spawned " .. ix.DiscordLogs:Format(ent),
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[ply:SteamID64()]
                }
            }
        }
    })
end

function PLUGIN:PlayerSpawnedSENT(ply, ent)
    if not ( IsValid(ply) or IsValid(ent) ) then
        return
    end

    ix.DiscordLogs:SendWebhook("admin", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Spawned Entity (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = ply:SteamName() .. " (" .. ply:SteamID64() .. ") " .. "(" .. ply:GetChar():GetName() .. ") spawned " .. ix.DiscordLogs:Format(ent),
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[ply:SteamID64()]
                }
            }
        }
    })
end

function PLUGIN:PlayerSpawnedNPC(ply, ent)
    if not ( IsValid(ply) or IsValid(ent) ) then
        return
    end

    ix.DiscordLogs:SendWebhook("admin", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Spawned NPC (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = ply:SteamName() .. " (" .. ply:SteamID64() .. ") " .. "(" .. ply:GetChar():GetName() .. ") spawned "  .. ix.DiscordLogs:Format(ent),
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[ply:SteamID64()]
                }
            }
        }
    })
end

function PLUGIN:PlayerSpawnedSWEP(ply, ent)
    if not ( IsValid(ply) or IsValid(ent) ) then
        return
    end
    
    ix.DiscordLogs:SendWebhook("admin", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Spawned Weapon (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = ply:SteamName() .. " (" .. ply:SteamID64() .. ") " .. "(" .. ply:GetChar():GetName() .. ") spawned " .. ix.DiscordLogs:Format(ent),
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[ply:SteamID64()]
                }
            }
        }
    })
end

function PLUGIN:PlayerGiveSWEP(ply, class, swep)
    if not ( IsValid(ply) ) then
        return
    end

    ix.DiscordLogs:SendWebhook("admin", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Spawned Weapon (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = ply:SteamName() .. " (" .. ply:SteamID64() .. ") " .. "(" .. ply:GetChar():GetName() .. ") spawned " .. class,
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[ply:SteamID64()]
                }
            }
        }
    })
end

function PLUGIN:PlayerHurt(victim, attacker, healthRemaining, damageTaken)
    if not ( IsValid(victim) ) then
        return
    end

    local msg = "World"

    if ( IsValid(attacker) and attacker:IsPlayer() and attacker:IsNPC() ) then
        msg = attacker:IsPlayer() and attacker:Nick() or attacker:GetClass()
    end

    ix.DiscordLogs:SendWebhook("admin", {
        content = "",
        avatarURL = "",
        embeds = {
            {
                title = "Player Spawned Prop (<t:" .. math.floor(os.time()) .. ":D> " .. "<t:" .. math.floor(os.time()) .. ":T>)",
                color = 3066993,
                description = msg .. " hurt " .. ix.DiscordLogs:Format(victim) .. " for " .. damageTaken .. " damage. (" .. healthRemaining .. " health remaining)",
                thumbnail = {
                    url = ix.DiscordLogs.StoredAvatars[victim:SteamID64()]
                }
            }
        }
    })
end