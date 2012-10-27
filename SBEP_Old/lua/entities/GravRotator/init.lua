
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo_2/rocketpod_smallrockethalf.mdl" ) 
	self.Entity:SetName("Rotate")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	--self.Inputs = Wire_CreateInputs( self.Entity, { "Speed" } )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
		phys:SetMass( 1 )
	end
	
	self.Entity:StartMotionController()
	
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	self.Speed = 0
	self.OAng = Angle(0,0,0)
	self.Forward = 0
	self.Right = 0
	self.Up = 0
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "GravRotator" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	ent.GravMode = 3
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Speed") then
		self.Speed = value
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	if self.CPL then
		if self.CPL.GravCon ~= self or (self.CPL:GetVehicle() and self.CPL:GetVehicle():IsValid()) or self.CPL:GetMoveType() == 8 then
			self:Remove()
		end
		--print(self.CPL:GetPhysicsObject():IsValid())
		self.CPL:SetMoveType(MOVETYPE_NONE)
		--self.CPL:SetParent(self)
		--self.PWeld = self.PWeld or constraint.Weld(self,self.CPL)
		--self.CPL:GetPhysicsObject():EnableGravity(false)
		--self.CPL:SetAngles(self:GetAngles())
		--self.CPL:SetPos(self:GetPos())
		local PVec = self:GetPos() + (self:GetUp() * 65) + Vector(0,0,-65)
		--self.CPL:SetPos(self:GetPos())
		self.CPL:SetAngles(Angle(0.01,0.01,180.1))
		print(self.CPL:GetAngles())
		--self.CPL:AddAngleVelocity(Angle(0,0,100))--:AddAngleVelocity(Angle(100,100,10))--:SetAngle(Angle(0,0,180))
		--self.CPL:SetLocalPos(self:WorldToLocal(PVec))
		local trace = {}
		trace.start = self:GetPos() + self:GetUp() * 20
		trace.endpos = self:GetPos() + self:GetUp() * -20
		trace.filter = { self.Entity, self.CPL }
		local tr = util.TraceEntity( trace, self )
		local OnGround = false
		if tr.Hit and !tr.HitSky then
			OnGround = true
		end
		if self.GravMode == 1 then
			if self.GravGen and self.GravGen:IsValid() then
				GravDir = self.GravGen:GetUp() * -1
			end
		elseif self.GravMode == 2 then
			if self.GravGen and self.GravGen:IsValid() then
				GravDir = (self.GravGen:GetPos() - self:GetPos()):GetNormal()
			end
		elseif self.GravMode == 3 then
			if tr.HitNormal ~= Vector(0,0,0) then
				GravDir = tr.HitNormal * -1
			else
				GravDir = self:GetUp() * -1
			end
			--self:SetAngles(tr.HitNormal:Angle():Up():Angle())
			--local Ang = self:GetAngles()
			--Ang.y = 0
			--self:SetAngles(Ang)
			
		end
		if GravDir then
			--print("Angling...")
			--print(GravDir:Angle():Up():Angle())
			local GravAng = GravDir:Angle()
			GravAng:RotateAroundAxis(GravAng:Right(),90)
			self:SetAngles(GravAng + Angle(0.01,0.01,0.01))
		end
		local PAng = self.CPL:EyeAngles()
		--PAng:RotateAroundAxis()
		PAng = self:WorldToLocalAngles(PAng)
		local AAng = self:GetAngles()
		AAng:RotateAroundAxis(self:GetUp(),PAng.y)
		if OnGround then
			local OVel = self:GetPhysicsObject():GetVelocity()
			if !self.Jumping then
				--self:SetPos(tr.HitPos + tr.HitNormal * 10)
			end
			local GravDir = nil
			--print(self.GravMode)
			
			--self.CPL:PrintMessage( HUD_PRINTCENTER, tostring(PAng) )
			--print(PAng)
			--local Forward = 0
			--local Right = 0
			--local Up = 0
			local BaseForward = 200
			local BaseStrafe = 200
			local BaseJump = 1000
			if self.CPL:KeyDown(IN_FORWARD) then
				--print("On the move...")
				self.Forward = BaseForward
			elseif self.CPL:KeyDown(IN_BACK) then
				self.Forward = -BaseForward
			else
				self.Forward = math.Approach(self.Forward, 0, 10) 
			end
			if self.CPL:KeyDown(IN_MOVERIGHT) then
				--print("On the move...")
				self.Right = BaseStrafe
			elseif self.CPL:KeyDown(IN_MOVELEFT) then
				self.Right = -BaseStrafe
			else
				self.Right = math.Approach(self.Right, 0, 10)
			end
			if self.CPL:KeyDown(IN_JUMP) then
				self.Up = BaseJump
				self.Jumping = true
			else
				self.Jumping = false
			end
			--self:SetPos(self:GetPos())
			--print("OnGround")
		else
			--print("Falling...")
			if GravDir then
				--print(GravDir)
				self:GetPhysicsObject():ApplyForceCenter(GravDir * 100)
			end
			--self:SetPos(self:GetPos())
		end
		self:GetPhysicsObject():SetVelocity( (AAng:Forward() * self.Forward) + (AAng:Right() * self.Right) + (AAng:Up() * self.Up))
		self:GetPhysicsObject():AddAngleVelocity(self:GetPhysicsObject():GetAngleVelocity() * -1)
		--print(self.CPL:GetAngles(),self.CPL:EyeAngles(),self.CPL:GetAimVector())
		--self.CPL:SetParent()
	else
		--self:Remove()
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
	if !self.Linked and ent:IsPlayer() then
		self.CPL = ent
		self.CPL.GravCon = self
		self.Linked = true
		self.GravMode = 3
	end
end