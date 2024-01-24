local PLUGIN = PLUGIN

PLUGIN.name = "Vocie Modes"
PLUGIN.author = "eon"
PLUGIN.license = [[
Copyright 2024 eon (bloodycop)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

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
            return true
        end
    end
end