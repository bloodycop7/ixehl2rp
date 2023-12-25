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

    ix.cmbSystems.waypoints[#ix.cmbSystems.waypoints + 1] = data
end

timer.Create("ix.cmbSystems.waypointTimer", 1, 0, function()
    for k, v in pairs(ix.cmbSystems.waypoints) do
        if ( v.duration <= CurTime() ) then
            ix.cmbSystems.waypoints[k] = nil
        end
    end
end)

for i = 6, 40, 2 do
    local value = Schema:ZeroNumber(i, 2)

    surface.CreateFont("ixCombineHUDFont"..value, {
        font = "Frak",
        size = ScreenScale(i),
        weight = 200,
        antialias = true,
        shadows = true,
    })
end