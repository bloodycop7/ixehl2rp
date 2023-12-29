function Schema:GetPlayerDeathSound(client)
	local char = client:GetCharacter()

	if not ( char ) then
		return
	end

	if ( Schema:IsCP(client) ) then
		return "npc/metropolice/die" .. math.random(1, 4) .. ".wav"
	elseif ( Schema:IsOTA(client) ) then
		return "npc/combine_soldier/die" .. math.random(1, 3) .. ".wav"
	end
end

function Schema:GetPlayerPainSound(client)
	local char = client:GetCharacter()

	if not ( char ) then
		return
	end

	if ( Schema:IsCP(client) ) then
		return "npc/metropolice/pain" .. math.random(1, 4) .. ".wav"
	elseif ( Schema:IsOTA(client) ) then
		return "npc/combine_soldier/pain" .. math.random(1, 3) .. ".wav"
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

    ix.cmbSystems:SetBOLStatus(ply, false)
	
	local maxDeathItems = ix.config.Get("maxItemDrops", 3)

	if ( maxDeathItems > 0 ) then
		local inventory = char:GetInventory()

		if ( inventory ) then
			local items = {}

			for _, v in pairs(inventory:GetItems()) do
				if ( hook.Run("CanPlayerDropItemOnDeath", ply, v) == false ) then
					continue
				end

				table.insert(items, v)
			end

			if ( #items > 0 ) then
				for i = 1, math.random(1, #items) do
					local item = table.Random(items)

					if ( item ) then
						item:Transfer(nil, nil, nil, ply:GetPos() + Vector(0, 0, 16))
					end
				end
			end
		end
	end
end