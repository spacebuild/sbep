--gyropod_advanced coders: Paradukes, DataSchmuck
--wireless_gyropod coder: LoRAWN
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

util.PrecacheSound( "ambient/atmosphere/outdoor2.wav" )
util.PrecacheSound( "ambient/atmosphere/indoor1.wav" )
util.PrecacheSound( "buttons/button1.wav" )
util.PrecacheSound( "buttons/button18.wav" )
util.PrecacheSound( "buttons/button6.wav" )
util.PrecacheSound( "buttons/lever7.wav" )

local entity_name = "wireless_gyropod"

--key mapping
local keys = {
	[IN_RELOAD]    = "Activate",
	[IN_WALK]      = "Freeze",
	[IN_FORWARD]   = "Forward",
	[IN_BACK]      = "Backward",
	[IN_MOVELEFT]  = "RollLeft",
	[IN_MOVERIGHT] = "RollRight",
	[IN_LEFT]      = "Left",  --change this to something that does not manipulate the vehicle view
	[IN_RIGHT]     = "Right", --change this to something that does not manipulate the vehicle view
	[IN_JUMP]      = "Up",
	[IN_DUCK]      = "Down",  --change this to something that does not manipulate the vehicle view
	[IN_SPEED]     = "Level",
	[IN_ATTACK2]   = "RollLock",
	-- not used atm
	[IN_ATTACK]    = "Mouse1",
	[IN_ZOOM]      = "Zoom",
}

--initializes the gyropod
function ENT:Initialize()
	self:SetName(entity_name)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then	phys:Wake()	end
	--CHANGED INTERNALLY
	self.frozen, self.playing, self.weighted = false, false, false
	--axial speeds (forward, right, up)
	self.velocity = Vector(0, 0, 0)
	--weight/force related fields
	self.AllGyroConstraints = {}
	self.MoveTable = {}
	self.GyroMass = 0
	self.frontlength, self.rearlength, self.rightwidth, self.leftwidth,	self.heaviest = 1, 1, 1, 1, 1
	--CHANGEABLE BY USER INPUT
	self.SystemOn, self.FreezeOn, self.LevelOn, self.RollLockOn = false, false, false, false
	--angular speeds (pitch, yaw, roll), changeable by user
	self.rotation = Vector(0, 0, 0)
	--axial inputs (forward, right, up), changeable by user
	self.axialinput = Vector(0, 0, 0)
	--speed multipliers, maybe make them dependent on the mass of the ship (TMult)? Or perhaps mouse sensitivity (PMult,YaMult,RMult)?
	self.PMult, self.YaMult, self.RMult, self.TMult = 1, 1, 2, 50
	self.SpdL = 1000
	self.Damper = 100
end

--updates the gyropod at a fixed rate (0.01)
function ENT:Think()	
	local round, clamp, abs = math.Round, math.Clamp, math.abs
	self.AllGyroConstraints = constraint.GetAllConstrainedEntities(self)
	--get input src, velocity src and sound src
	local soundsrc, velocitysrc, driver = self, self, nil
	if (self.Pod and IsValid(self.Pod)) then
		driver = self.Pod:GetDriver()
		soundsrc  = self.Pod	
	end 
	if IsValid(self:GetParent()) then velocitysrc = self:GetParent() end
	local localvel = self:WorldToLocal(velocitysrc:GetVelocity() + self:GetPos())
	local speed = round(localvel:Length())
	--update fields related to the users inputs
	self:updateGyroPitchYaw(driver)
	self:updateGyroVelocity(localvel)
	--enable/disable gravity
	if self.SystemOn and !self.weighted then self.weighted = !self:EnableGyroWeight(true) end
	if !self.SystemOn and self.weighted then self.weighted = !self:EnableGyroWeight(false) end
	--enable/disable freezing
	if self.FreezeOn and !self.frozen then
		soundsrc:EmitSound( "buttons/lever7.wav" )
		self.frozen = !self:EnableMot(false)
	end
	if !self.FreezeOn and self.frozen then
		soundsrc:EmitSound( "buttons/lever6.wav" )
		self.frozen = !self:EnableMot(true)
	end
	--enable/disable engine sounds
	if self.SystemOn then
		if !self.playing then
			soundsrc:EmitSound( "buttons/button1.wav" )
			self.playing = self:EnableEngineSounds(soundsrc, true)
		end
		--changing sounds based on speed
		local normSpeed = clamp(abs(speed), 0, self.SpdL) / self.SpdL
		self.HighEngineSound:ChangeVolume(normSpeed, 0)
		self.HighEngineSound:ChangePitch(normSpeed * 255, 0)
		self.LowDroneSound:ChangePitch(normSpeed * 255, 0)
	end
	if !self.SystemOn and self.playing then
		soundsrc:EmitSound( "buttons/button18.wav" )
		self.playing = self:EnableEngineSounds(soundsrc, false)
	end
	--apply forces
	self:updateForces(self:GetPos(), speed)
	self:NextThink( CurTime() + 0.01 )
	return true
