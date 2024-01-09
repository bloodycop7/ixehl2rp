local PLUGIN = PLUGIN

function PLUGIN:CanPlayerSpawnContainer(ply, model, entity)
    if ( entity:GetClass():find("ix_lootable_*") ) then
        return false
    end
end

function PLUGIN:SaveData()
    local data = {}

    for k, v in ipairs(ents.FindByClass("ix_lootable_*")) do
        data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetClass()}
    end

    ix.data.Set("lootablesContainers", data)
end

function PLUGIN:LoadData()
    data = ix.data.Get("lootablesContainers", {})

    for _, v in ipairs(data) do
        local container = ents.Create(v[3])
        container:SetPos(v[1])
        container:SetAngles(v[2])
        container:Spawn()
        container:Activate()
    end
end