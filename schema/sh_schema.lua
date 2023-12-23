Schema.name = "Half-Life 2 Roleplay"
Schema.author = "eon"
Schema.description = "Welcome to Half-Life 2."

ix.util.Include("cl_schema.lua")
ix.util.Include("sv_schema.lua")

ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sv_hooks.lua")

function Schema:IsCitizen(ply)
    if not ( IsValid(ply) ) then
        return false
    end

    local character = ply:GetCharacter()

    if not ( character ) then
        return false
    end

    return character:GetFaction() == FACTION_CITIZEN
end

function Schema:IsCP(ply)
    if not ( IsValid(ply) ) then
        return false
    end

    local character = ply:GetCharacter()

    if not ( character ) then
        return false
    end

    return character:GetFaction() == FACTION_CP
end

function Schema:IsOTA(ply)
    if not ( IsValid(ply) ) then
        return false
    end

    local character = ply:GetCharacter()

    if not ( character ) then
        return false
    end

    return character:GetFaction() == FACTION_OTA
end

function Schema:IsCombine(ply)
    if not ( IsValid(ply) ) then
        return false
    end

    local character = ply:GetCharacter()

    if not ( character ) then
        return false
    end

    return self:IsOTA(ply) or self:IsCP(ply)
end

ix.rank.LoadFromDir(Schema.folder .. "/schema/ranks")