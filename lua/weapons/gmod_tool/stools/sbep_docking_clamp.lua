TOOL.Category		= "SBEP"
TOOL.Tab 			= "Spacebuild"
TOOL.Name			= "#Docking Clamp"
TOOL.Command		= nil
TOOL.ConfigName 	= ""

local DockingClampModels = list.Get( "SBEP_DockingClampModels" )
local DockClampToolModels = list.Get( "SBEP_DockClampToolModels" )

if CLIENT then
	language.Add( "Tool.sbep_docking_clamp.name"	, "SBEP Docking Clamp Tool" 						)
	language.Add( "Tool.sbep_docking_clamp.desc"	, "Create an SBEP docking clamp."					)
	language.Add( "Tool.sbep_docking_clamp.0"		, "Left-click to spawn a docking clamp, or right-click an existing clamp to spawn a counterpart."	)
	language.Add( "undone_SBEP Docking Clamp"		, "Undone SBEP Docking Clamp"						)
end

local CategoryTable = {}
CategoryTable[1] = {
	{ name = "Doors"			, cat = "Door"	 	} ,
	{ name = "MedBridge"	 	, cat = "MedBridge"	} ,
	{ name = "ElevatorSmall" 	, cat = "ElevatorSmall"	} ,
	{ name = "PHX"				, cat = "PHX"	} ,
					}

TOOL.ClientConVar[ "model" 		] = "models/smallbridge/panels/sbpaneldockin.mdl"
TOOL.ClientConVar[ "allowuse"   ] = 1

if ( SERVER ) then

	function MakeDockingClamp( Player, Data )

		local DockEnt = ents.Create( "sbep_base_docking_clamp" )
		duplicator.DoGeneric( DockEnt, Data )
		DockEnt:Spawn()

		duplicator.DoGenericPhysics( DockEnt, Player, Data )

		return DockEnt

	end

	duplicator.RegisterEntityClass( "sbep_base_docking_clamp", MakeDockingClamp, "Data" )
	
end

function TOOL:LeftClick( tr )

	if CLIENT then return end
	local ply = self:GetOwner()
	local model = ply:GetInfo( "sbep_docking_clamp_model" )
	local Data = DockingClampModels[ string.lower( model ) ]
	
	local pos = tr.HitPos
	
	local DockEnt = ents.Create( "sbep_base_docking_clamp" )	
		DockEnt.SPL = self:GetOwner()
		DockEnt:SetModel( model )
		DockEnt:SetDockType( Data.ALType )
	DockEnt:Spawn()
	DockEnt:Initialize()
	DockEnt:Activate()
		
	for n,P in pairs( Data.EfPoints ) do
		DockEnt:SetNetworkedVector("EfVec"..n, P.vec)
		DockEnt:SetNetworkedInt("EfSp"..n, P.sp)
	end
	
	DockEnt:SetPos( pos - Vector(0,0,DockEnt:OBBMins().z) )
	DockEnt.Usable = ply:GetInfoNum( "sbep_docking_clamp_allowuse", 1 ) == 1
	
	DockEnt:AddDockDoor()
	
	undo.Create("SBEP Docking Clamp")
		undo.AddEntity( DockEnt )
		if DockEnt.Doors then
			for _,door in ipairs( DockEnt.Doors ) do
				undo.AddEntity( door )
			end
		end
		undo.SetPlayer( ply )
	undo.Finish()

	return true
end

function TOOL:RightClick( tr )

	if CLIENT then return end
	if !tr.Hit or !tr.Entity or !tr.Entity:IsValid() then return end
	local dock = tr.Entity
	local class = dock:GetClass()
	
	if class == "sbep_base_docking_clamp" then
		local type = dock.ALType
		for model,data in pairs( DockingClampModels ) do
			local check = false
			for i,T in ipairs( data.Compatible ) do
				if type == T.Type then
					check = i
					break
				end
			end
			if check then
				local pos = dock:GetPos()
				local ang = dock:GetAngles()
				
				local DockEnt = ents.Create( "sbep_base_docking_clamp" )	
					DockEnt.SPL = self:GetOwner()
					DockEnt:SetModel( model )
					DockEnt:SetDockType( data.ALType )
					DockEnt.Usable = dock.Usable
				DockEnt:Spawn()
				DockEnt:Initialize()
				DockEnt:Activate()
					
				for n,P in pairs( data.EfPoints ) do
					DockEnt:SetNetworkedVector("EfVec"..n, P.vec)
					DockEnt:SetNetworkedInt("EfSp"..n, P.sp)
				end
				
				DockEnt:SetPos( Vector(0,-50,100) + pos - Vector(0,0,DockEnt:OBBMins().z) )
				DockEnt:SetAngles( ang + Angle( 0, data.Compatible[ check ].AYaw or 0, 0 ) )
				
				DockEnt:AddDockDoor()
				
				dock.DMode = 2
				DockEnt.DMode = 2
				
				undo.Create("SBEP Docking Clamp")
					undo.AddEntity( DockEnt )
					if DockEnt.Doors then
						for _,door in ipairs( DockEnt.Doors ) do
							undo.AddEntity( door )
						end
					end
					undo.SetPlayer( self:GetOwner() )
				undo.Finish()
				
				return true
			end
		end
	else
		return
	end
end

function TOOL:Reload( trace )

end

function TOOL.BuildCPanel( panel )
	panel:SetSpacing( 10 )
	panel:SetName( "SBEP Docking Clamp" )

	local UseCheckBox = vgui.Create( "DCheckBoxLabel", panel )
	UseCheckBox:Dock(TOP)
	UseCheckBox:SetText( "Enable Use Key:" )
	UseCheckBox:SetTextColor(Color(0,0,0,255))
	UseCheckBox:SetConVar( "sbep_docking_clamp_allowuse" )
	UseCheckBox:SetValue( GetConVar( "sbep_docking_clamp_allowuse" ):GetBool()  )

	for Tab,v in pairs( DockClampToolModels ) do
		for Category, models in pairs( v ) do
			local catPanel = vgui.Create( "DCollapsibleCategory", panel )
			catPanel:Dock( TOP )
			catPanel:DockMargin(2,2,2,2)
			catPanel:SetText(Category)
			catPanel:SetLabel(Category)
			
			local grid = vgui.Create( "DGrid", catPanel )
			grid:Dock( TOP )
			
			local width,_ = catPanel:GetSize()
			grid:SetColWide( 64 )
			grid:SetRowHeight( 64 )
			
			for key, modelpath in pairs( models ) do
				local icon = vgui.Create( "SpawnIcon", panel )
				--icon:Dock( TOP )
				icon:SetModel( modelpath )
				icon:SetToolTip( modelpath )
				icon.DoClick = function( panel )
					RunConsoleCommand( "sbep_docking_clamp_model", modelpath )
				end
				--icon:SetIconSize( width )
				grid:AddItem( icon )
				
			end
			catPanel:SetExpanded( 0 )
		end
	end

	--[[local MCPS = vgui.Create( "MCPropSelect" )
		MCPS:SetConVar( "sbep_docking_clamp_model" )
		for Cat,mt in pairs( MTT ) do
			MCPS:AddMCategory( Cat , mt )
		end
	MCPS:SetCategory( 3 )
	panel:AddItem( MCPS ) ]]
	
end
