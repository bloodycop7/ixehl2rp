local PLUGIN = PLUGIN

PLUGIN.name = "Combine Systems"
PLUGIN.author = "eon"
PLUGIN.description = "Self-Explanatory, adds main Combine Functions."

ix.cmbSystems = ix.cmbSystems or {}

ix.config.Add("passiveDispatchCooldown", 120, "How long should the passive dispatch cooldown be?", nil, {
    category = "Combine Systems"
})

ix.char.RegisterVar("bOLStatus", {
    field = "bol_status",
    fieldType = ix.type.bool,
    default = false,
    isLocal = false,
    bNoDisplay = true,
})

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")

ix.cmbSystems.cityCodes = {
    {
        name = "Preserved",
        color = Color(0, 255, 0),
        onStart = function()
            print("PReserved")
        end
    },
    {
        name = "Marginal",
        color = Color(255, 255, 0),
        onStart = function()
            print("PReserved")
        end
    },
    {
        name = "Judgment Waiver",
        color = Color(255, 0, 0),
        onStart = function()
            print("PReserved")
        end
    },
    {
        name = "Autonomous Judgment",
        color = Color(255, 0, 0),
        onStart = function()
            print("PReserved")
        end
    }
}

function ix.cmbSystems:GetCityCode()
    return GetGlobalInt("ixCityCode", 1)
end

function PLUGIN:InitializedChatClasses()
    ix.chat.Register("cmb_global", {
        CanHear = function(self, speaker, listener)
            if not ( IsValid(listener) ) then
                return false
            end

            local char = listener:GetCharacter()

            if not ( char ) then
                return false
            end

            if not ( listener:Alive() ) then
                return false
            end

            if not ( Schema:IsCombine(listener) ) then
                return false
            end

            return true
        end,
        CanSay = function(self, speaker, text)
            if not ( IsValid(speaker) ) then
                return false
            end

            local char = speaker:GetCharacter()

            if not ( char ) then
                return false
            end

            if not ( speaker:Alive() ) then
                return false
            end

            if not ( Schema:IsCombine(speaker) ) then
                return false
            end
            
            return true
        end,
        OnChatAdd = function(self, speaker, text)
            chat.AddText(Color(0, 100, 170), "*[CMB] " .. speaker:GetChar():GetName() .. ": " .. text .. "*")
        end,
        prefix = {"/cmbradio", "/cmbr"},
        font = "ixCombineFont10",
    })

    ix.chat.Register("cmb_dispatch", {
        CanHear = function(self, speaker, listener)
            if not ( IsValid(listener) ) then
                return false
            end

            return true
        end,
        CanSay = function(self, speaker, text)
            if not ( IsValid(speaker) ) then
                return true
            end
            
            return false
        end,
        OnChatAdd = function(self, speaker, text)
            chat.AddText(Color(185, 40, 0), "*Dispatch: " .. text .. "*")
        end,
        font = "ixCombineFont30",
    })
end

function PLUGIN:OnReloaded()
    self:InitializedChatClasses()
end