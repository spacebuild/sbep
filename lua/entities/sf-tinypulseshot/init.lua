AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Items/combine_rifle_ammo01.mdl" )
	self.Entity:SetName("PulseShot")
	local r = 30
	self.Entity:PhysicsInitSphere(r)
    self.Entity:SetCollisionBounds(Vector(-r,-r,-r),Vector(r,r,r))
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup(3)
	
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end
	
	self.cbt = {}
	self.cbt.health = 5000
	self.cbt.armor = 500
	self.cbt.maxhealth = 5000
		
    self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.CAng = self.Entity:GetAngles()
	--util.SpriteTrail( self.Entity, 0, Color(50,50,200,50), false, 10, 0, 1, 1, "models/effects/splodearc_sheet.vmt" ) --"trails/smoke.vmt"


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
			phys:EnableGravity(false)
			phys:EnableDrag(false)
			phys:EnableCollisions(true)
			phys:EnableMotion(true)
		end
		 
		--self.PhysObj:SetVelocity(self.Entity:GetForward()*3100)

		self.PreLaunch = true
	end
	
	if (self.Exploded ~= true) then
		self.CAng = self.Entity:GetAngles()
	end
	
	/*
	local trace = {}
	trace.start = self.Entity:GetPos()
	trace.endpos = self.Entity:GetPos() + (self.Entity:GetForward() * 300)
	trace.filter = self.Entity
	local tr = util.TraceLine( trace )
	if !tr.Hit then
		self.Entity:SetPos(self.Entity:GetPos() + self.Entity:GetForward() * 300)
	else
		if tr.HitSky then
			self.Entity:Remove()
		else
			self.PhysObj:SetVelocity(self.Entity:GetForward()*3100)
		end
	end
	*/

	--self.Entity:NextThink( CurTime() + 0.01 )
	--return true
end

function ENT:PhysicsCollide( data, physobj )
	if(!self.Exploded) then
		self.Entity:GoBang()
	end
end

function ENT:OnTakeDamage( dmginfo )
	if(!self.Exploded) then
		--self.Entity:GoBang()
	end
end

function ENT:Use( activator, caller )

end

function ENT:GoBang()
	self.Exploded = true
	util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 300, 100)
	--gcombat.nrgexplode( self.Entity:GetPos(), 100, math.Rand(100, 200), 7)

	self.Entity:EmitSound("WeaponDissolve.Dissolve")
	
	local effectdata = EffectData()
	effectdata:SetOrigin(self.Entity:GetPos())
	effectdata:SetStart(self.Entity:GetPos())
	effectdata:SetAngles(self.Entity:GetAngles())
	util.Effect( "TinyPulseSplode", effectdata )
end