ITEM.name = "Ration"
ITEM.model = Model("models/weapons/w_package.mdl")
ITEM.description = "A shrink-wrapped packet containing some food and money."

ITEM.functions.OpenPackage = {
    name = "Open Package",
    OnRun = function(item)
        local ply = item.player

        if not ( IsValid(ply) ) then
            return false
        end

        if not ( ply:Alive() ) then
            return false
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return false
        end

        local suppliedItems = {
            ["soda"] = 1,
        }

        suppliedItems = hook.Run("PlayerGetRationSupplyment", ply, item, suppliedItems) or suppliedItems

        for k, v in pairs(suppliedItems) do
            local itemTable = ix.item.list[k]

            if not ( itemTable ) then
                continue
            end

            char:GetInventory():Add(k, v)
        end

        return true
    end,
}