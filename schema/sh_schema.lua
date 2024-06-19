Schema.name = "Half-Life 2 Roleplay"
Schema.author = "eon"
Schema.description = "Immerse yourself in the world of The Half-Life 2 Universe."

ix.util.Include("cl_schema.lua")
ix.util.Include("sv_schema.lua")

ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sv_hooks.lua")

ix.util.IncludeDir("voicelines")

ix.currency.symbol = "C"
ix.currency.singular = "credit"
ix.currency.plural = "credits"

ix.config.SetDefault("font", "Raju Regular")
ix.config.SetDefault("genericFont", "Raju Regular")
ix.config.SetDefault("combineFont", "Frak")

--[[
    FACTION.name = "Conscript Forces"
    FACTION.abbreviation = "CF"

    Schema:IsCF(ply)

    if your class doesn't have an abbreviation, it will use the class name instead.

    Schema:IsConscriptForces(ply)
]]

for index, FACTION in ipairs(ix.faction.indices) do
    local FACTION_NAME_SPACELESS = FACTION.name:Replace(" ", "")
    local ABBREVIATION = FACTION.abbreviation or FACTION_NAME_SPACELESS

    Schema["Is" .. ABBREVIATION] = function(self, ply)
        if not ( IsValid(ply) ) then
            return false
        end

        local character = ply:GetCharacter()
        if not ( character ) then
            return false
        end

        return character:GetFaction() == index
    end
end

--[[
    CLASS for Civil Protection Faction with Abbreviation 'CP'
    CLASS.name = "Cadet Officer"
    CLASS.abbreviation = "CO"

    Schema:IsCPCO(ply)

    if your class doesn't have an abbreviation, it will use the class name instead.

    Schema:IsCPCadetOfficer(ply)
]]

for index, CLASS in ipairs(ix.class.list) do
    local FACTION = ix.faction.Get(CLASS.faction)
    if not ( FACTION ) then
        continue
    end

    local FACTION_NAME_SPACELESS = FACTION.name:Replace(" ", "")
    local ABBREVIATION = FACTION.abbreviation or FACTION_NAME_SPACELESS

    local CLASS_NAME_SPACELESS = CLASS.name:Replace(" ", "")
    local CLASS_ABBREVIATION = CLASS.abbreviation or CLASS_NAME_SPACELESS

    Schema["Is" .. ABBREVIATION .. CLASS_ABBREVIATION] = function(self, ply)
        if not ( IsValid(ply) ) then
            return false
        end

        local character = ply:GetCharacter()
        if not ( character ) then
            return false
        end

        if not ( CLASS.faction ) then
            return false
        end

        if not ( CLASS.faction == character:GetFaction() ) then
            return false
        end

        return character:GetClass() == index
    end
end

ix.rank.LoadFromDir(Schema.folder .. "/schema/ranks")

--[[
    RANK for Civil Protection Faction with Abbreviation 'CP'
    RANK.name = "Patrol Officer"
    RANK.abbreviation = "PO"

    Schema:IsCPPO(ply)

    if your class doesn't have an abbreviation, it will use the class name instead.

    Schema:IsCPPatrolOfficer(ply)
]]

for index, RANK in ipairs(ix.rank.list) do
    local FACTION = ix.faction.Get(v.faction)
    if not ( FACTION ) then
        continue
    end

    local FACTION_NAME_SPACELESS = FACTION.name:Replace(" ", "")
    local ABBREVIATION = FACTION.abbreviation or FACTION_NAME_SPACELESS

    local RANK_NAME_SPACELESS = RANK.name:Replace(" ", "")
    local RANK_ABBREVIATION = RANK.abbreviation or RANK_NAME_SPACELESS

    Schema["Is" .. ABBREVIATION .. RANK_ABBREVIATION] = function(self, ply)
        if not ( IsValid(ply) ) then
            return false
        end

        local character = ply:GetCharacter()
        if not ( character ) then
            return false
        end

        if not ( RANK.faction ) then
            return false
        end

        if not ( RANK.faction == character:GetFaction() ) then
            return false
        end

        return character:GetRank() == index
    end
end

function Schema:ColorToText(color)
    if not ( IsColor(color) ) then
        return
    end

    return ( color.r or 255 ) .. "," .. ( color.g or 255 ) .. "," .. ( color.b or 255 ) .. "," .. ( color.a or 255 )
