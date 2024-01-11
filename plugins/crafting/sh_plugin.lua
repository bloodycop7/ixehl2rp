local PLUGIN = PLUGIN

PLUGIN.name = "Crafting"
PLUGIN.author = "eon"
PLUGIN.description = "Adds a crafting system."
PLUGIN.license = [[
Copyright 2024 eon (bloodycop)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.crafting = ix.crafting or {}
ix.crafting.recipes = {}
ix.crafting.stations = {}

function ix.crafting:RegisterRecipe(recipeTable)
    if not ( istable(recipeTable) ) then
        ErrorNoHalt("recipeTable is not a table!\n")

        return
    end
    if not ( recipeTable.name ) then
        ErrorNoHalt("recipeTable.name is not defined!\n")

        return
    end

    if not ( recipeTable.requirements ) then
        ErrorNoHalt("recipeTable.requirements is not defined!\n")

        return
    end

    if not ( recipeTable.result ) then
        ErrorNoHalt("recipeTable.result is not defined!\n")

        return
    end

    if ( recipeTable.stations and not ix.crafting.stations[recipeTable.stations] ) then
        ErrorNoHalt("recipeTable.stations contains a non valid station!\n")

        return
    end

    recipeTable.model = recipeTable.model or "models/props_junk/cardboard_box004a.mdl"
    recipeTable.category = recipeTable.category or "Miscellaneous"

    ix.crafting.recipes[recipeTable.uniqueID] = recipeTable
end

function ix.crafting:RegisterStation(stationTable)
    if not ( istable(stationTable) ) then
        ErrorNoHalt("recipeTable is not a table!\n")

        return
    end

    if not ( stationTable.name ) then
        ErrorNoHalt("recipeTable.name is not defined!\n")

        return
    end

    stationTable.model = stationTable.model or "models/props_junk/cardboard_box004a.mdl"
    stationTable.category = stationTable.category or "General"

    local STATION = {}

    STATION.Type = "anim"
    STATION.PrintName = stationTable.name .. " Station"
    STATION.Category = "ix: HL2RP - Crating Stations"
    STATION.Spawnable = true
    STATION.AdminOnly = true
    STATION.PhysgunDisable = true
    STATION.bNoPersist = true

    function STATION:SetupDataTables()
        self:NetworkVar("String", 0, "StationID")
    end

    if ( SERVER ) then
        function STATION:Initialize()
            self:SetModel(stationTable.model)
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            self:SetUseType(SIMPLE_USE)
            self:SetStationID(stationTable.uniqueID)

            local physics = self:GetPhysicsObject()
            physics:EnableMotion(false)
            physics:Sleep()

            self.nextUse = 0
        end

        function STATION:Use(ply)
            if not ( ply:GetEyeTrace().Entity == self ) then
                return
            end

            if ( self.nextUse > CurTime() ) then
                return
            end

            ply:SetData("ixCraftingStation", self)
            Schema:OpenUI(ply, "ixCraftingMenu")

            self.nextUse = CurTime() + 1
        end

        function STATION:OnRemove()
            for k, v in ipairs(player.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end

                if not ( v:GetCharacter() ) then
                    continue
                end

                if ( v:GetData("ixCraftingStation", nil) == self ) then
                    v:SetData("ixCraftingStation", nil)
                end
            end
        end
    end

    scripted_ents.Register(STATION, "ix_crafting_station_" .. stationTable.uniqueID)
    ix.crafting.stations[stationTable.uniqueID] = stationTable
end

ix.util.Include("sv_plugin.lua")

ix.util.IncludeDir(PLUGIN.folder .. "/stations", true)
ix.util.IncludeDir(PLUGIN.folder .. "/recipes", true)