local PLUGIN = PLUGIN

function PLUGIN:CanDrawCombineHUD()
    if not ( IsValid(localPlayer) ) then
        return false
    end

    local char = localPlayer:GetCharacter()

    if not ( char ) then
        return false
    end

    if not ( localPlayer:Alive() ) then
        return false
    end

    if not ( Schema:IsCP(localPlayer) ) then
        return false
    end

    if ( IsValid(ix.gui.menu) or IsValid(ix.gui.characterMenu) ) then
        return false
    end

    return true
end

function PLUGIN:HUDPaint()
    if ( self:CanDrawCombineHUD() ) then
        if not ( IsValid(ix.gui.combineHUD) ) then
            ix.gui.combineHUD = vgui.Create("ix.CMB.HUD")
        end
    else
        if ( IsValid(ix.gui.combineHUD) ) then
            ix.gui.combineHUD:Remove()
        end
    end
end