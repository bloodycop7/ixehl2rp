local PLUGIN = PLUGIN

PLUGIN.name = "Cleanup"
PLUGIN.author = "eon"
PLUGIN.description = "Adds a few configurations regarding cleanups."
PLUGIN.license = [[
Copyright 2024 eon (bloodycop)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.config.Add("shouldCleanupRagdolls", true, "Whether or not ragdolls should be cleaned up.", nil, {
    category = "Cleanup"
})

ix.config.Add("shouldCleanupItems", true, "Whether or not items should be cleaned up.", nil, {
    category = "Cleanup"
})

ix.config.Add("cleanupRate", 60, "How often the cleanup should run in seconds.", function(oldV, newV)
    timer.Adjust("ix.Cleanup", newV)
end, {
    category = "Cleanup",
    data = {min = 1, max = 3600},
})

timer.Create("ix.Cleanup", 60, 0, function()
    if ( ix.config.Get("shouldCleanupRagdolls", true) ) then
        for _, v in ipairs(ents.FindByClass("prop_ragdoll")) do
            if ( SERVER ) then
                v:Remove()
            end
        end

        for _, v in ipairs(ents.FindByClass("class C_ClientRagdoll")) do
            if ( CLIENT ) then
                v:Remove()
            end
        end
    end

    if ( ix.config.Get("shouldCleanupItems", true) ) then
        for _, v in ipairs(ents.FindByClass("ix_item")) do
            if ( SERVER ) then
                v:Remove()
            end
        end
    end
end)
