local PLUGIN = PLUGIN

PLUGIN.name = "Clothing"
PLUGIN.description = "Clothing Base"
PLUGIN.author = "eon"
PLUGIN.license = [[
Copyright 2024 eon (bloodycop)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

function PLUGIN:Think()
    for k, v in pairs(player.GetAll()) do
        if not ( IsValid(v) ) then
            continue
        end

        local char = v:GetCharacter()

        if not ( char ) then
            return
        end
        
        if not ( char:GetInventory() ) then // bots :d
            continue
        end

        if ( ( v.nextClothingThink or 0 ) > CurTime() ) then
            continue
        end

        for _, item in pairs(char:GetInventory():GetItemsByBase("base_clothing", false)) do
            if ( item:GetData("equip", false) ) then
                if ( item.Think ) then
                    item:Think(v)
                end
            end
        end

        v.nextClothingThink = CurTime() + 1
    end
end