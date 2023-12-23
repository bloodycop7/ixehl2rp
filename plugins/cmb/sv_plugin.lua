local PLUGIN = PLUGIN

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