Schema.name = "Half-Life 2 Roleplay"
Schema.author = "eon"
Schema.description = "Immerse yourself in the world of the Half-Life 2 Universe."

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

// Credit: https://github.com/NebulousCloud/helix-hl2rp/blob/master/schema/sh_schema.lua#L32-L35
function Schema:ZeroNumber(number, length)
	local amount = math.max(0, length - string.len(number))

	return string.rep("0", amount) .. tostring(number)
end

function Schema:IsOutside(ply)
    local trace = util.TraceLine({
        start = ply:GetPos(),
        endpos = ply:GetPos() + ply:GetUp() * 9999999999,
        filter = ply
    })

    return trace.HitSky
end

function Schema:GetGameDescription()
	return "IX: "..(Schema and Schema.name or "Unknown")
end

ix.rank.LoadFromDir(Schema.folder .. "/schema/ranks")

ix.config.Add("maxItemDrops", 3, "The maximum amount of items that can be dropped by a player on death.", nil, {
    data = {min = 1, max = 10},
    category = "misc"
})

