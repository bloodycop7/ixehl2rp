local PLUGIN = PLUGIN

PLUGIN.name = "Needs"
PLUGIN.author = "eon"
PLUGIN.description = "Adds Needs System."

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

ix.config.Add("hungerRate", 120, "How fast the player gets hungry.", function(newVal)
    if ( SERVER ) then
        for k, v in pairs(player.GetAll()) do
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
        for k, v in pairs(player.GetAll()) do
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