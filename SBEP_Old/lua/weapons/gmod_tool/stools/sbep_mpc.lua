TOOL.Category		= "SBEP"
TOOL.Name			= "#Mobile Platform Controller"
TOOL.Command		= nil
TOOL.ConfigName 	= ""

if CLIENT then
	language.Add( "Tool_sbep_mpc_name"	, "SBEP MPC Tool" 				)
	language.Add( "Tool_sbep_mpc_desc"	, "Create an SBEP Mobile Platform Controller." 		)
	language.Add( "Tool_sbep_mpc_0"		, "Left-click to spawn an MPC. Right-click to copy the model of whatever you're looking at, or Shift-Right-click to replace the target prop with an MPC." )
	language.Add( "undone_SBEP MPC"		, "Undone SBEP MPC"				)
	
	local function SBEPMPCModelToolNotify( um )
		GAMEMODE:AddNotify( um:ReadString() , um:ReadFloat() , 4 )
	end
	usermessage.Hook( "SBEPMPCTool_ModelNotify_cl" , SBEPMPCModelToolNotify )
end

TOOL.ClientConVar[ "model" ] = "models/SmallBridge/Panels/sbdooriris.mdl"
TOOL.ClientConVar[ "skin"  ] = 0

local MST1 = { "models/SmallBridge/Elevators,Small/sbselevp0.mdl" ,
			  "models/SmallBridge/Panels/sbdooriris.mdl" 		 ,
			  "models/props_phx/construct/metal_plate2x2.mdl" 	 ,
			  "models/props_phx/construct/metal_plate1x2.mdl" 	 ,
			  "models/props_junk/TrashDumpster02b.mdl"	}
local MST = {}

for k,v in ipairs( MST1 ) do
	if util.IsValidModel( v ) then
		table.insert( MST , v )
	end
end

if SERVER then
	function TOOL:CheckBadModel( model )
		if !util.IsValidModel( model ) then
			umsg.Start( "SBEPMPCTool_ModelNotify_cl" , RecipientFilter():AddPlayer( self:GetOwner() ) )
				umsg.String( "Invalid Model" )
				umsg.Float( 1 )
			umsg.End()
			return true
		else
			return false
		end
	end
end

function TOOL:LeftClick( tr )

	if CLIENT then return end
	local model = self:GetClientInfo( "model" )
	if self:CheckBadModel( model ) then return true end
	
	local skin  = tonumber(self:GetClientNumber( "skin" ))
	local pos   = tr.HitPos
	local ply   = self:GetOwner()

	local MPCEnt = ents.Create( "MobilePlatformController" )
		MPCEnt:SetPos( pos + Vector(0,0,50) )
		MPCEnt:Spawn()
		MPCEnt:Initialize()
		MPCEnt:Activate()
		MPCEnt:GetPhysicsObject():EnableMotion( false )
		
		MPCEnt.SPL 		= ply
		MPCEnt.PlModel 	= model
		if skin ~= 0 then
			MPCEnt.Skin = skin
		end
		
		MPCEnt.PasteDelay = false
		MPCEnt:Think()
		
		if MPCEnt.Plat and MPCEnt.Plat:IsValid() then
			MPCEnt:SetPos( pos - Vector(0,0,MPCEnt.Plat:OBBMins().z ) )
			MPCEnt.Plat:SetPos( MPCEnt:GetPos() )
		end
	
	undo.Create("SBEP MPC")
		undo.AddEntity( MPCEnt )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return true
	
end

