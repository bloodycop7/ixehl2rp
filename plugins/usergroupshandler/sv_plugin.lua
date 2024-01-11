local PLUGIN = PLUGIN

function PLUGIN:PlayerInitialSpawn(client)
	timer.Simple(1, function()
		if (client:IsValid()) then
		  	if (PLUGIN.Users[client:SteamID()]) then
				client:SetUserGroup(PLUGIN.Users[client:SteamID()])
			end
		end
	end)
end