
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/props_junk/PopCan01a.mdl" ) 
	self.Entity:SetName("Scythe")
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
		phys:EnableGravity(false)
		phys:EnableDrag(false)
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
	
	gcombat.registerent( self.Entity, 500, 6 )
		
	self.EMount = true
	self.HasHardpoints = true
	self.Cont = self.Entity
		
	self.HPC			= 8
	self.HP				= {}
	self.HP[1]			= {}
	self.HP[1]["Ent"]	= nil
	self.HP[1]["Type"]	= "Tiny"
	self.HP[1]["Pos"]	= Vector(320,0,0)
	self.HP[1]["Angle"] = Angle(0,0,0)
	self.HP[2]			= {}
	self.HP[2]["Ent"]	= nil
	self.HP[2]["Type"]	= "Tiny"
	self.HP[2]["Pos"]	= Vector(310,0,-15)
	self.HP[2]["Angle"] = Angle(0,0,0)
	self.HP[3]			= {}
	self.HP[3]["Ent"]	= nil
	self.HP[3]["Type"]	= { "Tiny", "Small" }
	self.HP[3]["Pos"]	= Vector(-75,95,45)
	self.HP[3]["Angle"] = Angle(0,0,0)
	self.HP[4]			= {}
	self.HP[4]["Ent"]	= nil
	self.HP[4]["Type"]	= { "Tiny", "Small" }
	self.HP[4]["Pos"]	= Vector(-75,-95,45)
	self.HP[4]["Angle"] = Angle(0,0,0)
	self.HP[5]			= {}
	self.HP[5]["Ent"]	= nil
	self.HP[5]["Type"]	= { "Tiny", "Small" }
	self.HP[5]["Pos"]	= Vector(-75,105,45)
	self.HP[5]["Angle"] = Angle(0,0,0)
	self.HP[6]			= {}
	self.HP[6]["Ent"]	= nil
	self.HP[6]["Type"]	= { "Tiny", "Small" }
	self.HP[6]["Pos"]	= Vector(-75,-105,45)
	self.HP[6]["Angle"] = Angle(0,0,0)
	self.HP[7]			= {}
	self.HP[7]["Ent"]	= nil
	self.HP[7]["Type"]	= { "Tiny", "Small","Medium" }
	self.HP[7]["Pos"]	= Vector(-75,100,-20)
	self.HP[7]["Angle"] = Angle(0,0,180)
	self.HP[8]			= {}
	self.HP[8]["Ent"]	= nil
	self.HP[8]["Type"]	= { "Tiny", "Small","Medium" }
	self.HP[8]["Pos"]	= Vector(-75,-100,-20)
	self.HP[8]["Angle"] = Angle(0,0,180)
	
	local SpawnPos = self:GetPos()
	
	Body = ents.Create( "prop_vehicle_prisoner_pod" )
	Body:SetModel( "models/Spacebuild/milcock8.mdl" ) 
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
	gcombat.registerent( Body, 300, 40 )
	
	
	
	Rear = ents.Create( "prop_physics" )
	Rear:SetModel( "models/Spacebuild/milcock7_emount1.mdl" ) 
	Rear:SetPos( SpawnPos )
	Rear:Spawn()
	Rear:Activate()
	Rear:SetParent(Body)
	Rear:SetLocalPos(Vector(-20,0,12.9))
	Rear:SetLocalAngles(Angle(0,0,0))
	self.Rear = Rear
	--local Weld = constraint.Weld(ent,Tail)
	
	
	self.Body:SetNetworkedEntity("ViewEnt",self.Rear,true)
	self.Body:SetNetworkedInt("OffsetOut",500,true)
	self.Body:SetNetworkedInt("OffsetUp",150,true)
	
	
	local phys = Rear:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end
	gcombat.registerent( Rear, 300, 40 )
	
	self:SetNetworkedEntity("Pod",Body,true)
	self:SetNetworkedEntity("Rear",Rear,true)
	
	
	LWingE = ents.Create( "SF-VTOLJet" )
	LWingE:SetPos( SpawnPos )
	LWingE:Spawn()
	LWingE:Activate()
	LWingE:SetParent(Rear)
	LWingE:SetLocalPos(Vector(-50,157,-10))
	LWingE:SetLocalAngles(Angle(0,0,-90))
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
	
	
	RWingE = ents.Create( "SF-VTOLJet" )
	RWingE:SetPos( SpawnPos )
	RWingE:Spawn()
	RWingE:Activate()
	RWingE:SetParent(Rear)
	RWingE:SetLocalPos(Vector(-50,-157,-10))
	RWingE:SetLocalAngles(Angle(0,0,90))
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
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,350)
	
	local ent = ents.Create( "Scythe" )
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
	self.Entity:SetColor(Color( 0, 0, 0, 0 ) )
	
	local Phys = nil
	if self.Body and self.Body:IsValid() then
		Phys = self.Body:GetPhysicsObject()
		self.CPL = self.Body:GetPassenger(1)
		if self.CPL and self.CPL:IsValid() then
			self.AMul = 1
			self.Active = true
			--self.CPL:CrosshairEnable()
			
			if self.OPAng then
				--self.CPL:SetEyeAngles(self.OPAng)
			end
			
			if self.CPL:KeyDown( IN_MOVELEFT ) then
				self.DRoll = -100
			elseif self.CPL:KeyDown( IN_MOVERIGHT ) then
				self.DRoll = 100
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
			
			if self.CPL:KeyDown( IN_JUMP ) then
				self.DFwd = -90
				local VThrust = ((self.AThrust -1) * 30)
				local MinC, MaxC = -10,10
				if VThrust > 0 then
					MinC = math.Min(-5 + (VThrust * 10),0)
				elseif VThrust < 0 then
					MaxC = math.Max(10 - (VThrust * 0.5),0)
				end
				self.HThrust = (math.Clamp(self:GetUp():DotProduct(Phys:GetVelocity()*-1), MinC , MaxC)) + VThrust
				print(MinC,self:GetUp():DotProduct(Phys:GetVelocity()*-1),MaxC)
			else
				self.DFwd = 0
				self.HThrust = 75 * (self.AThrust)
			end
			
			
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
			
			self.AThrust = math.Clamp(self.AThrust + (tonumber(self.CPL:GetInfo( "SBMWheel" )) * -0.1 ) ,0.1,2)
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
	
	if self.LWingE and self.LWingE:IsValid() then
		self.LWingE:SetLocalAngles(Angle(self.Fwd,self.Strafe,-90))
		self.LWingE.Speed = self.Thrust
	end
	if self.RWingE and self.RWingE:IsValid() then
		self.RWingE:SetLocalAngles(Angle(self.Fwd,-self.Strafe,90))
		self.RWingE.Speed = self.Thrust
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
				--Phys:EnableGravity(false)
			end
			--Phys:SetVelocity(Phys:GetVelocity() * .96)
			if self.Fwd > -90 then
				local Lift = math.Clamp(self:GetForward():DotProduct( Phys:GetVelocity() ) , 0 , 500 ) * 0.02
				--print(self:GetForward():DotProduct( Phys:GetVelocity() ))
				if self.RWingE and self.RWingE:IsValid() and self.LWingE and self.LWingE:IsValid() then
					Phys:ApplyForceCenter(self:GetUp() * (Lift * Phys:GetMass()) )
					--Phys:ApplyForceOffset(self.RWing:GetForward() * (self.Thrust * Phys:GetMass()), self:GetPos() + self:GetForward() * 86 + self:GetRight() * 50 )
					--Phys:SetVelocity(self.RWing:GetForward() * self.Thrust)
				end
			else
				
			end
			Phys:ApplyForceCenter(self.RWingE:GetForward() * (self.Thrust * Phys:GetMass()) )
		else
			if Phys and Phys:IsValid() then
				--Phys:EnableGravity(true)
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
	Phys:AddAngleVelocity(Phys:GetAngleVelocity() * -0.1)
	
	
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