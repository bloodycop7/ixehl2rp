function Schema:OpenUI(panel)
	return vgui.Create(panel)
end

function Schema:PlaySound(sound, level, pitch, volume, channel, customCheck)
	local ply = LocalPlayer()

	if not ( IsValid(ply) ) then
		return
	end

	local char = ply:GetCharacter()

	if ( customCheck and not customCheck(ply) ) then
		return
	end

	EmitSound(sound, ply:GetPos(), -2, channel or CHAN_AUTO, volume or 1, level or 75, 0, pitch or 100)
end

function Schema:SendCaption(text, duration)
	RunConsoleCommand("closecaption", "1")
	gui.AddCaption(text, duration or string.len(text) * 0.1)
end

ix.option.Add("itemOutlineColor", ix.type.color, Color(255, 255, 255), {
	category = "appearance"
})

ix.option.Add("itemOutline", ix.type.bool, true, {
	category = "appearance"
})

ix.option.Add("backgroundImages", ix.type.bool, true, {
	category = "appearance"
})

ix.option.Add("glowEyes", ix.type.bool, true, {
    category = "appearance",
})

ix.option.Add("glowEyesRenderDistance", ix.type.number, 1000, {
    category = "appearance",
    min = 0,
    max = 10000,
})

ix.gui.gradients = {
	["left"] = Material("vgui/gradient-l", "smooth noclamp"),
	["right"] = Material("vgui/gradient-r", "smooth noclamp"),
	["up"] = Material("vgui/gradient-u", "smooth noclamp"),
	["down"] = Material("vgui/gradient-d", "smooth noclamp")
}