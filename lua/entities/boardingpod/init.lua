AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--util.PrecacheSound( "SB/SteamEngine.wav" )

function ENT:Initialize()
	
	self.Entity:SetModel( "models/Spacebuild/medbridge2_doublehull_elevatorclamp.mdl" ) 
	self.Entity:SetName( "AssaultPodC" )-- .. self.Entity:EntIndex() )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetRenderMode( 4 )
	self.Entity:SetMoveType( 0 )
	self.Entity:SetSolid( 0 )
	--self.Entity:SetMaterial("models/props_wasteland/tugboat02")
	--self.Inputs = Wire_CreateInputs( self.Entity, { "Activate" } )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
		--phys:SetMass(20)
	end
	self.Entity:StartMotionController()
	self.PhysObj = self.Entity:GetPhysicsObject()


	self.Speed = 0
	self.TSpeed = 50
	self.Active = false
	self.Skewed = true
	self.ATime = 0
	
	self.HPC			= 0
	self.HP				= {}
	self.HP[1]			= {}
	self.HP[1]["Ent"]	= nil
	self.HP[1]["Type"]	= "Small"
	self.HP[1]["Pos"]	= Vector(-40,0,110)
	
	self:SetColor(Color(255,255,255,0))
end

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "BoardingPod" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
		
	local ent2 = ents.Create( "prop_vehicle_prisoner_pod" )
	ent2:SetModel( "models/Slyfo/assault_pod.mdl" ) 
	ent2:SetPos( SpawnPos )
	ent2:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
	ent2:SetKeyValue("limitview", 0)
	--ent2.HasHardpoints = true
	ent2:Spawn()
	ent2:Activate()
	local TB = ent2:GetTable()
	TB.HandleAnimation = function (vec, ply)
		return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) 
	end 
	ent2:SetTable(TB)
	ent2.SPL = ply
	ent2:SetNetworkedInt( "HPC", ent.HPC )
	ent2.HPType = "Vehicle"
	ent2.APPos = Vector(-20,0,-46)
	ent2.APAng = Angle(0,0,180)
	
	ent.Pod = ent2
	ent2.Cont = ent
	ent2.Pod = ent2
	ent:SetParent(ent2)
	--Constrain so they get duped together
	constraint.NoCollide( ent, ent2, 0, 0 )
	
	return ent
	
end

local BPodjcon = {}	
local BPodJoystickControl = function()
	--Joystick control stuff
	
	BPodjcon.pitch = jcon.register{
		uid = "bpod_pitch",
		type = "analog",
		description = "Pitch",
		category = "Boarding Pod",
	}
	BPodjcon.yaw = jcon.register{
		uid = "bpod_yaw",
		type = "analog",
		description = "Yaw",
		category = "Boarding Pod",
	}
	BPodjcon.roll = jcon.register{
		uid = "bpod_roll",
		type = "analog",
		description = "Roll",
		category = "Boarding Pod",
	}
	BPodjcon.launch = jcon.register{
		uid = "bpod_launch",
		type = "digital",
		description = "Launch",
		category = "Boarding Pod",
	}
	BPodjcon.switch = jcon.register{
		uid = "bpod_switch",
		type = "digital",
		description = "Yaw/Roll Switch",
		category = "Boarding Pod",
	}
	
end

hook.Add("JoystickInitialize","BPodJoystickControl",BPodJoystickControl)

