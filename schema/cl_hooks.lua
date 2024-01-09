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

// Credits: https://github.com/Lite-Network/lnhl2rpsemiserious/blob/main/schema/cl_schema.lua

function Schema:PopulateHelpMenu(tabs)
	tabs["voices"] = function(container)
		local classes = {}

		for k, v in pairs(Schema.voices.classes) do
			if (v.condition(localPlayer)) then
				classes[#classes + 1] = k
			end
		end

		if (#classes < 1) then
			local info = container:Add("DLabel")
			info:SetFont("ixSmallFont")
			info:SetText("You do not have access to any voice lines!")
			info:SetContentAlignment(5)
			info:SetTextColor(color_white)
			info:SetExpensiveShadow(1, color_black)
			info:Dock(TOP)
			info:DockMargin(0, 0, 0, 8)
			info:SizeToContents()
			info:SetTall(info:GetTall() + 16)

			info.Paint = function(_, width, height)
				surface.SetDrawColor(ColorAlpha(derma.GetColor("Error", info), 160))
				surface.DrawRect(0, 0, width, height)
			end

			return
		end

		table.sort(classes, function(a, b)
			return a < b
		end)

		local searchEntry = container:Add("ixIconTextEntry")
		searchEntry:Dock(TOP)
		searchEntry:SetEnterAllowed(false)

		local function ListVoices(filter)
			for _, class in ipairs(classes) do
				local category = container:Add("Panel")
				category:Dock(TOP)
				category:DockMargin(0, 0, 0, 8)
				category:DockPadding(8, 8, 8, 8)
				category.Paint = function(_, width, height)
					surface.SetDrawColor(Color(0, 0, 0, 66))
					surface.DrawRect(0, 0, width, height)
				end
				category.removeOnFilter = true

				local categoryLabel = category:Add("DLabel")
				categoryLabel:SetFont("ixMediumLightFont")
				categoryLabel:SetText(class:upper())
				categoryLabel:Dock(FILL)
				categoryLabel:SetTextColor(color_white)
				categoryLabel:SetExpensiveShadow(1, color_black)
				categoryLabel:SizeToContents()
				categoryLabel.removeOnFilter = true
				category:SizeToChildren(true, true)

				if self.voices and self.voices.stored and self.voices.stored[class] then
					for command, info in SortedPairs(self.voices.stored[class]) do
						if filter == nil or (command:lower():find(filter:lower()) or info.text:lower():find(filter:lower())) then
							local title = container:Add("ixMenuButton")
							title:SetFont("ixMediumFont")
							title:SetText(command:upper())
							title:Dock(TOP)
							title:SetTextColor(ix.config.Get("color"))
							title:SetSize(container:GetWide(), 18)
							title.DoClick = function()
								ix.util.Notify("You have copied: "..tostring(command:upper()))
								SetClipboardText(tostring(command:upper()))
							end
							title.removeOnFilter = true

							local description = container:Add("DLabel")
							description:SetFont("ixSmallFont")
							description:SetText(info.text)
							description:Dock(TOP)
							description:SetTextColor(color_white)
							description:SetExpensiveShadow(1, color_black)
							description:SetWrap(true)
							description:SetAutoStretchVertical(true)
							description:SizeToContents()
							description:DockMargin(0, 0, 0, 8)
							description.removeOnFilter = true
						end
					end
				end
			end
		end

		searchEntry.OnChange = function(entry)
			local function deepRemove(panel)
				for k, v in pairs(panel:GetChildren()) do
					if v.removeOnFilter == true then
						v:Remove()
					else
						if v:HasChildren() then deepRemove(v) end
					end
				end
			end

			deepRemove(container)
			ListVoices(searchEntry:GetValue())
		end

		ListVoices()
	end
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
	net.Start("ix.PlayerStartVoice")
	net.SendToServer()

	if ( IsValid(g_VoicePanelList) ) then
		g_VoicePanelList:Remove()
	end

	return true
end

function Schema:HUDShouldDraw(element)
	if ( element == "CHudVoiceStatus" or element == "CHudVoiceSelfStatus" ) then
		return false
	end
end

function Schema:PlayerEndVoice(ply)
	net.Start("ix.PlayerEndVoice")
	net.SendToServer()
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

	EmitSound(sound, localPlayer:GetPos(), -1, channel, volume, level, 0, pitch)
end)

net.Receive("ix.PlayGesture", function(len)
	if not ( IsValid(localPlayer) ) then
		return
	end

	local playerT = net.ReadEntity()

	if not ( IsValid(playerT) ) then
		return
	end

	if not ( playerT:GetCharacter() ) then
		return
	end

	local sequence = net.ReadString()

	if not ( playerT:LookupSequence(sequence) ) then
		return
	end

	local index, length = playerT:LookupSequence(sequence)

	playerT:DoAnimationEvent(index)
end)