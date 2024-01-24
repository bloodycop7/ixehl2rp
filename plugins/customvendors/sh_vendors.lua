local PLUGIN = PLUGIN

local vendor = {}
vendor.name = "Civil Protection Vendor"
vendor.model = "models/ez2npc/police.mdl"
vendor.uniqueID = "cp"
vendor.items = {}
vendor.sell = {}

vendor.items["wep_mp7"] = {
    canPurchase = function(ply, ent)
        if ( timer.Exists("ix.MP7.Cooldown." .. ply:SteamID64() .. "." .. ply:GetCharacter():GetID()) ) then
            return false
        end

        if ( ply:GetCharacter():GetInventory():HasItem("wep_mp7") ) then
            return false
        end
    end,
    GetPrice = function(ply, vendorEnt)
        return 0
    end,
    onPurchase = function(ply, vendorEnt)
        if not ( timer.Exists("ix.MP7.Cooldown." .. ply:SteamID64() .. "." .. ply:GetCharacter():GetID()) ) then
            timer.Create("ix.MP7.Cooldown." .. ply:SteamID64() .. "." .. ply:GetCharacter():GetID(), 180, 1, function()
            end)
        end
    end,
    category = "Weapons",
}

vendor.items["wep_usp"] = {
    canPurchase = function(ply)
        if ( timer.Exists("ix.USP.Cooldown." .. ply:SteamID64() .. "." .. ply:GetCharacter():GetID()) ) then
            return false
        end

        if ( ply:GetCharacter():GetInventory():HasItem("wep_usp") ) then
            return false
        end

        return true
    end,
    GetPrice = function(self, ply)
        return 0
    end,
    onPurchase = function(ply, vendorEnt)
        if not ( timer.Exists("ix.USP.Cooldown." .. ply:SteamID64() .. "." .. ply:GetCharacter():GetID()) ) then
            timer.Create("ix.USP.Cooldown." .. ply:SteamID64() .. "." .. ply:GetCharacter():GetID(), 180, 1, function()
            end)
        end
    end,
    category = "Weapons",
}

vendor.items["wep_stunstick"] = {
    canPurchase = function(ply)
        if ( ply:GetCharacter():GetInventory():HasItem("wep_stunstick") ) then
            return false
        end

        return true
    end,
    GetPrice = function(self, ply)
        return 0
    end,
    category = "Weapons",
}

vendor.items["health_kit"] = {
    canPurchase = function(ply)
        if ( ply:GetCharacter():GetInventory():GetItemCount("health_kit") >= 3 ) then
            return false
        end

        return true
    end,
    GetPrice = function(self, ply)
        return 0
    end,
    category = "Medical",
}

function vendor:onInit(ent)
    for i = 1, ent:GetSequenceCount() do
        if ( ent:GetSequenceName(i) == "batonidle1" ) then
            ent:ResetSequence(i)                

            break
        end
    end

    --ent:DropToFloor()
    --ent:SetPos(ent:GetPos() - ent:GetUp() * 6)
    ent:SetSkin(2)
end

ix.vendor:Register(vendor)