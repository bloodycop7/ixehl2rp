// Credits: https://github.com/impulseenhanced/impulse/blob/main/gamemode/core/sv_main.lua

function ix.util.IsEmpty(vector, ignore)
    ignore = ignore or {}

    local point = util.PointContents(vector)
    local a = point ~= CONTENTS_SOLID
        and point ~= CONTENTS_MOVEABLE
        and point ~= CONTENTS_LADDER
        and point ~= CONTENTS_PLAYERCLIP
        and point ~= CONTENTS_MONSTERCLIP

    if not ( a ) then
		return false
	end

    local b = true

    for k, v in ipairs(ents.FindInSphere(vector, 35)) do
        if ( ( v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics" or v.NotEmptyPos) and not table.HasValue(ignore, v) ) then
            b = false

            break
        end
    end

	return a and b
end

function ix.util.FindEmptyPos(pos, ignore, distance, step, area)
    if ix.util.IsEmpty(pos, ignore) and ix.util.IsEmpty(pos + area, ignore) then
        return pos
    end

    for j = step, distance, step do
        for i = -1, 1, 2 do -- alternate in direction
            local k = j * i

            -- Look North/South
            if ( ix.util.IsEmpty(pos + Vector(k, 0, 0), ignore) and ix.util.IsEmpty(pos + Vector(k, 0, 0) + area, ignore) ) then
                return pos + Vector(k, 0, 0)
            end

            -- Look East/West
            if ( ix.util.IsEmpty(pos + Vector(0, k, 0), ignore) and ix.util.IsEmpty(pos + Vector(0, k, 0) + area, ignore) ) then
                return pos + Vector(0, k, 0)
            end

            -- Look Up/Down
            if ( ix.util.IsEmpty(pos + Vector(0, 0, k), ignore) and ix.util.IsEmpty(pos + Vector(0, 0, k) + area, ignore) ) then
                return pos + Vector(0, 0, k)
            end
        end
    end

    return pos
end

function Schema:SlapPlayer(client)
	if (IsValid(client) and client:IsPlayer()) then
		client:SetVelocity(Vector(math.random(-50, 50), math.random(-50, 50), math.random(0, 20)))
		client:TakeDamage(math.random(5, 10))
	end
end

// Credits: https://github.com/NebulousCloud/helix-hl2rp/blob/master/schema/sv_schema.lua
function Schema:SearchPlayer(client, target)
	if not( target:GetCharacter() or target:GetCharacter():GetInventory() ) then
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

	if ( isstring(index) ) then
		index = ply:FindBodygroupByName(index)
	end

	value = value or 1

	if not ( isnumber(index) and isnumber(value) ) then
		return
	end

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
function Schema:PlaySound(players, sound, level, pitch, volume, channel)
	local actualPlayerTable = {}

	if ( type(players) == "Player" ) then
		actualPlayerTable = {players}
	elseif ( type(players) == "table" ) then
		actualPlayerTable = players
	else
		for k, v in player.Iterator() do
			if not ( IsValid(v) ) then
				continue
			end

			actualPlayerTable[#actualPlayerTable + 1] = v
		end
	end

	level = level or 75
	pitch = pitch or 100
	volume = volume or 1
	channel = channel or CHAN_AUTO

	net.Start("ix.PlaySound")
		net.WriteString(sound)
		net.WriteFloat(level)
		net.WriteFloat(pitch)
		net.WriteFloat(volume)
		net.WriteFloat(channel)
	net.Send(actualPlayerTable)
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