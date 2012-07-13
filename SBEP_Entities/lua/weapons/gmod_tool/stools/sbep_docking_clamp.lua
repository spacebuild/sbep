TOOL.Category		= "SBEP"
TOOL.Name			= "#Docking Clamp"
TOOL.Command		= nil
TOOL.ConfigName 	= ""

local MST = list.Get( "SBEP_DockingClampModels" )
local MTT = list.Get( "SBEP_DockClampToolModels" )

if CLIENT then
	language.Add( "Tool_sbep_docking_clamp_name"	, "SBEP Docking Clamp Tool" 						)
	language.Add( "Tool_sbep_docking_clamp_desc"	, "Create an SBEP docking clamp."					)
	language.Add( "Tool_sbep_docking_clamp_0"		, "Left-click to spawn a docking clamp, or right-click an existing clamp to spawn a counterpart."	)
	language.Add( "undone_SBEP Docking Clamp"		, "Undone SBEP Docking Clamp"						)
end

TOOL.ClientConVar[ "model" 		] = "models/smallbridge/panels/sbpaneldockin.mdl"
TOOL.ClientConVar[ "allowuse"   ] = 1

function TOOL:LeftClick( tr )

	if CLIENT then return end
	local ply = self:GetOwner()
	local model = ply:GetInfo( "sbep_docking_clamp_model" )
	local Data = MST[ string.lower( model ) ]
	
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
	DockEnt.Usable = ply:GetInfoNum( "sbep_docking_clamp_allowuse" ) == 1
	
	DockEnt:AddDockDoor()
	
	undo.Create("SBEP Docking Clamp")
		undo.AddEntity( DockEnt )
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
		for model,data in pairs( MST ) do
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
				DockEnt:SetAngles( ang + Angle( 0, data.Compatible[ check ].AYaw , 0 ) )
				
				DockEnt:AddDockDoor()
				
				dock.DMode = 2
				DockEnt.DMode = 2
				
				undo.Create("SBEP Docking Clamp")
					undo.AddEntity( DockEnt )
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

	local MCPS = vgui.Create( "MCPropSelect" )
		MCPS:SetConVar( "sbep_docking_clamp_model" )
		for Cat,mt in pairs( MTT ) do
			MCPS:AddMCategory( Cat , mt )
		end
	MCPS:SetCategory( 3 )
	panel:AddItem( MCPS )
	
	local UseCheckBox = vgui.Create( "DCheckBoxLabel" )
		UseCheckBox:SetText( "Enable Use Key" )
		UseCheckBox:SetConVar( "sbep_docking_clamp_allowuse" )
		UseCheckBox:SetValue( 1 )
		UseCheckBox:SizeToContents()
	panel:AddItem( UseCheckBox )
	
	local HelpB = vgui.Create( "DButton" )
		HelpB.DoClick = function()
								SBEPDoc.OpenPage( "Construction" , "Docking Clamps.txt" )
							end
		HelpB:SetText( "Docking Clamps Help Page" )
	panel:AddItem( HelpB )

end