end

function Schema:IsCombine(ply)
    if not ( IsValid(ply) ) then
        return false
    end

    local character = ply:GetCharacter()

    if not ( character ) then
        return false
    end

    return self:IsOW(ply) or self:IsCP(ply)
end

// Credits: https://github.com/NebulousCloud/helix-hl2rp/blob/master/schema/sh_schema.lua#L32-L35
function Schema:ZeroNumber(number, length)
	local amount = math.max(0, length - string.len(number))

	return string.rep("0", amount) .. tostring(number)
end

function Schema:IsOutside(ply)
    local trace = util.TraceLine({
        start = ply:GetPos(),
        endpos = ply:GetPos() + ply:GetUp() * 9999999999,
        filter = ply
    })

    return trace.HitSky
end

function Schema:PlayGesture(ply, gesture)
    if ( SERVER ) then
        net.Start("ix.PlayGesture")
            net.WritePlayer(ply)
            net.WriteString(gesture)
        net.Broadcast()
    end

	local index, length = ply:LookupSequence(gesture)

	if not ( ply:LookupSequence(gesture) ) then
		return
	end

	ply:DoAnimationEvent(index)
end

function Schema:CanSeeEntity(entA, entB) // Entity A must be an NPC or Player
    if not ( IsValid(entA) and IsValid(entB) ) then
        return false
    end

    if not ( entA:IsPlayer() or entA:IsNPC() ) then
        return false
    end

    if not ( entA:IsLineOfSightClear(entB) ) then
        return false
    end

    local diff = entB:GetPos() - entA:GetShootPos()

    if ( entA:GetAimVector():Dot(diff) / diff:Length() < 0.455 ) then
        return false
    end

    return true
end

function Schema:LerpColor(time, from, to)
    if not ( IsColor(from) ) then
        ErrorNoHalt("Schema:LerpColor: 'from' is not a color!\n")
        return
    end

    if not ( IsColor(to) ) then
        ErrorNoHalt("Schema:LerpColor: 'to' is not a color!\n")
        return
    end

    if not ( time ) then
        time = FrameTime() * 2
    end

    from = Color(from.r, from.g, from.b, from.a)

    to.r = Lerp(time, from.r, to.r)
    to.g = Lerp(time, from.g, to.g)
    to.b = Lerp(time, from.b, to.b)
    to.a = Lerp(time, from.a, to.a)

    to = Color(to.r, to.g, to.b, to.a)

    return to
end

function Schema:GetGameDescription()
	return "IX: "..(Schema.name or "Unknown")
end

ix.config.Add("maxItemDrops", 3, "The maximum amount of items that can be dropped by a player on death.", nil, {
    data = {min = 1, max = 10},
    category = "misc"
})

ix.config.Add("maxItemCrateDrops", 4, "The maximum amount of items an item cache can drop", nil, {
    data = {min = 1, max = 15},
    category = "misc"
})

ix.config.Add("confiscationLockerWipe", (60 * 30), "The maximum amount of items an item cache can drop", nil, {
    data = {min = 1, max = 3600},
    category = "misc"
})

ix.config.Add("rationInterval", (60 * 30), "How often a player can receive a ration.", nil, {
    data = {min = 1, max = 3600},
    category = "rations"
})

ix.config.Add("itemOutline", true, "Whether or not items should be outlined when hovered.", nil, {
    category = "misc"
})

ix.config.Add("vortHealMin", 5, "Minimum health value that can be healed by vortigaunt" , nil, {
	data = {min = 1, max = 100},
	category = "Vortigaunt Healing Swep"
})

ix.config.Add("vortHealMax", 20, "Maximum health value that can be healed by vortigaunt" , nil, {
	data = {min = 1, max = 100},
	category = "Vortigaunt Healing Swep"
})

ix.command.Add("CharSetRank", {
	description = "Sets the rank of a character.",
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.text
	},
	OnRun = function(self, client, target, rank)
		local rankTable

		for _, v in ipairs(ix.rank.list) do
			if ( ix.util.StringMatches(v.uniqueID, rank) or ix.util.StringMatches(v.name, rank) ) then
				rankTable = v
			end
		end

		if ( rankTable ) then
			local oldRank = target:GetRank()
			local targetPlayer = target:GetPlayer()

			if ( targetPlayer:Team() == rankTable.faction ) then
				target:SetRank(rankTable.index)
				hook.Run("PlayerJoinedRank", targetPlayer, rankTable.index, oldRank)

				targetPlayer:Notify("Your rank has been set to " .. rankTable.name .. ".")
			else
				return "Invalid Rank Faction"
			end
		else
			return "Invalid Rank"
		end
	end
})

