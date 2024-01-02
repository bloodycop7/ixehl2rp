ITEM.name = "Viscerator"
ITEM.description = "A deployable entity that attacks enemies."
ITEM.model = "models/props_junk/cardboard_box004a.mdl"
ITEM.category = "Combine"

ITEM.functions.Deploy = {
    OnRun = function(itemTable)
        local ply = itemTable.player

        local char = ply:GetCharacter()

        if not ( char ) then
            return true
        end

        if ( ply:GetSequenceInfo(ply:LookupSequence("deploy")) ) then
            ply:SetAction("Deploying...", 1.6)
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

                ent.deployedBy = ply
                ent:CallOnRemove("ix.RemoveOwnerLink", function(this)
                    if not ( IsValid(this.deployedBy) ) then
                        return
                    end

                    if not ( this.deployedBy:GetCharacter() ) then
                        return
                    end

                    if not ( this.deployedBy.ixDeployedEntities ) then
                        return
                    end

                    table.RemoveByValue(this.deployedBy.ixDeployedEntities, this)

                    this.deployedBy:GetCharacter():SetData("deployedEntities", this.deployedBy.ixDeployedEntities)

                    this.deployedBy = nil
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

                ent.deployedBy = ply
                ent:CallOnRemove("ix.RemoveOwnerLink", function(this)
                    if not ( IsValid(this.deployedBy) ) then
                        return
                    end

                    if not ( this.deployedBy:GetCharacter() ) then
                        return
                    end

                    if not ( this.deployedBy.ixDeployedEntities ) then
                        return
                    end

                    table.RemoveByValue(this.deployedBy.ixDeployedEntities, this)

                    this.deployedBy:GetCharacter():SetData("deployedEntities", this.deployedBy.ixDeployedEntities)

                    this.deployedBy = nil
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
                ent.deployedBy = ply
                ent:CallOnRemove("ix.RemoveOwnerLink", function(this)
                    if not ( IsValid(this.deployedBy) ) then
                        return
                    end

                    if not ( this.deployedBy:GetCharacter() ) then
                        return
                    end

                    if not ( this.deployedBy.ixDeployedEntities ) then
                        return
                    end

                    table.RemoveByValue(this.deployedBy.ixDeployedEntities, this)

                    this.deployedBy:GetCharacter():SetData("deployedEntities", this.deployedBy.ixDeployedEntities)

                    this.deployedBy = nil
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