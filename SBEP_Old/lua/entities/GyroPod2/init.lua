AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "k_lab.ambient_powergenerators" )
util.PrecacheSound( "ambient/machines/thumper_startup1.wav" )

function ENT:Initialize()

	self:SetModel( "models/props_combine/headcrabcannister01a.mdl" ) 
	self:SetName("GenericAircraft")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMaterial("models/props_combine/combinethumper002");
	self.Inputs = Wire_CreateInputs( self, { "PitchMultiplyer", "YawMultiplyer", "RollMultiplyer" } ) -- "ShipWidth", "ShipLength", "ShipHeight" } )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self:StartMotionController()
    self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self:GetPhysicsObject()
	self.LTab = {}
	
	self.TSpeed = 25
	
	self.SWidth = 5000
	self.SHeight = 5000
	self.SLength = 5000
	
	self.PMult = 1
	self.YMult = 1
	self.RMult = 1
end

local Gyrojcon = {}	
local GyroJoystickControl = function()
	--Joystick control stuff
	
	Gyrojcon.pitch = jcon.register{
		uid = "gyro_pitch",
		type = "analog",
		description = "Pitch",
		category = "Gyro-Pod",
	}
	Gyrojcon.yaw = jcon.register{
		uid = "gyro_yaw",
		type = "analog",
		description = "Yaw",
		category = "Gyro-Pod",
	}
	Gyrojcon.roll = jcon.register{
		uid = "gyro_roll",
		type = "analog",
		description = "Roll",
		category = "Gyro-Pod",
	}
	Gyrojcon.thrust = jcon.register{
		uid = "gyro_thrust",
		type = "analog",
		description = "Thrust",
		category = "Gyro-Pod",
	}
	Gyrojcon.accelerate = jcon.register{
		uid = "gyro_accelerate",
		type = "analog",
		description = "Accelerate/Decelerate",
		category = "Gyro-Pod",
	}
	Gyrojcon.up = jcon.register{
		uid = "gyro_strafe_up",
		type = "digital",
		description = "Strafe Up",
		category = "Gyro-Pod",
	}
	Gyrojcon.down = jcon.register{
		uid = "gyro_strafe_down",
		type = "digital",
		description = "Strafe Down",
		category = "Gyro-Pod",
	}
	Gyrojcon.right = jcon.register{
		uid = "gyro_strafe_right",
		type = "digital",
		description = "Strafe Right",
		category = "Gyro-Pod",
	}
	Gyrojcon.left = jcon.register{
		uid = "gyro_strafe_left",
		type = "digital",
		description = "Strafe Left",
		category = "Gyro-Pod",
	}
	Gyrojcon.launch = jcon.register{
		uid = "gyro_launch",
		type = "digital",
		description = "Launch",
		category = "Gyro-Pod",
	}
	Gyrojcon.switch = jcon.register{
		uid = "gyro_switch",
		type = "digital",
		description = "Yaw/Roll Switch",
		category = "Gyro-Pod",
	}
end

hook.Add("JoystickInitialize","GyroJoystickControl",GyroJoystickControl)

function ENT:TriggerInput(iname, value)
	
	if (iname == "ShipWidth") then
		if (value > 0) then
			self.SWidth = value
		end
		
	elseif (iname == "ShipLength") then
		if (value > 0) then
			self.SLength = value
		end
		
	elseif (iname == "ShipHeight") then
		if (value > 0) then
			self.SHeight = value
		end
	
	elseif (iname == "PitchMultiplyer") then
		if (value > 0) then
			self.PMult = value
		end
		
	elseif (iname == "YawMultiplyer") then
		if (value > 0) then
			self.YMult = value
		end
	
	elseif (iname == "RollMultiplyer") then
		if (value > 0) then
			self.RMult = value
		end
		
	end
	
end

