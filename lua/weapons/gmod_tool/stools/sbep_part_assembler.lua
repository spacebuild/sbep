TOOL.Category		= "SBEP"
TOOL.Name			= "#Part Assembler" 
TOOL.Command 		= nil 
TOOL.ConfigName 	= ""

TOOL.ClientConVar[ "skin"  	] = 0
TOOL.SPR = {}
TOOL.SPE = {}

local PAD = list.Get( "SBEP_PartAssemblyData" )

local SPD = {
	SWSH = "SWSH" ,
	SWDH = "SWDH" ,
	DWSH = "DWSH" ,
	DWDH = "DWDH" ,
	
	ESML = "ESML" ,
	ELRG = "ELRG" ,

	INSR = "INSR" ,
	
	LRC1 = "LRC2" ,
	LRC2 = "LRC1" ,
	LRC3 = "LRC4" ,
	LRC4 = "LRC3" ,
	LRC5 = "LRC6" ,
	LRC6 = "LRC5" ,
	
	MBSH = "MBSH" ,
		
	MOD1x1 = "MOD1x1" ,
	MOD2x1 = "MOD2x1" ,
	MOD3x1 = "MOD3x1" ,
	MOD3x2 = "MOD3x2" ,
	MOD1x1e = "MOD1x1e" ,
	MOD3x2e = "MOD3x2e" ,
			}

if CLIENT then
	language.Add( "Tool.sbep_part_assembler.name" , "SBEP Part Assembly Tool" 								)
	language.Add( "Tool.sbep_part_assembler.desc" , "Easily assemble SBEP parts." 							)
	language.Add( "Tool.sbep_part_assembler.0"	  , "Left-click an attachment point."						)
	language.Add( "Tool.sbep_part_assembler.1"	  , "Left-click another attachement point to connect to."	)
	language.Add( "Tool.sbep_part_assembler.2"	  , "Right-click to rotate, and left click to finish."		)
	language.Add( "undone_SBEP Part Assembly"	  , "Undone SBEP Part Assembly"								)
end

TOOL.ClientConVar[ 	 "mode" 	] = 1
TOOL.ClientConVar[  "nocollide" ] = 0

function TOOL:LeftClick( trace ) 

	if CLIENT then return end

	local ply = self:GetOwner()

	if self:GetStage() == 2 then
		
		self.E1.SEO:SetColor(Color( 255,255,255,255 ))

		local weld = constraint.Weld( self.E1.SEO , self.E2.SEO , 0 , 0 , 0 , self:ShouldNoCollide() )	
		
		undo.Create( "SBEP Part Assembly Weld" )
			undo.AddEntity( weld )
			undo.SetPlayer( ply )
		undo.Finish()
		
		-- Entity 1
		self.E1:Remove()
		self.E1 = nil

		-- Entity 2
		self.E2:Remove()
		self.E2 = nil
		
		self:SetStage( 0 )
		return true
	end
	
	local ent = trace.Entity
	if !ent or !ent:IsValid() or ent:GetClass() ~= "sbep_base_sprite" then return end
	
	if CPPI then
        if !ent:CPPICanTool(ply,"constraint") then return end
    end
	
	if self.E1 and self.E1:IsValid() and self:GetStage() == 1 then
		if self.E1:GetSpriteType() ~= SPD[ ent:GetSpriteType() ] then return end
		
		local pos = self.E1.SEO:GetPos()
		local ang = self.E1.SEO:GetAngles()
		
		self.E2 = ent
			local E1 = self.E1
			local E2 = self.E2
		local ENTS = { E1 , E2 , E1.SEO , E2.SEO }
		for k,v in ipairs( ENTS ) do
			v:GetPhysicsObject():EnableMotion( false )
		end
		
		E1.Following = false
		E1:SetPos( E2:GetPos() )
		E1:SetAngles( E2:LocalToWorldAngles( Angle(0,180,0) ) )
		
		local EO = Vector( E1.Offset.x , E1.Offset.y , E1.Offset.z )
		EO:Rotate( -1 * E1.Dir )
		E1.SEO:SetPos( E1:LocalToWorld( -1 * EO ) )
		E1.SEO:SetAngles( E1:LocalToWorldAngles( -1 * E1.Dir ) )
		
		if E1.RotMode then
			E1:SetNoDraw( true )
			E2:SetNoDraw( true )
			E1.SEO:SetColor(Color( 255,255,255,180 ))
			self:SetStage( 2 )
		else
			local function MoveUndo( Undo, Entity, pos , ang )
				if Entity:IsValid() then
					Entity:SetAngles( ang )
					Entity:SetPos( pos )
				end
			end
			
			undo.Create( "SBEP Part Assembly Move" )
				undo.AddEntity( weld )
				undo.SetPlayer( self:GetOwner() )
				undo.AddFunction( MoveUndo, self.E1.SEO , pos , ang )
			undo.Finish()

			if ply:GetInfoNum( "sbep_part_assembler_mode", 1 ) == 2 then
				local weld = constraint.Weld( E1.SEO , E2.SEO , 0 , 0 , 0 , self:ShouldNoCollide() )
				undo.Create( "SBEP Part Assembly Weld" )
					undo.AddEntity( weld )
					undo.SetPlayer( self:GetOwner() )
				undo.Finish()
			elseif self:ShouldNoCollide() then
				local nocollide = constraint.NoCollide( E1.SEO , E2.SEO , 0 , 0 )
				undo.Create( "SBEP Part Assembly NoCollide" )
					undo.AddEntity( nocollide )
					undo.SetPlayer( self:GetOwner() )
				undo.Finish()
			end
			
			E1:Remove()
				self.E1 = nil
			E2:Remove()
				self.E2 = nil
			self:SetStage( 0 )
		end
		return true
	elseif self:GetStage() == 0 then
		self.E1 = ent
		self:SetStage( 1 )
		return true
	end
