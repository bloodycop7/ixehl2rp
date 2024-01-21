function Schema:OpenUI(panel)
	return vgui.Create(panel)
end

function Schema:PlaySound(sound, level, pitch, volume, channel, customCheck)
	if not ( IsValid(localPlayer) ) then
		return
	end
	
	if ( customCheck and not customCheck(localPlayer) ) then
		return
	end

	EmitSound(sound, LocalPlayer():GetPos(), -2, channel or CHAN_AUTO, volume or 1, level or 75, 0, 1, pitch or 100)
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

ix.gui.gradients = {
	["left"] = Material("vgui/gradient-l", "smooth noclamp"),
	["right"] = Material("vgui/gradient-r", "smooth noclamp"),
	["up"] = Material("vgui/gradient-u", "smooth noclamp"),
	["down"] = Material("vgui/gradient-d", "smooth noclamp")
}