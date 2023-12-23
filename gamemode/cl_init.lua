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
    scrW = ScrW()
    scrH = ScrH()
end)