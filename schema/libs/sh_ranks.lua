if (SERVER) then
	util.AddNetworkString("ixRankUpdate")
end

ix.rank = ix.rank or {}
ix.rank.list = {}

ix.char.RegisterVar("rank", {
    bNoDisplay = true,
})

local charMeta = ix.meta.character

function ix.rank.LoadFromDir(directory)
	for _, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
		local niceName = v:sub(4, -5)
		local index = #ix.rank.list + 1
		local halt

		for _, v2 in ipairs(ix.rank.list) do
			if (v2.uniqueID == niceName) then
				halt = true
			end
		end

		if (halt == true) then
			continue
		end

		RANK = {index = index, uniqueID = niceName}
			RANK.name = "Unknown"
			RANK.description = "No description available."
			RANK.limit = 0

			if (PLUGIN) then
				RANK.plugin = PLUGIN.uniqueID
			end

			ix.util.Include(directory.."/"..v, "shared")

			if (!RANK.faction or !team.Valid(RANK.faction)) then
				ErrorNoHalt("Rank '"..niceName.."' does not have a valid faction!\n")
				RANK = nil

				continue
			end

			if (!RANK.CanSwitchTo) then
				RANK.CanSwitchTo = function(client)
					return true
				end
			end

			ix.rank.list[index] = RANK
		RANK = nil
	end
end

function ix.rank.CanSwitchTo(client, rank)
	local info = ix.rank.list[rank]

	if (!info) then
		return false, "no info"
	end

	if (client:Team() != info.faction) then
		return false, "not correct team"
	end

	if (client:GetCharacter():GetRank() == rank) then
		return false, "same class request"
	end

	if (info.limit > 0) then
		if (#ix.rank.GetPlayers(info.index) >= info.limit) then
			return false, "rank is full"
		end
	end

	if (hook.Run("CanPlayerJoinRank", client, rank, info) == false) then
		return false
	end

	return info:CanSwitchTo(client)
end

function ix.rank.Get(identifier)
	return ix.rank.list[identifier]
end

function ix.rank.GetPlayers(rank)
	local players = {}

	for _, v in ipairs(player.Iterator()) do
		local char = v:GetCharacter()

		if (char and char:GetRank() == rank) then
			table.insert(players, v)
		end
	end

	return players
end

if (SERVER) then
	function charMeta:JoinRank(rank)
		if (!class) then
			self:KickRank()
			return false
		end

		local oldRank = self:GetRank()
		local client = self:GetPlayer()

		if (ix.rank.CanSwitchTo(client, class)) then
			self:SetRank(class)
			hook.Run("PlayerJoinedRank", client, rank, oldRank)

			return true
		end

		return false
	end

	function charMeta:KickRank()
		local client = self:GetPlayer()
		if (!client) then return end

		local goRank

		for k, v in pairs(ix.rank.list) do
			if (v.faction == client:Team() and v.isDefault) then
				goRank = k

				break
			end
		end

		self:JoinRank(goRank)

		hook.Run("PlayerJoinedRank", client, goRank)
	end

	function GAMEMODE:PlayerJoinedRank(client, rank, oldRank)
		local info = ix.rank.list[rank]
		local info2 = ix.rank.list[oldRank]

		if (info.OnSet) then
			info:OnSet(client)
		end

		if (info2 and info2.OnLeave) then
			info2:OnLeave(client)
		end

		net.Start("ixRankUpdate")
			net.WriteEntity(client)
		net.Broadcast()
	end
end