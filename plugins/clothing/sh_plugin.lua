local PLUGIN = PLUGIN

PLUGIN.name = "Clothing"
PLUGIN.description = "Clothing Base"
PLUGIN.author = "eon"

function PLUGIN:Think()
    for k, v in ipairs(player.GetAll()) do
        if ( ( v.nextClothingThink or 0 ) > CurTime() ) then
            continue
        end

        if not ( IsValid(v) ) then
            continue
        end

        local char = v:GetCharacter()

        if not ( char ) then
            return
        end

        for _, item in pairs(char:GetInventory():GetItemsByBase("base_clothing", false)) do
            if ( item:GetData("equip", false) ) then
                if ( item.Think ) then
                    item:Think(v)
                end
            end
        end

        v.nextClothingThink = CurTime() + 1
    end
end