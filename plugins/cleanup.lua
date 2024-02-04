local PLUGIN = PLUGIN

PLUGIN.name = "Ragdoll Remover"
PLUGIN.author = "eon (bloodycop)"
PLUGIN.description = "Removes all ragdolls found on the ground."

ix.config.Add("ragdollRemoveTime", 60, "How long to wait before removing ragdolls.", function(iOld, iNew)
   if ( timer.Exists("ix.RagdollRemoveTimer") ) then
      timer.Adjust("ix.RagdollRemoveTimer", iNew, 0)
   end
end, {
   data = {min = 0, max = 500},
   category = PLUGIN.name
})

ix.config.Add("ragdollRemoveEnabled", false, "Should ragdoll remover be enabled?", function(bOld, bNew)
   if ( bNew ) then
      if ( timer.Exists("ix.RagdollRemoveTimer") ) then
         return
      end

      timer.Create("ix.RagdollRemoveTimer", ix.config.Get("ragdollRemoveTime", 60), 0, function()
         for k, v in ipairs(ents.FindByClass("prop_ragdoll")) do
            v:Remove()
         end

         if ( CLIENT ) then
            for k, v in ipairs(ents.FindByClass("class C_ClientRagdoll")) do  
               v:Remove()
            end
         end
      end)
   else
      if ( timer.Exists("ix.RagdollRemoveTimer") ) then
         timer.Remove("ix.RagdollRemoveTimer")
      end
   end
end, {
   category = PLUGIN.name
})
