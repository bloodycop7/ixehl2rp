local PLUGIN = PLUGIN

PLUGIN.name = "Cleanup"
PLUGIN.author = "eon"
PLUGIN.description = "Adds a few configurations regarding cleanups."

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

if ( SERVER ) then
    timer.Create("ix.Cleanup", 60, 0, function()
        if ( ix.config.Get("shouldCleanupRagdolls", true) ) then
            for _, v in ipairs(ents.FindByClass("prop_ragdoll")) do
                v:Remove()
            end

            for _, v in ipairs(ents.FindByClass("class C_ClientRagdoll")) do
                v:Remove()
            end
        end

        if ( ix.config.Get("shouldCleanupItems", true) ) then
            for _, v in ipairs(ents.FindByClass("ix_item")) do
                v:Remove()
            end
        end
    end)
end