TOOL.Category		= "SBEP"
TOOL.Name			= "#Part Spawner"
TOOL.Command		= nil
TOOL.ConfigName 	= ""

local SMBMST = list.Get( "SBEP_SmallBridgeModels" )

if CLIENT then
	language.Add( "Tool_sbep_part_spawner_name"	, "SBEP Part Spawner" 			)
	language.Add( "Tool_sbep_part_spawner_desc"	, "Spawn SBEP props." 			)
	language.Add( "Tool_sbep_part_spawner_0"	, "Left click to spawn a prop." )
	language.Add( "undone_SBEP Part"			, "Undone SBEP Part"			)
end

TOOL.ClientConVar[ "model" 		] = "models/SmallBridge/Hulls,SW/sbhulle1.mdl" 
TOOL.ClientConVar[ "skin"  		] = 0
TOOL.ClientConVar[ "glass"  	] = 0
TOOL.ClientConVar[ "hab_mod"	] = 0

function TOOL:LeftClick( trace )

	if CLIENT then return end

	local model 	= self:GetClientInfo( "model" )
	local hab 		= self:GetClientNumber( "hab_mod" )
	local skin 		= self:GetClientNumber( "skin" )
	local glass 	= self:GetClientNumber( "glass" )
	local pos 		= trace.HitPos
	
	local SMBProp = nil
	
	if hab == 1 then
		SMBProp = ents.Create( "base_livable_module" )
	else
		SMBProp = ents.Create( "prop_physics" )
	end
	
	SMBProp:SetModel( model )

	local skincount = SMBProp:SkinCount()
	local skinnum	= nil
	if skincount > 5 then
		skinnum	= skin * 2 + glass
	else
		skinnum = skin
	end
	SMBProp:SetSkin( skinnum )
			
	SMBProp:SetPos( pos - Vector(0,0,SMBProp:OBBMins().z ) )
	
	SMBProp:Spawn()
	SMBProp:Activate()
	
	undo.Create("SBEP Part")
		undo.AddEntity( SMBProp )
		undo.SetPlayer( self:GetOwner() )
	undo.Finish()

	return true
end

function TOOL:RightClick( trace )
	CC_GMOD_Tool(self:GetOwner(),"",{"sbep_part_assembler"})
end

function TOOL:Reload( trace )

end

function TOOL.BuildCPanel( panel )

		panel:SetSpacing( 10 )
		panel:SetName( "SBEP Part Spawner" )

	local PropertySheet = vgui.Create( "DPropertySheet" )
		PropertySheet:SetSize( 50, 660 )
	panel:AddItem( PropertySheet )
	
	for Tab,cl in pairs( SMBMST ) do
		local MCPS = vgui.Create( "MCPropSelect" )
			MCPS:SetConVar( "sbep_part_spawner_model" )
		
		local SkinMenu = vgui.Create("DButton")
			SkinMenu:SetText( "Skin" )
			SkinMenu:SetSize( 100, 20 )

		local SkinTable = {
				"Scrappers"  ,
				"Advanced"   ,
				"SlyBridge"  ,
				"MedBridge2" ,
				"Jaanus"
					}

		SkinMenu.DoClick = function ( btn )
				local SkinMenuOptions = DermaMenu()
				for i = 1, #SkinTable do
					SkinMenuOptions:AddOption( SkinTable[i] , function() RunConsoleCommand( "sbep_part_spawner_skin", (i - 1) ) end )
				end
				SkinMenuOptions:Open()
							end
		MCPS:AddItem( SkinMenu )
		
		local GlassCheckBox = vgui.Create( "DCheckBoxLabel" )
			GlassCheckBox:SetText( "Glass" )
			GlassCheckBox:SetConVar( "sbep_part_spawner_glass" )
			GlassCheckBox:SetValue( 0 )
			GlassCheckBox:SizeToContents()
		MCPS:AddItem( GlassCheckBox )
	
		if CAF and CAF.GetAddon("Spacebuild") and CAF.GetAddon("Spacebuild").GetStatus() then
			local HabCheckBox = vgui.Create( "DCheckBoxLabel" )
				HabCheckBox:SetText( "Habitable Module" )
				HabCheckBox:SetConVar( "sbep_part_spawner_hab_mod" )
				HabCheckBox:SetValue( 0 )
				HabCheckBox:SizeToContents()
			MCPS:AddItem( HabCheckBox )
		end
		
		for Cat,mt in pairs( cl ) do
			MCPS:AddMCategory( Cat , mt )
		end
		MCPS:SetCategory( 8 )
		
		PropertySheet:AddSheet( Tab , MCPS 	, "gui/silkicons/plugin"	, false , false , "SmallBridge" )
	end

end