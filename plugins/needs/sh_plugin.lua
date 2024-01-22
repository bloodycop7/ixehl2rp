local PLUGIN = PLUGIN

PLUGIN.name = "Needs"
PLUGIN.author = "eon"
PLUGIN.description = "Adds a Needs System."
PLUGIN.license = [[
Copyright 2024 eon (bloodycop)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.char.RegisterVar("hunger", {
    field = "hunger",
    fieldType = ix.type.number,
    default = 100,
    isLocal = false,
    bNoDisplay = true,
})

ix.char.RegisterVar("thirst", {
    field = "thirst",
    fieldType = ix.type.number,
    default = 100,
    isLocal = false,
    bNoDisplay = true,
})

ix.config.Add("needsEnabled", true, "Whether or not the needs system is enabled.", nil, {
    category = "Needs"
})

ix.config.Add("hungerRate", 120, "How fast the player gets hungry.", function(newVal)
    if ( SERVER ) then
        for k, v in pairs(player.GetAll())() do
            if not ( IsValid(v) ) then
                continue
            end
        
            if not ( v:GetCharacter() ) then
                return
            end

            timer.Adjust("ix.Characters.Needs.Hunger." .. v:GetCharacter():GetID(), newVal)
        end
    end
end, {
    data = {min = 0, max = 500},
    category = "Needs"
})

ix.config.Add("thirstRate", 120, "How fast the player gets thirsty.", function(newVal)
    if ( SERVER ) then
        for k, v in pairs(player.GetAll())() do
            if not ( IsValid(v) ) then
                continue
            end
        
            if not ( v:GetCharacter() ) then
                return
            end

            timer.Adjust("ix.Characters.Needs.Thirst." .. v:GetCharacter():GetID(), newVal)
        end
    end
end, {
    data = {min = 0, max = 500},
    category = "Needs"
})

ix.util.Include("sv_hooks.lua")