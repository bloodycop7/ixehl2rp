DeriveGamemode("helix")

hook.Add("OnScreenSizeChanged", "OnScreenSizeChanged.ixChangeScreenSize", function()
    timer.Simple(1, function()
        hook.Run("HUDPaint")
        hook.Run("HUDPaintBackground")
        hook.Run("LoadFonts", ix.config.Get("font"), ix.config.Get("genericFont"))
    end)
end)