ITEM.name = "Clothing Base"
ITEM.description = "The base item for the clothing items"
ITEM.category = "Clothing"
ITEM.model = "models/props_c17/suitcase_passenger_physics.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "glasses"

if ( CLIENT ) then
    function ITEM:PaintOver(item, w, h)
        if ( item:GetData("equip", false) ) then
            surface.SetDrawColor(0, 255, 0, 100)
            surface.DrawRect(w - 14, h - 14, 8, 8)
        end
    end
end

ITEM:Hook("drop", function(item)
    local ply = item.player

	if not ( IsValid(ply) ) then
		return
	end

    if ( item:GetData("equip", false) ) then
        item.functions.UnEquip.OnRun(item)
        item:SetData("equip", nil)
    end
end)

ITEM.functions.Equip = {
    name = "Equip",
    OnRun = function(item)
        local ply = item.player

        if not ( IsValid(ply) ) then
            return false
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return false
        end

        local outfitData = char:GetData("outfits", {})

        if ( outfitData[item.outfitCategory] ) then
            local oldItem = ix.item.instances[outfitData[item.outfitCategory]]

            if ( oldItem ) then
                oldItem:SetData("equip", false)

                if ( oldItem.OnUnEquipped ) then
                    oldItem["OnUnEquipped"](ply)
                end
            end
        end

        outfitData[item.outfitCategory] = item:GetID() // if someone wants to access the item

        if ( item.bodygroups ) then
            for k, v in pairs(item.bodygroups) do
                if ( isstring(k) ) then
                    k = ply:FindBodygroupByName(k)
                end

                ply:SetBodygroup(k, v)
            end
        end

        if ( item.subMaterials ) then
            for k, v in pairs(item.subMaterials) do
                ply:SetSubMaterial(k - 1, v)
            end
        end

        if ( item.skin ) then
            ply:SetSkin(item.skin)
        end

        if ( item.OnEquipped ) then
            item["OnEquipped"](ply) // Can be used for like sounds and shit idk
        end

        item:SetData("equip", true)
        char:SetData("outfits", outfitData)

        return false
    end,
    OnCanRun = function(item)
        local ply = item.player

        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return false
        end

        if not ( item.invID == char:GetInventory():GetID() ) then
            return false
        end

        if ( item:GetData("equip", false) ) then
            return false
        end

        if ( hook.Run("CanPlayerEquipItem", ply, item) == false ) then
            return false
        end

        if ( item.CanEquip and item:CanEquip() == false ) then
            return false
        end

        return true
    end
}

ITEM.functions.UnEquip = {
    name = "Un-Equip",
    OnRun = function(item)
        local ply = item.player

        if not ( IsValid(ply) ) then
            return false
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return false
        end

        local outfitData = char:GetData("outfits", {})

        if ( outfitData[item.outfitCategory] ) then
            local oldItem = ix.item.instances[outfitData[item.outfitCategory]]

            if ( oldItem ) then
                oldItem:SetData("equip", false)

                if ( oldItem.OnUnEquipped ) then
                    oldItem:OnUnEquipped(ply)
                end
            end
        end

        outfitData[item.outfitCategory] = nil

        if ( item.bodygroups ) then
            for k, v in pairs(item.bodygroups) do
                if ( isstring(k) ) then
                    k = ply:FindBodygroupByName(k)
                end

                ply:SetBodygroup(k, 0)
            end
        end

        if ( item.subMaterials ) then
            for k, v in pairs(item.subMaterials) do
                ply:SetSubMaterial(k - 1, "")
            end
        end

        if ( item.skin ) then
            ply:SetSkin(0)
        end

        if ( item.OnUnEquipped ) then
            item["OnUnEquipped"](ply)
        end

        item:SetData("equip", nil)
        char:SetData("outfits", outfitData)
        return false
    end,
    OnCanRun = function(item)
        local ply = item.player

        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return false
        end

        if not ( item.invID == char:GetInventory():GetID() ) then
            return false
        end

        if not ( item:GetData("equip", false) ) then
            return false
        end

        if ( hook.Run("CanPlayerUnequipItem", ply, item) == false ) then
            return false
        end

        if ( item.CanUnEquip and item["CanUnEquip"](ply) == false ) then
            return false
        end

        return true
    end
}

function ITEM:OnLoadout()
    local ply = self.player

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( self:GetData("equip", false) ) then
        self.functions.Equip.OnRun(self)
    end
end

function ITEM:OnRemoved()
	local inventory = ix.item.inventories[self.invID]
	local ply = inventory.GetOwner and inventory:GetOwner()

	if not ( IsValid(ply) and ply:IsPlayer() ) then
        return
	end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( self:GetData("equip", false) ) then
        self.functions.UnEquip.OnRun(self)
    end
end