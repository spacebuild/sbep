AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Items/AR2_Grenade.mdl" )
	self.Entity:SetName("Artillery Shell")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	gcombat.registerent( self.Entity, 10, 4 )

    self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.CAng = self.Entity:GetAngles()
	util.SpriteTrail( self.Entity, 0,  Color(255,50,50,200), false, 10, 0, 1, 1, "trails/smoke.vmt" )

	self.hasdamagecase = true
end

function ENT:PhysicsUpdate()

	if(self.Exploded) then
		self.Entity:Remove()
		return
	end

end

function ENT:Think()
	
	if (self.PreLaunch == false) then
		self.PreLaunch = true
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:EnableGravity(true)
			phys:EnableDrag(true)
			phys:EnableCollisions(true)
			phys:EnableMotion(true)
		end
	

		 
		--self.PhysObj:SetVelocity(self.Entity:GetForward()*3100)

		self.PreLaunch = true
	end
	
	if (self.Exploded ~= true) then
		self.Entity:SetAngles(self.CAng)
	end
	
	local trace = {}
	trace.start = self.Entity:GetPos()
	trace.endpos = self.Entity:GetPos() + (self.Entity:GetForward() * 200)
	trace.filter = self.Entity
	local tr = util.TraceLine( trace )
	if !tr.Hit then
		self.Entity:SetPos(self.Entity:GetPos() + self.Entity:GetForward() * 200)
	else
		if tr.HitSky then
			self.Entity:Remove()
		else
			self.PhysObj:SetVelocity(self.Entity:GetForward()*3100)
		end
	end
	if self.TCount > 1 then
		local TFound = 0
		local targets = ents.FindInSphere( self.Entity:GetPos(), 200)
		
		if targets then
			for _,i in pairs(targets) do
				if i:GetPhysicsObject() and i:GetPhysicsObject():IsValid() and i:GetPhysicsObject():GetMass() > 0 and i:GetClass() ~= self.Entity:GetClass() and i:GetClass() ~= "wreckedstuff" then
					TFound = TFound + 1
				end
			end
			if TFound > 0 then
				self.Entity:GoBang()
			end
		end
	end

	self.TCount = self.TCount + 1
	self.Entity:NextThink( CurTime() + 0.01 )
	return true
end

function ENT:PhysicsCollide( data, physobj )
	if(!self.Exploded) then
		self.Entity:GoBang()
	end
	self.Exploded = true
end

function ENT:OnTakeDamage( dmginfo )
	if(!self.Exploded) then
		--self.Entity:GoBang()
	end
	--self.Exploded = true
end

function ENT:Use( activator, caller )

end

function ENT:GoBang()
	if !self.Exploded then
		self.Exploded = true
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 500, 75)
		SBGCSplash( self.Entity:GetPos(), 500, math.Rand(100, 200), 6, { self.Entity:GetClass() } )
	
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetStart(self.Entity:GetPos())
		util.Effect( "Explosion", effectdata )
	end
end

function ENT:gcbt_breakactions( damage, pierce )
	if !self.Exploded then
		self.Entity:GoBang()
	end
	self.Exploded = true
end