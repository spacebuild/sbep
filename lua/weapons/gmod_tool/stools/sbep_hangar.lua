TOOL.Category		= "SBEP"
TOOL.Name			= "#Hangar"
TOOL.Command		= nil
TOOL.ConfigName 	= ""

local ModelSelectTable = list.Get( "SBEP_HangarModels" )

if CLIENT then
	language.Add( "Tool_sbep_hangar_name"	, "SBEP Hangar Tool" 				)
	language.Add( "Tool_sbep_hangar_desc"	, "Create an SBEP Hangar."			)
	language.Add( "Tool_sbep_hangar_0"	, "Left click to spawn a hangar." 		)
	language.Add( "undone_SBEP Hangar"	, "Undone SBEP Hangar"					)
end

local CategoryTable = {
			{ "MedBridge"		, "MedBridge"		, "models/Slyfo/hangar_singleside.mdl" 				} ,
			{ "SmallBridge" 	, "SmallBridge"		, "models/SmallBridge/Station Parts/SBdockCs.mdl" 	}
					}
for k,v in ipairs( CategoryTable ) do
	TOOL.ClientConVar[ "model_"..tostring(k) ] = v[3]
end
TOOL.ClientConVar[ "activecat"  ] = 1

function TOOL:LeftClick( trace )

	if CLIENT then return end
	local model = self:GetClientInfo( "model_"..tostring( self:GetClientNumber( "activecat" ) ) )
	local DataTable = table.Copy( ModelSelectTable[ model ]	)
	local pos = trace.HitPos
	
	local HangarEnt = ents.Create( "sbep_base_hangar" )
		HangarEnt.HangarName = DataTable[1]
		HangarEnt.Bay 		 = table.Copy(DataTable[3])
		HangarEnt:SetModel( model )

		HangarEnt:Spawn()
		HangarEnt:Activate()
		
		HangarEnt:SetPos( pos - Vector(0,0,HangarEnt:OBBMins().z) )
	
	undo.Create("SBEP Hangar")
		undo.AddEntity( HangarEnt )
		undo.SetPlayer( self:GetOwner() )
	undo.Finish()

end

function TOOL:RightClick( trace )

end

function TOOL:Reload( trace )

end

function TOOL.BuildCPanel( panel )

		panel:SetSpacing( 10 )
		panel:SetName( "SBEP Hangar" )

	local ModelCollapsibleCategories = {}
	
	for k,v in pairs(CategoryTable) do
		ModelCollapsibleCategories[k] = {}
			ModelCollapsibleCategories[k][1] = vgui.Create("DCollapsibleCategory")
			ModelCollapsibleCategories[k][1]:SetExpanded( false )
			ModelCollapsibleCategories[k][1]:SetLabel( v[1] )
		panel:AddItem( ModelCollapsibleCategories[k][1] )
	 
		ModelCollapsibleCategories[k][2] = vgui.Create( "DPanelList" )
			ModelCollapsibleCategories[k][2]:SetAutoSize( true )
			ModelCollapsibleCategories[k][2]:SetSpacing( 5 )
			ModelCollapsibleCategories[k][2]:EnableHorizontal( false )
			ModelCollapsibleCategories[k][2]:EnableVerticalScrollbar( false )
		ModelCollapsibleCategories[k][1]:SetContents( ModelCollapsibleCategories[k][2] )

		ModelCollapsibleCategories[k][3] = vgui.Create( "PropSelect" )
			ModelCollapsibleCategories[k][3]:SetConVar( "sbep_hangar_model_"..tostring(k) )
			ModelCollapsibleCategories[k][3].Label:SetText( "Model:" )
			for m,n in pairs( ModelSelectTable ) do
				if n[2] == v[2] then
					ModelCollapsibleCategories[k][3]:AddModel( m , {} )
				end
			end
		ModelCollapsibleCategories[k][2]:AddItem( ModelCollapsibleCategories[k][3] )
	end
	ModelCollapsibleCategories[1][1]:SetExpanded( true )
	RunConsoleCommand( "sbep_hangar_activecat", 1 )
	
	for k,v in pairs( ModelCollapsibleCategories ) do
		v[1].Header.OnMousePressed = function()
									for m,n in pairs(ModelCollapsibleCategories) do
										if n[1]:GetExpanded() then
											n[1]:Toggle()
										end
									end
									if !v[1]:GetExpanded() then
										v[1]:Toggle()
									end
									RunConsoleCommand( "sbep_hangar_activecat", k )
							end
	end

end