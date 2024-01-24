DeriveGamemode("helix")

// Caching for Perfomance, thanks to Preacher!

localPlayer = localPlayer or LocalPlayer()
scrW = ScrW()
scrH = ScrH()

hook.Add("InitPostEntity", "InitPostEntity.ixLoadCharacter", function()
    localPlayer = LocalPlayer()
end)

hook.Add("OnReloaded", "OnReloaded.ixLoadCharacter", function()
    localPlayer = LocalPlayer()
end)

hook.Add("OnScreenSizeChanged", "OnScreenSizeChanged.ixChangeScreenSize", function()
    timer.Simple(1, function()
        scrW = ScrW()
        scrH = ScrH()

        hook.Run("HUDPaint")
        hook.Run("HUDPaintBackground")
        hook.Run("LoadFonts", ix.config.Get("font"), ix.config.Get("genericFont"))
    end)
end)