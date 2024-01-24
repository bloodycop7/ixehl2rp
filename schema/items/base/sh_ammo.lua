
ITEM.name = "Ammo Base"
ITEM.model = "models/Items/BoxSRounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.ammo = "pistol" -- type of the ammo
ITEM.ammoAmount = 30 -- amount of the ammo
ITEM.description = "A Box that contains %s of Pistol Ammo"
ITEM.category = "Ammunition"
ITEM.useSound = "items/ammo_pickup.wav"

function ITEM:GetDescription()
	local rounds = self:GetData("rounds", self.ammoAmount)
	return Format(self.description, rounds)
end

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(
			item:GetData("rounds", item.ammoAmount), "DermaDefault", w - 5, h - 5,
			color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black
		)
	end
end

-- On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.use = {
	name = "Load",
	tip = "useTip",
	icon = "icon16/add.png",
	OnRun = function(item)
		local rounds = item:GetData("rounds", item.ammoAmount)

		local ply = item.player

		if not ( IsValid(ply) ) then
			return true
		end

		local char = ply:GetCharacter()

		if not ( char ) then
			return true
		end

		if ( ply.isLoadingAmmo ) then
			ply:Notify("You are already loading ammunition.")

			return false
		end
		
		if ( ply.isEquippingWeapon ) then
			ply:Notify("You cannot load ammo while equipping a weapon.")
			
			return false
		end

		if ( ply.isUnEquippingWeapon ) then
			ply:Notify("You cannot load ammo while unequipping a weapon.")
			
			return false
		end

		if ( item.useTime and item.useTime > 0 ) then
			ply.isLoadingAmmo = true

			local success, erorrs = pcall(function()
				ply:SetAction("Loading ammunition..", item.useTime, function()
					ply:GiveAmmo(rounds, item.ammo)
					ply:EmitSound(item.useSound, 110)

					ply.isLoadingAmmo = false
				end)
			end)

			if not ( success ) then
				ply.isLoadingAmmo = false

				return false
			end
		else
			ply:GiveAmmo(rounds, item.ammo)
			ply:EmitSound(item.useSound, 110)
		end

		return true
	end,
}

-- Called after the item is registered into the item tables.
function ITEM:OnRegistered()
	if (ix.ammo) then
		ix.ammo.Register(self.ammo)
	end
end
