AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/props_c17/consolebox01a.mdl" ) 
	self.Entity:SetName("MPC")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local N = "NORMAL"
	local inNames = {"X", "Y", "Z", "Vector", "Pitch", "Yaw", "Roll", "Angle","Reciprocate", "Duration", "Speed", "Teleport", "AbsVec", "AbsAng", "Disable", "FulcrumX", "FulcrumY", "FulcrumZ", "FulcrumVec" }
	local inTypes = {N,N,N,"VECTOR",N,N,N,"ANGLE",N,N,N,N,N,N,N,N,N,N,"VECTOR"}
	self.Inputs = WireLib.CreateSpecialInputs( self.Entity,inNames,inTypes)
	self.Entity:SetUseType( 3 )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(false)
		phys:SetMass(20)
	end

	self.PhysObj = self.Entity:GetPhysicsObject()
	
	self.Plat = nil	
	self.PlModel = nil
		
	self.XCo = 0
	self.YCo = 0
	self.ZCo = 0
		
	self.Yaw = 0
	self.Roll = 0
	self.Pitch = 0
	
	self.FulX = 0
	self.FulY = 0
	self.FulZ = 0
		
	self.AbsVec = false
	self.AbsAng = false
	self.Recip = false
	
	self.Disabled = false
	
	self.TPD = 0
	
	self.Speed = 1000000000
	
	self.Duration = 0.000000001
	
	self.Vel = 0.1
	
	self.ShadowParams = {}
		self.ShadowParams.maxangular = 100000000 --What should be the maximal angular force applied
		self.ShadowParams.maxangulardamp = 10000000 -- At which force/speed should it start damping the rotation
		self.ShadowParams.maxspeed = 100000000 -- Maximal linear force applied
		self.ShadowParams.maxspeeddamp = 10000000 -- Maximal linear force/speed before  damping
		self.ShadowParams.dampfactor = 0.8 -- The percentage it should damp the linear/angular force if it reachs it's max ammount
		self.ShadowParams.teleportdistance = 0 -- If it's further away than this it'll teleport (Set to 0 to not teleport)

	self:StartMotionController()
	
	self.PasteDelay = true
end

function ENT:TriggerInput(iname, value)
	
	if (iname == "X") then
		self.XCo = value
		
	elseif (iname == "Y") then
		self.YCo = value
		
	elseif (iname == "Z") then
		self.ZCo = value
		
	elseif (iname == "Vector") then
		self.XCo = value.x
		self.YCo = value.y
		self.ZCo = value.z
		
	elseif (iname == "Pitch") then
		self.Pitch = value
		
	elseif (iname == "Yaw") then
		self.Yaw = value
		
	elseif (iname == "Roll") then
		self.Roll = value
		
	elseif (iname == "Angle") then
		self.Yaw = value.y
		self.Roll = value.r
		self.Pitch = value.p
		
	elseif (iname == "Duration") then
		if (value >= 0) then
			self.Duration = math.Clamp(value,0.000000001,1000)
		end
		
	elseif (iname == "Teleport") then
		if (value >= 0) then
			self.TPD = value
		end
		
	elseif (iname == "AbsVec") then
		if (value > 0) then
			self.AbsVec = true
		else
			self.AbsVec = false
		end
		
	elseif (iname == "AbsAng") then
		if (value > 0) then
			self.AbsAng = true
		else
			self.AbsAng = false
		end
		
	elseif (iname == "Reciprocate") then
		if (value > 0) then
			self.Recip = true
		else
			self.Recip = false
		end
		
	elseif (iname == "Vel") then
		self.Vel = value
		
	elseif (iname == "Disable") then
		if (value > 0) then
			self.Disabled = true
		else
			self.Disabled = false
		end
	
	elseif (iname == "FulcrumX") then
		self.FulX = value
		
	elseif (iname == "FulcrumY") then
		self.FulY = value
		
	elseif (iname == "FulcrumZ") then
		self.FulZ = value
		
	end
