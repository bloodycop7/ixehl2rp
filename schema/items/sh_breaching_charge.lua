ITEM.name = "Breaching Charge"
ITEM.description = "A breaching charge that can be used to blow open doors."
ITEM.model = "models/weapons/w_slam.mdl"

ITEM.functions.Plant = {
    OnRun = function(itemTable)
        local ply = itemTable.player

        local data = {}
            data.start = ply:GetShootPos()
            data.endpos = data.start + ply:GetAimVector() * 96
            data.filter = ply
        local trace = util.TraceLine(data)
        local entity = trace.Entity

        if not ( IsValid(entity) ) then
            return
        end

        if ( IsValid(entity.ixBreachingCharge) ) then
            return
        end
        
        local chargeFake = ents.Create("prop_dynamic") // we don't want physics.
        chargeFake:SetModel(itemTable.model)
        local pos = trace.HitPos - trace.HitNormal * ( chargeFake:OBBMins().z + 4 )

        chargeFake:SetPos(pos)

        local ang = trace.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(), 270)

        chargeFake:SetAngles(ang)
        chargeFake:Spawn()
        chargeFake:Activate()
        chargeFake:SetParent(entity)
        
        entity.ixBreachingCharge = chargeFake
        entity:CallOnRemove("ixRemoveBreachingCharge." .. entity:EntIndex(), function(this)
            if ( IsValid(entity.ixBreachingCharge) ) then
                timer.Remove("ixBreachingChargeBeep." .. this:EntIndex())

                entity.ixBreachingCharge:Remove()
                entity.ixBreachingCharge = nil
            end
        end)
        
        chargeFake:EmitSound("weapons/c4/c4_plant.wav")

        if not ( ply.ixDeployedEntities ) then
            ply.ixDeployedEntities = {}
        end

        ply.ixDeployedEntities[#ply.ixDeployedEntities + 1] = grenade:EntIndex()

        char:SetData("deployedEntities", ply.ixDeployedEntities)
        
        timer.Create("ixBreachingChargeBeep." .. entity:EntIndex(), 1, 3, function()
            if ( IsValid(chargeFake) ) then
                chargeFake:EmitSound("weapons/c4/c4_beep1.wav")
            end
        end)

        timer.Simple(3.1, function()
            if not ( IsValid(entity) or IsValid(chargeFake) ) then
                return
            end

            local explosion = ents.Create("env_explosion")
            explosion:SetPos(chargeFake:GetPos())
            explosion:SetOwner(ply)
            explosion:Spawn()
            explosion:SetKeyValue("iMagnitude", "50")
            explosion:Fire("Explode", 0, 0)
            local dir = -chargeFake:GetUp() * 200

            if ( IsValid(entity) ) then
                entity:BlastDoor(dir, 180)
            end
            
            if ( IsValid(chargeFake) ) then
                chargeFake:Remove()
            end
        end)
    end
}