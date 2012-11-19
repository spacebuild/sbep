-- By Tingle

TOOL.Category		= "SBEP"
TOOL.Name			= "#Part Assembler" 
TOOL.Command 		= nil 
TOOL.ConfigName 	= ""

TOOL.ClientConVar["skin"] = 0
TOOL.ClientConVar["mode"] = 1
TOOL.ClientConVar["nocollide"] = 0

TOOL.SPR = {}
TOOL.SPE = {}

if SERVER then
	local function AddMaterials()
		local files, directories = file.Find("materials/sprites/sbep_assembler_tool/*", "GAME" )
		for k,v in pairs(files) do
			local sFile = "materials/sprites/sbep_assembler_tool/"..v
			resource.AddFile(sFile)
		end
	end
	AddMaterials()

	util.AddNetworkString( "SBEP_PA_LeftClick" )
	util.AddNetworkString( "SBEP_PA_RightClick" )
	util.AddNetworkString( "SBEP_PA_Reload" )
	util.AddNetworkString( "SBEP_PA_Holster" )

	util.AddNetworkString( "SBEP_ClSelectionRemoved" )
	util.AddNetworkString( "SBEP_ClSelected" )
	util.AddNetworkString( "SBEP_ClMerge" )
	
	function TOOL:LeftClick( trace )
		local xPlayer = self:GetOwner()
		
		net.Start( "SBEP_PA_LeftClick" )
			net.WriteInt( self:GetStage(), 2 )
		net.Send( xPlayer )
	end 
	
	function TOOL:RightClick( trace )
		local xPlayer = self:GetOwner()
		
		net.Start( "SBEP_PA_RightClick" )
			net.WriteInt( self:GetStage(), 2 )
		net.Send( xPlayer )
	end

	function TOOL:Reload( trace )
		local xPlayer = self:GetOwner()
		
		net.Start( "SBEP_PA_Reload" )
			net.WriteInt( self:GetStage(), 2 )
		net.Send( xPlayer )
		
		if( self:GetStage() == 1 ) then
			self:SetStage( 0 )
		end
	end
	
	function TOOL:Holster( wep )
		local xPlayer = self:GetOwner()
		
		self:SetStage( 0 )
		
		net.Start( "SBEP_PA_Holster" )
		net.Send( xPlayer )
	end
	
	local function SelectionRemoved( len, xPlayer )
		xPlayer:GetTool():SetStage( 0 )
	end
	net.Receive( "SBEP_ClSelectionRemoved", SelectionRemoved )
	
	
	local function Selected( len, xPlayer )
		xPlayer:GetTool():SetStage( 1 )
	end
	net.Receive( "SBEP_ClSelected", Selected )
	
	local function Merge( len, xPlayer )
		xPlayer:GetTool():SetStage( 0 )
		
		local bNoCollide = xPlayer:GetInfoNum( "sbep_part_assembler_nocollide", 0 )
		local bWeld = xPlayer:GetInfoNum( "sbep_part_assembler_weld", 0 )

		local xAEntity = net.ReadEntity()
		local vALocalPos = net.ReadVector()
		local vALocalAng = net.ReadAngle()

		local xBEntity = net.ReadEntity()
		local vBLocalPos = net.ReadVector()
		local vBLocalAng = net.ReadAngle()
		
		local vOldPos = xBEntity:GetPos()
		local vOldAng = xBEntity:GetAngles()
		
		xBEntity:SetAngles( xBEntity:AlignAngles( xBEntity:LocalToWorldAngles( vBLocalAng ), xAEntity:LocalToWorldAngles( (-vALocalAng:Forward()):Angle() ) ) )
		
		local vAPos = Vector( vALocalPos.x, vALocalPos.y, vALocalPos.z )
		vAPos:Rotate( xAEntity:GetAngles() )
		vAPos = vAPos + xAEntity:GetPos()
		
		local vBPos = Vector( vBLocalPos.x, vBLocalPos.y, vBLocalPos.z )
		vBPos:Rotate( xBEntity:GetAngles() )
		vBPos = vBPos + xBEntity:GetPos()
		
		local vDiff = vAPos - vBPos
		xBEntity:SetPos( xBEntity:GetPos() + vDiff )
		
		xAEntity:GetPhysicsObject():EnableMotion( false )
		xBEntity:GetPhysicsObject():EnableMotion( false )
		
		local function MoveUndo( Undo, xEntity, vPos , vAng )
			if( xEntity:IsValid() ) then
				xEntity:SetAngles( vAng )
				xEntity:SetPos( vPos )
			end
		end
		
		undo.Create( "SBEP Part Assembly" )
			undo.SetPlayer( xPlayer )
			undo.AddFunction( MoveUndo, xBEntity, vOldPos, vOldAng )
			if( bNoCollide == 1 ) then
				local xNoCollide = constraint.NoCollide( xAEntity, xBEntity, 0, 0 );
				undo.AddEntity( xNoCollide )
			end
			if( bWeld == 1 ) then
				local xWeld = constraint.Weld( xAEntity, xBEntity, 0, 0, 0, true )
				undo.AddEntity( xWeld )
			end
		undo.Finish()
	end
	net.Receive( "SBEP_ClMerge", Merge )
