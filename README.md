# ix: Enhanced Half-Life 2 Roleplay
ix: Enhanced Half-Life 2 Roleplay is a project started by [eon](https://github.com/bloodycop7), it was made to provide more core functions that you see in Half-Life 2.

The code is also open-source with a license.

**Keep in mind you do require a bit of programming experience to understand what you're reading/modifying!**
# Recommended Addons for Usage
[TFA: Project HL2 MMod Pack](https://steamcommunity.com/sharedfiles/filedetails/?id=2665902404)\
[TFA: Aim FX](https://steamcommunity.com/sharedfiles/filedetails/?id=2834386148)\
[True Combine Hands](https://steamcommunity.com/sharedfiles/filedetails/?id=2860571852)\
[Entropy: Zero 2 - Metropolice Pack](https://steamcommunity.com/sharedfiles/filedetails/?id=2854473898)

# Help Needed!
Hello, as some of you may have tested/noticed. The UI in the Schema is Janky (Sucks), if you are good with Derma (VGUI) and if you wish to contribute. Please fork the project and submit a pull request upgrading as many as you choose of the following:
- Combine HUD
- User Interface

# Contributions
You may fork this project and submit pull requests ***if you wish***, it will be very appreciated!\
You may find various Credits everywhere through out the code, make sure to check them out!

**IMPORTANT**
- Schema does NOT use netstream, use the net. library.
- localPlayer is cached Clientside, do not use LocalPlayer()
- scrW is cached Clientside, do not use ScrW()
- scrH is cached Clientside, do not use ScrH()
- The schema does not use client:IsCombine(), use Schema:IsCombine(client) instead. (Look at sh_schema to look at more code.)

**Thanks to all contributors who have submitted pull requests to improve this project!**
# Useful Navigation
[Combine Fonts](https://github.com/bloodycop7/ixehl2rp/blob/main/plugins/cmb/cl_plugin.lua#L38-L77) - [Download](https://dl.dafont.com/dl/?f=frak)\
[NPC Relationships](https://github.com/bloodycop7/ixehl2rp/blob/main/schema/libs/sh_npcrelationships.lua)\
[Combine HUD](https://github.com/bloodycop7/ixehl2rp/blob/main/plugins/cmb/cl_hooks.lua#L31)\
[City Codes Configuration](https://github.com/bloodycop7/ixehl2rp/blob/main/plugins/cmb/sh_plugin.lua#L108)
# Plugins
This schema includes custom and open-source plugins.
If you want to add any to fit your roleplay server, you can find some [here](https://plugins.gethelix.co/all/)
# Donations
If you feel generous and want to donate, you can do so [here](https://paypal.me/theb3ta)
