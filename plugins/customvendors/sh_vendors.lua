local PLUGIN = PLUGIN

local vendor = {}
vendor.name = "Civil Protection Vendor"
vendor.model = "models/ez2npc/police.mdl"
vendor.uniqueID = "cp"
vendor.items = {}

vendor.items["wep_mp7"] = {
    canPurchase = function(ply, ent)
        if ( timer.Exists("ixMP7Cooldown." .. ply:SteamID64() .. "." .. ply:GetCharacter():GetID()) ) then
            return false
        end
    end,
    GetPrice = function(ply, vendorEnt)
        return 0
    end,
    onPurchase = function(ply, vendorEnt)
        if not ( timer.Exists("ixMP7Cooldown." .. ply:SteamID64() .. "." .. ply:GetCharacter():GetID()) ) then
            timer.Create("ixMP7Cooldown." .. ply:SteamID64() .. "." .. ply:GetCharacter():GetID(), 180, 1, function()
            end)
        end
    end
}

vendor.items["wep_usp"] = {
    canPurchase = function(ply)

    end,
    GetPrice = function(self, ply)
        return 0
    end
}

vendor.items["wep_stunstick"] = {
    GetPrice = function(self, ply)
        return 0
    end
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