end

if CLIENT then
	CreateClientConVar("sbep_part_assembler_nocollide", 0, true, true)
	CreateClientConVar("sbep_part_assembler_weld", 0, true, true)

	language.Add( "tool.sbep_part_assembler.name" , "Part Assembly Tool" )
	language.Add( "tool.sbep_part_assembler.desc" , "Easily assemble SBEP parts. Tingle's Remake" )
	language.Add( "tool.sbep_part_assembler.0"	  , "(1) Left-click an attachment point. Right-click to show/hide attachment points. Reload to hide all attachment points."						)
	language.Add( "tool.sbep_part_assembler.1"	  , "(2) Left-click another attachement point to connect to. Right-click to show/hide attachment points. Reload to cancel." )
	language.Add( "undone_SBEP Part Assembly"	  , "Undone SBEP Part Assembly" )

	local PAD = list.Get( "SBEP_PartAssemblyData" )
	local xMaterialsInfo = {
	SWSH = { Material( "sprites/sbep_assembler_tool/SWSHblue"		) , { 42 , 30 } } ,
	SWSH_MO = { Material( "sprites/sbep_assembler_tool/SWSHblue_mo"		) , { 42 , 30 } } ,
	SWSH_S = { Material( "sprites/sbep_assembler_tool/SWSHblue_s"		) , { 42 , 30 } } ,
	SWDH = { Material( "sprites/sbep_assembler_tool/SWDHgreen"		) , { 21 , 30 } } ,
	SWDH_MO = { Material( "sprites/sbep_assembler_tool/SWDHgreen_mo"		) , { 21 , 30 } } ,
	SWDH_S = { Material( "sprites/sbep_assembler_tool/SWDHgreen_s"		) , { 21 , 30 } } ,
	DWSH = { Material( "sprites/sbep_assembler_tool/DWSHred"		) , { 42 , 15 } } ,
	DWSH_MO = { Material( "sprites/sbep_assembler_tool/DWSHred_mo"		) , { 42 , 15 } } ,
	DWSH_S = { Material( "sprites/sbep_assembler_tool/DWSHred_s"		) , { 42 , 15 } } ,
	DWDH = { Material( "sprites/sbep_assembler_tool/DWDHyellow"		) , { 42 , 30 } } ,
	DWDH_MO = { Material( "sprites/sbep_assembler_tool/DWDHyellow_mo"		) , { 42 , 30 } } ,
	DWDH_S = { Material( "sprites/sbep_assembler_tool/DWDHyellow_s"		) , { 42 , 30 } } ,

	INSR = { Material( "sprites/sbep_assembler_tool/Insert"			) , { 42 , 30 } } ,
	INSR_MO = { Material( "sprites/sbep_assembler_tool/SWSHblue_mo"		) , { 42 , 30 } } ,
	INSR_S = { Material( "sprites/sbep_assembler_tool/SWSHblue_s"		) , { 42 , 30 } } ,	

	ESML = { Material( "sprites/sbep_assembler_tool/ESML"			) , { 35 , 35 } } ,
	ESML_MO = { Material( "sprites/sbep_assembler_tool/ESML_mo"			) , { 35 , 35 } } ,
	ESML_S = { Material( "sprites/sbep_assembler_tool/ESML_s"			) , { 35 , 35 } } ,
	ELRG = { Material( "sprites/sbep_assembler_tool/ELRG"			) , { 35 , 35 } } ,
	ELRG_MO = { Material( "sprites/sbep_assembler_tool/ELRG_mo"			) , { 35 , 35 } } ,
	ELRG_S = { Material( "sprites/sbep_assembler_tool/ELRG_s"			) , { 35 , 35 } } ,
	
	LRC1 = { Material( "sprites/sbep_assembler_tool/LRC1"			) , { 42 , 30 } } ,
	LRC1_MO = { Material( "sprites/sbep_assembler_tool/LRC1_mo"			) , { 42 , 30 } } ,
	LRC1_S = { Material( "sprites/sbep_assembler_tool/LRC1_s"			) , { 42 , 30 } } ,
	LRC2 = { Material( "sprites/sbep_assembler_tool/LRC1"			) , { 42 , 30 } } ,
	LRC2_MO = { Material( "sprites/sbep_assembler_tool/LRC1_mo"			) , { 42 , 30 } } ,
	LRC2_S = { Material( "sprites/sbep_assembler_tool/LRC1_s"			) , { 42 , 30 } } ,
	LRC3 = { Material( "sprites/sbep_assembler_tool/LRC3"			) , { 42 , 30 } } ,
	LRC3_MO = { Material( "sprites/sbep_assembler_tool/LRC3_mo"			) , { 42 , 30 } } ,
	LRC3_S = { Material( "sprites/sbep_assembler_tool/LRC3_s"			) , { 42 , 30 } } ,
	LRC4 = { Material( "sprites/sbep_assembler_tool/LRC3"			) , { 42 , 30 } } ,
	LRC4_MO = { Material( "sprites/sbep_assembler_tool/LRC3_mo"			) , { 42 , 30 } } ,
	LRC4_S = { Material( "sprites/sbep_assembler_tool/LRC3_s"			) , { 42 , 30 } } ,
	LRC5 = { Material( "sprites/sbep_assembler_tool/LRC5"			) , { 21 , 30 } } ,
	LRC5_MO = { Material( "sprites/sbep_assembler_tool/LRC5_mo"			) , { 21 , 30 } } ,
	LRC5_S = { Material( "sprites/sbep_assembler_tool/LRC5_s"			) , { 21 , 30 } } ,
	LRC6 = { Material( "sprites/sbep_assembler_tool/LRC5"			) , { 21 , 30 } } ,
	LRC6_MO = { Material( "sprites/sbep_assembler_tool/LRC5_mo"			) , { 21 , 30 } } ,
	LRC6_S = { Material( "sprites/sbep_assembler_tool/LRC5_s"			) , { 21 , 30 } } ,
	
	MBSH = { Material( "sprites/sbep_assembler_tool/MBSH"			) , { 35 , 35 } } ,
	MBSH_MO = { Material( "sprites/sbep_assembler_tool/MBSH_mo"			) , { 35 , 35 } } ,
	MBSH_S = { Material( "sprites/sbep_assembler_tool/MBSH_s"			) , { 35 , 35 } } ,
		
	MOD1x1 = { Material( "sprites/sbep_assembler_tool/mod1x1"		) , { 35 , 35 } } ,
	MOD1x1_MO = { Material( "sprites/sbep_assembler_tool/mod1x1_mo"		) , { 35 , 35 } } ,
	MOD1x1_S = { Material( "sprites/sbep_assembler_tool/mod1x1_s"		) , { 35 , 35 } } ,
	MOD2x1 = { Material( "sprites/sbep_assembler_tool/mod2x1"		) , { 35 , 35 } } ,
	MOD2x1_MO = { Material( "sprites/sbep_assembler_tool/mod2x1_mo"		) , { 35 , 35 } } ,
	MOD2x1_S = { Material( "sprites/sbep_assembler_tool/mod2x1_s"		) , { 35 , 35 } } ,
	MOD3x1 = { Material( "sprites/sbep_assembler_tool/mod3x1"		) , { 35 , 35 } } ,
	MOD3x1_MO = { Material( "sprites/sbep_assembler_tool/mod3x1_mo"		) , { 35 , 35 } } ,
	MOD3x1_S = { Material( "sprites/sbep_assembler_tool/mod3x1_s"		) , { 35 , 35 } } ,
	MOD3x2 = { Material( "sprites/sbep_assembler_tool/mod3x2"		) , { 35 , 35 } } ,
	MOD3x2_MO = { Material( "sprites/sbep_assembler_tool/mod3x2_mo"		) , { 35 , 35 } } ,
	MOD3x2_S = { Material( "sprites/sbep_assembler_tool/mod3x2_s"		) , { 35 , 35 } } ,
	MOD1x1e = { Material( "sprites/sbep_assembler_tool/ESML"		) , { 35 , 35 } } ,
	MOD1x1e_MO = { Material( "sprites/sbep_assembler_tool/ESML_mo"		) , { 35 , 35 } } ,
	MOD1x1e_S = { Material( "sprites/sbep_assembler_tool/ESML_s"		) , { 35 , 35 } } ,
	MOD3x2e = { Material( "sprites/sbep_assembler_tool/ELRG"		) , { 35 , 35 } } ,
	MOD3x2e_MO = { Material( "sprites/sbep_assembler_tool/ELRG_mo"		) , { 35 , 35 } } ,
	MOD3x2e_S = { Material( "sprites/sbep_assembler_tool/ELRG_s"		) , { 35 , 35 } } }
	
	local nToolStage = 0
	local aSelectedEntities = {}
	local xFirstSelection = nil
	
	local function GetSpriteWorldPos( xSprite )
		local vPos = Vector( xSprite.vLocalPos.x, xSprite.vLocalPos.y, xSprite.vLocalPos.z )
		vPos:Rotate( xSprite.xEntity:GetAngles() )
		vPos = vPos + xSprite.xEntity:GetPos()
		
		return vPos
	end

	local function IsLookingAtSprite( xSprite )
		local vPos = GetSpriteWorldPos( xSprite )
		local vA = vPos - LocalPlayer():EyePos()
		local vB = LocalPlayer():EyeAngles():Forward() * vA:Length()
		local vC = vA - vB
		local fDist = vC:Length()

		local fWidth, fHeight = xMaterialsInfo[xSprite.sType][2][1], xMaterialsInfo[xSprite.sType][2][2]
		local fRad = math.sqrt((fWidth*fWidth)+(fHeight*fHeight)) / 2

		if( fDist < fRad ) then
			return true
		else
			return false
		end
	end
	
	local function GetClosestLookingAtSprite()
		local xClosest = nil
		local fDist = 0
		
		for i, xSprite in pairs( aSelectedEntities ) do
			if( IsLookingAtSprite( xSprite ) ) then
				local vPos = GetSpriteWorldPos( xSprite )
				local fTempDist = LocalPlayer():GetPos():Distance( vPos )
				if( fTempDist < fDist || fDist == 0 ) then
					fDist = fTempDist
					xClosest = xSprite
				end
			end
		end
		
		return xClosest
	end
	
	local function ClLeftClick( len )
		nToolStage = net.ReadInt(2)
		
		local xSprite = GetClosestLookingAtSprite()
		if( xSprite ) then
			if( !xFirstSelection ) then
				nToolStage = 1
				xSprite.bSelected = true
				xFirstSelection = xSprite
				
				net.Start("SBEP_ClSelected")
				net.SendToServer()
				
				LocalPlayer():EmitSound( "buttons/button14.wav", 100, 100 )
			else
				if( xSprite.sType == xFirstSelection.sType && xSprite.xEntity != xFirstSelection.xEntity ) then
					net.Start("SBEP_ClMerge")
						net.WriteEntity( xSprite.xEntity )
						net.WriteVector( xSprite.vLocalPos )
						net.WriteAngle( xSprite.vLocalAng )
						
						net.WriteEntity( xFirstSelection.xEntity )
						net.WriteVector( xFirstSelection.vLocalPos )
						net.WriteAngle( xFirstSelection.vLocalAng )
					net.SendToServer()
					
					nToolStage = 0
					aSelectedEntities = {}
					xFirstSelection = nil
					
					LocalPlayer():EmitSound( "buttons/button14.wav", 100, 100 )
				end
			end
		end
	end
	net.Receive("SBEP_PA_LeftClick", ClLeftClick)
	
	local function ClRightClick( len )
		nToolStage = net.ReadInt(2)
		local xEntity = LocalPlayer():GetEyeTrace().Entity
		if( !IsValid( xEntity ) ) then return end
		
		local xPADData = PAD[ string.lower( xEntity:GetModel() ) ]
		if !xPADData then return end
		
		local bSelected = false
		local bUnSelect = false
		for i in ipairs( aSelectedEntities ) do
			if( aSelectedEntities[i].xEntity == xEntity ) then
				bUnSelect = true
				if( aSelectedEntities[i].bSelected ) then
					bSelected = true
				end
			end
		end
		
		if( !bSelected ) then
			if( bUnSelect ) then
				for i in ipairs( aSelectedEntities ) do
					if( aSelectedEntities[i].xEntity == xEntity ) then
						aSelectedEntities[i] = nil
					end
				end
				
				local aCleanArray = {}
				for i, xElement in pairs( aSelectedEntities ) do
					table.insert( aCleanArray, xElement )
				end
				aSelectedEntities = aCleanArray
				
				LocalPlayer():EmitSound( "buttons/lightswitch2.wav", 100, 100 )
			else
				for i, xPointData in ipairs( xPADData ) do
					local xSprite = {}
					xSprite.xEntity = xEntity
					xSprite.sType = xPointData.type
					xSprite.vLocalPos = xPointData.pos
					xSprite.vLocalAng = xPointData.dir
					xSprite.bSelected = false
					
					table.insert( aSelectedEntities, xSprite )
					
					LocalPlayer():EmitSound( "buttons/lightswitch2.wav", 100, 100 )
				end
			end
		end
	end
	net.Receive("SBEP_PA_RightClick", ClRightClick)
	
	local function ClReload( len )
		nToolStage = net.ReadInt(2)
		if( nToolStage == 0 && next( aSelectedEntities ) != nil ) then
			aSelectedEntities = {}
			LocalPlayer():EmitSound( "buttons/lightswitch2.wav", 100, 100 )
		elseif( nToolStage == 1 && xFirstSelection ) then
			xFirstSelection = nil
			for i, xSprite in ipairs( aSelectedEntities ) do
				xSprite.bSelected = false
			end
			LocalPlayer():EmitSound( "buttons/button15.wav", 100, 100 )
		end
	end
	net.Receive("SBEP_PA_Reload", ClReload)
	
	local function ClHolster( xEntity )
		nToolStage = net.ReadInt(2)
		aSelectedEntities = {}
		xFirstSelection = nil
	end
	net.Receive("SBEP_PA_Holster", ClHolster)
	
	local function CompareSprites( a, b )
		local vAPos = GetSpriteWorldPos( a )		
		local vBPos = Vector( b.vLocalPos.x, b.vLocalPos.y, b.vLocalPos.z )
		vBPos:Rotate( b.xEntity:GetAngles() )
		vBPos = vBPos + b.xEntity:GetPos()
		
		return LocalPlayer():EyePos():Distance( vAPos ) > LocalPlayer():EyePos():Distance( vBPos )
	end
	
	local function DrawSprites()
		table.sort( aSelectedEntities, CompareSprites )
		
		local xClosestLookingAtSprite = GetClosestLookingAtSprite()
		for i, xSprite in ipairs( aSelectedEntities ) do
			local xSpriteInfo = nil
			if( !xSprite.bSelected ) then
				if( xClosestLookingAtSprite == xSprite ) then
					xSpriteInfo = xMaterialsInfo[xSprite.sType .. "_MO"]
				else
					xSpriteInfo = xMaterialsInfo[xSprite.sType]
				end
			else
				xSpriteInfo = xMaterialsInfo[xSprite.sType .. "_S"]
			end
			
			local vPos = GetSpriteWorldPos( xSprite )
			
			cam.Start3D( LocalPlayer():EyePos(), LocalPlayer():EyeAngles() )
				render.SetMaterial( xSpriteInfo[1] )
				render.DrawQuadEasy( vPos, LocalPlayer():GetAimVector() * -1, xSpriteInfo[2][1], xSpriteInfo[2][2], Color( 255 , 255, 255, 255 ), 180 ) 
			cam.End3D()
		end
	end
	hook.Add( "HUDPaint", "DrawAssemblerSprites", DrawSprites )
	
	local function OnEntityRemoved( xEntity )
		local bUnSelect = false
		for i in ipairs( aSelectedEntities ) do
			if( aSelectedEntities[i].xEntity == xEntity ) then
				if( aSelectedEntities[i].bSelected ) then
					xFirstSelection = nil
					net.Start("SBEP_ClSelectionRemoved")
					net.SendToServer()
				end
				
				aSelectedEntities[i] = nil
				bUnSelect = true
			end
		end
		
		if( bUnSelect ) then
			local aCleanArray = {}
			for i, xElement in pairs( aSelectedEntities ) do
				table.insert( aCleanArray, xElement )
			end
			aSelectedEntities = aCleanArray
		end
	end
	hook.Add( "EntityRemoved", "OnEntityRemoved", OnEntityRemoved )
	
	function TOOL.BuildCPanel( panel )
		panel:SetName( "SBEP Part Assembler" )
		panel:DockPadding(2,2,2,2)
		panel:DockMargin(2,2,2,2)
	
		local UseCheckBoxA = vgui.Create( "DCheckBoxLabel", panel )
		UseCheckBoxA:DockMargin( 5,5,5,5 )
		UseCheckBoxA:Dock(TOP)
		UseCheckBoxA:SetText( "No Collide Parts" )
		UseCheckBoxA:SetTextColor( Color( 0,0,0,255 ) )
		UseCheckBoxA:SetConVar( "sbep_part_assembler_nocollide" )
		UseCheckBoxA:SetValue( 0 )
		
		local UseCheckBoxB = vgui.Create( "DCheckBoxLabel", panel )
		UseCheckBoxB:DockMargin( 5,5,5,5 )
		UseCheckBoxB:Dock(TOP)
		UseCheckBoxB:SetText( "Weld Parts" )
		UseCheckBoxB:SetTextColor( Color( 0,0,0,255 ) )
		UseCheckBoxB:SetConVar( "sbep_part_assembler_weld" )
		UseCheckBoxB:SetValue( 0 )
	end
end