end

-- 1. update pitch yaw roll

--updates the pitch and yaw of the gyropod
function ENT:updateGyroPitchYaw(GyroDriver)
	if self.SystemOn then
		if (GyroDriver and IsValid(GyroDriver)) then
			self:AimByMouse(GyroDriver)				
		else
			self.ViewDelay = true
		end
	end	
end

--retrieves the view direction of the vehicle driver and translates it to pitch and yaw (acceleration?)
function ENT:AimByMouse(GyroDriver)
	local clamp = math.Clamp
	--small delay before mouse look is enabled
	if self.ViewDelay then
		timer.Simple(1.5, function() self.ViewDelay = false end)
		return
	end
	GyroDriver:CrosshairEnable()
	local pmf = self:PodModelFix(self.Pod)
	local PodPos, PodUp = self.Pod:GetPos(), self.Pod:GetUp()	  	
	local PodAim = GyroDriver:GetAimVector()
	local PRel = PodPos + PodAim * 100
	--pitch
	local FDistP = PRel:Distance( PodPos + PodUp * 500 )
	local BDistP = PRel:Distance( PodPos - PodUp * 500 )
	local PitchA = clamp((FDistP - BDistP) * 0.03, -7, 7)
	self.rotation.x = 0
	if (PitchA > 0.3) then self.rotation.x = (PitchA - 0.3) end
	if (PitchA < -0.3) then	self.rotation.x = (PitchA + 0.3)	end
	--yaw
	local FDistY = PRel:Distance( PodPos - pmf )
	local BDistY = PRel:Distance( PodPos + pmf )
	local YawA = clamp((BDistY - FDistY) * 0.03, -7, 7)
	self.rotation.y = 0
	if (YawA > 0.3) then self.rotation.y = (YawA - 0.3) end
	if (YawA < -0.3) then self.rotation.y = (YawA + 0.3) end	
end

--fixes the bug where some vehicles are rotated 90 degrees
function ENT:PodModelFix(pod)
	if (pod and IsValid(pod)) then  
		local model = pod:GetModel()
		if (string.find(model, "carseat") or string.find(model, "nova") or string.find(model, "prisoner_pod_inner")) then
			return pod:GetRight() * 500
		end
		return pod:GetForward() * -500
	end
	return self:GetRight() * 500
end

-- 2. update axial speeds

