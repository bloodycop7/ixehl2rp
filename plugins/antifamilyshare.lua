local PLUGIN = PLUGIN

PLUGIN.name = "Anti-Family Share"
PLUGIN.author = "eon"
PLUGIN.description = "Prevents family share accounts from joining the server."
PLUGIN.license = [[
Copyright 2024 eon (bloodycop)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

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

                if not ( v:IsAdmin() ) then
                    continue
                end

                v:ChatNotify("Family share account " .. ply:Name() .. " (" .. steamID64 .. ") attempted to join the server.")
            end
        end
    end
end