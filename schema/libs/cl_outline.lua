// Credits: https://github.com/ShadowBonnieRUS/garrysmod/blob/master/garrysmod/lua/includes/modules/outline.lua

ix.outline = {}
ix.outline.List = {}

local istable = istable
local render = render
local Material = Material
local CreateMaterial = CreateMaterial
local hook = hook
local cam = cam
local ScrW = ScrW
local ScrH = ScrH
local IsValid = IsValid
local surface = surface

local RenderEnt = NULL
local RenderType = 0 // 0 - Before Viewmodel, 1 - Before Effects, 2 - After Effects
local OutlineThickness = 1

local StoreTexture = render.GetScreenEffectTexture(0)
local DrawTexture = render.GetScreenEffectTexture(1)

local OutlineMatSettings = {
	["$basetexture"] = DrawTexture:GetName(),
	["$ignorez"] = 1,
	["$alphatest"] = 1
}

local CopyMat = Material("pp/copy")
local OutlineMat = CreateMaterial("outline", "UnlitGeneric", OutlineMatSettings)

function ix.outline.Add(ents, color, mode, customCheck)
	if ( #ix.outline.List >= 255 ) then
        return
    end

	if not ( istable(ents) ) then
        ents = {ents}
    end

	if ( ents[1] == nil ) then
        return
    end
	
	if (
        mode != 0 and // Both
        mode != 1 and // When it's not visible
        mode != 2 // When it's visible
	) then
        mode = 0
	end
	
	local data = {
        [1] = ents,
        [2] = color,
        [3] = mode
	}

    if ( customCheck ) then
        data[4] = customCheck
    end

	ix.outline.List[#ix.outline.List + 1] = data
end

function ix.outline.RenderedEntity()
	if not (IsValid(RenderEnt)) then
        return
    end

	return RenderEnt
end

function ix.outline.SetRenderType(render_type)
	if (
        render_type != 0 and
        render_type != 1 and
        render_type != 2
	) then
        return
	end

	local old_type = RenderType
	RenderType = render_type
	
	return old_type
end

function ix.outline.GetRenderType()
	return RenderType
end

function ix.outline.SetDoubleThickness(thickness)
	local old_thickness = OutlineThickness == 2
	OutlineThickness = thickness and 2 or 1
	
	return old_thickness
end

function ix.outline.IsDoubleThickness()
	return OutlineThickness == 2
end

local function Render()
	local scene = render.GetRenderTarget()
	render.CopyRenderTargetToTexture(StoreTexture)
	
	local w, h = ScrW(), ScrH()
	
	render.ClearStencil()
	
	render.SetStencilEnable(true)
    render.SuppressEngineLighting(true)
    
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    
    render.SetStencilCompareFunction(STENCIL_GREATER)
    render.SetStencilFailOperation(STENCIL_KEEP)
    
    cam.Start3D()
        render.SetBlend(1)
        
        for i = 1, #ix.outline.List do
            local reference = 0xFF - (i - 1)
            
            local data = ix.outline.List[i]
            local mode = data[3]
            local ents = data[1]
            local customCheck = data[4]
            
            render.SetStencilReferenceValue(reference)
            
            if ( mode == 0 or mode == 2 ) then
                if ( customCheck ) then
                    if not ( customCheck(localPlayer) ) then
                        continue
                    end
                end

                render.SetStencilZFailOperation(mode == 0 and STENCIL_REPLACE or STENCIL_KEEP)
                render.SetStencilPassOperation(STENCIL_REPLACE)
                
                for j = 1, #ents do
                    local ent = ents[j]
                    
                    if ( IsValid(ent) ) then
                        RenderEnt = ent
                        ent:DrawModel()
                    end
                end
            elseif ( mode == 1 ) then
                if ( customCheck ) then
                    if not ( customCheck(localPlayer) ) then
                        continue
                    end
                end

                render.SetStencilZFailOperation(STENCIL_REPLACE)
                render.SetStencilPassOperation(STENCIL_KEEP)
                
                for j = 1, #ents do
                    local ent = ents[j]

                    if ( IsValid(ent) ) then
                        RenderEnt = ent
                        ent:DrawModel()
                    end
                end
                
                render.SetStencilCompareFunction(STENCIL_EQUAL)
                render.SetStencilZFailOperation(STENCIL_KEEP)
                render.SetStencilPassOperation(STENCIL_ZERO)
                
                for j = 1, #ents do
                    local ent = ents[j]
                    
                    if ( IsValid(ent) ) then
                        RenderEnt = ent
                        ent:DrawModel() 
                    end
                end
                
                render.SetStencilCompareFunction(STENCIL_GREATER)
                
            end
        end
        
        RenderEnt = NULL  
        render.SetBlend(1)
    cam.End3D()
    
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilPassOperation(STENCIL_KEEP)
    
    render.Clear(0, 0, 0, 0, false, false)
    
    cam.Start2D()
        for i = 1, #ix.outline.List do
            local reference = 0xFF - (i - 1)
            
            render.SetStencilReferenceValue(reference)
            
            surface.SetDrawColor(ix.outline.List[i][2])
            surface.DrawRect(0, 0, w, h)
        end
    cam.End2D()
    
    render.SuppressEngineLighting(false)
        render.SetStencilEnable(false)
            render.CopyRenderTargetToTexture(DrawTexture)
            
            render.SetRenderTarget(scene)
            CopyMat:SetTexture("$basetexture", StoreTexture)
            render.SetMaterial(CopyMat)
            render.DrawScreenQuad()
        render.SetStencilEnable(true)
    render.SetStencilReferenceValue(0)
    
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    
    OutlineMat:SetTexture("$basetexture", DrawTexture)
    render.SetMaterial(OutlineMat)
    
    render.DrawScreenQuadEx(-OutlineThickness, -OutlineThickness, w, h)
    render.DrawScreenQuadEx(-OutlineThickness, 0, w, h)
    render.DrawScreenQuadEx(-OutlineThickness, OutlineThickness, w, h)
    render.DrawScreenQuadEx(0, -OutlineThickness, w, h)
    render.DrawScreenQuadEx(0, OutlineThickness, w, h)
    render.DrawScreenQuadEx(OutlineThickness, -OutlineThickness, w, h)
    render.DrawScreenQuadEx(OutlineThickness, 0, w, h)
    render.DrawScreenQuadEx(OutlineThickness, OutlineThickness, w, h)
    
    render.SetStencilEnable(false)
    
    render.ClearDepth()
end

local function RenderOutlines()
	hook.Run("SetupOutlines", Add)
	
	if ( #ix.outline.List == 0 ) then 
        return 
    end
	
	Render()
	
	ix.outline.List = {}
end

hook.Add("PreDrawViewModels", "RenderOutlines", function()
	if ( RenderType == 0 ) then
        RenderOutlines()
	end
end)

hook.Add("PreDrawEffects", "RenderOutlines", function()
	if ( RenderType == 1 ) then
        RenderOutlines()
	end
end)

hook.Add("PostDrawEffects", "RenderOutlines", function()
	if ( RenderType == 2 ) then
        RenderOutlines() 
	end
end)