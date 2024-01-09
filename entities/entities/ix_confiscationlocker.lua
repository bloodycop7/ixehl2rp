AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Confiscation Locker"
ENT.Category = "ix: HL2RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

if ( SERVER ) then
    util.AddNetworkString("ixConfiscationLockerSyncTime")

    function ENT:SetItems(items)
        if not ( items ) then
            items = {}
        end

        self.items = items
    end

	function ENT:Initialize()
		self:SetModel("models/props/de_train/lockers001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
        self:SetItems()

		local physics = self:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()

        if not ( timer.Exists("ix.ConfiscationLocker.Wipe." .. self:EntIndex()) ) then
            timer.Create("ix.ConfiscationLocker.Wipe." .. self:EntIndex(), ix.config.Get("confiscationLockerWipeTime", (60 * 30)), 0, function()
                if not ( IsValid(self) ) then
                    return
                end

                self:SetItems()
            end)
        end
        self.storedIndex = self:EntIndex()

		self.nextUse = 0
	end

    function ENT:OnRemove()
        timer.Remove("ix.ConfiscationLocker.Wipe." .. self:EntIndex())
    end

    function ENT:GetItems()
        return self.items or {}
    end

    function ENT:GetWipeTime()
        return timer.TimeLeft("ix.ConfiscationLocker.Wipe." .. self:EntIndex())
    end

	function ENT:Use(ply)
		if not ( ply:GetEyeTrace().Entity == self ) then
			return
		end

		if ( self.nextUse > CurTime() ) then
			return
		end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        local inv = char:GetInventory()
        local totalConfiscatedCount = 0
        local sterCreditsNew = 0

        if ( Schema:IsCombine(ply) ) then
            for k, v in pairs(inv:GetItems()) do
                if ( hook.Run("CanPlayerConfiscateItem", ply, v) == false ) then
                    continue
                end

                if not ( v.illegal ) then
                    continue
                end

                if ( v:GetData("equip") ) then
                    v:SetData("equip", nil)
                end

                local items = self:GetItems()
                table.insert(items, v.uniqueID)

                self:SetItems(items)
                v:Remove()

                local sterToAdd = hook.Run("GetPlayerSterilizationCreditAward", ply, v) or ( v.sterCreditsReward or 5 )

                totalConfiscatedCount = totalConfiscatedCount + 1
                sterCreditsNew = sterCreditsNew + sterToAdd
            end
            
            if ( totalConfiscatedCount > 0 ) then
                ply:Notify("You have confiscated " .. totalConfiscatedCount .. " item(s) and gained " .. sterCreditsNew .. " Sterilization Credits.")
                char:SetSterilizationCredits(char:GetSterilizationCredits() + sterCreditsNew)
            end
        else
            local items = self:GetItems()
            local takeCount = 0
            local itemsToRemoveFromLocker = {}

            for i = 1, #items do
                local randomItem = items[math.random(1, #items)]

                local itemData = ix.item.Get(randomItem)

                if not ( itemData ) then
                    return
                end

                if ( inv:FindEmptySlot(itemData.w, itemData.h, false) ) then
                    inv:Add(randomItem)

                    itemsToRemoveFromLocker[#itemsToRemoveFromLocker + 1] = randomItem 
                end
            end

            for k, v in pairs(itemsToRemoveFromLocker) do
                if ( table.HasValue(items, v) ) then
                    table.RemoveByValue(items, v)
                end
            end

            self:SetItems(items)

            if ( #itemsToRemoveFromLocker > 0 ) then
                ply:Notify("You stole " .. #itemsToRemoveFromLocker .. " confiscated item(s).")
            end
        end

		self.nextUse = CurTime() + 1
    end

    net.Receive("ixConfiscationLockerSyncTime", function(len, ply)
        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        local locker = net.ReadEntity()

        if not ( IsValid(locker) ) then
            return
        end

        local timeLeft = locker:GetWipeTime()

        net.Start("ixConfiscationLockerSyncTime")
            net.WriteFloat(locker.storedIndex)
            net.WriteFloat(timeLeft)
        net.Send(ply)
    end)
else
    net.Receive("ixConfiscationLockerSyncTime", function()
        local storedIndex = net.ReadFloat()
        local locker = Entity(storedIndex)

        if not ( IsValid(locker) ) then
            return
        end

        local timeLeft = net.ReadFloat()

        if ( timer.Exists("ix.ConfiscationLocker.Wipe." .. locker:EntIndex()) ) then
            timer.Adjust("ix.ConfiscationLocker.Wipe." .. locker:EntIndex(), timeLeft)
        else
            timer.Create("ix.ConfiscationLocker.Wipe." .. locker:EntIndex(), timeLeft, 0, function() end)
        end
    end)

    function ENT:GetWipeTime()
        net.Start("ixConfiscationLockerSyncTime")
            net.WriteEntity(self)
        net.SendToServer()

        return timer.TimeLeft("ix.ConfiscationLocker.Wipe." .. self:EntIndex()) or 0
    end

    ENT.PopulateEntityInfo = true

    function ENT:OnPopulateEntityInfo(container)
        local text = container:AddRow("name")
        text:SetImportant()
        text:SetText(self.PrintName)
        text:SizeToContents()

        local time = container:AddRow("wipeTime")
        time:SetText("Expires in: " .. string.NiceTime(math.Round(self:GetWipeTime() or 0, 0)))
        time:SizeToContents()
    end
end