--updates the velocity of the gyropod
function ENT:updateGyroVelocity(velocity)
	if self.SystemOn then
		self.velocity.x = self:adjustSpeed(self.axialinput.x,self.velocity.x, self.TMult, self.Damper)
		self.velocity.y = self:adjustSpeed(self.axialinput.y,self.velocity.y, self.TMult, self.Damper)
		self.velocity.z = self:adjustSpeed(self.axialinput.z,self.velocity.z, self.TMult, self.Damper)
	else
		self.velocity.x = velocity.x
		self.velocity.y = -velocity.y
		self.velocity.z = velocity.z
	end
	--limit speed
	if (self.velocity.x > self.SpdL)  then self.velocity.x =  self.SpdL end
	if (self.velocity.x < -self.SpdL) then self.velocity.x = -self.SpdL end
	if (self.velocity.z > self.SpdL)  then self.velocity.z =  self.SpdL end
	if (self.velocity.z < -self.SpdL) then self.velocity.z = -self.SpdL end
	if (self.velocity.y > self.SpdL)  then self.velocity.y =  self.SpdL end
	if (self.velocity.y < -self.SpdL) then self.velocity.y = -self.SpdL end
end

--accelerates in the direction of signum, else dampens the speed
function ENT:adjustSpeed(signum, speed, mult, damper)
	if(signum == 0) then return (speed + (-speed / damper)) end
	return (speed + (signum * mult))
end

-- 3. enable/disable gyro weighting, calculates the forces that are applied to the gyropod

--updates the weight and movable objects linked to this gyropod
function ENT:EnableGyroWeight(on)
	local rnd = math.Round
	--empty table and reset gyro mass
	table.Empty(self.MoveTable)
	self.GyroMass = 0
	--gravity is turned on if gyropod is off
	if (!on) then
		return self:EnableGrav(true)
	end
	--else calculate the new gyro mass and update the table of movable objects
	local pos = self:GetPos() 
	local fw   = pos + (self:GetForward() * 5000)
	local bk  = pos + (self:GetForward() * -5000)
	local rt = pos + (self:GetRight() * 5000)
	local lt  = pos + (self:GetRight() * -5000)
	--get gyro mass and determine which entities are at the edges of the contraption
	local PhysTable = self:recalculateWeightAndBounds(fw, bk, rt, lt)
	local fEnt, bEnt, rEnt, lEnt, hEnt = self.frontlength, self.rearlength, self.rightwidth, self.leftwidth, self.heaviest
	--update moveable table
	local GyroParentIndex = 0
	if IsValid(self:GetParent()) then GyroParentIndex = self:GetParent():EntIndex()	end	
	for _, i in pairs( PhysTable ) do
		local iphys = i:GetPhysicsObject()
		local ipos = i:GetPos()
		local idx = i:EntIndex()
		if ((rnd(ipos:Distance(fw)) == fEnt) or (rnd(ipos:Distance(bk)) == bEnt) or (rnd(ipos:Distance(rt)) == rEnt) 
			or (rnd(ipos:Distance(lt)) == lEnt) or (rnd(iphys:GetMass()) == hEnt) or (idx == GyroParentIndex)) then
			table.insert(self.MoveTable, i)
		end
	end	
	return self:EnableGrav(false)
end

--Turns on/off gravity for all constrained entities
function ENT:EnableGrav(on)
	local constrained = self.AllGyroConstraints
	for _, ents in pairs( constrained ) do
		if (IsValid(ents)) then
			local phys = ents:GetPhysicsObject()
			phys:EnableDrag(false)
			phys:EnableGravity(on)
		end
	end
	return on
end

--recalculates the gyropods mass and bounds
function ENT:recalculateWeightAndBounds(gyrofor, gyroback, gyroright, gyroleft)
	local rnd = math.Round
	local MassTable, FrontDist, BackDist, RightDist, LeftDist, PhysTable = {}, {}, {}, {}, {}, {}
	for _, ents in pairs( self.AllGyroConstraints ) do 
		if (IsValid(ents)) then
			local mass = ents:GetPhysicsObject():GetMass()
			local pos = ents:GetPos()
			self.GyroMass = (self.GyroMass + mass)
			if (mass > 10) then
				table.insert(MassTable, mass)
				table.insert(FrontDist, pos:Distance(gyrofor))
				table.insert(BackDist, pos:Distance(gyroback))
				table.insert(RightDist, pos:Distance(gyroright))
				table.insert(LeftDist, pos:Distance(gyroleft))
				table.insert(PhysTable, ents)
			end
		end
	end
	--get the maxima of each table
	table.SortDesc(MassTable)
	table.sort(FrontDist)
	table.sort(BackDist)
	table.sort(RightDist)
	table.sort(LeftDist)
	self.frontlength, self.rearlength, self.rightwidth, self.leftwidth, self.heaviest = rnd(FrontDist[1]), rnd(BackDist[1]), rnd(RightDist[1]), rnd(LeftDist[1]), rnd(MassTable[1])
	return PhysTable
