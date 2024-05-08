local PANEL = {}

// Recipes Table: ix.crafting.recipes
// Stations Table: ix.crafting.stations
// Recipes value to check for stations: recipe.stations

function PANEL:Init()
    if ( IsValid(ix.gui.craftingMenu) ) then
        self:Remove()
    end

    local ply = LocalPlayer()

    if not ( IsValid(ply) ) then
        self:Remove()
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        self:Remove()
    end

    if not ( IsValid(ply:GetNetVar("ixCraftingStation", nil)) ) then
        self:Remove()
    end

    ix.gui.craftingMenu = self

    self:SetSize(ScrW(), ScrH())
    self:Center()
    self:MakePopup()

    local craftLabel = self:Add("DLabel")
    craftLabel:Dock(TOP)
    craftLabel:SetText(ix.crafting.stations[ply:GetNetVar("ixCraftingStation", nil):GetStationID()].name .. " Station")
    craftLabel:SetFont("ixIntroSubtitleFont")
    craftLabel:SetTextColor(color_white)
    craftLabel:SetContentAlignment(5)
    craftLabel:SizeToContents()
    craftLabel.Paint = function(s, w, h)
        surface.SetDrawColor(10, 10, 10, 230)
        surface.SetMaterial(ix.gui.gradients["up"])
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.leftPanel = self:Add("DScrollPanel")
    self.leftPanel:Dock(LEFT)
    self.leftPanel:SetWide(self:GetWide() * 0.3)
    self.leftPanel.Paint = function(s, w, h)
        surface.SetDrawColor(10, 10, 10, 230)
        surface.SetMaterial(ix.gui.gradients["left"])
        surface.DrawTexturedRect(0, 0, w, h * 2)
    end

    self.rightPanel = self:Add("DScrollPanel")
    self.rightPanel:Dock(RIGHT)
    self.rightPanel:SetWide(self:GetWide() * 0.32)
    self.rightPanel.Paint = function(s, w, h)
        surface.SetDrawColor(10, 10, 10, 230)
        surface.SetMaterial(ix.gui.gradients["right"])
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.middlePanel = self:Add("DScrollPanel")
    self.middlePanel:Dock(BOTTOM)
    self.middlePanel:SetTall(self:GetTall() * 0.3)
    self.middlePanel.Paint = function(s, w, h)
        surface.SetDrawColor(10, 10, 10, 230)
        surface.SetMaterial(ix.gui.gradients["down"])
        surface.DrawTexturedRect(0, 0, w, h)
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
    local ply = LocalPlayer()

    if not ( IsValid(ply) ) then
        self:Remove()
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        self:Remove()
    end

    self.middlePanel:Clear()

    for k, v in pairs(ix.crafting.recipes) do
        if not ( string.lower(v.category) == string.lower(category) ) then
            continue
        end

        if ( v.stations and not v.stations[ply:GetNetVar("ixCraftingStation", nil):GetStationID()] ) then
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
    local ply = LocalPlayer()

    if not ( IsValid(ply) ) then
        return self:Remove()
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return self:Remove()
    end

    self.rightPanel:Clear()

    if ( self.recipeModelTable ) then
        self.recipeModelTable:Remove()
    end

    self.recipeModelTable = ClientsideModel(recipe.model)
    self.recipeModelTable:SetPos(recipe.overview and recipe.overview["pos"](ply, ply:GetNetVar("ixCraftingStation", nil)) or ply:GetNetVar("ixCraftingStation", nil):GetPos() + ply:GetNetVar("ixCraftingStation", nil):GetUp() * 20)
    self.recipeModelTable:SetAngles(recipe.overview and recipe.overview["ang"](ply, ply:GetNetVar("ixCraftingStation", nil)) or ply:GetNetVar("ixCraftingStation", nil):GetRight():Angle() + Angle(0, 0, 90))
    self.recipeModelTable:Spawn()
    self.recipeModelTable.isFromStation = true

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
        local itemCount = char:GetInventory():GetItemCount(k)

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
end

function PANEL:Think()
    if ( input.IsKeyDown(KEY_SPACE) ) then
        self:Remove()
    end
end

function PANEL:OnRemove()
    for k, v in ipairs(ents.FindByClass("class C_BaseFlex")) do
        if not ( v.isFromStation ) then
            continue
        end

        v:Remove() 
    end

    net.Start("ix.Crafting.ClosePanel")
    net.SendToServer()
end

vgui.Register("ixCraftingMenu", PANEL, "Panel")