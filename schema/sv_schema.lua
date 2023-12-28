function Schema:SlapPlayer(client)
	if (IsValid(client) and client:IsPlayer()) then
		client:SetVelocity(Vector(math.random(-50, 50), math.random(-50, 50), math.random(0, 20)))
		client:TakeDamage(math.random(5, 10))
	end
end

util.AddNetworkString("ix.Schema.OpenUI")
function Schema:OpenUI(ply, panel)
	net.Start("ix.Schema.OpenUI")
		net.WriteString(panel)
	net.Send(ply)
end

util.AddNetworkString("ix.PlaySound")
function Schema:PlaySound(players, sound, level, pitch, volume, channel)
	if ( isentity(players) ) then
		players = {players}
	end

	net.Start("ix.PlaySound")
		net.WriteString(sound)
		net.WriteFloat(level or 75)
		net.WriteFloat(pitch or 100)
		net.WriteFloat(volume or 1)
		net.WriteFloat(channel or CHAN_AUTO)
	for k, v in ipairs(players) do
		net.Send(v)
	end
end