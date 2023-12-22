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
    isLocal = isLocal,
    bNoDisplay = true,
})