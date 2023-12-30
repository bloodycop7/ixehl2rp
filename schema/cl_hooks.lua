function Schema:ShouldHideBars()
	return true
end

function Schema:CanDrawAmmoHUD()
	return false
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
	return true
end

local COMMAND_PREFIX = "/"

function Schema:ChatTextChanged(text)
	if ( self:IsCombine(localPlayer) ) then
		local key = nil

		if ( text == COMMAND_PREFIX .. "radio " ) then
			key = "r"
		elseif ( text == COMMAND_PREFIX .. "w ") then
			key = "w"
		elseif ( text == COMMAND_PREFIX .. "y " ) then
			key = "y"
		elseif ( text:sub(1, 1):match("%w") ) then
			key = "t"
		end

		if ( key ) then
			net.Start("ix.PlayerChatTextChanged")
				net.WriteString(key)
			net.SendToServer()
		end
	end
end

function Schema:FinishChat()
	net.Start("ix.PlayerFinishChat")
	net.SendToServer()
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