local PLUGIN = PLUGIN

PLUGIN.name = "Vocie Modes"
PLUGIN.author = "eon"

ix.voiceModes = ix.voiceModes or { Stored = {
    {
        name = "Normal",
    },
    {
        name = "Yell",
    },
    {
        name = "Whisper",
    }
} }

ix.voiceModes.ChatTypes = {
    [1] = "ic",
    [2] = "y",
    [3] = "w"
}

ix.command.Add("SetVoiceMode", {
    description = "Set your voice mode.",
    arguments = {ix.type.number},
    OnRun = function(self, ply, voiceMode)
        if not ( IsValid(ply) ) then
            return
        end
        
        local char = ply:GetCharacter()

        if not ( char ) then
            return
        end

        local voiceModeTable = ix.voiceModes.Stored[voiceMode]

        if not ( voiceModeTable ) then
            return
        end

        char:SetData("voiceMode", voiceMode)
        ply:Notify("You have set your voice mode to " .. voiceModeTable.name .. ".")
    end
})

if ( SERVER ) then
    function PLUGIN:PlayerCanHearPlayersVoice(listener, talker)
        if not ( IsValid(listener) or IsValid(talker) ) then
            return
        end
        
        local talkerChar = talker:GetCharacter()

        if not ( talkerChar ) then
            return
        end

        local listenerChar = listener:GetCharacter()

        if not ( listenerChar ) then
            return
        end

        local convertToChatType = ix.voiceModes.ChatTypes[listenerChar:GetData("voiceMode", 1)]

        if not ( convertToChatType ) then
            return
        end

        local chatType = ix.chat.classes[convertToChatType]

        if not ( chatType ) then
            return
        end

        if ( listener == talker ) then
            return
        end

        if ( not convertToChatType == "ic" and chatType:CanHear(talker, listener) ) then
            print(listener .. " can hear " .. talker .. ".")
            return true
        end
    end
end