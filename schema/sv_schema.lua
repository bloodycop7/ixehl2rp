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