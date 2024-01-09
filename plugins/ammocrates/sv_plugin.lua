local PLUGIN = PLUGIN

function PLUGIN:CanPlayerSpawnContainer(ply, model, entity)
    if ( entity:GetClass():find("ix_ammo_crate_*") ) then
        return false
    end
end

function PLUGIN:SaveData()
    local data = {}

    for k, v in ipairs(ents.FindByClass("ix_ammo_crate_*")) do
        data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetAmmoType(), v:GetClass()}

        if ( data[4] == 0 and not v:GetRemainingAmmo() ) then
            table.RemoveByValue(data, data[4])
        end
    end

    ix.data.Set("ammoCrates", data)
end

function PLUGIN:LoadData()
    data = ix.data.Get("ammoCrates", {})

    for _, v in ipairs(data) do
        local crate = ents.Create(v[5])
        crate:SetPos(v[1])
        crate:SetAngles(v[2])
        crate:SetAmmoType(v[3])
        crate:Spawn()
        crate:Activate()
    end
end