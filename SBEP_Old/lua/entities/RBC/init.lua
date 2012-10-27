
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/props_junk/PopCan01a.mdl" ) 
	self:SetName("RustBucketChopper")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( 0 )
	
	if WireAddon then
		local V,N,A,E = "VECTOR","NORMAL","ANGLE","ENTITY"
		self.Outputs = WireLib.CreateSpecialOutputs( self, 
			{ "CPos", "Pos", "Vel", "Ang" },
			{V,V,V,A})
	end
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
		phys:SetMass(1)
	end
	self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self:GetPhysicsObject()
	
	self.DRoll = 0
	self.Roll = 0
	self.DPitch = 0
	self.Pitch = 0	
	self.DYaw = 0
	self.Yaw = 0
	
	self.DFwd = 0
	self.Fwd = 0
	
	self.AThrust = 1
	self.HThrust = 0
	self.DThrust = 0
	self.Thrust = 0
	
	
	self.DVThrust = 0
	self.VThrust = 0
	
	self.Health = 500
	
	self.TMul = 1
	self.AMul = 0
	
	self.Strafe = 0
	self.DStrafe = 0
	
	--gcombat.registerent( self, 500, 6 )
		
	self.EMount = true
	self.HasHardpoints = true
	self.Cont = self
		
	self.HPC			= 4
	self.HP				= {}
	self.HP[1]			= {}
	self.HP[1]["Ent"]	= nil
	self.HP[1]["Type"]	= "Tiny"
	self.HP[1]["Pos"]	= Vector(70,20,-6)
	self.HP[1]["Angle"] = Angle(0,0,0)
	self.HP[2]			= {}
	self.HP[2]["Ent"]	= nil
	self.HP[2]["Type"]	= "Tiny"
	self.HP[2]["Pos"]	= Vector(70,-20,-6)
	self.HP[2]["Angle"] = Angle(0,0,0)
	self.HP[3]			= {}
	self.HP[3]["Ent"]	= nil
	self.HP[3]["Type"]	= { "Tiny", "Small" }
	self.HP[3]["Pos"]	= Vector(-15,30,5)
	self.HP[3]["Angle"] = Angle(0,0,-90)
	self.HP[4]			= {}
	self.HP[4]["Ent"]	= nil
	self.HP[4]["Type"]	= { "Tiny", "Small" }
	self.HP[4]["Pos"]	= Vector(-15,-30,5)
	self.HP[4]["Angle"] = Angle(0,0,90)
	
	local SpawnPos = self:GetPos()
	
	local Body = ents.Create( "prop_vehicle_prisoner_pod" )
	Body:SetModel( "models/Slyfo_2/protorover.mdl" ) 
	Body:SetPos( self:GetPos() + Vector(0,0,50) )
	--self:SetPos(Body:GetPos())
	Body:Spawn()
	Body:Activate()
	Body:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
	Body:SetKeyValue("limitview", 0)
	local TB = Body:GetTable()
	TB.HandleAnimation = function (vec, ply)
		return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) 
	end 
	--Body:SetParent(self)
	self.Body = Body
	Body.ContEnt = self
	Body.Cont = self
	Body:SetNetworkedInt( "HPC", self.HPC )
	Body.HasHardpoints = true
	--local Weld = constraint.Weld(self,Body)
	self:SetParent(Body)
	
	--self:SetLocalPos(Vector(0,0,0))
	
	
	local phys = Body:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1000 )
	end
	--gcombat.registerent( Body, 150, 800 )
	
	
	
	local Rear = ents.Create( "prop_physics" )
	Rear:SetModel( "models/Slyfo_2/power_unit.mdl" ) 
	Rear:SetPos( SpawnPos )
	Rear:Spawn()
	Rear:Activate()
	Rear:SetParent(Body)
	Rear:SetLocalPos(Vector(-70,0,10))
	Rear:SetLocalAngles(Angle(90,0,0))
	self.Rear = Rear
	--local Weld = constraint.Weld(ent,Tail)
	
	
	self.Body:SetNetworkedEntity("ViewEnt",self.Rear,true)
	self.Body:SetNetworkedInt("OffsetOut",300,true)
	self.Body:SetNetworkedInt("OffsetUp",100,true)
	
	
	local phys = Rear:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end
	--gcombat.registerent( Rear, 100, 7000 )
	
	self:SetNetworkedEntity("Pod",Body,true)
	self:SetNetworkedEntity("Rear",Rear,true)
	
	local Rotor = ents.Create( "prop_physics" )
	Rotor:SetModel( "models/Slyfo_2/rocketpod_bigrocket.mdl" ) 
	Rotor:SetPos( SpawnPos )
	Rotor:Spawn()
	Rotor:Activate()
	Rotor:SetParent(Body)
	Rotor:SetLocalPos(Vector(-20,0,35))
	Rotor:SetLocalAngles(Angle(0,0,0))
	self.Rotor = Rotor
	--local Weld = constraint.Weld(ent,Tail)
	
	local phys = Rotor:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end
	--gcombat.registerent( Rotor, 10, 4000 )
	
	
	
	
	
	local LBlade = ents.Create( "prop_physics" )
	LBlade:SetModel( "models/props_c17/TrapPropeller_Blade.mdl" ) 
	LBlade:SetPos( SpawnPos )
	LBlade:Spawn()
	LBlade:Activate()
	LBlade:SetParent(Rotor)
	LBlade:SetLocalPos(Vector(16,-25,-2))
	LBlade:SetLocalAngles(Angle(0,0,0))
	self.LBlade = LBlade
	--local Weld = constraint.Weld(ent,Tail)
	
	local phys = LBlade:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end
	--gcombat.registerent( LBlade, 10, 1000 )
	
	
	local RBlade = ents.Create( "prop_physics" )
	RBlade:SetModel( "models/props_c17/TrapPropeller_Blade.mdl" ) 
	RBlade:SetPos( SpawnPos )
	RBlade:Spawn()
	RBlade:Activate()
	RBlade:SetParent(Rotor)
	RBlade:SetLocalPos(Vector(-16,25,-2))
	RBlade:SetLocalAngles(Angle(0,180,0))
	self.RBlade = RBlade
	--local Weld = constraint.Weld(ent,Tail)
	
	local phys = RBlade:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end
	--gcombat.registerent( RBlade, 10, 1000 )
	
	self.RotorSpeed = 0
	self.RotorAng = 0
	

