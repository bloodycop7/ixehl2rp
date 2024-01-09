function Schema:SlapPlayer(client)
	if (IsValid(client) and client:IsPlayer()) then
		client:SetVelocity(Vector(math.random(-50, 50), math.random(-50, 50), math.random(0, 20)))
		client:TakeDamage(math.random(5, 10))
	end
end

// Credits: https://github.com/NebulousCloud/helix-hl2rp/blob/master/schema/sv_schema.lua
function Schema:SearchPlayer(client, target)
	if (!target:GetCharacter() or !target:GetCharacter():GetInventory()) then
		return false
	end

	local name = hook.Run("GetDisplayedName", target) or target:Name()
	local inventory = target:GetCharacter():GetInventory()

	ix.storage.Open(client, inventory, {
		entity = target,
		name = name
	})

	return true
end

function Schema:SetCharBodygroup(ply, index, value)
	if not ( IsValid(ply) ) then
		return
	end

	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	index = index or 1
	value = value or 1

	local groupsData = char:GetData("groups", {})
	groupsData[index] = value

	char:SetData("groups", groupsData)
	ply:SetBodygroup(index, value)
end

util.AddNetworkString("ix.Schema.OpenUI")
function Schema:OpenUI(ply, panel)
	net.Start("ix.Schema.OpenUI")
		net.WriteString(panel)
	net.Send(ply)
end

util.AddNetworkString("ix.PlaySound")
function Schema:PlaySound(players, sound, level, pitch, volume, channel, customCheck)
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
		if not ( IsValid(v) ) then
			continue
		end

		if ( customCheck and not customCheck(v) ) then
			continue
		end

		net.Send(v)
	end
end

util.AddNetworkString("ix.PlayGesture")

if ( TFA ) then
	if ( GetConVar("sv_tfa_attachments_enabled"):GetInt() != 0 ) then
		RunConsoleCommand("sv_tfa_attachments_enabled", 0)
	end

	if ( GetConVar("sv_tfa_cmenu"):GetInt() != 0 ) then
		RunConsoleCommand("sv_tfa_cmenu", 0)
	end
end