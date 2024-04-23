util.AddNetworkString("ix.PlayerStartVoice")
util.AddNetworkString("ix.PlayerEndVoice")

net.Receive("ix.PlayerStartVoice", function(len, ply)
	if ( ( ix.nextStartVoice or 0 ) > CurTime() ) then
		return
	end

	ix.nextStartVoice = CurTime() + 0.5

	if not ( IsValid(ply) ) then
		return
	end

	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	hook.Run("PlayerStartVoice", ply)
end)

net.Receive("ix.PlayerEndVoice", function(len, ply)
	if ( ( ix.nextEndVoiceVoice or 0 ) > CurTime() ) then
		return
	end

	ix.nextEndVoiceVoice = CurTime() + 0.5

	if not ( IsValid(ply) ) then
		return
	end

	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	hook.Run("PlayerEndVoice", ply)
end)

function Schema:GetPlayerDeathSound(client)
	local char = client:GetCharacter()

	if not ( char ) then
		return
	end

	local rank = ix.rank.list[char:GetRank()]

	if ( rank and rank.GetDeathSound ) then
		if not ( rank.faction == char:GetFaction() ) then
			return
		end

		return rank:GetDeathSound(client)
	end

	local class = ix.class.list[char:GetClass()]

	if ( class and class.GetDeathSound ) then
		if not ( class.faction == char:GetFaction() ) then
			return
		end

		return class:GetDeathSound(client)
	end
	
	local faction = ix.faction.Get(char:GetFaction())
	
	if ( faction and faction.GetDeathSound ) then
		return faction:GetDeathSound(client)
	end
end

function Schema:GetPlayerPainSound(client)
	local char = client:GetCharacter()

	if not ( char ) then
		return
	end

	local rank = ix.rank.list[char:GetRank()]

	if ( rank and rank.GetPainSound ) then
		if not ( rank.faction == char:GetFaction() ) then
			return
		end

		return rank:GetPainSound(client)
	end

	local class = ix.class.list[char:GetClass()]

	if ( class and class.GetPainSound ) then
		if not ( class.faction == char:GetFaction() ) then
			return
		end

		return class:GetPainSound(client)
	end

	local faction = ix.faction.Get(char:GetFaction())
	
	if ( faction and faction.GetPainSound ) then
		return faction:GetPainSound(client)
	end
end

function Schema:PlayerSpray(ply)
	return true
end

