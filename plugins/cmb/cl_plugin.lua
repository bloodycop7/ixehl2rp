local PLUGIN = PLUGIN
ix.cmbSystems.waypoints = {}

function ix.cmbSystems:MakeWaypoint(data)
    if not ( istable(data) ) then
        ErrorNoHalt("Attempted to create a waypoint with invalid data!")
        return
    end

    if not ( data.text ) then
        ErrorNoHalt("Attempted to create a waypoint without text!")
        return
    end

    data.sentBy = data.sentBy or "Dispatch"

    if not ( data.duration ) then
        data.duration = 5
    end

    data.duration = CurTime() + data.duration

    if not ( data.pos ) then
        data.pos = localPlayer:GetPos()
    end

    data.id = data.id or "ix_cmb_waypoint." .. (table.Count(ix.cmbSystems.waypoints) + 1)

    ix.cmbSystems.waypoints[data.id] = data
end

timer.Create("ix.cmbSystems.waypointTimer", 1, 0, function()
    for k, v in pairs(ix.cmbSystems.waypoints) do
        if ( v.duration <= CurTime() ) then
            ix.cmbSystems.waypoints[k] = nil
        end
    end
end)

surface.CreateFont("ixCombineHUDFont", {
    font = "Frak",
    size = ScreenScale(10),
    weight = 200,
    antialias = true,
    shadows = true,
})

surface.CreateFont("ixCombineTerminalFont", {
    font = "Frak",
    size = ScreenScale(15),
    weight = 200,
    antialias = true,
    shadows = true,
})

surface.CreateFont("ixCombineHUDWaypointText", {
    font = "Frak",
    size = ScreenScale(8),
    weight = 200,
    antialias = true,
    shadows = true,
})