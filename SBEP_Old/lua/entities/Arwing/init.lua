
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/props_junk/PopCan01a.mdl" ) 
	self.Entity:SetName("Arwing")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( 0 )
	
	if WireAddon then
		local V,N,A,E = "VECTOR","NORMAL","ANGLE","ENTITY"
		self.Outputs = WireLib.CreateSpecialOutputs( self, 
			{ "CPos", "Pos", "Vel", "Ang" },
			{V,V,V,A})
	end
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(false)
		phys:SetMass(1)
	end
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	self.DRoll = 0
	self.Roll = 0
	self.DPitch = 0
	self.Pitch = 0	
	self.DYaw = 0
	self.Yaw = 0
	
	self.DFwd = 0
	self.Fwd = 0
	
	self.DThrust = 0
	self.Thrust = 0
	
	self.DVThrust = 0
	self.VThrust = 0
	
	self.Health = 500
	
	self.TMul = 1
	self.AMul = 0
	
	self.Strafe = 0
	self.DStrafe = 0
	
	gcombat.registerent( self.Entity, 500, 6 )
	
	local SpawnPos = self:GetPos()
	
	
	
	
	
	
	Body = ents.Create( "prop_vehicle_prisoner_pod" )
	Body:SetModel( "models/Slyfo/arwing_body.mdl" ) 
	Body:SetPos( self:GetPos() + self:GetForward() * 150 + self:GetUp() * -50 )
	Body:Spawn()
	Body:Activate()
	Body:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
	Body:SetKeyValue("limitview", 0)
	local TB = Body:GetTable()
	TB.HandleAnimation = function (vec, ply)
		return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) 
	end 
	--Body:SetParent(self)
	Body:SetLocalPos(Vector(-55,0,38))
	Body:SetLocalAngles(Angle(0,0,0))
	self.Body = Body
	local Weld = constraint.Weld(self,Body)
	
	local phys = Body:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1000 )
	end
	gcombat.registerent( Body, 300, 40 )
	
	--self.Body:SetNetworkedEntity("ViewEnt",self.Body,true)
	self:SetNetworkedEntity("Pod",self.Body,true)
	--self.Body:SetNetworkedInt("OffsetOut",500,true)
	
	
	
	LWing = ents.Create( "prop_physics" )
	LWing:SetModel( "models/props_junk/PopCan01a.mdl" ) 
	LWing:SetPos( SpawnPos )
	LWing:Spawn()
	LWing:Activate()
	LWing:SetParent(Body)
	LWing:SetLocalPos(Vector(-100,50,27))
	LWing:SetLocalAngles(Angle(0,0,0))
	LWing:SetSolid( 0 )
	self.LWing = LWing
	--local Weld = constraint.Weld(ent,Tail)
	
	local phys = LWing:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end
	gcombat.registerent( LWing, 300, 40 )
	
	
	RWing = ents.Create( "prop_physics" )
	RWing:SetModel( "models/props_junk/PopCan01a.mdl" ) 
	RWing:SetPos( SpawnPos )
	RWing:Spawn()
	RWing:Activate()
	RWing:SetParent(Body)
	RWing:SetLocalPos(Vector(-100,-50,27))
	RWing:SetLocalAngles(Angle(0,0,0))
	RWing:SetSolid( 0 )
	self.RWing = RWing
	--local Weld = constraint.Weld(ent,Tail)
	
	local phys = RWing:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end
	gcombat.registerent( RWing, 300, 40 )
	
	
	
	
	LWingE = ents.Create( "prop_physics" )
	LWingE:SetModel( "models/Slyfo/arwing_engineleft.mdl" ) 
	LWingE:SetPos( SpawnPos )
	LWingE:Spawn()
	LWingE:Activate()
	LWingE:SetParent(LWing)
	LWingE:SetLocalPos(Vector(-1,60,-75))
	LWingE:SetLocalAngles(Angle(0,0,0))
	LWingE:SetSolid( 0 )
	self.LWingE = LWingE
	--local Weld = constraint.Weld(ent,Tail)
	
	local phys = LWingE:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end
	gcombat.registerent( LWingE, 300, 40 )
	
	
	RWingE = ents.Create( "prop_physics" )
	RWingE:SetModel( "models/Slyfo/arwing_engineright.mdl" ) 
	RWingE:SetPos( SpawnPos )
	RWingE:Spawn()
	RWingE:Activate()
	RWingE:SetParent(RWing)
	RWingE:SetLocalPos(Vector(-1,-60,-75))
	RWingE:SetLocalAngles(Angle(0,0,0))
	RWingE:SetSolid( 0 )
	self.RWingE = RWingE
	--local Weld = constraint.Weld(ent,Tail)
	
	local phys = RWingE:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end
	gcombat.registerent( RWingE, 300, 40 )
	
	
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "Arwing" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
				
	return ent
