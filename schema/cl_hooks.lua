function Schema:ShouldHideBars()
	return true
end

function Schema:BuildBusinessMenu()
	return false
end

function Schema:CanPlayerJoinClass(client, class, info)
	return false
end

local supress = {}

function Schema:CreateCharacterInfo(charInfo)
	if not ( supress.health ) then
		supress.money = charInfo:Add("ixListRow")
		supress.money:SetList(charInfo.list)
		supress.money:Dock(TOP)
		supress.money:SizeToContents()
	end
end

function Schema:UpdateCharacterInfo(charInfo, char)
	if (supress.money) then
		supress.money:SetLabelText("Health")
		supress.money:SetText(localPlayer:Health())
		supress.money:SizeToContents()
	end
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
	local dsp = net.ReadFloat()

	localPlayer:EmitSound(sound, level, pitch, volume, channel, dsp)
end)