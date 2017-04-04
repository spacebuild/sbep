
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
util.PrecacheSound( "SB/Charging.wav" )

function ENT:Initialize()

	self.Entity:SetModel( "models/props_combine/headcrabcannister01a_skybox.mdl" ) 
	self.Entity:SetName("MicroShip")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1000 )
	end
	
	self.Entity:StartMotionController()
	
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
		
	self.W = 0
	self.S = 0
	self.A = 0
	self.D = 0
	
	self.X = 0
	self.Y = 0
	
	self.AThrust = 1
	
	self.Speed = 0

end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "MicroShip" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	local CPL = nil
	if self.Pod and self.Pod:IsValid() then
		CPL = self.Pod:GetPassenger(1)
		if CPL and CPL:IsValid() then
			if !CPL.CamCon then
				CPL.CamCon = true
				CPL:SetViewEntity( self )
			end
			
			self.W = CPL:KeyDown( IN_FORWARD ) and 500 or 0
			self.S = CPL:KeyDown( IN_BACK ) and -500 or 0
			self.A = CPL:KeyDown( IN_MOVELEFT ) and -1 or 0
			self.D = CPL:KeyDown( IN_MOVERIGHT ) and 1 or 0
			
			self.X = CPL.SBEPYaw
			self.Y = -CPL.SBEPPitch
			
			self.AThrust = math.Clamp(self.AThrust + (tonumber(CPL:GetInfo( "SBMWheel" )) * -0.1 ) ,0.01,3)
			
			self.Active = true
		else
			self.W = 0
			self.S = 0
			self.A = 0
			self.D = 0
			
			self.X = 0
			self.Y = 0
			
			self.AThrust = 1
			
			self.Active = false
		end
	else
		self.W = 0
		self.S = 0
		self.A = 0
		self.D = 0
		
		self.X = 0
		self.Y = 0
		
		self.AThrust = 1
		
		self.Active = false
	end
	
	self.Speed = math.Approach(self.Speed, (self.W + self.S) * self.AThrust, self.AThrust + (self.Speed * 0.01) + 5)
	 //if CPL and CPL:IsValid() then CPL:PrintMessage( HUD_PRINTCENTER, ""..self.Speed..", "..self.AThrust ) end
	--print(self.Speed)
	
	local Phys = self:GetPhysicsObject()
	if Phys and Phys:IsValid() and self.Active then
		Phys:SetVelocity(self:GetForward() * self.Speed)	
		
		local MTurn = 50
		
		local RAng = Angle(0,0,0)
		RAng.r = math.Clamp(self.X * -0.03 * (self.Speed + 50) * 0.01, -MTurn,MTurn) -- Controls Yaw...
		RAng.y = math.Clamp(self.Y * -0.03 * (self.Speed + 50) * 0.01, -MTurn,MTurn)-- Controls Pitch...
		RAng.p = math.Clamp((self.A + self.D) * 10.2 * (self.Speed + 10) * 0.5, -MTurn,MTurn) -- Controls Roll...
		Phys:AddAngleVelocity((Phys:GetAngleVelocity() * -0.1))
	end
	
	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

end

function ENT:Touch( ent )
	if ent:IsVehicle() then
		self.Pod = ent
	end
end

function ENT:BuildDupeInfo()
	local info = self.BaseClass.BuildDupeInfo(self) or {}
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	self.BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID)
end

function ENT:BuildClientModel(Scale)
	if !self.Building then
		--self.Building = true
		local CEnts = constraint.GetAllConstrainedEntities( self.Entity )
		for k,e in pairs(CEnts) do
			if e and e:IsValid() and e ~= self then
				--local V,A = WorldToLocal( e:GetPos(), e:GetAngles(), self:GetPos(), self:GetAngles() ) --Why doesn't this work anymore?
				local V2 = e:GetPos() - self:GetPos() --This really, really shouldn't fix the entity. And yet it does. 
														--To err is human. To really foul things up, try a crappy implementation of Lua...
				--print(V, V2)
				
				local RP = RecipientFilter()
				RP:AddAllPlayers()
				
				umsg.Start("MicroShipBuildSegment", RP )
				umsg.Entity( self )
				umsg.String( e:GetModel() )
				umsg.Vector( V2 )
				umsg.Angle( e:GetAngles() )
				umsg.Float( Scale )
				umsg.End()
				
			end
		end
		constraint.RemoveAll(self)
	end
		
end