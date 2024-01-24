ITEM.name = "Repair Tool"
ITEM.desc = "A tool used to repair things."
ITEM.model = "models/props_c17/tools_wrench01a.mdl"

local repairEnts = {
    ["ix_citizen_terminal"] = true,
    ["ix_cmb_terminal"] = true
}

ITEM.functions.DoRepair = {
    icon = "icon16/wrench.png",
    name = "Repair",
    OnRun = function(item)
        local ply = item.player
        local trace = util.TraceEntity({
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + ply:GetAimVector() * 96,
            filter = ply
        }, ply)

        local ent = trace.Entity

        if not ( IsValid(ent) ) then
            return false
        end

        if not ( repairEnts[ent:GetClass()] ) then
            ply:Notify("You cannot repair this entity.")

            return false
        end

        if not ( ent:GetBroken() ) then
            ply:Notify("This entity is not broken.")

            return false
        end

        ply:SetAction("Repairing...", 5)
        ply:DoStaredAction(ent, function()
            ent:SetBroken(false)
            ent:SetHealth(ent.ixHealth or 50)
            ent:EmitSound("ambient/energy/spark"..math.random(1, 6)..".wav", 75, math.random(90, 110))

            local uID = "ixSparks." .. ent:GetClass() .. "." .. ent:EntIndex()

            if ( timer.Exists(uID) ) then
                timer.Remove(uID)
            end

            uID = "ix.Repair." .. ent:GetClass() .. "." .. ent:EntIndex()

            if ( timer.Exists(uID) ) then
                timer.Remove(uID)
            end

            ply:Notify("You have repaired this entity.")
        end, 5, function()
            if ( IsValid(ply) ) then
                ply:SetAction()
                ply:Notify("You have stopped repairing the entity.")
            end
        end, 96)

        return false
    end
}