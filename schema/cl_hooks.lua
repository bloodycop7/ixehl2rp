function Schema:ShouldHideBars()
	return true
end

function Schema:BuildBusinessMenu()
	return false
end

function Schema:CanPlayerJoinClass(client, class, info)
	return false
end

function Schema:ShouldDrawCrosshair()
	if ( IsValid(localPlayer:GetActiveWeapon()) ) then
		if ( localPlayer:GetActiveWeapon():GetClass():find("tfa*") ) then
			return
		end
	end

	return false
end

local supress = {}

function Schema:CreateCharacterInfo(charInfo)
	if not ( supress.health ) then
		supress.health = charInfo:Add("ixListRow")
		supress.health:SetList(charInfo.list)
		supress.health:Dock(TOP)
		supress.health:SizeToContents()
	end
end

function Schema:UpdateCharacterInfo(charInfo, char)
	if ( supress.health ) then
		supress.health:SetLabelText("Health")
		supress.health:SetText(localPlayer:Health())
		supress.health:SizeToContents()
	end
end

function Schema:CanPlayerJoinClass(ply, class, info)
	return false
end

function Schema:CanPlayerJoinRank(ply, rank, info)
	return false
end

net.Receive("ix.Schema.OpenUI", function()
	local panel = net.ReadString()

	Schema:OpenUI(panel)
end)

net.Receive("ix.PlaySound", function()
	local sound = net.ReadString()
	local level = net.ReadFloat()
	local pitch = net.ReadFloat()
	local volume = net.ReadFloat()
	local channel = net.ReadFloat()

	localPlayer:EmitSound(sound, level, pitch, volume, channel)
end)