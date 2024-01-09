local PLUGIN = PLUGIN
ix.cmbSystems.waypoints = {}

ix.option.Add("combineOverlay", ix.type.bool, true, {
    category = "Combine Systems"
})

ix.option.Add("combineOverlayAssets", ix.type.bool, true, {
    category = "Combine Systems",
})

ix.option.Add("combineOutlineDeployables", ix.type.bool, true, {
    category = "Combine Systems",
})  

ix.option.Add("combineOutlineAssets", ix.type.bool, true, {
    category = "Combine Systems",
})

ix.option.Add("combineOutlineAssetsTeamOnly", ix.type.bool, false, {
    category = "Combine Systems",
})

ix.option.Add("combineOutlineNPCs", ix.type.bool, true, {
    category = "Combine Systems",
})

ix.option.Add("combineOutlineColorNPCsEnemy", ix.type.color, Color(255, 0, 0), {
    category = "Combine Systems",
})

ix.option.Add("combineOutlineColorNPCsFriendlyFallback", ix.type.color, Color(0, 175, 255), {
    category = "Combine Systems",
})

ix.option.Add("combineOverlaySquad", ix.type.bool, true, {
    category = "Combine Systems",
})

ix.option.Add("combineOverlaySquadHealth", ix.type.bool, true, {
    category = "Combine Systems",
})

ix.option.Add("combineOverlaySquadColor", ix.type.color, Color(0, 255, 150), {
    category = "Combine Systems",
})

ix.option.Add("combineOverlaySquadOutline", ix.type.bool, true, {
    category = "Combine Systems",
})

ix.option.Add("combineOverlaySquadOutlineColor", ix.type.color, Color(0, 140, 255), {
    category = "Combine Systems",
})

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

    if not ( data.pos ) then
        data.pos = localPlayer:GetPos()
    end

    timer.Simple(data.duration, function()
        table.RemoveByValue(ix.cmbSystems.waypoints, data)  
    end)

    ix.cmbSystems.waypoints[#ix.cmbSystems.waypoints + 1] = data
end

function PLUGIN:LoadFonts(font, genericFont)
    for i = 6, 40, 2 do
        local value = Schema:ZeroNumber(i, 2)

        surface.CreateFont("ixCombineFont" .. value, {
            font = "Frak",
            size = ScreenScale(i),
            weight = 100,
            antialias = true,
            extended = true,
            shadows = true,
        })
        
        // Registers fonts:
            // "ixCombineFont06"
            // "ixCombineFont08"
            // "ixCombineFont10"
            // "ixCombineFont12"
            // "ixCombineFont14"
            // "ixCombineFont16"
            // "ixCombineFont18"
            // "ixCombineFont20"
            // "ixCombineFont22"
            // "ixCombineFont24"
            // "ixCombineFont26"
            // "ixCombineFont28"
            // "ixCombineFont30"
            // "ixCombineFont32"
            // "ixCombineFont34"
            // "ixCombineFont36"
            // "ixCombineFont38"
            // "ixCombineFont40"
    end
end