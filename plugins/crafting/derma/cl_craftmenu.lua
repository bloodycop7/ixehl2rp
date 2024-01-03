local PANEL = {}

// Recipes Table: ix.crafting.recipes
// Stations Table: ix.crafting.stations
// Recipes value to check for stations: recipe.stations

function PANEL:Init()
    if ( IsValid(ix.gui.craftingMenu) ) then
        self:Remove()
    end

    ix.gui.craftingMenu = self

    self.sysTime = SysTime()

    self:SetSize(scrW * 0.6, scrH * 0.6)
    self:Center()
    self:MakePopup()

    local craftLabel = self:Add("DLabel")
    craftLabel:Dock(TOP)
    craftLabel:SetText(ix.crafting.stations[localPlayer:GetData("ixCraftingStation", nil):GetStationID()].name .. " Station")
    craftLabel:SetFont("ixIntroSubtitleFont")
    craftLabel:SetTextColor(color_white)
    craftLabel:SetContentAlignment(5)
    craftLabel:SizeToContents()

    self.leftPanel = self:Add("DScrollPanel")
    self.leftPanel:Dock(LEFT)
    self.leftPanel:SetWide(self:GetWide() * 0.3)
    self.leftPanel.Paint = function(s, w, h)
        surface.SetDrawColor(10, 10, 10, 230)
        surface.SetMaterial(ix.gui.gradients["left"])
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.middlePanel = self:Add("DScrollPanel")
    self.middlePanel:Dock(FILL)
    self.middlePanel.Paint = function(s, w, h)
    end

    self.rightPanel = self:Add("DScrollPanel")
    self.rightPanel:Dock(RIGHT)
    self.rightPanel:SetWide(self:GetWide() * 0.32)
    self.rightPanel.Paint = function(s, w, h)
        surface.SetDrawColor(Color(0, 0, 0, 240))
        surface.DrawRect(0, 0, w, h)
    end

    self.categories = {}
    for k, v in pairs(ix.crafting.recipes) do
        if ( self.categories[v.category] ) then
            continue
        end

        self.categories[v.category] = v
    end

    for k, v in pairs(self.categories) do
        local category = self.leftPanel:Add("ixMenuButton")
        category:Dock(TOP)
        category:SetText(k)
        category:SetFont("ixMenuButtonFont")
        category:SetTextColor(color_white)
        category:SetContentAlignment(5)
        category:SizeToContents()
        category:DockMargin(0, 0, 0, 5)
        category.DoClick = function()
            self:PopulateRecipes(k)
        end
        category:SizeToContents()

        self.activeCategory = k
    end
end

function PANEL:PopulateRecipes(category)
    self.middlePanel:Clear()

    for k, v in pairs(ix.crafting.recipes) do
        if not ( string.lower(v.category) == string.lower(category) ) then
            continue
        end

        local recipe = self.middlePanel:Add("ixMenuButton")
        recipe:Dock(TOP)
        recipe:SetText(v.name)
        recipe:SetFont("ixSmallTitleFont")
        recipe:SizeToContents()

        recipe.DoClick = function()
            self:PopulateRecipe(v)
        end

        local spawnIcon = recipe:Add("ixSpawnIcon")
        spawnIcon:SetSize(64, 64)
        spawnIcon:Dock(RIGHT)
        spawnIcon:DockMargin(5, 5, 5, 5)
        spawnIcon:SetModel(v.model)
        spawnIcon:SetFOV(3)
    end
end

function PANEL:PopulateRecipe(recipe)
    self.rightPanel:Clear()

    local recipeName = self.rightPanel:Add("DLabel")
    recipeName:Dock(TOP)
    recipeName:SetText(recipe.name)
    recipeName:SetFont("ixSmallTitleFont")
    recipeName:SetTextColor(color_white)
    recipeName:SetContentAlignment(5)
    recipeName:SizeToContents()

    local recipeDesc = self.rightPanel:Add("DLabel")
    recipeDesc:Dock(TOP)
    recipeDesc:SetText(recipe.description)
    recipeDesc:SetFont("ixSmallFont")
    recipeDesc:SetTextColor(color_white)
    recipeDesc:SetContentAlignment(5)
    recipeDesc:SetAutoStretchVertical(true)
    recipeDesc:SetWrap(true)

    local recipeModel = self.rightPanel:Add("ixModelPanel")
    recipeModel:Dock(TOP)
    recipeModel:SetSize(256, 256)
    recipeModel:SetModel(recipe.model)
    recipeModel:SetFOV(50)
    recipeModel:SetCamPos(recipeModel:GetCamPos() + Vector(0, 0, 0, 10))
    recipeModel:SetLookAt(Vector(0, 0, 10))

    local recipeIngredients = self.rightPanel:Add("DLabel")
    recipeIngredients:Dock(TOP)
    recipeIngredients:SetText("Ingredients:")
    recipeIngredients:SetFont("ixSmallTitleFont")
    recipeIngredients:SetTextColor(color_white)
    recipeIngredients:SetContentAlignment(5)
    recipeIngredients:SizeToContents()

    for k, v in pairs(recipe.requirements) do
        local ingredient = self.rightPanel:Add("DLabel")
        ingredient:Dock(TOP)
        ingredient:SetText(ix.item.Get(k).name .. " x" .. v)
        ingredient:SetFont("ixSmallFont")
        ingredient:SetTextColor(color_white)
        ingredient:SetContentAlignment(5)
        ingredient:SizeToContents()

        local colorText = Color(0, 255, 0)
        local itemCount = localPlayer:GetCharacter():GetInventory():GetItemCount(k)

        if ( itemCount < v ) then
            colorText = Color(255, 0, 0)
        end

        ingredient:SetTextColor(colorText)
    end

    local recipeButton = self.rightPanel:Add("ixMenuButton")
    recipeButton:SetText("Craft")
    recipeButton:SetFont("ixMenuButtonFont")
    recipeButton:SetTextColor(color_white)
    recipeButton:SetContentAlignment(5)
    recipeButton:Dock(BOTTOM)
    recipeButton:SizeToContents()
    recipeButton.DoClick = function()
        net.Start("ix.Crafting.DoCraft")
            net.WriteString(recipe.uniqueID)
        net.SendToServer()
    end
end

function PANEL:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.sysTime)

    surface.SetDrawColor(0, 0, 0, 230)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:Think()
    if ( input.IsKeyDown(KEY_SPACE) ) then
        self:Remove()
    end
end

function PANEL:OnRemove()
    net.Start("ix.Crafting.ClosePanel")
    net.SendToServer()
end

vgui.Register("ixCraftingMenu", PANEL, "Panel")