
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
util.PrecacheSound( "SB/Charging.wav" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Spacebuild/Nova/dronebase.mdl" ) 
	self.Entity:SetName("ShipAI")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
	local inNames = {"MoveVector", "TargetVector", "Angle", "Stance", "TargetsFound", "Size", "AlternateTargetVector1", "AlternateTargetVector2", "AlternateTargetVector3", "AlternateTargetVector4", "AlternateTargetVector5"}
	local inTypes = {"VECTOR","VECTOR","ANGLE","NORMAL","NORMAL","NORMAL","VECTOR","VECTOR","VECTOR","VECTOR","VECTOR"}
	self.Inputs = WireLib.CreateSpecialInputs( self.Entity,inNames,inTypes)
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Pitch", "Yaw", "Roll", "Forward", "Lateral", "Vertical", "WaypointReached", "Stance" })
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 10 )
	end
	
	self.Entity:StartMotionController()
	
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	self.Stance = 0
	self.AVec = Vector(0,0,0)
	self.MVec = Vector(0,0,0)
	self.TVec = Vector(0,0,0)
	self.Alternates = {Vector(0,0,0),Vector(0,0,0),Vector(0,0,0),Vector(0,0,0),Vector(0,0,0)}
	self.MAngle = Angle(0,0,0)
	self.Weaponry = {}
	self.TSClamp = 100
	self.SpeedClamp = 500
	self.Reversible = false
	self.Targets = 0
	self.WPRad = 500
	self.Entity:SetNetworkedInt("Size", 500)
	self.Fade = false
	
	self.IsShipController = true
	
	self.WaypointReached = 0
	
	self.Forward = 0
	
	self.TFound = false
	
	self.Pitch = 0
	self.Roll = 0
	self.Yaw = 0

end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "ShipController" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)
	
	if (iname == "MoveVector") then
		self.MVec = value
		
	elseif (iname == "TargetVector") then
		self.TVec = value
		
	elseif (iname == "Angle") then
		self.MAngle = value
		if value ~= Angle(0,0,0) then
			self.Angling = true
		else
			self.Angling = true
		end
		
	elseif (iname == "Stance") then
		self.Stance = value
		
	elseif (iname == "Size") then
		self.WPRad = math.abs(value)
		self.Entity:SetNetworkedInt("Size", self.WPRad)
		
	elseif (iname == "TargetsFound") then
		if value > 0 then
			self.TFound = true
		else
			self.TFound = false
		end
		self.Targets = value
	
	elseif (iname == "AlternateTargetVector1") then
		self.Alternates[1] = value
		
	elseif (iname == "AlternateTargetVector2") then
		self.Alternates[2] = value
	
	elseif (iname == "AlternateTargetVector3") then
		self.Alternates[3] = value
		
	elseif (iname == "AlternateTargetVector4") then
		self.Alternates[4] = value
		
	elseif (iname == "AlternateTargetVector5") then
		self.Alternates[5] = value
		
	end
end

function ENT:Think()

	self.WaypointReached = 0
	
	self.Forward = 0
	
	self.Pitch = 0
	self.Roll = 0
	self.Yaw = 0
	
	self.Lat = 0
	self.Vert = 0

	if self.Stance > 0 then --Dear god, this is a mess... I must remember to organize this function better.
		if (self.Stance < 3) or (self.Stance == 3 and !self.TFound) then
			if self.MVec ~= Vector(0,0,0) then
				local MDist = self.Entity:GetPos():Distance(self.MVec)
				if MDist < self.WPRad then
					self.WaypointReached = 1
					if self.Angling then--self.MAngle ~= Angle(0,0,0) then
						self.Pitch = math.AngleDifference(self.Entity:GetAngles().p,self.MAngle.p) * -0.01
						self.Roll = math.AngleDifference(self.Entity:GetAngles().r,self.MAngle.r) * -0.01
						self.Yaw = math.AngleDifference(self.Entity:GetAngles().y,self.MAngle.y) * -0.01
					end
					if MDist > self.WPRad * 0.1 then
						self.Entity:StrafeFinder( self.MVec, self.Entity:GetPos(), self.Entity:GetUp(), self.Entity:GetRight(), self.Entity:GetForward() )
					end
				else
					self.Entity:Orient( self.MVec, self.Entity:GetPos(), self.Entity:GetUp(), self.Entity:GetRight() )
					
					self.Roll = self.Entity:GetAngles().r * -0.005
					
					self.Entity:SpeedFinder( self.MVec, self.Entity:GetPos(), self.Entity:GetForward() )
				end
			end
		elseif self.Stance == 3 and self.TFound then
			local MDist = self.Entity:GetPos():Distance(self.TVec)
			if MDist > 1000 then
				self.Entity:Orient( self.TVec, self.Entity:GetPos(), self.Entity:GetUp(), self.Entity:GetRight() )
				self.Entity:SpeedFinder( self.TVec, self.Entity:GetPos(), self.Entity:GetForward() )
			else
				local HighP = 0
				local MainG = 0
				for k,e in pairs( self.Weaponry ) do
					if e and e:IsValid() and e.Priority > 0 and e.Priority > HighP then
						HighP = e.Priority
						MainG = k
					end
				end
				if MainG > 0 then
					self.Entity:Orient( self.TVec, self.Weaponry[MainG]:GetPos(), self.Weaponry[MainG]:GetUp(), self.Weaponry[MainG]:GetRight() )
				else
					self.Entity:Orient( self.TVec, self.Entity:GetPos(), self.Entity:GetUp(), self.Entity:GetRight() )
					
					self.Roll = self.Entity:GetAngles().r * -0.001
					if MDist > 1000 then
						self.Entity:SpeedFinder( self.TVec, self.Entity:GetPos(), self.Entity:GetForward() )
					end
				end
			end
		end
	end
		
	Wire_TriggerOutput( self.Entity, "WaypointReached", self.WaypointReached )			
	
	Wire_TriggerOutput( self.Entity, "Forward", self.Forward )
	
	Wire_TriggerOutput( self.Entity, "Lateral", self.Lat )
	Wire_TriggerOutput( self.Entity, "Vertical", self.Vert )	
				
	Wire_TriggerOutput( self.Entity, "Pitch", self.Pitch )
	Wire_TriggerOutput( self.Entity, "Roll", self.Roll )
	Wire_TriggerOutput( self.Entity, "Yaw", self.Yaw )
	
	Wire_TriggerOutput( self.Entity, "Stance", self.Stance )
		
	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )
	if !self.Fade then
		self.Fade = true
	else
		self.Fade = false
	end