function Schema:InitializedChatClasses()
    ix.chat.Register("ic", {
        format = "%s says \"%s\"",
        indicator = "chatTalking",
        GetColor = function(self, speaker, text)
            -- If you are looking at the speaker, make it greener to easier identify who is talking.
            if (LocalPlayer():GetEyeTrace().Entity == speaker) then
                return ix.config.Get("chatListenColor")
            end

            -- Otherwise, use the normal chat color.
            return ix.config.Get("chatColor")
        end,
        OnChatAdd = function(self, speaker, text, anonymous, info)
            local color = self.color
			local name = anonymous and
				L"someone" or hook.Run("GetCharacterName", speaker, "ic") or
				(IsValid(speaker) and speaker:Name() or "Console")

			if (self.GetColor) then
				color = self:GetColor(speaker, text, info)
			end

			local translated = L2("ic" .. "Format", name, text)

            Schema:SendCaption("<clr:" .. Schema:ColorToText(color) .. ">" .. string.format(self.format, name, text))
			chat.AddText(color, translated or string.format(self.format, name, text))
        end,
        CanHear = ix.config.Get("chatRange", 280)
    })

    -- Actions and such.
    ix.chat.Register("me", {
        format = "** %s %s",
        GetColor = ix.chat.classes.ic.GetColor,
        CanHear = ix.config.Get("chatRange", 280) * 2,
        prefix = {"/Me", "/Action"},
        description = "@cmdMe",
        indicator = "chatPerforming",
        OnChatAdd = function(self, speaker, text, anonymous, info)
            local color = ix.chat.classes["ic"]:GetColor(speaker, text, anonymous, info)

            local name = anonymous and
				L"someone" or hook.Run("GetCharacterName", speaker, "ic") or
				(IsValid(speaker) and speaker:Name() or "Console")

            Schema:SendCaption("<clr:" .. Schema:ColorToText(color) .. ">" .. string.format(self.format, name, text))
            chat.AddText(color, string.format(self.format, name, text))
        end,
        deadCanChat = true
    })

    -- Actions and such.
    ix.chat.Register("it", {
        OnChatAdd = function(self, speaker, text, anonymous, info)
            local colorToText = Schema:ColorToText(ix.config.Get("chatColor"))

            Schema:SendCaption("<clr:" .. colorToText .. ">** " .. text)
            chat.AddText(ix.config.Get("chatColor"), "** "..text)
        end,
        CanHear = ix.config.Get("chatRange", 280) * 2,
        prefix = {"/It"},
        description = "@cmdIt",
        indicator = "chatPerforming",
        deadCanChat = true
    })

    -- Whisper chat.
    ix.chat.Register("w", {
        format = "%s whispers \"%s\"",
        GetColor = function(self, speaker, text)
            local color = ix.chat.classes.ic:GetColor(speaker, text)

            -- Make the whisper chat slightly darker than IC chat.
            return Color(color.r - 35, color.g - 35, color.b - 35)
        end,
        OnChatAdd = function(self, speaker, text, anonymous, info)
            local colToGet = ix.chat.classes.ic:GetColor(speaker, text, anonymous, info)
            colToGet = Color(colToGet.r - 35, colToGet.g - 35, colToGet.b - 35)

            local colorToText = Schema:ColorToText(colToGet)

            local name = anonymous and
				L"someone" or hook.Run("GetCharacterName", speaker, "ic") or
				(IsValid(speaker) and speaker:Name() or "Console")

            Schema:SendCaption("<clr:" .. colorToText .. ">" .. string.format(self.format, name, text))
            chat.AddText(colToGet, string.format(self.format, name, text))
        end,
        CanHear = ix.config.Get("chatRange", 280) * 0.25,
        prefix = {"/W", "/Whisper"},
        description = "@cmdW",
        indicator = "chatWhispering"
    })

    -- Yelling out loud.
    ix.chat.Register("y", {
        format = "%s yells \"%s\"",
        GetColor = function(self, speaker, text)
            local color = ix.chat.classes.ic:GetColor(speaker, text)

            -- Make the yell chat slightly brighter than IC chat.
            return Color(color.r + 35, color.g + 35, color.b + 35)
        end,
        OnChatAdd = function(self, speaker, text, anonymous, info)
            local colToGet = ix.chat.classes.ic:GetColor(speaker, text, anonymous, info)
            colToGet = Color(colToGet.r + 35, colToGet.g + 35, colToGet.b + 35)

            local colorToText = Schema:ColorToText(colToGet)

            local name = anonymous and
				L"someone" or hook.Run("GetCharacterName", speaker, "ic") or
				(IsValid(speaker) and speaker:Name() or "Console")

            Schema:SendCaption("<clr:" .. colorToText .. ">" .. string.format(self.format, name, text))
            chat.AddText(colToGet, string.format(self.format, name, text))
        end,
        CanHear = ix.config.Get("chatRange", 280) * 2,
        prefix = {"/Y", "/Yell"},
        description = "@cmdY",
        indicator = "chatYelling"
    })

    -- Out of character.
    ix.chat.Register("ooc", {
        CanSay = function(self, speaker, text)
            if (!ix.config.Get("allowGlobalOOC")) then
                speaker:NotifyLocalized("Global OOC is disabled on this server.")
                return false
            else
                local delay = ix.config.Get("oocDelay", 10)

                -- Only need to check the time if they have spoken in OOC chat before.
                if (delay > 0 and speaker.ixLastOOC) then
                    local lastOOC = CurTime() - speaker.ixLastOOC

                    -- Use this method of checking time in case the oocDelay config changes.
                    if (lastOOC <= delay and !CAMI.PlayerHasAccess(speaker, "Helix - Bypass OOC Timer", nil)) then
                        speaker:NotifyLocalized("oocDelay", delay - math.ceil(lastOOC))

                        return false
                    end
                end

                -- Save the last time they spoke in OOC.
                speaker.ixLastOOC = CurTime()
            end
        end,
        OnChatAdd = function(self, speaker, text)
            -- @todo remove and fix actual cause of speaker being nil
            if (!IsValid(speaker)) then
                return
            end

            local icon = "icon16/user.png"

            if (speaker:IsSuperAdmin()) then
                icon = "icon16/shield.png"
            elseif (speaker:IsAdmin()) then
                icon = "icon16/star.png"
            elseif (speaker:IsUserGroup("moderator") or speaker:IsUserGroup("operator")) then
                icon = "icon16/wrench.png"
            elseif (speaker:IsUserGroup("vip") or speaker:IsUserGroup("donator") or speaker:IsUserGroup("donor")) then
                icon = "icon16/heart.png"
            end

            icon = Material(hook.Run("GetPlayerIcon", speaker) or icon)

            Schema:SendCaption("<clr:" .. Schema:ColorToText(Color(255, 50, 50)) .. ">" .. "[OOC] <clr:" .. Schema:ColorToText(ix.faction.Get(speaker:GetChar():GetFaction()).color) .. "<clr>" .. speaker:Name() .. "<clr:" .. Schema:ColorToText(color_white) .. "<clr>: " .. text)
            chat.AddText(icon, Color(255, 50, 50), "[OOC] ", speaker, color_white, ": "..text)
        end,
        prefix = {"//", "/OOC"},
        description = "@cmdOOC",
        noSpaceAfter = true
    })

    -- Local out of character.
    ix.chat.Register("looc", {
        CanSay = function(self, speaker, text)
            local delay = ix.config.Get("loocDelay", 0)

            -- Only need to check the time if they have spoken in OOC chat before.
            if (delay > 0 and speaker.ixLastLOOC) then
                local lastLOOC = CurTime() - speaker.ixLastLOOC

                -- Use this method of checking time in case the oocDelay config changes.
                if (lastLOOC <= delay and !CAMI.PlayerHasAccess(speaker, "Helix - Bypass OOC Timer", nil)) then
                    speaker:NotifyLocalized("loocDelay", delay - math.ceil(lastLOOC))

                    return false
                end
            end

            -- Save the last time they spoke in OOC.
            speaker.ixLastLOOC = CurTime()
        end,
        OnChatAdd = function(self, speaker, text)
            Schema:SendCaption("<clr:" .. Schema:ColorToText(Color(255, 50, 50)) .. ">" .. "[LOOC] <clr:" .. Schema:ColorToText(ix.config.Get("chatColor")) .. "<clr>" .. speaker:Name() .. ": " .. text)
            chat.AddText(Color(255, 50, 50), "[LOOC] ", ix.config.Get("chatColor"), speaker:Name()..": "..text)
        end,
        CanHear = ix.config.Get("chatRange", 280),
        prefix = {".//", "[[", "/LOOC"},
        description = "@cmdLOOC",
        noSpaceAfter = true
    })

    -- Roll information in chat.
    ix.chat.Register("roll", {
        format = "** %s has rolled %s out of %s.",
        color = Color(155, 111, 176),
        CanHear = ix.config.Get("chatRange", 280),
        deadCanChat = true,
        OnChatAdd = function(self, speaker, text, bAnonymous, data)
            local max = data.max or 100
            local translated = L2(self.uniqueID.."Format", speaker:Name(), text, max)

            Schema:SendCaption("<clr:" .. Schema:ColorToText(self.color) .. ">" .. string.format(self.format, speaker:Name(), text, max))

            chat.AddText(self.color, translated and "** "..translated or string.format(self.format,
                speaker:Name(), text, max
            ))
        end
    })

    ix.chat.Register("event", {
        CanHear = 1000000,
        OnChatAdd = function(self, speaker, text)
            Schema:SendCaption("<clr:" .. Schema:ColorToText(Color(255, 150, 0)) .. ">" .. text)
            chat.AddText(Color(255, 150, 0), text)
        end,
        indicator = "chatPerforming"
    })

    local randomVortWords =
    {
        "ahglah", "ahhhr", "alla", "allu", "baah", "beh", "bim", "buu", "chaa", "chackt", "churr", "dan", "darr", "dee", "eeya", "ge", "ga", "gaharra",
        "gaka", "galih", "gallalam", "gerr", "gog", "gram", "gu", "gunn", "gurrah", "ha", "hallam", "harra", "hen", "hi", "jah", "jurr", "kallah", "keh", "kih",
        "kurr", "lalli", "llam", "lih", "ley", "lillmah", "lurh", "mah", "min", "nach", "nahh", "neh", "nohaa", "nuy", "raa", "ruhh", "rum", "saa", "seh", "sennah",
        "shaa", "shuu", "surr", "taa", "tan", "tsah", "turr", "uhn", "ula", "vahh", "vech", "veh", "vin", "voo", "vouch", "vurr", "xkah", "xih", "zurr"
    }

    ix.chat.Register("Vortigese", {
        format = "%s says in vortigese \"%s\"",
        GetColor = function(self, speaker, text)
            -- If you are looking at the speaker, make it greener to easier identify who is talking.
            if (LocalPlayer():GetEyeTrace().Entity == speaker) then
                return ix.config.Get("chatListenColor")
            end

            -- Otherwise, use the normal chat color.
            return ix.config.Get("chatColor")
        end,
        CanHear = ix.config.Get("chatRange", 280),
        CanSay = function(self, speaker,text)
            if ( Schema:IsVortigaunt(speaker) ) then
                return true
            else
                speaker:NotifyLocalized("You don't know Vortigese!")
                return false
            end
        end,
        OnChatAdd = function(self,speaker, text, anonymous, info)
            local color = self:GetColor(speaker, text, info)
            local name = anonymous and
                    L"someone" or hook.Run("GetCharacterName", speaker, chatType) or
                    (IsValid(speaker) and speaker:Name() or "Console")

            if (!Schema:IsVortigaunt(LocalPlayer())) then
                local splitedText = string.Split(text, " ")
                local vortigese = {}

                for k, v in pairs(splitedText) do
                    local word = randomVortWords[math.random(1, #randomVortWords)]
                    table.insert( vortigese, word )

                end
                text = table.concat( vortigese, " " )
            end

            chat.AddText(color, string.format(self.format, name, text))
        end,
        prefix = {"/v", "/vort"},
        description = "Says in vortigaunt language",
        indicator = "Vortigesing",
        deadCanChat = false
    })
end

function Schema:OnReloaded()
    self:InitializedChatClasses()
end
