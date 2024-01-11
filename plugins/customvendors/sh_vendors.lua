local PLUGIN = PLUGIN

local vendor = {}
vendor.name = "Civil Protection Vendor"
vendor.model = "models/ez2npc/police.mdl"
vendor.uniqueID = "cp"
vendor.items = {
    ["wep_mp7"] = {
        price = 0
    },
    ["wep_usp"] = {
        price = 0
    }
}

vendor.sell = {
    ["wep_mp7"] = {
        price = 50,
    }
}

function vendor:onInit(vendorData, ent)
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