end

function ENT:Touch( ent )
	if ent:GetClass() == "gyropod_advanced" and (!self.Gyro or !self.Gyro:IsValid()) then
		--Speed
		Wire_Link_Start(self:EntIndex(), ent, ent:GetPos(), "SpeedAbs", "cable/cable2", Color(0,0,0,0), 0)
		Wire_Link_End(self:EntIndex(), self.Entity, self.Entity:GetPos(), "Forward", self.SPL)
		--Pitch
		Wire_Link_Start(self:EntIndex(), ent, ent:GetPos(), "PitchAbs", "cable/cable2", Color(0,0,0,0), 0)
		Wire_Link_End(self:EntIndex(), self.Entity, self.Entity:GetPos(), "Pitch", self.SPL)
		--Yaw
		Wire_Link_Start(self:EntIndex(), ent, ent:GetPos(), "YawAbs", "cable/cable2", Color(0,0,0,0), 0)
		Wire_Link_End(self:EntIndex(), self.Entity, self.Entity:GetPos(), "Yaw", self.SPL)
		--Roll
		Wire_Link_Start(self:EntIndex(), ent, ent:GetPos(), "RollAbs", "cable/cable2", Color(0,0,0,0), 0)
		Wire_Link_End(self:EntIndex(), self.Entity, self.Entity:GetPos(), "Roll", self.SPL)
		--Active
		Wire_Link_Start(self:EntIndex(), ent, ent:GetPos(), "Activate", "cable/cable2", Color(0,0,0,0), 0)
		Wire_Link_End(self:EntIndex(), self.Entity, self.Entity:GetPos(), "Stance", self.SPL)
		--Lateral
		Wire_Link_Start(self:EntIndex(), ent, ent:GetPos(), "Lateral", "cable/cable2", Color(0,0,0,0), 0)
		Wire_Link_End(self:EntIndex(), self.Entity, self.Entity:GetPos(), "Lateral", self.SPL)
		--Vertical
		Wire_Link_Start(self:EntIndex(), ent, ent:GetPos(), "Vertical", "cable/cable2", Color(0,0,0,0), 0)
		Wire_Link_End(self:EntIndex(), self.Entity, self.Entity:GetPos(), "Vertical", self.SPL)
		self.Gyro = ent
	end
end
--I should really merge the next two functions together
function ENT:Orient( Vec, Pos, Up, Right )
	local FDist = Vec:Distance( Pos + Up * 100 )
	local BDist = Vec:Distance( Pos + Up * -100 )
	self.Pitch = math.Clamp((FDist - BDist) * 0.01, -self.TSClamp, self.TSClamp)
	FDist = Vec:Distance( Pos + Right * 100 )
	BDist = Vec:Distance( Pos + Right * -100 )
	self.Yaw = math.Clamp((BDist - FDist) * -0.01, -self.TSClamp, self.TSClamp)
end

function ENT:StrafeFinder( Vec, Pos, Up, Right, Forward )
	local FDist = Vec:Distance( Pos + Up * 100 )
	local BDist = Vec:Distance( Pos + Up * -100 )
	self.Vert = math.Clamp((FDist - BDist) * -0.001, -self.SpeedClamp * 0.01, self.SpeedClamp * 0.01)
	
	FDist = Vec:Distance( Pos + Right * 100 )
	BDist = Vec:Distance( Pos + Right * -100 )
	self.Lat = math.Clamp((BDist - FDist) * 0.001, -self.SpeedClamp * 0.01, self.SpeedClamp * 0.01)
	
	FDist = Vec:Distance( Pos + Forward * 100 )
	BDist = Vec:Distance( Pos + Forward * -100 )
	self.Forward = math.Clamp((BDist - FDist) * 0.001, -self.SpeedClamp * 0.01, self.SpeedClamp * 0.01)
	
end


function ENT:SpeedFinder( Vec, Pos, Forward )
	local FDist = Vec:Distance( Pos + Forward * 1000 )
	local BDist = Vec:Distance( Pos + Forward * -1000 )
	if self.Reversible then
		self.Forward = math.Clamp((FDist - BDist) * -0.01, -self.SpeedClamp, self.SpeedClamp)
	else
		self.Forward = math.Clamp((FDist - BDist) * -0.01, 0, self.SpeedClamp)
	end
	
	if self.Forward < 0 then
		self.Yaw = self.Yaw * -1
		self.Pitch = self.Pitch * -1
	end
end