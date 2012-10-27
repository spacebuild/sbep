TOOL.Category		= "SBEP"
TOOL.Name			= "#Gyro-Pod"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ent = {}
TOOL.LT  = {}

-- Add Default Language translation (saves adding it to the txt files)
if ( CLIENT ) then

	language.Add( "Tool_gpod_name", "Gyro-Pod" )
	language.Add( "Tool_gpod_desc", "Make stuff fly." )
	language.Add( "Tool_gpod_0", "Right-Click to spawn the gyro, left click a prop followed by a gyro to link the two. The last vehicle linked to the gyro will control its motion.\nConnect the Gyro to every prop in the ship it's meant to control. The turning speed can be fine-tuned using wire-inputs on the gyro." )
	language.Add( "Tool_gpod_1", "Select all other props to be linked, then click a Gyro-Pod to link them." )
	
	language.Add( "Tool_turret_type", "Type of weapon" )
	
end

function TOOL:LeftClick( trace )

if ( !trace.Hit ) then return end
	
	--if ( SERVER and !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	--if (CLIENT) then return true end
	
	if (!trace.Entity.GPod) and (trace.Entity:IsValid()) then
		if trace.Entity:IsVehicle() then
			if self.LP then
				self.LP:SetColor( Color(255 , 255 , 255 , 255 ))
			end
			self.LP = trace.Entity
			trace.Entity:SetColor(Color( 0 , 0 , 255 , 255 ))
		else
			table.insert( self.LT , trace.Entity )
			trace.Entity:SetColor(Color( 255 , 0 , 0 , 255 ))
		end

		self:SetStage(1)
		return true
	elseif (self:GetStage() == 1) and (trace.Entity.GPod) and (trace.Entity:IsValid()) then
		for n,E in ipairs( self.LT ) do
			trace.Entity:Link( E )
			E:SetColor(Color( 255 , 255 , 255 , 255 ))
		end
		self.LT = {}
		
		if self.LP then
			trace.Entity:Link( self.LP )
			self.LP:SetColor(Color( 255 , 255 , 255 , 255 ))
		end
		self.LP = nil
		
		self:SetStage(0)
		return true
	else
		return false
	end
	
	return true
end

function TOOL:RightClick( trace )
	
if !trace.Hit or self:GetStage() == 1 then return end
	
	if ( SERVER and !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	if (CLIENT) then return true end
		
	local SpawnPos = trace.HitPos + trace.HitNormal * 20
	
	local ply = self:GetOwner()
	
	local ent = ents.Create( "GyroPod2" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	undo.Create("Gyro-Pod")
		undo.AddEntity( ent )
		undo.SetPlayer( ply )
	undo.Finish()
	return true

end

function TOOL:Reload(trace)

end

function TOOL:Holster( wep )
	self:SetStage(0)
	
	for n,E in ipairs( self.LT ) do
		E:SetColor(Color( 255 , 255 , 255 , 255 ))
	end
	self.LT = {}
	
	if self.LP then
		self.LP:SetColor(Color( 255 , 255 , 255 , 255 ))
	end
	self.LP = nil
end

function TOOL.BuildCPanel( panel )

	panel:SetSpacing( 10 )
	panel:SetName( "SBEP Gyro-Pod" )
	
	local HelpB = vgui.Create( "DButton" )
		HelpB.DoClick = function()
								SBEPDoc.OpenPage( "Construction" , "Gyro-Pod.txt" )
							end
		HelpB:SetText( "Gyro-Pod Help Page" )
	panel:AddItem( HelpB )

end