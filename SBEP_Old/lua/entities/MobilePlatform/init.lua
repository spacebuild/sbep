AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	--self.Entity:SetModel( "models/props_c17/consolebox01a.mdl" ) 
	self.Entity:SetName("MobilePlatform")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass(200)
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
		
	self.Duration = 0.005
	
	self.TPD = 0
		
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

function ENT:PhysicsSimulate( phys, deltatime )
	
	if self.PasteDelay or !self.Controller or !self.Controller:IsValid() or self.Controller.Disabled then return SIM_NOTHING end
	
	phys:Wake()
	local Ang = Angle(0,0,0)
	Ang.y = self.Yaw
	Ang.r = self.Roll
	Ang.p = self.Pitch
	
	
	
	self.ShadowParams.secondstoarrive = self.Duration
	self.ShadowParams.pos = Vector(self.XCo,self.YCo,self.ZCo)
	if self.AbsAng then
		self.ShadowParams.angle = Ang
	else
		self.ShadowParams.angle = self.Controller:LocalToWorldAngles(Ang)
	end
	self.ShadowParams.deltatime = deltatime
	self.ShadowParams.teleportdistance = self.TPD
	self.ShadowParams.maxangular = self.Speed
	self.ShadowParams.maxangulardamp = self.Speed * 0.1
	self.ShadowParams.maxspeed = self.Speed
	self.ShadowParams.maxspeeddamp = self.Speed * 0.1
	
	local RPos = self.Entity:GetPos() + (self.Controller:GetUp() * -self.ZCo) + (self.Controller:GetForward() * -self.YCo) + (self.Controller:GetRight() * -self.XCo) --+ (self.Controller:GetPhysicsObject():GetVelocity() * self.Controller.Vel ) --(phys:GetVelocity() * 0.8)
	
	return phys:ComputeShadowControl(self.ShadowParams)
	
end

function ENT:Think()
		
	if self.PasteDelay or self.Controller.Disabled then return end
	
	if !self.Controller or !self.Controller:IsValid() then
		self.Entity:Remove()
		return
	end
			
	if self.TPD == 1 then
		self.Entity:SetPos(Vector(self.XCo,self.YCo,self.ZCo))
		local Ang = Angle(0,0,0)
		Ang.y = self.Yaw
		Ang.r = self.Roll
		Ang.p = self.Pitch
		if self.AbsAng then
			self.Entity:SetAngles(Ang)
		else
			self.Entity:SetAngles(self.Controller:LocalToWorldAngles(Ang))
		end
	end
	
	self.Entity:NextThink( CurTime() + 0.01 )
	return true
end

function ENT:Use( activator, caller )
	self.PasteDelay = false
	/*
	if !self.Socked then
		--Vector( self.Controller.FulX , self.Controller.FulY , self.Controller.FulZ )
		local LPos = Vector(0,0,0)--self.Controller:WorldToLocal(self:GetPos() + self:GetRight() * self.Controller.FulX + self:GetForward() * self.Controller.FulY + self:GetUp() * self.Controller.FulZ)
		local Cons = constraint.Ballsocket( self, self.Controller, 0, 0, LPos, 0, 0, 1)
		self.Socked = true
	end
	*/
end

function ENT:PreEntityCopy()
	local DI = {}

	if (self.Controller) and (self.Controller:IsValid()) then
	    DI.Controller = self.Controller:EntIndex()
	end
	
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self.Entity )
	end
	
	duplicator.StoreEntityModifier(self, "SBEPMobPlat", DI)
end
duplicator.RegisterEntityModifier( "SBEPMobPlat" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPMobPlat

	if (DI.Controller) then
		self.Controller = CreatedEntities[ DI.Controller ]
		/*if (!self.Controller) then
			self.Controller = ents.GetByIndex(DI.Controller)
		end*/
	end
	
	if(Ent.EntityMods and Ent.EntityMods.SBEPMobPlat.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPMobPlat.WireData, function(id) return CreatedEntities[id] end)
	end

end