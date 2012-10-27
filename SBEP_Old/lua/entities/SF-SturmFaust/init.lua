AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "explode_8" )
util.PrecacheSound( "explode_5" )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/missile_sturmfaustshot.mdl" )
	self:SetName("HomingMissile")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetMaterial("models/props_combine/combinethumper002")
	--self.Inputs = Wire_CreateInputs( self, { "Arm" } )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end

	gcombat.registerent( self, 10, 4 )
	self.Armed = false
	
    --self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	
end

function ENT:PhysicsUpdate()
	if self.Armed then
		local physi = self:GetPhysicsObject()
		physi:SetVelocity( self:GetForward() * 5000 )
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
	trace.start = self:GetPos()
	trace.endpos = self:GetPos() + (self:GetVelocity())
	trace.filter = self
	local tr = util.TraceLine( trace )
	if tr.Hit and tr.HitSky then
		self:Remove()
	end
end

function ENT:Splode()
	if(!self.Exploded) then
		self.Exploded = true
		util.BlastDamage(self, self, self:GetPos(), 100, 100)
		SBGCSplash( self:GetPos(), 100, math.Rand(400, 700), 9, { self:GetClass() } )
		
		--targets = ents.FindInSphere( self:GetPos(), 2000)
		
		self:EmitSound("explode_9")
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetStart(self:GetPos())
		util.Effect( "explosion", effectdata )
		self.Exploded = true
		
		local ShakeIt = ents.Create( "env_shake" )
		ShakeIt:SetName("Shaker")
		ShakeIt:SetKeyValue("amplitude", "200" )
		ShakeIt:SetKeyValue("radius", "200" )
		ShakeIt:SetKeyValue("duration", "5" )
		ShakeIt:SetKeyValue("frequency", "255" )
		ShakeIt:SetPos( self:GetPos() )
		ShakeIt:Fire("StartShake", "", 0);
		ShakeIt:Spawn()
		ShakeIt:Activate()
		
		ShakeIt:Fire("kill", "", 6)
	end
	self.Exploded = true
	self:Remove()
end