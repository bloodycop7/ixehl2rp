local PLUGIN = PLUGIN

function PLUGIN:CalcView(ply, origin, angles, fov)
    if not ( IsValid(localPlayer) ) then
        return
    end

    local stationEnt = localPlayer:GetNetVar("ixCraftingStation")

    if not ( IsValid(stationEnt) ) then
        if ( IsValid(ix.gui.craftingMenu) ) then
            ix.gui.craftingMenu:Remove()
            ix.gui.craftingMenu = nil
        end

        return
    end

    if not ( IsValid(ix.gui.craftingMenu) ) then
        return
    end

    local stationData = ix.crafting.stations[stationEnt:GetStationID()]

    if not ( stationData ) then
        return
    end

    local view = {}
    view.origin = ( stationData.overview and stationData.overview["pos"] or stationEnt:GetPos() + stationEnt:GetUp() * 80 )
    // Make the fall back face down of the entity's angles 
    view.angles = ( stationData.overview and stationData.overview["ang"] or stationEnt:GetAngles() + Angle(90, 180, 0) )
    view.fov = fov

    return view
end