function ENT:Think()
	if self.Pod and self.Pod:IsValid() then
		
		self.CPL = self.Pod:GetPassenger()
		if (self.CPL and self.CPL:IsValid()) then
			self.Active = true
			if (self.CPL:KeyDown( IN_FORWARD )) then
				if self.MCC then
					self.VSpeed = 50
				else
					self.Pitch = self.TSpeed
				end
			elseif (self.CPL:KeyDown( IN_BACK )) then
				if self.MCC then
					self.VSpeed = -50
				else
					self.Pitch = -self.TSpeed
				end
			else
				self.Pitch = 0
				self.VSpeed = 0
			end
	
			if (self.CPL:KeyDown( IN_MOVERIGHT )) then
				self.Roll = self.TSpeed
			elseif (self.CPL:KeyDown( IN_MOVELEFT )) then
				self.Roll = -self.TSpeed
			else
				self.Roll = 0
			end
			
			/*
			if (self.CPL:KeyDown( IN_RIGHT )) then
				self.Yaw = self.TSpeed
			elseif (self.CPL:KeyDown( IN_LEFT )) then
				self.Yaw = -self.TSpeed
			else
				self.Yaw = 0
			end
			*/
	
			if (self.CPL:KeyDown( IN_SPEED )) then
				self.Speed = math.Clamp(self.Speed + 2, -40, 2000)
			elseif (self.CPL:KeyDown( IN_WALK )) then
				self.Speed = math.Clamp(self.Speed - 5, -40, 2000)
			end
	
			if (self.CPL:KeyDown( IN_RELOAD )) then
				if !self.MTog then
					if self.MCC then
						self.MCC = false
					else
						self.MCC = true
					end
				end
				self.MTog = true
			else
				self.MTog = false
			end
			
			if (self.CPL:KeyDown( IN_JUMP ) or (joystick and joystick.Get(self.CPL, "gyro_launch"))) then
				if !self.LTog then
					if self.Launchy then
						self.Launchy = false
						self:StopSound( "k_lab.ambient_powergenerators" )
					else
						self.Launchy = true
						self:EmitSound( "k_lab.ambient_powergenerators" )
						self:EmitSound( "ambient/machines/thumper_startup1.wav" )
					end
				end
				self.LTog = true
			else
				self.LTog = false
			end
			
			if (joystick) then
				if (joystick.Get(self.CPL, "gyro_strafe_up")) then
					self.VSpeed = 50
				elseif (joystick.Get(self.CPL, "gyro_strafe_down")) then
					self.VSpeed = -50
				end
			
				if (joystick.Get(self.CPL, "gyro_strafe_right")) then
					self.HSpeed = 50
				elseif (joystick.Get(self.CPL, "gyro_strafe_left")) then
					self.HSpeed = -50
				else
					self.HSpeed = 0
				end
			
				--Acceleration, greater than halfway accelerates, less than decelerates
				if (joystick.Get(self.CPL, "gyro_accelerate")) then
					if (joystick.Get(self.CPL, "gyro_accelerate") > 128) then
						self.Speed = math.Clamp(self.Speed + (joystick.Get(self.CPL, "gyro_accelerate")/127.5-1)*5, -40, 2000)
					elseif (joystick.Get(self.CPL, "gyro_accelerate") < 127) then
						self.Speed = math.Clamp(self.Speed + (joystick.Get(self.CPL, "gyro_accelerate")/127.5-1)*10, -40, 2000)
					end
				end
				
				--Set the speed
				if (joystick.Get(self.CPL, "gyro_thrust")) then
					if (joystick.Get(self.CPL, "gyro_thrust") > 128) then
						self.TarSpeed = (joystick.Get(self.CPL, "gyro_thrust")/127.5-1)*2000
					elseif (joystick.Get(self.CPL, "gyro_thrust") < 127) then
						self.TarSpeed = (joystick.Get(self.CPL, "gyro_thrust")/127.5-1)*40
					elseif (joystick.Get(self.CPL, "gyro_thrust") < 128 and joystick.Get(self.CPL, "gyro_thrust") > 127) then
						self.TarSpeed = 0
					end
					if (self.TarSpeed > self.Speed) then
						self.Speed = math.Clamp(self.Speed + 5, -40, 2000)
					elseif (self.TarSpeed < self.Speed) then
						self.Speed = math.Clamp(self.Speed - 10, -40, 2000)						
					end
				end
				
				--forward is down on pitch, if you don't like it check the box on joyconfig to inver it
				if (joystick.Get(self.CPL, "gyro_pitch")) then
					if (joystick.Get(self.CPL, "gyro_pitch") > 128) then
						self.Pitch = -(joystick.Get(self.CPL, "gyro_pitch")/127.5-1)*90
					elseif (joystick.Get(self.CPL, "gyro_pitch") < 127) then
						self.Pitch = -(joystick.Get(self.CPL, "gyro_pitch")/127.5-1)*90
					elseif (joystick.Get(self.CPL, "gyro_pitch") < 128 and joystick.Get(self.CPL, "gyro_pitch") > 127) then
						self.Pitch = 0
					end
				end
			
				--The control for inverting yaw and roll
				local yaw = ""
				local roll = ""
				if (joystick.Get(self.CPL, "gyro_switch")) then
					yaw = "gyro_roll"
					roll = "gyro_yaw"
				else
					yaw = "gyro_yaw"
					roll = "gyro_roll"
				end
				
				--Yaw is negative because Paradukes says so
				--You could invert it, but the default configuration should be correct
				if (joystick.Get(self.CPL, yaw)) then
					if (joystick.Get(self.CPL, yaw) > 128) then
						self.Yaw = -(joystick.Get(self.CPL, yaw)/127.5-1)*90
					elseif (joystick.Get(self.CPL, yaw) < 127) then
						self.Yaw = -(joystick.Get(self.CPL, yaw)/127.5-1)*90
					elseif (joystick.Get(self.CPL, yaw) < 128 and joystick.Get(self.CPL, yaw) > 127) then
						self.Yaw = 0
					end
				end
			
				if (joystick.Get(self.CPL, roll)) then
					if (joystick.Get(self.CPL, roll) > 128) then
						self.Roll = (joystick.Get(self.CPL, roll)/127.5-1)*90
					elseif (joystick.Get(self.CPL, roll) < 127) then
						self.Roll = (joystick.Get(self.CPL, roll)/127.5-1)*90
					elseif (joystick.Get(self.CPL, roll) < 128 and joystick.Get(self.CPL, roll) > 127) then
						self.Roll = 0
					end
				end
			end
			
			if self.MCC then
				local PRel = self.Pod:GetPos() + self.CPL:GetAimVector() * 100
				
				--Believe it or not, the following code came from a set of tank treads. Who'd have thunk it?
				local FDist = PRel:Distance( self.Pod:GetPos() + self.Pod:GetUp() * 500 )
				local BDist = PRel:Distance( self.Pod:GetPos() + self.Pod:GetUp() * -500 )
				self.Pitch = (FDist - BDist) * 0.1
				FDist = PRel:Distance( self.Pod:GetPos() + self.Pod:GetForward() * 500 )
				BDist = PRel:Distance( self.Pod:GetPos() + self.Pod:GetForward() * -500 )
				self.Yaw = (BDist - FDist) * 0.1
				/*
				
				Paradukes: TVec = TheirPos - OurPos
				Paradukes: AVec = self:WorldToLocal(TVec)
				Hysteria: lol
				Paradukes: Angle = AVec:Angle
				Paradukes: And that's about it, I think
				
				*/

				self.CPL:CrosshairEnable()
			end
			
			if (self.Launchy) then
				for x, c in pairs(self.LTab) do
					if (c:IsValid()) then
						local physi = c:GetPhysicsObject()
						physi:SetVelocity( (physi:GetVelocity() * 0.75) + ((self:GetForward() * self.Speed) + (self:GetUp() * self.VSpeed)) + (self:GetRight() * self.HSpeed) )
						physi:AddAngleVelocity(physi:GetAngleVelocity() * -0.5)
						physi:ApplyForceOffset( self:GetForward() * ((self.Pitch * self.PMult * 0.005) * physi:GetMass()), self:GetPos() + self:GetUp() * 5000 )
						physi:ApplyForceOffset( self:GetForward() * ((-self.Pitch * self.PMult * 0.005) * physi:GetMass()), self:GetPos() + self:GetUp() * -5000 )
						physi:ApplyForceOffset( self:GetForward() * ((self.Yaw * self.YMult * 0.01) * physi:GetMass()), self:GetPos() + self:GetRight() * 5000 )
						physi:ApplyForceOffset( self:GetForward() * ((-self.Yaw * self.YMult * 0.01) * physi:GetMass()), self:GetPos() + self:GetRight() * -5000 )
						physi:ApplyForceOffset( self:GetUp() * ((-self.Roll * self.RMult * 0.01) * physi:GetMass()), self:GetPos() + self:GetRight() * 5000 )
						physi:ApplyForceOffset( self:GetUp() * ((self.Roll * self.RMult * 0.01) * physi:GetMass()), self:GetPos() + self:GetRight() * -5000 )
						physi:EnableGravity(false)
					end
				end
			else
				self.Speed = 0
				self.Yaw = 0
				self.Roll = 0
				self.Pitch = 0
				for x, c in pairs(self.LTab) do
					if (c:IsValid()) then
						local physi = c:GetPhysicsObject()
						physi:EnableGravity(true)
					end
				end			
			end
			
			if (self.Launchy) then
				self:GetPhysicsObject():EnableGravity(false)
			else
				self:GetPhysicsObject():EnableGravity(true)
			end
		else
			self.Speed = 0
			self.Yaw = 0
			self.Roll = 0
			self.Pitch = 0
			self:GetPhysicsObject():EnableGravity(false)
		end
	end

	self:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Link( hitEnt )
	if (hitEnt:IsVehicle()) then
		self.Pod = hitEnt
	end
	
	local LCount = 0
	local AddBreak = false
	for x, c in pairs(self.LTab) do
		if (c == hitEnt) then
			AddBreak = true
		end
		if (c:IsValid()) then
			LCount = LCount + 1
		end
	end
	if (!AddBreak) then
		self.LTab[LCount] = hitEnt
	end		
