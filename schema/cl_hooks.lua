function Schema:ShouldHideBars()
	return true
end

function Schema:BuildBusinessMenu()
	return false
end

function Schema:CanPlayerJoinClass(client, class, info)
	return false
end

net.Receive("ix.Schema.OpenUI", function()
	local panel = net.ReadString()

	Schema:OpenUI(panel)
end)