function TOOL:RightClick( tr )

	if CLIENT then return end
	
	local ply   = self:GetOwner()
	
	if self:GetOwner():KeyDown( IN_SPEED ) then
		if !tr.Hit or !tr.Entity or !tr.Entity:IsValid() then return end

		local model = tr.Entity:GetModel()
		if self:CheckBadModel( model ) then return end
		
		local skin  = tr.Entity:GetSkin()
		local pos   = tr.Entity:GetPos()
		local ang   = tr.Entity:GetAngles()

		local MPCEnt = ents.Create( "MobilePlatformController" )
			MPCEnt:SetPos( pos )
			MPCEnt:SetAngles( ang )
			MPCEnt:Spawn()
			MPCEnt:Initialize()
			MPCEnt:Activate()
			MPCEnt:GetPhysicsObject():EnableMotion( false )
			
			MPCEnt.SPL 		= ply
			MPCEnt.PlModel 	= model
			if skin ~= 0 then
				MPCEnt.Skin = skin
			end
			MPCEnt.PasteDelay = false --I really need a better system than this...
		
		undo.Create("SBEP MPC")
			undo.AddEntity( MPCEnt )
			undo.SetPlayer( ply )
		undo.Finish()
		
		tr.Entity:Remove()
		
		return true
	else
		if ( !tr.Hit or !tr.Entity or !tr.Entity:IsValid() ) then return end
		
		local PlModel = tr.Entity:GetModel()
		local skin	  = tr.Entity:GetSkin()
		local vec	  = tr.Entity:OBBMaxs()
		
		if self:CheckBadModel( PlModel ) then return true end
		
		ply:ConCommand( "sbep_mpc_model "..PlModel )
		ply:ConCommand( "sbep_mpc_skin "..skin    )
		
		umsg.Start( "SBEPMPCTool_ModelNotify_cl" , RecipientFilter():AddPlayer( ply ) )
				umsg.String( "Copied Model!" )
				umsg.Float( 0 )
			umsg.End()

		umsg.Start("SBEP_MPCTool_Model", RecipientFilter():AddPlayer( ply ) )
			umsg.String( PlModel )
			umsg.Vector( vec )
			umsg.Char( skin )
		umsg.End()
		
		return true
	end
end

function TOOL:Reload( tr )

	if CLIENT then return end
	
	if !tr.Hit or !tr.Entity or !tr.Entity:IsValid() then return end
	local mp = tr.Entity
	local class = mp:GetClass()
	
	if string.lower( class ) == "mobileplatform" then
		if self:GetOwner():KeyDown( IN_SPEED ) then
			mp.Controller.FulX = 0
			mp.Controller.FulY = 0
			mp.Controller.FulZ = 0
		else
			local fulcrum = mp:WorldToLocal( tr.HitPos )
			
			mp.Controller.FulX = fulcrum.x
			mp.Controller.FulY = fulcrum.y
			mp.Controller.FulZ = fulcrum.z
		end
		return true
	end

end

function TOOL.BuildCPanel( panel )

	panel:SetSpacing( 10 )
	panel:SetName( "SBEP Mobile Platform Controller" )
	
	local ModelDispLabel = vgui.Create( "DLabel" )
		ModelDispLabel:SetText("Copied Model:")
	panel:AddItem( ModelDispLabel )
	
	local ModelDisp = vgui.Create( "DModelPanel" )
		ModelDisp:SetSize( 100,200 )
		ModelDisp:SetModel( "models/SmallBridge/Panels/sbdooriris.mdl" )
		ModelDisp:SetCamPos( Vector( 100, 100, 100 ) )
		ModelDisp:SetLookAt( -1 * ModelDisp:GetCamPos() )
	panel:AddItem( ModelDisp )
	
	function SBEP_MPCTool_Model( um )
	    ModelDisp:SetModel( um:ReadString() )
		ModelDisp:SetCamPos( 2.2 * um:ReadVector() )
		ModelDisp:SetLookAt( -1 * ModelDisp:GetCamPos() )
		ModelDisp.Entity:SetSkin( um:ReadChar() )
	end
	usermessage.Hook("SBEP_MPCTool_Model", SBEP_MPCTool_Model)
	
	local ModelSelect = vgui.Create( "PropSelect" )
		ModelSelect:SetConVar( "sbep_mpc_model" )
		ModelSelect.Label:SetText( "Default Models:" )
		for m,n in pairs( MST ) do
			ModelSelect:AddModel( n , {} )
		end
	panel:AddItem( ModelSelect )
	
	local HelpB = vgui.Create( "DButton" )
		HelpB.DoClick = function()
								SBEPDoc.OpenPage( "Construction" , "MPCs.txt" )
							end
		HelpB:SetText( "MPC Help Page" )
	panel:AddItem( HelpB )

end
