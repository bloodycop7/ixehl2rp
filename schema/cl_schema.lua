function Schema:OpenUI(panel)
	return vgui.Create(panel)
end

ix.gui.gradients = {
	["left"] = Material("vgui/gradient-l", "smooth noclamp"),
	["right"] = Material("vgui/gradient-r", "smooth noclamp"),
	["up"] = Material("vgui/gradient-u", "smooth noclamp"),
	["down"] = Material("vgui/gradient-d", "smooth noclamp")
}