end
/*
function ENT:PhysicsSimulate( phys, deltatime )

	if self.Recip then
		local OVel = phys:GetVelocity()
		--local Phys = self.Entity:GetPhysicsObject()
		--Phys:AddAngleVelocity((Phys:GetAngleVelocity() * -1) + self.Plat:LocalToWorldAngles(Ang * -1))
		local RPos = self.Plat:GetPos() + (self.Entity:GetUp() * self.ZCo * -1) + (self.Entity:GetForward() * self.YCo * -1) + (self.Entity:GetRight() * self.XCo * -1)
		--Phys:SetVelocity(RPos - self.Entity:GetPos())
		phys:Wake()
				
		self.ShadowParams.secondstoarrive = self.Duration
		self.ShadowParams.pos = RPos
		--if self.AbsAng then
		self.ShadowParams.angle = self.Entity:GetAngles()
		--else
		--	self.ShadowParams.angle = self.Controller:LocalToWorldAngles(Ang)
		--end
		self.ShadowParams.deltatime = deltatime
		self.ShadowParams.teleportdistance = self.TPD
		self.ShadowParams.maxangular = self.Speed
		self.ShadowParams.maxangulardamp = self.Speed * 0.1
		self.ShadowParams.maxspeed = self.Speed
		self.ShadowParams.maxspeeddamp = self.Speed * 0.1
		
		phys:ComputeShadowControl(self.ShadowParams)
		
		local NVel = phys:GetVelocity()
		
		local CVel = OVel - NVel
		
		self.ShadowParams.pos = RPos + CVel
		
		phys:ComputeShadowControl(self.ShadowParams)
	end
end


function ENT:PhysicsUpdate( phys )
	if self.Recip then
		local OVel = phys:GetVelocity()
		local RPos = self.Plat:GetPos() + (self.Entity:GetUp() * self.ZCo * -1) + (self.Entity:GetForward() * self.YCo * -1) + (self.Entity:GetRight() * self.XCo * -1)
		
		NVel = ((OVel / self.Vel) - ((RPos - self.Entity:GetPos()) * self.Vel)) + ((RPos - self.Entity:GetPos()) * self.Vel)
		phys:SetVelocity(NVel)
	end
end

*/

