local PLUGIN = PLUGIN

ix.vendor:Register({
    name = "Civil Protection Vendor",
    model = "models/ez2npc/police.mdl",
    uniqueID = "cp",
    items = {
        ["wep_mp7"] = {
            price = 0
        },
        ["wep_usp"] = {
            price = 0
        }
    },
    --[[sell = {
        ["wep_mp7"] = {
            price = 50,
        }
    },]]
    onInit = function(vendorData, ent)
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
})