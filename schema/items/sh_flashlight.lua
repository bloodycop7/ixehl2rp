ITEM.name = "Flashlight"
ITEM.description = "A small flashlight, used to illuminate dark areas."
ITEM.model = "models/items/battery.mdl"

ITEM:Hook("drop", function(item)
    local ply = item.player

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( ply:FlashlightIsOn() ) then
        ply:Flashlight(false)
    end
end)