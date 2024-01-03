local PLUGIN = PLUGIN

PLUGIN.name = "Anti-Family Share"
PLUGIN.author = "eon"
PLUGIN.description = "Prevents family share accounts from joining the server."

ix.config.Add("familyShare", true, "Whether or not to prevent family share accounts from joining the server.", nil, {
    category = "Anti-Family Share"
})

ix.config.Add("notifyAdmins", true, "Whether or not to notify admins when a family share account attempts to join the server.", nil, {
    category = "Anti-Family Share"
})

if not ( SERVER ) then
    return
end

function PLUGIN:PlayerAuthed(ply, steamid, uniqueID)
    local steamID64 = util.SteamIDTo64(steamid)

    if not ( ix.config.Get("familyShare", true) ) then
        return
    end
    
    if not ( ply:OwnerSteamID64() == steamID64 ) then
        ply:Kick("Family share accounts are not allowed on this server.")

        if ( ix.config.Get("notifyAdmins", true) ) then
            for k, v in ipairs(player.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end

                v:ChatNotify("Family share account " .. ply:Name() .. " (" .. steamID64 .. ") attempted to join the server.")
            end
        end
    end
end