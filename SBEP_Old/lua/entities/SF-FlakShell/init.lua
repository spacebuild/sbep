AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Items/AR2_Grenade.mdl" )
	self:SetName("Artillery Shell")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	gcombat.registerent( self, 10, 4 )

    self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	util.SpriteTrail( self, 0,  Color(255,50,50,200), false, 10, 0, 1, 1, "trails/smoke.vmt" )

	self.hasdamagecase = true
end

function ENT:PhysicsUpdate()

	if(self.Exploded) then
		self:Remove()
		return
	end

end

function ENT:Think()
	
	if (self.PreLaunch == false) then
		self.PreLaunch = true
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:EnableGravity(true)
			phys:EnableDrag(true)
			phys:EnableCollisions(true)
			phys:EnableMotion(true)
		end
	

		 
		--self.PhysObj:SetVelocity(self:GetForward()*3100)

		self.PreLaunch = true
	end
	
	if (self.Exploded ~= true) then
		self:SetAngles(self.CAng)
	end
	
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:GetPos() + (self:GetForward() * 200)
	trace.filter = self
	local tr = util.TraceLine( trace )
	if !tr.Hit then
		self:SetPos(self:GetPos() + self:GetForward() * 200)
	else
		if tr.HitSky then
			self:Remove()
		else
			self.PhysObj:SetVelocity(self:GetForward()*3100)
		end
	end
	if self.TCount > 1 then
		local TFound = 0
		local targets = ents.FindInSphere( self:GetPos(), 200)
		
		if targets then
			for _,i in pairs(targets) do
				if i:GetPhysicsObject() and i:GetPhysicsObject():IsValid() and i:GetPhysicsObject():GetMass() > 0 and i:GetClass() ~= self:GetClass() and i:GetClass() ~= "wreckedstuff" then
					TFound = TFound + 1
				end
			end
			if TFound > 0 then
				self:GoBang()
			end
		end
	end

	self.TCount = self.TCount + 1
	self:NextThink( CurTime() + 0.01 )
	return true
end

function ENT:PhysicsCollide( data, physobj )
	if(!self.Exploded) then
		--self:GoBang()
	end
	--self.Exploded = true
end

function ENT:OnTakeDamage( dmginfo )
	if(!self.Exploded) then
		--self:GoBang()
	end
	--self.Exploded = true
end

function ENT:Use( activator, caller )

end

function ENT:GoBang()
	if !self.Exploded then
		self.Exploded = true
		util.BlastDamage(self, self, self:GetPos(), 500, 75)
		SBGCSplash( self:GetPos(), 500, math.Rand(100, 200), 6, { self:GetClass() } )
	
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetStart(self:GetPos())
		util.Effect( "Explosion", effectdata )
	end
end

function ENT:gcbt_breakactions( damage, pierce )
	if !self.Exploded then
		self:GoBang()
	end
	self.Exploded = true
end