end

function ENT:OnRemove()
	if self.Body and self.Body:IsValid() then
		self.Body:Remove()
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	--self.Entity:SetColor( 0, 0, 255, 255)
	local Phys = self.Body:GetPhysicsObject()

	if self.Body and self.Body:IsValid() then
		self.CPL = self.Body:GetPassenger()
		if self.CPL and self.CPL:IsValid() then
			
			self.AMul = 1
			self.Active = true
			--self.CPL:CrosshairEnable()
			
			if self.OPAng then
				--self.CPL:SetEyeAngles(self.OPAng)
			end
			
			if self.CPL:KeyDown( IN_MOVELEFT ) then
				self.DRoll = -30
			elseif self.CPL:KeyDown( IN_MOVERIGHT ) then
				self.DRoll = 30
			else
				self.DRoll = 0
			end
			
			if self.Alt then
				--self:SetPos(Vector(0,0,500))
				--self:SetAngles(Angle(self:GetAngles().p,self:GetAngles().y,0))
				self.DStrafe = 90
			else
				self.DStrafe = 0
			end
			
			if self.CPL:KeyDown( IN_BACK ) then
				self.DThrust = -10--math.Clamp(self:GetUp():DotProduct( Phys:GetVelocity() ) , -5 , -1.2 ) * -4
			elseif self.CPL:KeyDown( IN_FORWARD ) then
				self.DThrust = 60
			else
				self.DThrust = 0
			end
			
			if self.CPL:KeyDown( IN_JUMP ) then
				self.TMul = 0.1
				if self.Thrust < 0 then
					self.TMul = 1
				end
				self.DFwd = -90
			else
				self.TMul = 1
				self.DFwd = 0
			end
			
			
			/*
			if self.CPL:KeyDown( IN_JUMP ) then
				if !self.JTog then
					self.Active = !self.Active
					self.JTog = true
				end
			else
				self.JTog = false
			end
			*/
			--local CPLA = self.Pod:WorldToLocalAngles(self.CPL:EyeAngles())
			--if self.Fwd > -90 then
				--self.DYaw = self.ParL.X * 3 -- math.Clamp(self.CPL.SBEPYaw * 2,-45,45)
				--self.DPitch = self.ParL.Y * -3--math.Clamp(self.CPL.SBEPPitch * 2,-45,45)
				
				--self.CPL:PrintMessage( HUD_PRINTCENTER, self.Thrust..", "..self.DVThrust..", "..self.VThrust )
			--else
			--	self.DYaw = 0
			--	self.DPitch = 0
			--end
			if self.CPL.SBEPYaw == 0 and self.CPL.SBEPPitch == 0 then
				if self.OPAng then
					self.CPL:SetEyeAngles(self:WorldToLocalAngles(self.OPAng):Forward():Angle())
				else
					self.OPAng = self.CPL:EyeAngles()
				end
			else
				self.OPAng = nil
			end
			if self.CPL:KeyDown( IN_SPEED ) then
				self.DPitch = 0
				self.DYaw = 0
			else
				local AAng = self:WorldToLocalAngles(self.CPL:EyeAngles())
				self.DPitch = AAng.p
				self.DYaw = AAng.y
			end
			--self.CPL:PrintMessage( HUD_PRINTCENTER, ""..self.DPitch..", "..self.DYaw )
		else
			self.DThrust = 0
			self.DPitch = 0
			self.DRoll = 0
			self.DYaw = 0
			self.DFwd = 0
			self.AMul = 0
			self.OPAng = nil
			self.Active = false
		end
	else
		
		self:Remove()
	end
		
	
	local TSpeed = 1
	if self.Thrust > self.DThrust then
		TSpeed = 50
	end
	--self.VThrust = math.Approach(self.VThrust, self.DVThrust * self.TMul, VTSpeed)
	self.Thrust = math.Approach(self.Thrust, self.DThrust * self.TMul, TSpeed)
	--self.Strafe = math.Approach(self.Strafe, self.DStrafe, 1.5)
	self.Pitch = math.Approach(self.Pitch, self.DPitch, 2)
	self.Yaw = math.Approach(self.Yaw, self.DYaw, 2)
	self.Roll = math.Approach(self.Roll, self.DRoll, 2)
	self.Fwd = math.Approach(self.Fwd, self.DFwd, 2)
	
	
	
	
	local YRo = 0
	local PRo = 0
	local RRo = 0
	if self.Fwd > -90 then
		YRo = self.Yaw
		PRo = self.Pitch
		RRo = self.Roll * -0.5
	else
		RRo = self.Yaw * 0.1
	end
	
	if self.LWing and self.LWing:IsValid() then
		self.LWing:SetLocalAngles(Angle(self.Fwd + RRo,self.Strafe,0))
	end
	if self.RWing and self.RWing:IsValid() then
		self.RWing:SetLocalAngles(Angle(self.Fwd - RRo,-self.Strafe,0))
	end
	
	if self.TREng and self.TREng:IsValid() then
		self.TREng:SetLocalAngles(Angle(self.Fwd - PRo,YRo, 90))
	end
	if self.TLEng and self.TLEng:IsValid() then
		self.TLEng:SetLocalAngles(Angle(self.Fwd - PRo,YRo,-90))
	end
	
	
	
	if Phys:IsValid() then
		if self.Active then
			if Phys and Phys:IsValid() then
				Phys:EnableGravity(false)
			end
			Phys:SetVelocity(Phys:GetVelocity() * .96)
			if self.Fwd > -90 then
				--Phys:EnableGravity(false)
			else
				--Phys:EnableGravity(true)
			end
			--local Lift =  math.Clamp(self:GetForward():DotProduct( Phys:GetVelocity() ) , 0 , 100 ) * 0.04
			if self.RWingE and self.RWingE:IsValid() and self.LWingE and self.LWingE:IsValid() then
				--Phys:ApplyForceOffset(self:GetUp() * (Lift * Phys:GetMass()), self:GetPos() + self:GetRight() * 50 )
				--Phys:ApplyForceOffset(self.RWing:GetForward() * (self.Thrust * Phys:GetMass()), self:GetPos() + self:GetForward() * 86 + self:GetRight() * 50 )
				Phys:ApplyForceCenter(self.RWing:GetForward() * (self.Thrust * Phys:GetMass()) )
				--Phys:SetVelocity(self.RWing:GetForward() * self.Thrust)
			end
		else
			if Phys and Phys:IsValid() then
				Phys:EnableGravity(true)
			end
		end
	end
	
	
	if !self.Tail or !self.Tail:IsValid() then
		if self.TREng and self.TREng:IsValid() then
			self.TREng:Remove()
		end
		if self.TLEng and self.TLEng:IsValid() then
			self.TLEng:Remove()
		end
	end
	
	local RAng = Angle(0,0,0)
	RAng.r = self.Yaw * 0.2 -- Controls Yaw...
	RAng.y = self.Pitch * 0.2 -- Controls Pitch...
	RAng.p = self.Roll * 0.2 -- Controls Roll...
	Phys:AddAngleVelocity((Phys:GetAngleVelocity() * -0.1) + RAng)
	
	/*
	local CPos = self:GetPos() + self:GetUp() * 120 + self:GetForward() * -150
	Wire_TriggerOutput(self.Entity, "CPos", CPos )
	Wire_TriggerOutput(self.Entity, "Pos", self:GetPos() )
	Wire_TriggerOutput(self.Entity, "Ang", self:GetAngles())
	Wire_TriggerOutput(self.Entity, "Vel", self:GetPhysicsObject():GetVelocity())
	*/
	
	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true	
end

function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 200 then
		local P = data.HitObject:GetMass()
		if data.HitEntity:IsWorld() then
			P = 1000
		end
		--gcombat.hcghit( self, data.Speed * 1, P, self:GetPos(), self:GetPos())
	end
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