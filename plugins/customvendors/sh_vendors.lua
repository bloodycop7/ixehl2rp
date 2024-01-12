local PLUGIN = PLUGIN

local vendor = {}
vendor.name = "Civil Protection Vendor"
vendor.model = "models/ez2npc/police.mdl"
vendor.uniqueID = "cp"
vendor.items = {}

vendor.items["wep_mp7"] = {
    GetPrice = function(self, ply)
        return 50
    end
}

vendor.items["wep_usp"] = {}

vendor.items["wep_stunstick"] = {}

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