function ENT:Think()
	
	if self.PasteDelay then return end
	
	if (!self.Plat or !self.Plat:IsValid()) and self.PlModel then
		self.Plat = ents.Create( "MobilePlatform" )
		self.Plat:SetModel( self.PlModel )
		self.Plat:SetPos( self.Entity:GetPos() )
		self.Plat:SetAngles( self.Entity:GetAngles() )
		self.Plat.Controller = self.Entity
		self.Plat:Spawn()
		self.Plat:Initialize()
		self.Plat:Activate()
		self.PNoc = constraint.NoCollide(self.Entity,self.Plat,0,0)
		if self.Skin then
			self.Plat:SetSkin( self.Skin )
		end
		self.Plat.PasteDelay = false
		--self.MWeld = constraint.Weld(self.Entity,self.Plat,0,0,0,true)
		--self.Plat:SetParent(self.Entity)
	end
	--self.Plat:SetLocalPos(Vector(self.XCo, self.YCo, self.ZCo))
	--self.Plat:SetLocalAngles(Vector(self.Pitch, self.Yaw, self.Roll))
	--print(self.PlModel)
	/*
	if !self.AbsAng then
		local RAng = self.Entity:GetAngles()
		
		RAng.y = math.fmod(RAng.y + self.Yaw,360)
		RAng.r = math.fmod(RAng.r + self.Roll,360)
		RAng.p = math.fmod(RAng.p + self.Pitch,360)
	
		self.Plat.Yaw = RAng.y
		self.Plat.Roll = RAng.r
		self.Plat.Pitch = RAng.p
	else
	*/
		self.Plat.Yaw = self.Yaw
		self.Plat.Roll = self.Roll
		self.Plat.Pitch = self.Pitch
	--end
	
	self.Plat.AbsAng = self.AbsAng
	
	if !self.AbsVec then

		--[[local YawX = 0
		local YawY = 0
		local RollX = 0
		local RollZ = 0
		local PitchY = 0
		local PitchZ = 0]]
		local RPos = Vector( self.XCo , self.YCo , self.ZCo )
		
		if self.FulX ~= 0 or self.FulY ~= 0 or self.FulZ ~= 0 then
			local FulVec = Vector( self.FulX , self.FulY , self.FulZ )
			FulVec:Rotate( Angle( self.Pitch , self.Yaw , self.Roll ) )
			
			RPos = RPos - FulVec
			
			--[[if self.Pitch ~= 0 then
				PitchY = (math.cos(math.rad(self.Pitch)) * -self.FulY) + (math.sin(math.rad(self.Pitch)) * self.FulZ)
				PitchZ = (math.sin(math.rad(self.Pitch)) * self.FulY) + (math.cos(math.rad(self.Pitch)) * self.FulZ)
			elseif self.Roll ~= 0 then
				RollX = (math.sin(math.rad(self.Roll)) * self.FulZ) + (math.cos(math.rad(self.Yaw)) * self.FulX)
				RollZ = (math.cos(math.rad(self.Roll)) * self.FulZ) + (math.sin(math.rad(self.Yaw)) * -self.FulX)
			elseif self.Yaw ~= 0 then
				YawX = (math.sin(math.rad(self.Yaw)) * self.FulY) + (math.cos(math.rad(self.Yaw)) * self.FulX)
				YawY = (math.cos(math.rad(self.Yaw)) * -self.FulY) + (math.sin(math.rad(self.Yaw)) * self.FulX)
			end]]
		end
		
		--local RPos = self.Entity:GetPos() + (self.Entity:GetUp() * (self.ZCo + RollZ + PitchZ)) + (self.Entity:GetForward() * (self.YCo + YawY + PitchY)) + (self.Entity:GetRight() * (self.XCo + YawX + RollX))
		--local Pos = self.Entity:GetPos() + (self.Entity:GetUp() * RPos.z) + (self.Entity:GetForward() * RPos.y) + (self.Entity:GetRight() * RPos.x)
		local Pos = self.Entity:LocalToWorld( RPos )

		
		self.Plat.XCo = Pos.x
		self.Plat.YCo = Pos.y
		self.Plat.ZCo = Pos.z
	else
		self.Plat.XCo = self.XCo
		self.Plat.YCo = self.YCo
		self.Plat.ZCo = self.ZCo
	end
	
	--self.Plat:SetLocalPos(Vector(self.XCo,self.YCo,self.ZCo))
	--self.Plat:SetLocalAngles(Angle(self.Pitch,self.Yaw,self.Roll))
	
	self.Plat.Duration = self.Duration
	
	self.Plat.TPD = self.TPD
	
	self.Plat.Speed = self.Speed
	
	local phys = self.Entity:GetPhysicsObject()
	
	if self.Recip then
		local NVel = self:GetPhysicsObject():GetVelocity()
		local RPos = self.Plat:GetPos() + (self:GetUp() * -self.ZCo) + (self:GetForward() * -self.YCo) + (self:GetRight() * -self.XCo) --+ (self.Controller:GetPhysicsObject():GetVelocity() * self.Controller.Vel ) --(phys:GetVelocity() * 0.8)
		self:SetPos(RPos)
		phys:SetVelocity(NVel)
	end
		
	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:Touch( ent )
	
end

function ENT:Use( activator, caller )
	self.PasteDelay = false
	if activator:KeyDown( IN_SPEED ) and activator:KeyDown( IN_WALK ) then
		local RPos = Vector( self.XCo , self.YCo , self.ZCo )
		
		if self.FulX ~= 0 or self.FulY ~= 0 or self.FulZ ~= 0 then
			local FulVec = Vector( self.FulX , self.FulY , self.FulZ )
			FulVec:Rotate( Angle( self.Pitch , self.Yaw , self.Roll ) )
			RPos = RPos - FulVec
		end
		
		local Pos = self.Plat:LocalToWorld( RPos * -1 )
		self.Entity:SetPos(Pos)
	end
end

function ENT:PreEntityCopy()
	local DI = {}

	if (self.Plat) and (self.Plat:IsValid()) then
	    DI.Plat = self.Plat:EntIndex()
	end
	
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self.Entity )
	end
	
	duplicator.StoreEntityModifier(self, "SBEPMobPlatCont", DI)
end
duplicator.RegisterEntityModifier( "SBEPMobPlatCont" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPMobPlatCont

	if (DI.Plat) then
		self.Plat = CreatedEntities[ DI.Plat ]
		/*if (!self.Plat) then
			self.Plat = ents.GetByIndex(DI.Plat)
		end*/
	end
	
	if(Ent.EntityMods and Ent.EntityMods.SBEPMobPlatCont.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPMobPlatCont.WireData, function(id) return CreatedEntities[id] end)
	end

end