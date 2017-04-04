AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "explode_8" )
util.PrecacheSound( "explode_5" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/missile_sturmfaustshot.mdl" )
	self.Entity:SetName("HomingMissile")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	--self.Entity:SetMaterial("models/props_combine/combinethumper002")
	--self.Inputs = Wire_CreateInputs( self.Entity, { "Arm" } )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end

	gcombat.registerent( self.Entity, 10, 4 )
	self.Armed = false
	
    --self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
end

function ENT:PhysicsUpdate()
	if self.Armed then
		local physi = self.Entity:GetPhysicsObject()
		//physi:SetVelocity( self.Entity:GetForward() * 5000 )
	end
end

function ENT:PhysicsCollide( data, physobj )
	if (!self.Exploded and self.Armed) then
		self:Splode()
	end
end

function ENT:OnTakeDamage( dmginfo )
	--if (!self.Exploded and self.Armed) then
		--self:Splode()
	--end
end

function ENT:Think()
	local trace = {}
	trace.start = self.Entity:GetPos()
	trace.endpos = self.Entity:GetPos() + (self.Entity:GetVelocity())
	trace.filter = self.Entity
	local tr = util.TraceLine( trace )
	if tr.Hit and tr.HitSky then
		self.Entity:Remove()
	end
end

function ENT:Splode()
	if(!self.Exploded) then
		self.Exploded = true
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 100)
		SBGCSplash( self.Entity:GetPos(), 100, math.Rand(400, 700), 9, { self.Entity:GetClass() } )
		
		--targets = ents.FindInSphere( self.Entity:GetPos(), 2000)
		
		self.Entity:EmitSound("explode_9")
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetStart(self.Entity:GetPos())
		util.Effect( "explosion", effectdata )
		self.Exploded = true
		
		local ShakeIt = ents.Create( "env_shake" )
		ShakeIt:SetName("Shaker")
		ShakeIt:SetKeyValue("amplitude", "200" )
		ShakeIt:SetKeyValue("radius", "200" )
		ShakeIt:SetKeyValue("duration", "5" )
		ShakeIt:SetKeyValue("frequency", "255" )
		ShakeIt:SetPos( self.Entity:GetPos() )
		ShakeIt:Fire("StartShake", "", 0);
		ShakeIt:Spawn()
		ShakeIt:Activate()
		
		ShakeIt:Fire("kill", "", 6)
	end
	self.Exploded = true
	self.Entity:Remove()
end