function ENT:Think()
	if self.Pod and self.Pod:IsValid() then
		self.CPL = self.Pod:GetPassenger(1)
		if (self.CPL and self.CPL:IsValid()) then
			if not self.CPL.CamCon then
				self.CPL.CamCon = true
				if not self.CamC or not self.CamC:IsValid() then
					self.CamC = ents.Create( "prop_physics" )
					self.CamC:SetModel( "models/props_junk/PopCan01a.mdl" )
					self.CamC:SetPos( self.Pod:GetPos() + self.Pod:GetRight() * 10 ) 
					self.CamC:SetAngles( self.Pod:GetAngles() )
					self.CamC:Spawn()
					--self.CamC:Initialize()
					self.CamC:Activate()
					self.CamC:SetParent( self.Pod )
					self.CamC:SetColor(Color(0,0,0,0))
				end
				self.CPL:SetViewEntity( self.CamC )	
			end
			
			if (self.CPL:KeyDown( IN_JUMP )) then
				if not self.Active then
					self.Entity:SetActive()
				end
			end
	
			if (self.CPL:KeyDown( IN_MOVERIGHT )) then
				self.Roll = self.TSpeed
			elseif (self.CPL:KeyDown( IN_MOVELEFT )) then
				self.Roll = -self.TSpeed
			else
				self.Roll = 0
			end
			
			
			self.Yaw = self.CPL.SBEPYaw * -0.02
			self.Pitch = self.CPL.SBEPPitch * 0.02
			
			if (joystick) then
				local roll, yaw
				local pitch = "bpod_pitch"
				if (joystick.Get(self.CPL, "bpod_switch")) then
				yaw = "bpod_roll"
				roll = "bpod_yaw"
				else
				yaw = "bpod_yaw"
				roll = "bpod_roll"
				end
				--Pitch is usually forwards to pitch down
				if (joystick.Get(self.CPL, pitch)) then
					self.Pitch = 10-joystick.Get(self.CPL, pitch)/12.75
				end
				--Yaw needs inverting again
				if (joystick.Get(self.CPL, yaw)) then
					self.Yaw = 10-joystick.Get(self.CPL, yaw)/12.75
				end
				if (joystick.Get(self.CPL, roll)) then
					self.Roll = self.TSpeed * (joystick.Get(self.CPL, roll)/127.5-1)
				end
				if (joystick.Get(self.CPL, "bpod_launch")) then
					if not self.Active then
						self.Entity:SetActive()
					end
				end
			end
	
			if (self.CPL:KeyDown( IN_ATTACK )) then
				for i = 1, self.HPC do
					local HPC = self.CPL:GetInfo( "SBHP_"..i )
					if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() and (HPC == "1.00" or HPC == "1" or HPC == 1) then
						self.HP[i]["Ent"].Entity:HPFire()
					end
				end
			end
			
			if (self.CPL:KeyDown( IN_ATTACK2 )) then
				for i = 1, self.HPC do
					local HPC = self.CPL:GetInfo( "SBHP_"..i.."a" )
					if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() and (HPC == "1.00" or HPC == "1" or HPC == 1) then
						self.HP[i]["Ent"].Entity:HPFire()
					end
				end
			end
						
			
		else
			self.Yaw = 0
			self.Roll = 0
			self.Pitch = 0
		end
	
		if (self.Active and !self.Impact) then
					
			local physi = self.Pod:GetPhysicsObject()
			physi:SetVelocity( ( physi:GetVelocity() * 0.75 ) + ( self.Pod:GetRight() * 6000 ) )
			physi:AddAngleVelocity(Vector((physi:GetAngleVelocity() * -0.9),(physi:GetAngleVelocity() * -0.9),(physi:GetAngleVelocity() * -0.9)))
			physi:EnableGravity(false)
			
			if CurTime() >= self.ATime then
				local trace = {}
				trace.start = self.Pod:GetPos() + self.Pod:GetRight() * 80
				trace.endpos = self.Pod:GetPos() + self.Pod:GetRight() * 120
				trace.filter = self.Pod
				local tr = util.TraceLine( trace )
				if tr.HitNonWorld and tr.Entity and tr.Entity:IsValid() then
					self.Impact = true
					self.Active = false
					self.Pod:SetPos(tr.HitPos)
					if self.CPL and self.CPL:IsValid() then
						self.CPL:ExitVehicle()
						self.CPL:SetPos( self.Pod:GetPos() + self.Pod:GetRight() * 200 )
						local Vel = self.Pod:GetPhysicsObject():GetVelocity() * 0.05
						self.CPL:SetVelocity( Vel )
					end
					self.Pod:Fire("kill", "", 20)
					self.RockTrail:Remove()
					local Weld = constraint.Weld(self.Pod, tr.Entity, 0, 0, 0, true)
					local effectdata = EffectData()
					effectdata:SetOrigin( self.Pod:GetPos() )
					effectdata:SetStart( self.Pod:GetPos() )
					effectdata:SetAngle( self.Pod:GetAngles() )
					effectdata:SetNormal( self.Pod:GetForward() )
					util.Effect( "ShellDrill", effectdata )
				elseif tr.HitWorld then
					local effectdata = EffectData()
					effectdata:SetOrigin( self.Pod:GetPos() )
					effectdata:SetStart( self.Pod:GetPos() )
					effectdata:SetAngles( self.Pod:GetAngles() )
					effectdata:SetNormal( self.Pod:GetForward() )
					util.Effect( "ShellDrill", effectdata )
					local Vel = self.Pod:GetPhysicsObject():GetVelocity()
					if self.CPL and self.CPL:IsValid() then
						self.CPL:ExitVehicle()
						self.CPL:SetVelocity( Vel )
					end
					self.Pod:Remove()
				end
			end
		else
			--self.Speed = 0
			self.Yaw = 0
			self.Roll = 0
			self.Pitch = 0
			--local physi = self.Pod:GetPhysicsObject()
			--physi:EnableGravity(true)
		end
		
		if !self.Active and !self.Mounted then
			local mn, mx = self.Pod:WorldSpaceAABB()
			mn = mn - Vector(2, 2, 2)
			mx = mx + Vector(2, 2, 2)
			local T = ents.FindInBox(mn, mx)
			for _,i in pairs( T ) do
				if( i.Entity and i.Entity:IsValid() and i.Entity ~= self.Pod ) then
					if i.HasHardpoints then
						if i.Cont and i.Cont:IsValid() then HPLink( i.Cont, i.Entity, self.Pod ) end
						self.Mounted = true
						self.DMounted = true
						--self.Pod:SetParent()
					end
				end
			end
		end
		
	else
		self.Entity:Remove()
	end
	
	

	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:HPFire()
	if !self.CPL or !self.CPL:IsValid() then
		local ECPL = self.Pod.Pod:GetPassenger(1)
		if ECPL and ECPL:IsValid() then
			ECPL:ExitVehicle()
			ECPL:EnterVehicle( self.Pod )
			self.Pod.Pod:Fire("kill", "", 5.2)
			timer.Simple(5,function() 
				local effectdata = EffectData()
				effectdata:SetOrigin( self.Pod.Pod:GetPos() )
				effectdata:SetStart( self.Pod.Pod:GetPos() )
				effectdata:SetAngle( self.Pod.Pod:GetAngles() )
				util.Effect( "ShellSplode", effectdata )
			end)	
		end
	end
	self.Entity:SetActive()