end

-- 4. Freezes/ Unfreezes the contraption at its current location and rotation

--Freeze/Thaw all constrained entities
function ENT:EnableMot(status)
	local constrained = self.AllGyroConstraints
	for _, ents in pairs( constrained ) do
		if (IsValid(ents)) then
			local phys = ents:GetPhysicsObject()
			phys:EnableMotion(status)
			phys:Wake()
		end
	end
	return status
end

-- 5. Enables/Disables the sounds emitted by the gyropod

--start or stop engine sounds
function ENT:EnableEngineSounds(soundsrc, status)
	if(status) then
		if self.HighEngineSound or self.LowDroneSound then
			self.HighEngineSound:Stop()
			self.LowDroneSound:Stop()
		end 
		self.HighEngineSound = CreateSound(soundsrc, Sound("ambient/atmosphere/outdoor2.wav"))
		self.LowDroneSound = CreateSound(soundsrc, Sound("ambient/atmosphere/indoor1.wav"))
		self.HighEngineSound:Play()
		self.LowDroneSound:Play()
		return true
	end
	if self.HighEngineSound or self.LowDroneSound then
		self.HighEngineSound:FadeOut(1)
		self.LowDroneSound:FadeOut(1)
	end 
	return false
end

-- 6. Applies the user input to the gyropod

--updates the movement, rotation and forces applied to the gyropod and its linked entities
function ENT:updateForces(gyropos, speed)
	if !self.SystemOn then
		return
	end
	--increase pitch yaw during high speeds
	--TODO: clamp NTC to a reasonable amount, maybe first normalize speed...
	local NTC = 1
	--if speed > 75 then
	--	NTC = speed / 75
	--end
	--apply forces and movement to all props in the move table (see GyroWeight)
	for x, c in pairs(self.MoveTable) do
		self:applyForce(c, NTC, gyropos)
	end
end

--applies the angular and directional velocity to target, also applies torque
function ENT:applyForce(target, NTC, pos)
	if(!IsValid(target)) then return end
	--calculate rotational forces
	local mass = self.GyroMass * 0.5 * NTC
	local pF = self.rotation.x * self.PMult * mass
	local yF = self.rotation.y * self.YaMult * mass
	local rF = self.rotation.z * self.RMult * mass
	if self.RollLockOn then
		rF = 0
		--use roll input for strafing
		self.velocity.y = self:adjustSpeed(self.rotation.z, self.velocity.y, self.TMult, self.Damper)
	end
	if self.LevelOn then
		local angles = self:GetAngles()
		pF = -math.NormalizeAngle(angles.p * 0.05) * self.PMult * mass
		rF = -math.NormalizeAngle(angles.r * 0.05) * self.RMult * mass
		--use roll input for strafing
		self.velocity.y = self:adjustSpeed(self.rotation.z, self.velocity.y, self.TMult, self.Damper)
	end
	--get force apply positions
	local forceApplyPosFront = pos + self:GetForward() * self.frontlength
	local forceApplyPosBack  = pos + self:GetForward() * -self.rearlength
	local forceApplyPosRight = pos + self:GetRight() * self.rightwidth
	local forceApplyPosLeft  = pos + self:GetRight() * -self.leftwidth
	--set velocities
	local phys = target:GetPhysicsObject()
	phys:SetVelocity( (self:GetForward() * self.velocity.x) + (self:GetUp() * self.velocity.z) + (self:GetRight() * self.velocity.y) )
	phys:AddAngleVelocity( -phys:GetAngleVelocity() )
	--apply forces
	phys:ApplyForceOffset( self:GetUp() * -pF, forceApplyPosFront)
	phys:ApplyForceOffset( self:GetUp() * pF, forceApplyPosBack )
	phys:ApplyForceOffset( self:GetRight() * -yF, forceApplyPosFront)
	phys:ApplyForceOffset( self:GetRight() *  yF, forceApplyPosBack )
	phys:ApplyForceOffset( self:GetUp() * -rF, forceApplyPosRight)
	phys:ApplyForceOffset( self:GetUp() * rF, forceApplyPosLeft )				
