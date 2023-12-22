local PLUGIN = PLUGIN

function ix.cmbSystems:SetBOLStatus(ply, bolStatus)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    char:SetBOLStatus(bolStatus)
end