end

function ENT:OnRemove()
	self:StopSound( "k_lab.ambient_powergenerators" )
end

function ENT:Use()
end

function ENT:PreEntityCopy()
	local DI = {}

	--PrintTable(self.LTab)
	DI.LTab = {}
	for k,v in pairs(self.LTab) do
		DI.LTab[k] = v:EntIndex()
	end
	DI.Pod = self.Pod:EntIndex()
	
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self )
	end
	
	duplicator.StoreEntityModifier(self, "SBEPGyro2", DI)
end
duplicator.RegisterEntityModifier( "SBEPGyro2" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPGyro2

	--PrintTable(DI.LTab)
	if (DI.Pod) then
		self.Pod = CreatedEntities[ DI.Pod ]
		/*if (!self.Pod) then
			self.Pod = ents.GetByIndex(DI.Pod)
		end*/
		--[[local TB = self.Pod:GetTable()
		TB.HandleAnimation = function (vec, ply)
			return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) 
		end 
		self.Pod:SetTable(TB)
		self.Pod:SetKeyValue("limitview", 0)]]
	end
	self.LTab = self.LTab or {}
	for k,v in pairs(DI.LTab) do
		self.LTab[k] = CreatedEntities[ v ]
		/*if (!self.LTab[k]) then
			self.LTab[k] = ents.GetByIndex(v)
		end*/
	end
	--PrintTable(self.LTab)
	
	if(Ent.EntityMods and Ent.EntityMods.SBEPGyro2.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPGyro2.WireData, function(id) return CreatedEntities[id] end)
	end

end