end

-- 7. Hooks these entities into the keypressed/keyreleased events, processes user inputs

--hook into keypressed events
hook.Add( "KeyPress", entity_name .. "_keypressed", function( ply, key )
	if (!keys[key]) then return end
	for _,v in pairs(ents.FindByClass(entity_name)) do
		local pod = v:GetPod()
		if (pod and pod:GetDriver() == ply and pod:IsVehicle()) then
			v:TriggerInput(keys[key], 1)
		end
	end
end)

--hook into keyreleased events
hook.Add( "KeyRelease", entity_name .. "_keyreleased", function( ply, key )
	if (!keys[key]) then return end
	for _,v in pairs(ents.FindByClass(entity_name)) do
		local pod = v:GetPod()
		if (pod and pod:GetDriver() == ply and pod:IsVehicle()) then
			v:TriggerInput(keys[key], 0)
		end
	end
end)

--get the pod this gyro is linked to
function ENT:GetPod()
	return self.Pod
end

--triggers the behavior associated with the keys
function ENT:TriggerInput(iname, value)
	if (iname == "Activate") then self.SystemOn   = self:ZeroCheck(value, !self.SystemOn, self.SystemOn) return end
	if (iname == "Freeze") 	 then self.FreezeOn   = self:ZeroCheck(value, !self.FreezeOn, self.FreezeOn) return end
	if (iname == "Level") 	 then self.LevelOn    = self:ZeroCheck(value, true, false) return end
	if (iname == "RollLock") then self.RollLockOn = self:ZeroCheck(value, true, false) return end
	if (iname == "Forward")  then self.axialinput.x = self.axialinput.x + self:ZeroCheck(value, 1, -1) return end
	if (iname == "Backward") then self.axialinput.x = self.axialinput.x + self:ZeroCheck(value, -1, 1) return end
	if (iname == "Right")    then self.axialinput.y = self.axialinput.y + self:ZeroCheck(value, 1, -1) return end
	if (iname == "Left")     then self.axialinput.y = self.axialinput.y + self:ZeroCheck(value, -1, 1) return end
	if (iname == "Up")       then self.axialinput.z = self.axialinput.z + self:ZeroCheck(value, 1, -1) return end
	if (iname == "Down")     then self.axialinput.z = self.axialinput.z + self:ZeroCheck(value, -1, 1) return end
	if (iname == "RollRight")then self.rotation.z = self.rotation.z + self:ZeroCheck(value, 1, -1) return end
	if (iname == "RollLeft") then self.rotation.z = self.rotation.z + self:ZeroCheck(value, -1, 1) return end 
end

--performs a simple zero check
function ENT:ZeroCheck(value, val1, val2)
	if (value ~= 0) then return val1 else return val2 end
end

-- 8. Stuff used to initialize/clean up the gyropod

--link the gyro to a pod
function ENT:Link(pod)
	if !pod then return false end
	self.Pod = pod
	return true
end

--clear all gyro constraints
function ENT:OnRemove()
	local constrained = self.AllGyroConstraints
	for _, ents in pairs( constrained ) do
		if (IsValid(ents)) then
			local phys = ents:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableDrag(true)
				phys:EnableGravity(true)
			end
		end
	end	
end