end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,350)
	
	local ent = ents.Create( "RBC" )
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
	self:SetLocalPos(Vector(0,0,0))
	self:SetColor( 0, 0, 0, 0 )
	
	local Phys = nil
	if self.Body and self.Body:IsValid() then
		Phys = self.Body:GetPhysicsObject()
		self.CPL = self.Body:GetPassenger()
		if self.CPL and self.CPL:IsValid() then
			self.AMul = 1
			self.Active = true
			--self.CPL:CrosshairEnable()
			
			if self.OPAng then
				--self.CPL:SetEyeAngles(self.OPAng)
			end
			
			if self.CPL:KeyDown( IN_MOVELEFT ) then
				self.DRoll = -50
			elseif self.CPL:KeyDown( IN_MOVERIGHT ) then
				self.DRoll = 50
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
				self.DThrust = -1--math.Clamp(self:GetUp():DotProduct( Phys:GetVelocity() ) , -5 , -1.2 ) * -4
			elseif self.CPL:KeyDown( IN_FORWARD ) then
				self.DThrust = 1
			else
				self.DThrust = 0
			end
			
			--if self.CPL:KeyDown( IN_JUMP ) then
				self.DFwd = -90
				local VThrust = ((self.AThrust -1) * 20)
				local MinC, MaxC = -10,10
				if VThrust > 0 then
					MinC = math.Min(-5 + (VThrust * 10),0)
				elseif VThrust < 0 then
					MaxC = math.Max(10 - (VThrust * 0.5),0)
				end
				self.HThrust = (math.Clamp(self:GetUp():DotProduct(Phys:GetVelocity()*-1), MinC , MaxC)) + VThrust
				--print(MinC,self:GetUp():DotProduct(Phys:GetVelocity()*-1),MaxC)
			--else
			--	self.DFwd = 0
			--	self.HThrust = 75 * (self.AThrust)
			--end
			
			
			for i = 1,self.HPC do
				if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() then
					local Phys = self.HP[i]["Ent"]:GetPhysicsObject()
					if Phys and Phys:IsValid() then
						Phys:EnableGravity(false)
						Phys:EnableDrag(false)
						Phys:EnableCollisions(false)
						Phys:SetMass( 1 )
					end
				end
			end
			
			---------------------------------------- Primary Attack ----------------------------------------
			if ( self.CPL:KeyDown( IN_ATTACK ) ) then
				if self.HPC and self.HPC > 0 then
					for i = 1, self.HPC do
						local HPC = self.CPL:GetInfo( "SBHP_"..i )
						--print(HPC)
						--print(string.byte(HPC))
						if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() and (tonumber(HPC) > 0) then
							if self.HP[i]["Ent"].Cont and self.HP[i]["Ent"].Cont:IsValid() then
								self.HP[i]["Ent"].Cont:HPFire()
							else
								self.HP[i]["Ent"].Entity:HPFire()
							end
						end
					end
				end
			end
			
			
			---------------------------------------- Secondary Attack ----------------------------------------
			if ( self.CPL:KeyDown( IN_ATTACK2 ) ) then
				if self.HPC and self.HPC > 0 then
					for i = 1, self.HPC do
						local HPC = self.CPL:GetInfo( "SBHP_"..i.."a" )
						if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() and (tonumber(HPC) > 0) then
							if self.HP[i]["Ent"].Cont and self.HP[i]["Ent"].Cont:IsValid() then
								self.HP[i]["Ent"].Cont:HPFire()
							else
								self.HP[i]["Ent"].Entity:HPFire()
							end
						end
					end
				end
			end	
			
			
			
			
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
			
			self.AThrust = math.Clamp(self.AThrust,0.1,2) + (tonumber(self.CPL:GetInfo( "SBMWheel" )) * -0.1 ) 
			if self.Fwd <= -90 then
				self.AThrust = math.Approach(self.AThrust, 1, 0.01)
			end
			--self.CPL:PrintMessage( HUD_PRINTCENTER, ""..self.AThrust..", "..self.Fwd..", "..self.Thrust )
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
		--TSpeed = 50
	end
	--self.VThrust = math.Approach(self.VThrust, self.DVThrust * self.TMul, VTSpeed)
	self.Thrust = math.Approach(self.Thrust, self.DThrust * self.HThrust, TSpeed)
	self.RotorSpeed = math.Approach(self.RotorSpeed, self.Thrust * 3, .4)
	--self.Strafe = math.Approach(self.Strafe, self.DStrafe, 1.5)
	self.Pitch = math.Approach(self.Pitch, self.DPitch, 2)
	self.Yaw = math.Approach(self.Yaw, self.DYaw, 2)
	self.Roll = math.Approach(self.Roll, self.DRoll, 50)
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
	
	self.RotorAng = self.RotorAng + self.RotorSpeed
	
	if self.RotorAng >= 360 then -- Yes, I could just use fmod, but I want to play a sound every time the rotors... rotate.
		self.RotorAng = self.RotorAng - 360
		--print(self.RotorSpeed)
		--self.RotorSounds[x]
		self:EmitSound("weapons/fx/nearmiss/bulletLtoR13.wav", 400, math.Clamp(self.RotorSpeed * 3,30,200))
	end
	
	if self.RotorAng < 0 then
		self.RotorAng = self.RotorAng + 360
	end
	
	if self.Rotor and self.Rotor:IsValid() then
		self.Rotor:SetLocalAngles(Angle(0,self.RotorAng,0))
	end
	
	if Phys:IsValid() then
		if self.Active then
			--if Phys and Phys:IsValid() then
				--Phys:EnableGravity(false)
			--end
			--Phys:SetVelocity(Phys:GetVelocity() * .96)
			--if self.Fwd > -90 then
			--	local Lift = math.Clamp(self:GetForward():DotProduct( Phys:GetVelocity() ) , 0 , 500 ) * 0.02
				--print(self:GetForward():DotProduct( Phys:GetVelocity() ))
				--if self.RWingE and self.RWingE:IsValid() and self.LWingE and self.LWingE:IsValid() then
			--		Phys:ApplyForceCenter(self:GetUp() * (Lift * Phys:GetMass()) )
					--Phys:ApplyForceOffset(self.RWing:GetForward() * (self.Thrust * Phys:GetMass()), self:GetPos() + self:GetForward() * 86 + self:GetRight() * 50 )
					--Phys:SetVelocity(self.RWing:GetForward() * self.Thrust)
				--end
			--else
				
			--end
			Phys:ApplyForceCenter(self:GetUp() * (self.Thrust * Phys:GetMass()) )
		else
			if Phys and Phys:IsValid() then
				--Phys:EnableGravity(true)
			end
		end
	end
	
	if self.DThrust ~= 0 then
		local RAng = Angle(0,0,0)
		RAng.r = self.Yaw * 0.2 -- Controls Yaw...
		RAng.y = self.Pitch * 0.2 -- Controls Pitch...
		RAng.p = self.Roll * 0.2 -- Controls Roll...
		Phys:AddAngleVelocity((Phys:GetAngleVelocity() * -0.1) + RAng)
	end
	
	/*
	local CPos = self:GetPos() + self:GetUp() * 120 + self:GetForward() * -150
	Wire_TriggerOutput(self, "CPos", CPos )
	Wire_TriggerOutput(self, "Pos", self:GetPos() )
	Wire_TriggerOutput(self, "Ang", self:GetAngles())
	Wire_TriggerOutput(self, "Vel", self:GetPhysicsObject():GetVelocity())
	*/
	
	self:NextThink( CurTime() + 0.01 ) 
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