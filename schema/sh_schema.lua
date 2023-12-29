Schema.name = "Half-Life 2 Roleplay"
Schema.author = "eon"
Schema.description = "Immerse yourself in the world of The Half-Life 2 Universe."

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
	return "IX: "..(Schema.name or "Unknown")
end

ix.rank.LoadFromDir(Schema.folder .. "/schema/ranks")

ix.config.Add("maxItemDrops", 3, "The maximum amount of items that can be dropped by a player on death.", nil, {
    data = {min = 1, max = 10},
    category = "misc"
})

ix.command.Add("CharSetRank", {
	description = "Sets the rank of a character.",
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.text
	},
	OnRun = function(self, client, target, rank)
		local rankTable

		for _, v in ipairs(ix.rank.list) do
			if ( ix.util.StringMatches(v.uniqueID, rank) or ix.util.StringMatches(v.name, rank) ) then
				rankTable = v
			end
		end

		if ( rankTable ) then
			local oldRank = target:GetRank()
			local targetPlayer = target:GetPlayer()

			if ( targetPlayer:Team() == rankTable.faction ) then
				target:SetRank(rankTable.index)
				hook.Run("PlayerJoinedRank", targetPlayer, rankTable.index, oldRank)

				targetPlayer:Notify("Your rank has been set to " .. rankTable.name .. ".")
			else
				return "Invalid Rank Faction"
			end
		else
			return "Invalid Rank"
		end
	end
})