AddCSLuaFile()

if (CLIENT) then
	SWEP.PrintName = "Combine Door Register"
	SWEP.Slot = 0
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Category = "ix: HL2 RP"
SWEP.Author = "eon"
SWEP.Instructions = "Primary Fire: Register Door | Secondary Fire: Remove Door"
SWEP.Purpose = "Registering combine doors."
SWEP.Drop = false

SWEP.HoldType = "melee"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Damage = 0
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.Delay = 1

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( ply:IsAdmin() ) then
        return
    end

    if not ( SERVER ) then
        return
    end

    if ( self:GetNextPrimaryFire() > CurTime() ) then
        return
    end

    local trace = ply:GetEyeTrace().Entity

    if not ( IsValid(trace) ) then
        ply:Notify("You must be looking at a valid entity.")
        self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

        return
    end

    if not ( trace:GetClass() == "func_door" or trace:GetClass() == "prop_dynamic" ) then
        ply:Notify("You must be looking at a func_door.")
        self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

        return
    end

    local data = ix.data.Get("combineDoors", {})

    if ( trace.ixIsCombineDoor ) then
        ply:Notify("Door is already Registered!")
        self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

        return
    end
    
    trace.ixIsCombineDoor = true

    for k, v in ipairs(ents.FindByClass("func_door")) do
        if not ( IsValid(v) ) then
            continue
        end

        if ( v.ixIsCombineDoor ) then
            data[#data + 1] = {v:GetPos()}
        end
    end

    for k, v in ipairs(ents.FindByClass("prop_dynamic")) do
        if not ( IsValid(v) ) then
            continue
        end

        if ( v.ixIsCombineDoor ) then
            data[#data + 1] = {v:GetPos()}
        end
    end

    ix.data.Set("combineDoors", data)
    ply:Notify("Added Door to Registered Combine Doors!")
    
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
    local ply = self:GetOwner()

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( ply:IsAdmin() ) then
        return
    end

    if not ( SERVER ) then
        return
    end

    if ( self:GetNextSecondaryFire() > CurTime() ) then
        return
    end

    local trace = ply:GetEyeTrace().Entity

    if not ( IsValid(trace) ) then
        ply:Notify("You must be looking at a valid entity.")

        return
    end

    if not ( trace:GetClass() == "func_door" or trace:GetClass() == "prop_dynamic" ) then
        ply:Notify("You must be looking at a func_door.")

        return
    end

    local data = ix.data.Get("combineDoors", {})

    if not ( trace.ixIsCombineDoor ) then
        ply:Notify("Door Not Registered!")

        return
    end

    trace.ixIsCombineDoor = false

    for i = 1, #data do
        if ( data[i][1] ) then
            if ( data[i][1] == trace:GetPos() ) then
                table.remove(data, i)
                ply:Notify("Door Removed from Registered Combine Doors!")
                ix.data.Set("combineDoors", data)

                break
            end
        end
    end

    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end