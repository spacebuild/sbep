AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "explode_8" )
util.PrecacheSound( "explode_5" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/missile_smallmissile.mdl" )
	self.Entity:SetName("SmallBomb")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end

    --self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.CAng = self.Entity:GetAngles()
	

end

function ENT:Think()

end

function ENT:PhysicsCollide( data, physobj )
	if (!self.Exploded) then
		self:Splode()
	end
end

function ENT:PhysicsUpdate( phys )
	local Vel = phys:GetVelocity()
	self.Entity:SetAngles( Vel:Angle() )
	phys:SetVelocity(Vel)
	phys:EnableCollisions(true)
end

function ENT:Splode()
	if(!self.Exploded) then
		--self.Exploded = true
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 300, 300)
		cbt_hcgexplode( self.Entity:GetPos(), 300, math.random(1000,1500), 6)
		local targets = ents.FindInSphere( self.Entity:GetPos(), 1000)
	
		for _,i in pairs(targets) do
			if i:GetClass() == "prop_physics" then
				i:GetPhysicsObject():ApplyForceOffset( Vector(5000,5000,5000), self.Entity:GetPos() )
			end
		end
		
		self.Entity:EmitSound("explode_9")
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetStart(self.Entity:GetPos())
		effectdata:SetMagnitude(3)
		util.Effect( "WhomphSplode", effectdata )
		self.Exploded = true
		
		local ShakeIt = ents.Create( "env_shake" )
		ShakeIt:SetName("Shaker")
		ShakeIt:SetKeyValue("amplitude", "200" )
		ShakeIt:SetKeyValue("radius", "500" )
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