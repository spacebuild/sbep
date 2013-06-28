TOOL.Category = "SBEP"
TOOL.Name = "#Part Spawner"
TOOL.Command = nil
TOOL.ConfigName = ""

local SmallBridgeModels = list.Get("SBEP_SmallBridgeModels")

if CLIENT then
    language.Add("Tool.sbep_part_spawner.name", "SBEP Part Spawner")
    language.Add("Tool.sbep_part_spawner.desc", "Spawn SBEP props.")
    language.Add("Tool.sbep_part_spawner.0", "Left click to spawn a prop.")
    language.Add("undone_SBEP Part", "Undone SBEP Part")
end

TOOL.ClientConVar["model"] = "models/SmallBridge/Hulls_SW/sbhulle1.mdl"
TOOL.ClientConVar["skin"] = 0
TOOL.ClientConVar["glass"] = 0
TOOL.ClientConVar["hab_mod"] = 0

function TOOL:LeftClick(trace)

    if CLIENT then return end

    local model = self:GetClientInfo("model")
    local hab = self:GetClientNumber("hab_mod")
    local skin = self:GetClientNumber("skin")
    local glass = self:GetClientNumber("glass")
    local pos = trace.HitPos

    local SMBProp = nil

    if hab == 1 then
        SMBProp = ents.Create("livable_module")
    else
        SMBProp = ents.Create("prop_physics")
    end

    SMBProp:SetModel(model)

    local skincount = SMBProp:SkinCount()
    local skinnum = nil
    if skincount > 5 then
        skinnum = skin * 2 + glass
    else
        skinnum = skin
    end
    SMBProp:SetSkin(skinnum)

    SMBProp:SetPos(pos - Vector(0, 0, SMBProp:OBBMins().z))

    SMBProp:Spawn()
    SMBProp:Activate()

    undo.Create("SBEP Part")
    undo.AddEntity(SMBProp)
    undo.SetPlayer(self:GetOwner())
    undo.Finish()

    return true
end

function TOOL:RightClick(trace)
    -- CC_GMOD_Tool(self:GetOwner(), "", { "sbep_part_assembler" })
end

function TOOL:Reload(trace)
end

function TOOL.BuildCPanel(panel)

    panel:SetSpacing(10)
    panel:SetName("SBEP Part Spawner")
	
	local SkinTable = 
	{
		"Advanced",
		"SlyBridge",
		"MedBridge2",
		"Jaanus",
		"Scrappers"
	}
	
	local SkinSelector = vgui.Create( "DComboBox", panel )
	SkinSelector:Dock(TOP)
	SkinSelector:DockMargin( 2,2,2,2 )
	SkinSelector:SetValue( SkinTable[GetConVar("sbep_part_spawner_skin"):GetInt()] or SkinTable[1] )
	SkinSelector.OnSelect = function( index, value, data )
		RunConsoleCommand( "sbep_part_spawner_skin", value )
	end
	for k,v in pairs( SkinTable ) do
		SkinSelector:AddChoice( v )
	end
	
	local GlassButton = vgui.Create( "DCheckBoxLabel", panel )
	GlassButton:Dock(TOP)
	GlassButton:DockMargin(2,2,2,2)
	GlassButton:SetValue( GetConVar( "sbep_part_spawner_glass" ):GetBool() )
	GlassButton:SetText( "Glass:" )
	GlassButton:SetConVar( "sbep_part_spawner_glass" )
	
	local HabitableModuleButton = vgui.Create("DCheckBoxLabel", panel )
	HabitableModuleButton:Dock(TOP)
	HabitableModuleButton:DockMargin(2,2,2,2)
	HabitableModuleButton:SetValue( GetConVar( "sbep_part_spawner_hab_mod" ):GetBool() )
	HabitableModuleButton:SetText( "Habitable Module:" )
	HabitableModuleButton:SetConVar( "sbep_part_spawner_hab_mod" )
	
	for Tab,v  in pairs( SmallBridgeModels ) do
		for Category, models in pairs( v ) do
			local catPanel = vgui.Create( "DCollapsibleCategory", panel )
			catPanel:Dock( TOP )
			catPanel:DockMargin(2,2,2,2)
			catPanel:SetText(Category)
			catPanel:SetLabel(Category)
			
			local grid = vgui.Create( "DGrid", catPanel )
			grid:Dock( TOP )
			--grid:SetCols( 3 )
			local width,_ = catPanel:GetSize()
			grid:SetColWide( 64 )
			grid:SetRowHeight( 64 )
			
			for key, modelpath in pairs( models ) do
				local icon = vgui.Create( "SpawnIcon", panel )
				--icon:Dock( TOP )
				icon:SetModel( modelpath )
				icon:SetToolTip( modelpath )
				icon.DoClick = function( panel )
					
					RunConsoleCommand( "sbep_part_spawner_model", modelpath )
				end
				--icon:SetIconSize( width )
				grid:AddItem( icon )
				
			end
			catPanel:SetExpanded( 0 )
		end
	end
end