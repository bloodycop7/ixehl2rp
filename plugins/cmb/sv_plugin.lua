local PLUGIN = PLUGIN
util.AddNetworkString("ix.Combine.SetCityCode")
util.AddNetworkString("ix.Combine.ToggleBOL")

net.Receive("ix.Combine.SetCityCode", function(len, ply)
    local id = net.ReadUInt(8)
    local codeData = ix.cmbSystems.cityCodes[id]

    if not ( codeData ) then
        return
    end

    if not ( Schema:IsCombine(ply) ) then
        return
    end

    ix.cmbSystems:SetCityCode(id)
end)

net.Receive("ix.Combine.ToggleBOL", function(len, ply)
    local target = net.ReadEntity()

    if not ( IsValid(target) ) then
        return
    end

    if not ( Schema:IsCombine(ply) ) then
        return
    end

    ix.cmbSystems:SetBOLStatus(target, !target:GetCharacter():GetBOLStatus())
end)

function ix.cmbSystems:SetBOLStatus(ply, bolStatus, callback)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    char:SetBOLStatus(bolStatus)

    if ( callback ) then
        callback(ply, bolStatus)
    end
end

function ix.cmbSystems:SetCityCode(id)
    local codeData = ix.cmbSystems.cityCodes[id]

    if not ( codeData ) then
        return
    end

    if ( codeData.onStart ) then
        codeData:onStart()
    end

    SetGlobalInt("ixCityCode", id)
end

local baseRadioVoiceDir = "npc/overwatch/cityvoice/"

ix.cmbSystems.dispatchPassive = {
    {
        soundDir = baseRadioVoiceDir .. "f_innactionisconspiracy_spkr.wav",
        text = "Citizen reminder: inaction is conspiracy. Report counter-behavior to a Civil Protection team immediately.",
    },
    {
        soundDir = baseRadioVoiceDir .. "f_trainstation_offworldrelocation_spkr.wav",
        text = "Citizen notice: Failure to cooperate will result in permanent off-world relocation.",
    }
}

timer.Remove("ix.DispatchPassive")
timer.Create("ix.DispatchPassive", ix.config.Get("passiveDispatchCooldown", 120), 0, function()
    local cityCode = ix.cmbSystems.cityCodes[GetGlobalInt("ixCityCode", 1)]

    if ( cityCode ) then
        if ( cityCode.dispatchPassive ) then
            cityCode:dispatchPassive()

            return
        end
    end

    local dispatchData = ix.cmbSystems.dispatchPassive[math.random(1, #ix.cmbSystems.dispatchPassive)]

    ix.chat.Send(nil, "cmb_dispatch", dispatchData.text)
    Schema:PlaySound(player.GetAll(), dispatchData.soundDir)
end)