end 

function TOOL:RightClick( trace ) 
	if CLIENT then return end
	if self:GetStage() == 2 then
		self.E1:SetAngles( self.E1:GetAngles() + Angle(0,0,90) )
		self.E1.SEO:SetAngles( self.E1:LocalToWorldAngles( -1 * self.E1.Dir ) )
		return true
	elseif self:GetStage() == 0 then
		CC_GMOD_Tool(self:GetOwner(),"",{"sbep_part_spawner"})
	end
end

function TOOL:Reload( trace ) 
	if CLIENT then return end
	self.E1 = nil
	self.E2 = nil
	self:SetStage(0)
	return true
end

function TOOL:ShouldNoCollide()
	if SERVER then
		return self:GetOwner():GetInfoNum( "sbep_part_assembler_nocollide", 0 ) == 1
	end
end

if SERVER then
	function TOOL:Think()
		local ply = self:GetOwner()
		local trace = ply:GetEyeTrace()
		if !trace.Hit or trace.HitWorld or trace.HitSky then return end
		
		local ent = trace.Entity
		if !ent or !ent:IsValid() then return end
		
		if CPPI then
			if !ent:CPPICanTool(ply,"constraint") then return end
		end
		
		local model = string.lower( ent:GetModel() )
		local data = PAD[ model ]
		if !data then return end

		if ent.SPR then return end

		if !ent.SPR then ent.SPR = {} end
		for k,v in ipairs( data ) do
			if ent:GetClass() == "sbep_elev_housing" and (v.type == "ESML" or v.type == "ELRG") then break end
			local sprite = ents.Create( "sbep_base_sprite" )
			sprite:Spawn()
			
			if (CPPI) then
                sprite:CPPISetOwner(ply)
            end
			
			sprite:SetSpriteType( v.type )
			sprite.Offset = v.pos
			sprite.Dir = v.dir
			sprite.SEO = ent
			sprite.Following = true

			ent:DeleteOnRemove( sprite )
			table.insert( ent.SPR , sprite )
			table.insert( self.SPR , sprite )
			table.insert( self.SPE , ent )
		end
	end
	
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	function TOOL:Holster( wep )
		if self.SPR then
			for k,v in pairs( self.SPR ) do
				if v and v:IsValid() then
					v:Remove()
				end
			end
		end
		
		if self.SPE then
			for k,v in pairs( self.SPE ) do
				if v.SPR then
					v.SPR = nil
				end
			end
		end
		
		self.E1 = nil
		self.E2 = nil
		
		self:SetStage(0)
		
		return true
	end
end

function TOOL.BuildCPanel( panel )
	panel:SetName( "SBEP Part Assembler" )
	panel:DockPadding(2,2,2,2)
	panel:DockMargin(2,2,2,2)
	local ModeTable =
	{
		"1. Move first part to second",
		"2. Move first part to second and weld"   		
	}

	local ModeSelect = vgui.Create("DComboBox", panel )
	ModeSelect:Dock(TOP)
	ModeSelect:DockMargin( 5,5,5,5 )
	ModeSelect:SetValue( ModeTable[GetConVar("sbep_part_assembler_mode"):GetInt()] or ModeTable[1] )
	ModeSelect.OnSelect = function ( index, value, data )
		RunConsoleCommand( "sbep_part_assembler_mode", value )
	end
	
	for k,v in ipairs( ModeTable ) do 
		ModeSelect:AddChoice( v )
	end
	
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local UseCheckBox = vgui.Create( "DCheckBoxLabel", panel )
	UseCheckBox:DockMargin( 5,5,5,5 )
	UseCheckBox:Dock(TOP)
	UseCheckBox:SetText( "NoCollide Parts" )
	UseCheckBox:SetConVar( "sbep_part_assembler_nocollide" )
	UseCheckBox:SetValue( 0 )
	
	local HelpB = vgui.Create( "DButton", panel )
	HelpB:Dock( TOP )
	HelpB:DockMargin( 5,5,5,5 )
	HelpB.DoClick = function()
		SBEPDoc.OpenPage( "Construction" , "Part Assembler.txt" )
	end
		
	HelpB:SetText( "Part Assembler Help Page" )
	
 end  