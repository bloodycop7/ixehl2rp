local PLUGIN = PLUGIN

PLUGIN.name = "Crafting"
PLUGIN.author = "eon"
PLUGIN.description = "Adds a crafting system."

ix.crafting = ix.crafting or {}
ix.crafting.recipes = {}
ix.crafting.stations = {}

function ix.crafting:RegisterRecipe(recipeTable)
    if not ( istable(recipeTable) ) then
        ErrorNoHalt("recipeTable is not a table!")

        return
    end

    if not ( recipeTable.name ) then
        ErrorNoHalt("recipeTable.name is not defined!")

        return
    end

    recipeTable.model = recipeTable.model or "models/props_junk/cardboard_box004a.mdl"
    recipeTable.category = recipeTable.category or "Miscellaneous"

    ix.crafting.recipes[recipeTable.uniqueID] = recipeTable
end

function ix.crafting:RegisterStation(stationTable)
    if not ( istable(stationTable) ) then
        ErrorNoHalt("recipeTable is not a table!")

        return
    end

    if not ( stationTable.name ) then
        ErrorNoHalt("recipeTable.name is not defined!")

        return
    end

    stationTable.model = stationTable.model or "models/props_junk/cardboard_box004a.mdl"
    stationTable.category = stationTable.category or "General"

    local STATION = {}

    STATION.Type = "anim"
    STATION.PrintName = "Crafting Station - " .. stationTable.name
    STATION.Category = "ix: HL2RP"
    STATION.Spawnable = true
    STATION.AdminOnly = true
    STATION.PhysgunDisable = true
    STATION.bNoPersist = true

    if ( SERVER ) then
        function STATION:Initialize()
            self:SetModel(stationTable.model)
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            self:SetUseType(SIMPLE_USE)

            local physics = self:GetPhysicsObject()
            physics:EnableMotion(false)
            physics:Sleep()

            self.nextUse = 0
        end
    end

    scripted_ents.Register(STATION, "ix_crafting_station_" .. stationTable.uniqueID)
    ix.crafting.stations[stationTable.uniqueID] = stationTable
end

ix.util.Include("sv_plugin.lua")

ix.util.IncludeDir(PLUGIN.folder .. "/station", true)
ix.util.IncludeDir(PLUGIN.folder .. "/recipes", true)