ix.relationships = {}

ix.relationships.CombineNPCs = {
    ["npc_metropolice"] = true,
    ["npc_combine_s"] = true,
    ["npc_combinegunship"] = true,
    ["npc_combinedropship"] = true,
    ["npc_helicopter"] = true,
    ["npc_strider"] = true,
    ["npc_turret_ceiling"] = true,
    ["npc_turret_floor"] = true,
    ["npc_turret_ground"] = true,
    ["npc_manhack"] = true,
    ["npc_clawscanner"] = true,
    ["npc_cscanner"] = true,
    ["npc_rollermine"] = true,
    ["npc_stalker"] = true,
    ["npc_sniper"] = true,
    ["npc_hunter"] = true,
    ["npc_breen"] = true,
    ["npc_combine_camera"] = true,

    // ZBase Combine NPCs

    ["zb_metropolice"] = true,
    ["zb_metropolice_elite"] = true,
    ["zb_crab_synth"] = true,
    ["zb_hunter"] = true,
    ["zb_mortar_synth"] = true,
    ["zb_combine_nova_prospekt"] = true,
    ["zb_combine_elite"] = true,
    ["zb_combine_soldier"] = true,
    ["zb_stalker"] = true,

    // No Idea where these are from

    ["mbn_apc_manager"] = true,
}

ix.relationships.RebelNPCs = {
    ["npc_citizen"] = true,
    ["npc_magnusson"] = true,
    ["npc_monk"] = true,
    ["npc_eli"] = true,
    ["npc_kleiner"] = true,
    ["npc_mossman"] = true,
    ["npc_vortigaunt"] = true,
    ["npc_barney"] = true,
    ["npc_dog"] = true,
    ["npc_fisherman"] = true,
    ["npc_gman"] = true,
    ["npc_kleiner"] = true,
    ["npc_mossman"] = true,
    ["npc_alyx"] = true,
    ["npc_breen"] = true,
    ["npc_magnusson"] = true,
    ["npc_monk"] = true,
    ["npc_vortigaunt"] = true,

    // ZBase Rebel NPCs

    ["zb_kleiner"] = true,
    ["zb_human_civilian_f"] = true,
    ["zb_human_medic_f"] = true,
    ["zb_human_rebel_f"] = true,
    ["zb_human_refugee_f"] = true,
    ["zb_human_civilian"] = true,
    ["zb_human_medic"] = true,
    ["zb_human_rebel"] = true,
    ["zb_human_refugee"] = true,
    ["zb_odessa"] = true,
    ["zb_friendly_hunter"] = true,
    ["zb_vortigaunt"] = true
}

if ( SERVER ) then
    function ix.relationships.Update(ent)
        if not ( IsValid(ent) ) then
            return
        end
        
        if not ( ent:IsNPC() ) then
            ErrorNoHalt("Attempted to update relationships on a non-NPC entity!\n")
        end

        for k, v in player.Iterator() do
            if not ( IsValid(v) ) then
                continue
            end

            if not ( v:GetCharacter() ) then
                continue
            end

            if not ( v:Alive() or v:Health() > 0 ) then
                continue
            end

            local relationshipStatus = D_HT

            local checkName = ent:GetClass()

            if ( string.find(checkName, "zbase*") ) then
                checkName = ent:GetNWString("NPCName", ent.NPCName)
            end

            local isRebelNPC = false

            if ( checkName:find("turret") and ( ent:HasSpawnFlags(SF_FLOOR_TURRET_CITIZEN) or false ) ) then
                isRebelNPC = true
            end

            if ( ix.relationships.CombineNPCs[checkName] and not isRebelNPC) then
                local oldTable = ent.VJ_NPC_Class or {}

                if not ( table.HasValue(oldTable, "CLASS_COMBINE") ) then
                    oldTable[#oldTable + 1] = "CLASS_COMBINE"
                end

                ent.VJ_NPC_Class = oldTable

                if ( ent:GetClass():find("zbase*") ) then
                    if ( ZBaseSetFaction ) then
                        ZBaseSetFaction(ent, "combine")
                    end
                end

                if ( Schema:IsCombine(v) ) then
                    if ( ZBaseSetFaction ) then
                        ZBaseSetFaction(v, "combine")
                    end

                    relationshipStatus = D_LI
                end
            elseif ( ix.relationships.RebelNPCs[ent:GetClass()] or isRebelNPC ) then
                local oldTable = ent.VJ_NPC_Class or {}

                if not ( table.HasValue(oldTable, "CLASS_REBEL") ) then
                    oldTable[#oldTable + 1] = "CLASS_REBEL"
                end

                ent.VJ_NPC_Class = oldTable
                
                if ( ent:GetClass():find("zbase*") ) then
                    if ( ZBaseSetFaction ) then
                        ZBaseSetFaction(ent, "ally")
                    end
                end

                if not ( Schema:IsCombine(v) ) then
                    if ( ZBaseSetFaction ) then
                        ZBaseSetFaction(v, "ally")
                    end

                    relationshipStatus = D_LI
                end
            end

            if ( hook.Run("GetNPCRelationshipStatus", v, ent) != nil ) then
                relationshipStatus = hook.Run("GetNPCRelationshipStatus", v, ent)
            end

            if ( ent:Disposition(v) == relationshipStatus ) then
                continue
            end

            ent:AddEntityRelationship(v, relationshipStatus, 0)
        end
    end

    hook.Add("OnEntityCreated", "ix.NPCRelationships.OnEntityCreated", function(ent)
        if not ( IsValid(ent) ) then
            return
        end

        if not ( ent:IsNPC() ) then
            return
        end

        timer.Simple(0.1, function()
            if not ( IsValid(ent) ) then
                return
            end

            ix.relationships.Update(ent)

            local timerID = "ix.NPCRelationships.Update." .. ent:EntIndex()

            if not ( timer.Exists(timerID) ) then
                timer.Create(timerID, 1, 0, function()
                    if not ( IsValid(ent) ) then
                        timer.Remove(timerID)

                        return
                    end

                    ix.relationships.Update(ent)
                end)
            end
        end)
    end)

    hook.Add("OnNPCKilled", "ix.NPCRelationships.OnNPCKilled", function(ent, attacker, inflictor)
        if not ( IsValid(ent) ) then
            return
        end

        local timerID = "ix.NPCRelationships.Update." .. ent:EntIndex()

        if ( timer.Exists(timerID) ) then
            timer.Remove(timerID)
        end
    end)

    hook.Add("EntityRemoved", "ix.NPCRelationships.EntityRemoved", function(ent)
        if not ( IsValid(ent) ) then
            return
        end

        if not ( ent:IsNPC() ) then
            return
        end

        local timerID = "ix.NPCRelationships.Update." .. ent:EntIndex()

        if ( timer.Exists(timerID) ) then
            timer.Remove(timerID)
        end
    end)

    hook.Add("PlayerLoadedCharacter", "ix.NPCRelationships.PlayerLoadedCharacter", function(ply, newChar, oldChar)
        timer.Simple(0.1, function()
            if ( Schema:IsCombine(ply) ) then
                ply.ZBaseFaction = "combine"
            else
                ply.ZBaseFaction = "ally"
            end

            for k, v in ipairs(ents.GetAll()) do
                if not ( IsValid(v) ) then
                    continue
                end

                if not ( v:IsNPC() ) then
                    continue
                end

                if not ( v:Health() > 0 ) then
                    continue
                end

                ix.relationships.Update(v)
            end
        end)
    end)
end