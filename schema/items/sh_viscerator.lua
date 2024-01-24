ITEM.name = "Viscerator"
ITEM.description = "A deployable entity that attacks enemies."
ITEM.model = "models/props_junk/cardboard_box004a.mdl"
ITEM.category = "Combine"

ITEM:Hook("take", function(item)
    local ply = item.player

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    if ( Schema:IsCP(ply) ) then
        ply:SetBodygroup(ply:FindBodygroupByName("manhack"), 1)
    end
end)

ITEM:Hook("drop", function(item)
    local ply = item.player

    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    timer.Simple(0.1, function()
        local itemCount = char:GetInventory():GetItemCount(item.uniqueID)

        if ( Schema:IsCP(ply) and itemCount < 1 ) then
            ply:SetBodygroup(ply:FindBodygroupByName("manhack"), 0)
        end
    end)
end)

ITEM.functions.Deploy = {
    OnRun = function(itemTable)
        local ply = itemTable.player

        local char = ply:GetCharacter()

        if not ( char ) then
            return true
        end

        if ( ply:GetSequenceInfo(ply:LookupSequence("deploy")) ) then
            ply:SetAction("Deploying...", 1.6)
            ply:SetLocalVelocity(Vector(0, 0, 0))
            ply:ForceSequence("deploy")

            timer.Simple(1.6, function()
                if not ( IsValid(ply) ) then
                    return
                end

                if not ( ply:Alive() ) then
                    return
                end

                local data = {}
                    data.start = ply:GetShootPos()
                    data.endpos = data.start + ply:GetAimVector()*96
                    data.filter = ply
                local trace = util.TraceLine(data)

                local ent = ents.Create("npc_manhack")
                ent:SetPos(ply:GetPos() + ply:GetForward() * 30 + ply:GetUp() * 100)
                ent:SetAngles(ply:GetForward():Angle())
                ent:Spawn()
                ent:Activate()
                ent:SetNetVar("owner", ply:GetCharacter():GetID())

                ent:SetNWEntity("deployedBy", ply)
                ent:CallOnRemove("ix.RemoveOwnerLink", function(this)
                    if not ( IsValid(this:GetNWEntity("deployedBy", nil)) ) then
                        return
                    end

                    if not ( this:GetNWEntity("deployedBy", nil):GetCharacter() ) then
                        return
                    end

                    if not ( this:GetNWEntity("deployedBy", nil).ixDeployedEntities ) then
                        return
                    end

                    if ( table.HasValue(this:GetNWEntity("deployedBy", nil).ixDeployedEntities, this:EntIndex()) ) then
                        table.RemoveByValue(this:GetNWEntity("deployedBy", nil).ixDeployedEntities, this:EntIndex())
                    end

                    this:GetNWEntity("deployedBy", nil):GetCharacter():SetData("deployedEntities", this:GetNWEntity("deployedBy", nil).ixDeployedEntities)

                    this:SetNWEntity("deployedBy", nil)
                end)

                ix.relationships.Update(ent)

                if not ( ply.ixDeployedEntities ) then
                    ply.ixDeployedEntities = {}
                end

                ply.ixDeployedEntities[#ply.ixDeployedEntities + 1] = ent:EntIndex()

                char:SetData("deployedEntities", ply.ixDeployedEntities)

                ply:UnLock()
            end)
        elseif ( ply:GetSequenceInfo(ply:LookupSequence("grenplace")) ) then
            ply:SetAction("Deploying...", 1.6)
            ply:SetLocalVelocity(Vector(0, 0, 0))
            ply:ForceSequence("grenplace")

            timer.Simple(1.6, function()
                if not ( IsValid(ply) ) then
                    return
                end

                if not ( ply:Alive() ) then
                    return
                end

                local data = {}
                    data.start = ply:GetShootPos()
                    data.endpos = data.start + ply:GetAimVector()*96
                    data.filter = ply
                local trace = util.TraceLine(data)

                local ent = ents.Create("npc_manhack")
                ent:SetPos(trace.HitPos + trace.HitNormal * 16)
                ent:SetAngles(ply:GetForward():Angle())
                ent:Spawn()
                ent:Activate()
                ent:SetNetVar("owner", ply:GetCharacter():GetID())

                ent:SetNWEntity("deployedBy", ply)
                ent:CallOnRemove("ix.RemoveOwnerLink", function(this)
                    if not ( IsValid(this:GetNWEntity("deployedBy", nil)) ) then
                        return
                    end

                    if not ( this:GetNWEntity("deployedBy", nil):GetCharacter() ) then
                        return
                    end

                    if not ( this:GetNWEntity("deployedBy", nil).ixDeployedEntities ) then
                        return
                    end

                    if ( table.HasValue(this:GetNWEntity("deployedBy", nil).ixDeployedEntities, this:EntIndex()) ) then
                        table.RemoveByValue(this:GetNWEntity("deployedBy", nil).ixDeployedEntities, this:EntIndex())
                    end

                    this:GetNWEntity("deployedBy", nil):GetCharacter():SetData("deployedEntities", this:GetNWEntity("deployedBy", nil).ixDeployedEntities)

                    this:SetNWEntity("deployedBy", nil)
                end)

                ix.relationships.Update(ent)

                if not ( ply.ixDeployedEntities ) then
                    ply.ixDeployedEntities = {}
                end

                ply.ixDeployedEntities[#ply.ixDeployedEntities + 1] = ent:EntIndex()

                char:SetData("deployedEntities", ply.ixDeployedEntities)

                ply:UnLock()
            end)
        else
            ply:Lock()

            ply:SetAction("Deploying...", 1.6, function()
                if not ( IsValid(ply) ) then
                    return
                end

                if not ( ply:Alive() ) then
                    return
                end

                local data = {}
                    data.start = ply:GetShootPos()
                    data.endpos = data.start + ply:GetAimVector()*96
                    data.filter = ply
                local trace = util.TraceLine(data)

                local ent = ents.Create("npc_manhack")
                ent:SetPos(trace.HitPos + trace.HitNormal * 16)
                ent:SetAngles(ply:GetForward():Angle())
                ent:Spawn()
                ent:Activate()
                ent:SetNetVar("owner", ply:GetCharacter():GetID())
                ent:SetNWEntity("deployedBy", ply)
                ent:CallOnRemove("ix.RemoveOwnerLink", function(this)
                    if not ( IsValid(this:GetNWEntity("deployedBy", nil)) ) then
                        return
                    end

                    if not ( this:GetNWEntity("deployedBy", nil):GetCharacter() ) then
                        return
                    end

                    if not ( this:GetNWEntity("deployedBy", nil).ixDeployedEntities ) then
                        return
                    end

                    if ( table.HasValue(this:GetNWEntity("deployedBy", nil).ixDeployedEntities, this:EntIndex()) ) then
                        table.RemoveByValue(this:GetNWEntity("deployedBy", nil).ixDeployedEntities, this:EntIndex())
                    end

                    this:GetNWEntity("deployedBy", nil):GetCharacter():SetData("deployedEntities", this:GetNWEntity("deployedBy", nil).ixDeployedEntities)

                    this:SetNWEntity("deployedBy", nil)
                end)

                ix.relationships.Update(ent)

                if not ( ply.ixDeployedEntities ) then
                    ply.ixDeployedEntities = {}
                end

                ply.ixDeployedEntities[#ply.ixDeployedEntities + 1] = ent:EntIndex()

                char:SetData("deployedEntities", ply.ixDeployedEntities)

                ply:UnLock()    
            end)
        end

        return true
    end,
    OnCanRun = function(item)
        local ply = item.player
        
        if not ( IsValid(ply) ) then
            return false
        end

        if not ( ply:Alive() ) then
            return false
        end
    
        local char = ply:GetCharacter()

        if not ( char ) then
            return false
        end

        return true
    end
}