AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/props_phx/construct/metal_plate1.mdl" )
	self:SetName("TankTread")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetMaterial("models/props_combine/combinethumper002")
	self.Inputs = Wire_CreateInputs( self, { "MoveSpeed", "HeightOffset", "TrackLength", "SegWidth", "SegHeight", "SegLength", "Radius", "Model" } )
	--self.Outputs = Wire_CreateOutputs( self, { "Scroll" })
    
	self.SWidth = 1
	self.SHeight = 1
	self.SLength = 1
	self.CSModel = 0
	self.Radius = 50
	self.TLength = 300
    self:SetLength( self.TLength )
    self:SetSegSize( Vector(self.SLength, self.SWidth, self.SHeight) )
    self:SetRadius( self.Radius )
    self:SetCSModel( self.CSModel )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
		phys:SetMass( 1000 )
	end
	
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	self:StartMotionController()
	
	self.IsTankTrack = true
	self.PrevPos = self:GetPos()
	self.TargetZ = 0
	self.ZVelocity = 5
	self.HSpeed = 3
	self.Hovering = false
	self.DSpeed = 0
	self.CSpeed = 0
	self.HeightOffSet = 0
	
	self.FTab = { self }
end

function ENT:TriggerInput(iname, value)		
	
	if (iname == "TrackLength") then
		if ( value > 0 and value < 1000 ) then
			self:SetLength( value )
		end
		
	elseif (iname == "MoveSpeed") then	
		self.DSpeed = math.Clamp( value, -1000, 1000 )
	
	elseif (iname == "HeightOffset") then	
		self.HeightOffSet = math.Clamp( value, -1000, 1000 )
	
	elseif (iname == "SegWidth") then	
		if ( value > 0 and value < 50 ) then
			self.SWidth = value
			self:SetSegSize( Vector(self.SLength, self.SWidth, self.SHeight) )
		end
		
	elseif (iname == "SegHeight") then	
		if ( value > 0 and value < 50 ) then
			self.SHeight = value
			self:SetSegSize( Vector(self.SLength, self.SWidth, self.SHeight) )
		end
		
	elseif (iname == "SegLength") then	
		if ( value > 0 and value < 50 ) then
			self.SLength = value
			self:SetSegSize( Vector(self.SLength, self.SWidth, self.SHeight) )
		end

	elseif (iname == "Radius") then	
		if ( value > 0 ) then
			self:SetRadius( value )
		end
		
	elseif (iname == "Model") then	
		if ( value > 0 ) then
			self.CSModel = value
			self:SetCSModel( self.CSModel )
		end

	end
end

function ENT:Think()

	if self.DSpeed > 0 then
		if self.DSpeed > self.CSpeed then
			if self.DSpeed - self.CSpeed < 10 then
				self.CSpeed = self.DSpeed
			else
				self.CSpeed = self.CSpeed + 10
			end
		else
			if self.CSpeed - self.DSpeed < 50 then
				self.CSpeed = self.DSpeed
			else
				self.CSpeed = self.CSpeed - 50
			end
		end
	else
		if self.DSpeed > self.CSpeed then
			if self.DSpeed - self.CSpeed < 50 then
				self.CSpeed = self.DSpeed
			else
				self.CSpeed = self.CSpeed + 50
			end
		else
			if self.CSpeed - self.DSpeed < 10 then
				self.CSpeed = self.DSpeed
			else
				self.CSpeed = self.CSpeed - 10
			end
		end
	end
	--print(self.CSpeed..", "..self.DSpeed)

	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:GetPos() + (self:GetUp() * (-self.Radius - (self.HeightOffSet * 2) - 200))
	trace.filter = self.FTab
	--trace.mask = -1
	local tr = util.TraceLine( trace )
	if tr.Hit then
		local HVPos = tr.HitPos + (tr.HitNormal * 100)
		if HVPos.z > tr.HitPos.z + 50 then --This controls the maximum incline the treads will function on.
			self.Hovering = true
			self.TargetZ = tr.HitPos.z + self.Radius + (self.SHeight * 10) + self.HeightOffSet
			
			local Speed = self.CSpeed * self:GetPhysicsObject():GetMass()
			
			local physi = self:GetPhysicsObject()
			
			physi:SetVelocity( physi:GetVelocity() * 0.9 )
			physi:ApplyForceCenter( self:GetForward() * Speed )
		end
	else
		self.Hovering = false
	end
	
	self:NextThink( CurTime() + 0.1 ) 
	return true

end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "TankTreadsLoop" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Use( activator, caller )
	local CEnts = constraint.GetAllConstrainedEntities( self )
	self.FTab = { self }
	for _, constr in pairs( CEnts ) do
		table.insert( self.FTab, constr.Entity )
	end
end

function ENT:Touch( ent )
	if self.Linking and ent:IsValid() and ent.IsTankTrack then
		ent:SetCont( self )
	end
end

function ENT:PhysicsSimulate( phys, deltatime )

	if !self.Hovering then return SIM_NOTHING end

	if ( self.ZVelocity ~= 0 ) then
	
		self.TargetZ = self.TargetZ + (self.ZVelocity * deltatime * self.HSpeed)
		self:GetPhysicsObject():Wake()
	
	end
	
	phys:Wake()
	
	local Pos = phys:GetPos()
	local Vel = phys:GetVelocity()
	local Distance = self.TargetZ - Pos.z
	
	if ( Distance == 0 ) then return end
	
	local Exponent = Distance^2
	
	if ( Distance < 0 ) then
		Exponent = Exponent * -1
	end
	
	Exponent = Exponent * deltatime * 300
	
	local physVel = phys:GetVelocity()
	local zVel = physVel.z
	
	Exponent = Exponent - ( zVel * deltatime * 600 )
	-- The higher you make this 300 the less it will flop about
	-- I'm thinking it should actually be relative to any objects we're connected to
	-- Since it seems to flop more and more the heavier the object
	
	Exponent = math.Clamp( Exponent, -5000, 5000 )
	
	local Linear = Vector(0,0,0)
	local Angular = Vector(0,0,0)
	
	Linear.z = Exponent
	
	return Angular, Linear, SIM_GLOBAL_ACCELERATION
	
end

function ENT:PreEntityCopy()
	local DI = {}
	
	local t = {
		"SWidth"		,
		"SHeight"		,
		"SLength"		,
		"CSModel"		,
		"Radius"		,
		"TLength"		,
		"HeightOffset"	,
		"FTab"			
			}

	for n,P in ipairs( t ) do
		if self[ P ] then
			DI[ P ] = self[ P ]
		end
	end
	
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self )
	end
	
	duplicator.StoreEntityModifier(self, "SBEPTankTread", DI)
end
duplicator.RegisterEntityModifier( "SBEPTankTread" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPTankTread

	for P,q in ipairs( DI ) do
		self[ P ] = q
	end
	
	self:SetCSModel( self.CSModel )
	self:SetSegSize( Vector(self.SLength, self.SWidth, self.SHeight) )
	self:SetLength( self.TLength )
    self:SetRadius( self.Radius )
	
	if(Ent.EntityMods and Ent.EntityMods.SBEPTankTread.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPTankTread.WireData, function(id) return CreatedEntities[id] end)
	end

end