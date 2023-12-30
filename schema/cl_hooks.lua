function Schema:ShouldHideBars()
	return true
end

function Schema:BuildBusinessMenu()
	return false
end

function Schema:CanPlayerJoinClass(ply, class, info)
	return false
end

function Schema:CanPlayerJoinRank(ply, rank, info)
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

function Schema:CreateCharacterInfo(panel)
	panel.health = panel:Add("ixListRow")
	panel.health:SetList(panel.list)
	panel.health:Dock(TOP)
end

-- populates labels in the status screen
function Schema:UpdateCharacterInfo(panel)
	panel.health:SetLabelText("Health")
	panel.health:SetText(localPlayer:Health())
	panel.health:SizeToContents()
end

function Schema:CanPlayerJoinClass(ply, class, info)
	return false
end

function Schema:CanPlayerJoinRank(ply, rank, info)
	return false
end

function Schema:PlayerStartVoice(ply)
	if ( localPlayer:IsAdmin() ) then
		return false
	end

	return true
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