end

function ENT:SetActive()
	self.Active = true
	self.ATime = CurTime() + 0.5
	self.Pod:Fire("kill", "", 90)
	--self.Entity:SetActive( true )
	
	self.RockTrail = ents.Create("env_rockettrail")
	self.RockTrail:SetAngles( self.Pod:GetAngles()  )
	self.RockTrail:SetPos( self.Pod:GetPos() + self.Pod:GetRight() * -100 )
	self.RockTrail:SetParent(self.Pod)
	self.RockTrail:Spawn()
	self.RockTrail:Activate()
			
	self.Pod:GetPhysicsObject():Wake()
	self.Pod:GetPhysicsObject():EnableMotion( true )
	constraint.RemoveConstraints( self.Pod, "Weld" )
	self.Pod:SetParent()
	if self.DMounted then self.Pod:SetPos( self.Pod:GetPos() + self.Pod:GetUp() * -60 )	end
	
	if self.Pod.Pod and self.Pod.Pod:IsValid() then
		--//self.Pod.Pod.Cont.HP[self.Pod.HPN]["Ent"] = nil
		local NC = constraint.NoCollide(self.Pod, self.Pod.Pod, 0, 0, 0, true)
	end
end

function ENT:PhysicsCollide( data, physobj )

end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Touch( ent )

end

function ENT:OnRemove()
	if self.Pod and self.Pod:IsValid() then
		self.Pod:Remove()
	end
end

function ENT:PreEntityCopy()
	local DI = {}

	if (self.Pod) and (self.Pod:IsValid()) then
	    DI.Pod = self.Pod:EntIndex()
		if (self.Pod.Pod) and (self.Pod.Pod:IsValid()) then
			DI.Pod2 = self.Pod.Pod:EntIndex()
		end
	end
	
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self.Entity )
	end
	
	duplicator.StoreEntityModifier(self, "SBEPBoardPod", DI)
end
duplicator.RegisterEntityModifier( "SBEPBoardPod" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPBoardPod

	if (DI.Pod) then
		self.Pod = CreatedEntities[ DI.Pod ]
		/*if (!self.Pod) then
			self.Pod = ents.GetByIndex(DI.Pod)
		end*/
		self.Pod.Pod = CreatedEntities[ DI.Pod2 ]
		/*if (!self.Pod.Pod) then
			self.Pod.Pod = ents.GetByIndex(DI.Pod2)
		end*/
		self.Pod.Pod.Pod = self.Pod
		self.Pod.Cont = self.Entity
		self.Pod.SPL = ply
		self.Pod:SetNetworkedInt( "HPC", ent.HPC )
		local TB = self.Pod:GetTable()
		TB.HandleAnimation = function (vec, ply)
			return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) 
		end 
		self.Pod:SetTable(TB)
		self.Pod:SetKeyValue("limitview", 0)
	end
	self.SPL = ply
	if (DI.guns) then
		for k,v in pairs(DI.guns) do
			--local gun = CreatedEntities[ v ]
			self.HP[k]["Ent"] = CreatedEntities[ v ]
			/*if (!self.HP[k]["Ent"]) then
				gun = ents.GetByIndex(v)
				self.HP[k]["Ent"] = gun
			end*/
		end
	end
	
	if(Ent.EntityMods and Ent.EntityMods.SBEPBoardPod.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPBoardPod.WireData, function(id) return CreatedEntities[id] end)
	end

end