function Schema:DoPlayerDeath(ply, attacker, damageInfo)
	local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

	if ( ply.ixDeployedEntities ) then
		for i = 1, #ply.ixDeployedEntities do
			ply.ixDeployedEntities[i] = nil
		end

		char:SetData("deployedEntities", ply.ixDeployedEntities)
	end

    // CMB:SetBOLStatus(ply, false) -- It works, enable if you want.
	
	local maxDeathItems = ix.config.Get("maxItemDrops", 3)

	if ( maxDeathItems > 0 ) then
		local inventory = char:GetInventory()

		if ( inventory ) then
			for i = 1, math.random(1, maxDeathItems) do
				local random = inventory:GetItems()[math.random(1, #inventory:GetItems())]

				if ( random and random.Remove ) then
					random:Remove()
				end
			end
		end
	end
end

function Schema:CanOverridePlayerHoldObject(ply, ent)
	if not ( IsValid(ply) ) then
		return
	end

	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	if ( ent:GetModel() == "models/combine_turrets/floor_turret.mdl" ) then
		return true
	end
end

function Schema:EntityRemoved(ent)
	local deployer = ent:GetNWEntity("deployedBy", nil)

	if ( IsValid(deployer) ) then
		local char = deployer:GetCharacter()

		if not ( char ) then
			return
		end

		if ( deployer.ixDeployedEntities ) then
			if ( table.HasValue(deployer.ixDeployedEntities, ent:EntIndex()) ) then
				table.RemoveByValue(deployer.ixDeployedEntities, ent:EntIndex())

				char:SetData("deployedEntities", deployer.ixDeployedEntities)
			end
		end
	end
end

function Schema:PlayerSwitchFlashlight(ply, bEnabled)
	if not ( IsValid(ply) ) then
		return
	end

	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end
	
	if ( Schema:IsCombine(ply) ) then
		return true
	end

	local inv = char:GetInventory()

	if not ( inv ) then
		return
	end

	if ( inv:HasItem("flashlight") ) then
		return true
	end
end

function Schema:SaveData()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_cmb_terminal")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles()}
	end

	ix.data.Set("cmbTerminals", data)

	data = {}

	for _, v in ipairs(ents.FindByClass("ix_citizen_terminal")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles()}
	end

	ix.data.Set("citizenTerminals", data)

	data = {}

	for _, v in ipairs(ents.FindByClass("ix_vendingmachine")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetAllStock()}
	end

	ix.data.Set("vendingMachines", data)

	data = {}

	for _, v in ipairs(ents.FindByClass("ix_rationdistribution")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles()}
	end

	ix.data.Set("rationDistributions", data)

	data = {}

	for _, v in ipairs(ents.FindByClass("ix_confiscationlocker")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetItems()}
	end

	ix.data.Set("confiscationLockers", data)

	data = {}

	for _, v in ipairs(ents.FindByClass("ix_cmb_forcefield")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetMode()}
	end

	ix.data.Set("cmbForcefields", data)

	data =  {}

	for _, v in ipairs(ents.FindByClass("ix_custom_vendor_*")) do
		data[#data + 1] = {v:GetClass(), v:GetPos(), v:GetAngles(), v:GetVendorID()}
	end

	ix.data.Set("customVendors", data)
end

function Schema:LoadData()
	local data = ix.data.Get("cmbTerminals", {})

	for _, v in ipairs(data) do
		local terminal = ents.Create("ix_cmb_terminal")
		terminal:SetPos(v[1])
		terminal:SetAngles(v[2])
		terminal:Spawn()
		terminal:Activate()
	end

	data = ix.data.Get("citizenTerminals", {})
	for _, v in ipairs(data) do
		local CitTerminal = ents.Create("ix_citizen_terminal")
		CitTerminal:SetPos(v[1])
		CitTerminal:SetAngles(v[2])
		CitTerminal:Spawn()
		CitTerminal:Activate()
	end

	data = ix.data.Get("vendingMachines", {})
	for _, v in ipairs(data) do
		local vm = ents.Create("ix_vendingmachine")
		vm:SetPos(v[1])
		vm:SetAngles(v[2])
		vm:SetStock(v[3])
		vm:Spawn()
		vm:Activate()
	end

	data = ix.data.Get("rationDistributions", {})
	for _, v in ipairs(data) do
		local ration = ents.Create("ix_rationdistribution")
		ration:SetPos(v[1])
		ration:SetAngles(v[2])
		ration:Spawn()
		ration:Activate()
	end

	data = ix.data.Get("confiscationLockers", {})
	for _, v in ipairs(data) do
		local locker = ents.Create("ix_confiscationlocker")
		locker:SetPos(v[1])
		locker:SetAngles(v[2])
		locker.items = v[3]
		locker:Spawn()
		locker:Activate()
	end

	data = ix.data.Get("cmbForcefields", {})
	for _, v in ipairs(data) do
		local forcefield = ents.Create("ix_cmb_forcefield")
		forcefield:SetPos(v[1])
		forcefield:SetAngles(v[2])
		forcefield:SetMode(v[3] or 1)
		forcefield:Spawn()
		forcefield:Activate()
	end

	data = ix.data.Get("customVendors", {})
	for _, v in ipairs(data) do
		local vendor = ents.Create(v[1])
		vendor:SetPos(v[2])
		vendor:SetAngles(v[3])
		vendor:SetVendorID(v[4])
		vendor:Spawn()
		vendor:Activate()
	end
end

function Schema:PlayerJoinedClass(ply, class, oldClass)
	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	local classData = ix.class.Get(class)
	if ( classData.bodygroups ) then
		for k, v in pairs(classData.bodygroups) do
			if ( isstring(k) ) then
				k = ply:FindBodygroupByName(k)
			end

			ply:SetBodygroup(k, v)
		end
	end

	if ( classData.skin ) then
		ply:SetSkin(classData.skin)
	end

	char:SetData("permaClass", class)
	hook.Run("PlayerSetHandsModel", ply, ply:GetHands())
end

function Schema:PlayerJoinedRank(ply, rank, oldRank)
	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	local rankData = ix.rank.Get(rank)
	if ( rankData.bodygroups ) then
		for k, v in pairs(rankData.bodygroups) do
			if ( isstring(k) ) then
				ply:SetBodygroup(ply:FindBodygroupByName(k), v)
			else
				ply:SetBodygroup(k, v)
			end
		end
	end

	if ( rankData.skin ) then
		ply:SetSkin(rankData.skin)
	end

	char:SetData("permaRank", rank)

	hook.Run("PlayerSetHandsModel", ply, ply:GetHands())
end

function Schema:EntityEmitSound(data)
	if ( data.SoundName == "weapons/airboat/airboat_gun_lastshot1.wav" or data.SoundName == "weapons/airboat/airboat_gun_lastshot2.wav" ) then
		if ( data.Entity:IsPlayer() and data.Entity:IsAdmin() and data.Entity:GetMoveType() == MOVETYPE_NOCLIP ) then
			return false
		end
	end
end

function Schema:PlayerLoadedCharacter(ply, newChar, oldChar)
	if not ( newChar ) then
		return
	end

	timer.Simple(0.1, function()
		local permaClass = newChar:GetData("permaClass")
		local permaClassData = ix.class.list[permaClass]

		local permaRank = newChar:GetData("permaRank")
		local permaRankData = ix.rank.list[permaRank]

		if ( permaClass and permaClassData ) then
			local oldClass = newChar:GetClass()
			newChar:SetClass(permaClass)
			
			hook.Run("PlayerJoinedClass", ply, permaClass, oldClass)
		end

		if ( permaRank and permaRankData ) then
			local oldRank = newChar:GetRank()
			newChar:SetRank(permaRank)
			
			hook.Run("PlayerJoinedRank", ply, permaRank, oldRank)
		end

		hook.Run("PlayerSetHandsModel", ply, ply:GetHands())

		if ( ix.faction.Get(newChar:GetFaction()).skin ) then
			ply:SetSkin(ix.faction.Get(newChar:GetFaction()).skin)
		end

		if ( ix.faction.Get(newChar:GetFaction()).bodygroups ) then
			for k, v in pairs(ix.faction.Get(newChar:GetFaction()).bodygroups) do
				if ( isstring(k) ) then
					ply:SetBodygroup(ply:FindBodygroupByName(k), v)
				else
					ply:SetBodygroup(k, v)
				end
			end
		end

		local inv = newChar:GetInventory()

		for k, v in inv:Iter() do
			if ( k.OnLoadout ) then
				k:Call("OnLoadout", ply)
			end
		end
		
		local filter = RecipientFilter()
        filter:AddAllPlayers()

        newChar:SetData("squadID", -1, false, filter)
	end)
end

function Schema:PlayerSetHandsModel(ply, ent)
	timer.Simple(0.1, function()
		if not ( IsValid(ent) ) then
			return
		end

		if ( self:IsOW(ply) ) then
			if ( self:IsOWElite(ply) ) then
				ply:SetPlayerColor(Vector(1, 0, 0))
				
				ent:SetModel("models/weapons/c_arms_combine_elite/c_arms_combine_elite_color.mdl")
				ent:SetSkin(0)
				ent:SetBodyGroups("000000")
			end
			
			if ( self:IsOWSoldier(ply) or self:IsOWShotgunner(ply) ) then
				local skin = 0

				if ( self:IsOWShotgunner(ply) ) then
					skin = 1
				end

				ent:SetModel("models/weapons/c_arms_combine_default/c_arms_combine_regular.mdl")
				ent:SetSkin(skin)
				ent:SetBodyGroups("000000")
			end
		elseif ( self:IsCP(ply) ) then
			ent:SetModel("models/weapons/c_metrocop_hands.mdl")
			ent:SetSkin(1)
			ent:SetBodyGroups("000000")
		end
	end)
end

local keys = {
	["y"] = true,
	["w"] = true,
	["t"] = true,
}

util.AddNetworkString("ix.PlayerChatTextChanged")
net.Receive("ix.PlayerChatTextChanged", function(len, ply)
	if ( ( ix.nextPlayerTextChanged or 0 ) > CurTime() ) then
		return
	end

	ix.nextPlayerTextChanged = CurTime() + 0.5

	if not ( IsValid(ply) ) then
		return
	end

	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	if ( ( ply.bTypingBeep or false ) ) then
		return
	end

	local key = net.ReadString()

	if ( Schema:IsCombine(ply) ) then
		if not ( keys[key] ) then
			return
		end

		if ( Schema:IsOW(ply) ) then
			ply:EmitSound("npc/combine_soldier/vo/on" .. math.random(1, 2) .. ".wav")
		elseif ( Schema:IsCP(ply) ) then
			ply:EmitSound("npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav")
		end
	end

	ply.bTypingBeep = true
end)

util.AddNetworkString("ix.PlayerStartChat")
net.Receive("ix.PlayerStartChat", function(len, ply)
	if ( ( ix.nextPlayerStartChat or 0 ) > CurTime() ) then
		return
	end

	ix.nextPlayerStartChat = CurTime() + 0.5

	if not ( IsValid(ply) ) then
		return
	end

	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	if ( ( ply.bTypingBeep or false ) ) then
		return
	end

	local key = net.ReadString()

	if ( Schema:IsCombine(ply) ) then
		if not ( keys[key] ) then
			return
		end

		if ( Schema:IsOW(ply) ) then
			ply:EmitSound("npc/combine_soldier/vo/on" .. math.random(1, 2) .. ".wav")
		elseif ( Schema:IsCP(ply) ) then
			ply:EmitSound("npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav")
		end
	end

	ply.bTypingBeep = true
end)

util.AddNetworkString("ix.PlayerFinishChat")
net.Receive("ix.PlayerFinishChat", function(len, ply)
	if ( ( ix.nextPlayerFinishChat or 0 ) > CurTime() ) then
		return
	end

	ix.nextPlayerFinishChat = CurTime() + 0.5

	if not ( IsValid(ply) ) then
		return
	end

	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	if not ( ( ply.bTypingBeep or false ) ) then
		return
	end

	if ( Schema:IsCombine(ply) ) then
		if ( Schema:IsOW(ply) ) then
			ply:EmitSound("npc/combine_soldier/vo/off" .. math.random(1, 3) .. ".wav")
		elseif ( Schema:IsCP(ply) ) then
			ply:EmitSound("npc/metropolice/vo/off" .. math.random(1, 4) .. ".wav")
		end
	end

	ply.bTypingBeep = nil
end)