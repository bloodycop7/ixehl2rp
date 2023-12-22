if (SERVER) then
	util.AddNetworkString("ixRankUpdate")
end

ix.rank = ix.rank or {}
ix.rank.list = {}

ix.char.RegisterVar("rank", {
    bNoDisplay = true,
})

local charMeta = ix.meta.character

--- Loads classes from a directory.
-- @realm shared
-- @internal
-- @string directory The path to the class files.
function ix.rank.LoadFromDir(directory)
	for _, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
		-- Get the name without the "sh_" prefix and ".lua" suffix.
		local niceName = v:sub(4, -5)
		-- Determine a numeric identifier for this class.
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

		-- Set up a global table so the file has access to the class table.
		RANK = {index = index, uniqueID = niceName}
			RANK.name = "Unknown"
			RANK.description = "No description available."
			RANK.limit = 0

			-- For future use with plugins.
			if (PLUGIN) then
				RANK.plugin = PLUGIN.uniqueID
			end

			ix.util.Include(directory.."/"..v, "shared")

			-- Why have a class without a faction?
			if (!RANK.faction or !team.Valid(RANK.faction)) then
				ErrorNoHalt("Rank '"..niceName.."' does not have a valid faction!\n")
				RANK = nil

				continue
			end

			-- Allow classes to be joinable by default.
			if (!RANK.CanSwitchTo) then
				RANK.CanSwitchTo = function(client)
					return true
				end
			end

			ix.rank.list[index] = RANK
		RANK = nil
	end
end

--- Determines if a player is allowed to join a specific class.
-- @realm shared
-- @player client Player to check
-- @number class Index of the class
-- @treturn bool Whether or not the player can switch to the class
function ix.rank.CanSwitchTo(client, rank)
	-- Get the class table by its numeric identifier.
	local info = ix.rank.list[rank]

	-- See if the class exists.
	if (!info) then
		return false, "no info"
	end

	-- If the player's faction matches the class's faction.
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

	-- See if the class allows the player to join it.
	return info:CanSwitchTo(client)
end

--- Retrieves a class table.
-- @realm shared
-- @number identifier Index of the class
-- @treturn table Class table
function ix.rank.Get(identifier)
	return ix.rank.list[identifier]
end

--- Retrieves the players in a class
-- @realm shared
-- @number class Index of the class
-- @treturn table Table of players in the class
function ix.rank.GetPlayers(rank)
	local players = {}

	for _, v in ipairs(player.GetAll()) do
		local char = v:GetCharacter()

		if (char and char:GetRank() == rank) then
			table.insert(players, v)
		end
	end

	return players
end

if (SERVER) then
	--- Character class methods
	-- @classmod Character

	--- Makes this character join a class. This automatically calls `KickClass` for you.
	-- @realm server
	-- @number class Index of the class to join
	-- @treturn bool Whether or not the character has successfully joined the class
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

	--- Kicks this character out of the class they are currently in.
	-- @realm server
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