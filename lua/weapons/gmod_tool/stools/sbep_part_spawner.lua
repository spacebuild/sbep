TOOL.Category		= "SBEP"
TOOL.Tab 			= "Spacebuild"
TOOL.Name = "#Part Spawner"
TOOL.Command = nil
TOOL.ConfigName = ""

local SmallBridgeModels = list.Get("SBEP_SmallBridgeModels")

if CLIENT then
    language.Add("Tool.sbep_part_spawner.name", "SBEP Part Spawner")
    language.Add("Tool.sbep_part_spawner.desc", "Spawn SBEP props.")
    language.Add("Tool.sbep_part_spawner.0", "Left click to spawn a prop. Shift + Right click to toggle between Part Spawner and Part Assembler Tool.")
    language.Add("undone_SBEP Part", "Undone SBEP Part")
end

TOOL.ClientConVar["model"] = "models/smallbridge/hulls_sw/sbhulle1.mdl"
TOOL.ClientConVar["skin"] = 0
TOOL.ClientConVar["glass"] = 0
TOOL.ClientConVar["hab_mod"] = 0
TOOL.ClientConVar["weld"] = 0
function TOOL:LeftClick(trace)

    if CLIENT then return end

    local model = self:GetClientInfo("model")
    local hab = self:GetClientNumber("hab_mod")
    local skin = self:GetClientNumber("skin")
    local glass = self:GetClientNumber("glass")
    local weld = self:GetClientNumber("weld")
    local pos = trace.HitPos

    local SMBProp = nil

    if hab == 1 then
        SMBProp = ents.Create("livable_module")
    else
        SMBProp = ents.Create("prop_physics")
    end

    SMBProp:SetModel(model)

    local skincount = SMBProp:SkinCount()
	SMBProp:SetNWInt("Skin",skinnum)
    local skinnum = nil
    if skincount > 5 then
        skinnum = skin * 2 + glass
    else
        skinnum = skin
    end

	SMBProp:SetNWInt("Skin", skinnum)

    SMBProp:SetSkin(skinnum)
    SMBProp:SetPos(pos - Vector(0, 0, SMBProp:OBBMins().z))

    SMBProp:Spawn()
    SMBProp:Activate()
	if weld == 1 and IsValid(trace.Entity) then
		constraint.Weld( SMBProp, trace.Entity, 0, trace.PhysicsBone, 0, collision == 1, false )
	end
    undo.Create("SBEP Part")
    undo.AddEntity(SMBProp)
    undo.SetPlayer(self:GetOwner())
    undo.Finish()

    return true
end


function TOOL:RightClick(trace)	
    if CLIENT then return end
    self:GetOwner():SendLua('if input.IsShiftDown() then RunConsoleCommand("gmod_tool", "sbep_part_assembler") end')
    return false
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
	GlassButton:SetTextColor(Color(0,0,0,255))
	GlassButton:SetConVar( "sbep_part_spawner_glass" )
	
	local HabitableModuleButton = vgui.Create("DCheckBoxLabel", panel )
	HabitableModuleButton:Dock(TOP)
	HabitableModuleButton:DockMargin(2,2,2,2)
	HabitableModuleButton:SetValue( GetConVar( "sbep_part_spawner_hab_mod" ):GetBool() )
	HabitableModuleButton:SetText( "Habitable Module:" )
	HabitableModuleButton:SetTextColor(Color(0,0,0,255))
	HabitableModuleButton:SetConVar( "sbep_part_spawner_hab_mod" )
	
	local WeldButton = vgui.Create("DCheckBoxLabel", panel )
	WeldButton:Dock(TOP)
	WeldButton:DockMargin(2,2,2,2)
	WeldButton:SetValue( GetConVar( "sbep_part_spawner_weld" ):GetBool() )
	WeldButton:SetText( "Weld:" )
	WeldButton:SetTextColor(Color(0,0,0,255))
	WeldButton:SetConVar( "sbep_part_spawner_weld" )
	
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


function TOOL:Think()
 	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != self:GetClientInfo( "model" ) ) then
		self:MakeGhostEntity( self:GetClientInfo( "model"), Vector( 0, 0, 0 ), Angle( 0, 0, 0 )) 
	end
	
	self:UpdateGhostPart( self.GhostEntity, self:GetOwner())

 end
function TOOL:UpdateGhostPart( ent, pl )

	if CLIENT then return end
	if ( !IsValid( ent ) ) then return end

	local tr = util.GetPlayerTrace( pl )
	local trace	= util.TraceLine( tr )
	if ( !trace.Hit ) then return end

	if ( trace.Entity:IsPlayer()) then

		ent:SetNoDraw( true )
		return

	end

	local CurPos = ent:GetPos()
	local NearestPoint = ent:NearestPoint( CurPos - ( trace.HitNormal * 512 ) )
	local Offset = CurPos - NearestPoint

	
	ent:SetPos( trace.HitPos + Offset )

	ent:SetNoDraw( false )

end