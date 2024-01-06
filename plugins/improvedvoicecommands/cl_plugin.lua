local PLUGIN = PLUGIN

netstream.Hook("PlayQueuedSound", function(entity, sounds, delay, spacing, volume, pitch)
    entity = entity or LocalPlayer()

    ix.util.EmitQueuedSounds(false, entity, sounds, delay, spacing, volume, pitch)
end)