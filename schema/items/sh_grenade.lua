ITEM.name = "Grenade"
ITEM.description = "A small grenade that can be thrown."
ITEM.model = "models/items/grenadeammo.mdl"

ITEM.functions.throw = {
    name = "Throw",
    OnRun = function(item)
        local ply = item.player

        if not ( IsValid(ply) ) then
            return
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        if ( timer.Exists("ix.Char.GrenadeCooldown." .. ply:SteamID64() .. "." .. char:GetID()) ) then
            ply:Notify("You cannot throw another grenade for another " .. math.ceil(timer.TimeLeft("ix.Char.GrenadeCooldown." .. ply:SteamID64())) .. " second(s).")

            return
        end

        if ( ply:GetSequenceInfo(ply:LookupSequence("grenthrow")) ) then
            ply:SetLocalVelocity(Vector(0, 0, 0))
            ply:ForceSequence("grenthrow")
        end

        timer.Simple(0.7, function()
            if not ( IsValid(ply) ) then // AKA Run the command and leave :skull:
                return
            end

            if not ( ply:GetCharacter() ) then
                return
            end

            local grenade = ents.Create("npc_grenade_frag")
            grenade:SetPos(ply:EyePos() + ply:GetRight() * -8 + ply:GetForward() * 20 + ply:GetUp() * 4)
            grenade:SetAngles(ply:GetForward():Angle())
            grenade:Spawn()
            grenade:Activate()
            grenade:Fire("SetTimer", 2.90)
            grenade:GetPhysicsObject():AddVelocity(ply:GetAimVector() * 950)
            grenade:SetNWEntity("deployedBy", ply)
            grenade:CallOnRemove("GrenadeRemove", function(this)
                if ( IsValid(ply) ) then
                    if not ( ply:GetCharacter() ) then
                        return
                    end

                    if ( ply.ixDeployedEntities ) then
                        if ( table.HasValue(ply.ixDeployedEntities, this:EntIndex()) ) then
                            table.RemoveByValue(ply.ixDeployedEntities, this:EntIndex())
                        end
                    end

                    this:SetNWEntity("deployedBy", nil)
                end
            end)

            if not ( ply.ixDeployedEntities ) then
                ply.ixDeployedEntities = {}
            end

            ply.ixDeployedEntities[#ply.ixDeployedEntities + 1] = grenade:EntIndex()

            char:SetData("deployedEntities", ply.ixDeployedEntities)
        end)

        if not ( timer.Exists("ix.Char.GrenadeCooldown." .. ply:SteamID64()) ) then
            timer.Create("ix.Char.GrenadeCooldown." .. ply:SteamID64() .. "." .. char:GetID(), ix.config.Get("grenadeCooldown", 30), 1, function() end)
        end

        return true
    end,
    
    OnCanRun = function(item)
        local ply = item.player

        if not ( IsValid(ply) ) then
            return false
        end

        local char = ply:GetCharacter()

        if not ( char ) then
            return false
        end

        if ( timer.Exists("ix.Char.GrenadeCooldown." .. ply:SteamID64() .. "." .. char:GetID()) ) then
            return false
        end

        return true
    end
}