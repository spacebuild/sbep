AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "explode_8" )
util.PrecacheSound( "explode_5" )

function ENT:Initialize()

	self:SetModel( "models/props_phx/mk-82.mdl" )
	self:SetName("SmallBomb")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end

    --self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	

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
	self:SetAngles( Vel:Angle() )
	phys:SetVelocity(Vel)
end

function ENT:Splode()
	if(!self.Exploded) then
		--self.Exploded = true
		util.BlastDamage(self, self, self:GetPos(), 400, 400)
		cbt_hcgexplode( self:GetPos(), 400, math.random(400,600), 7)
		local targets = ents.FindInSphere( self:GetPos(), 1000)
	
		for _,i in pairs(targets) do
			if i:GetClass() == "prop_physics" then
				i:GetPhysicsObject():ApplyForceOffset( (i.Entity:NearestPoint(self:GetPos()) - self:GetPos()):Normalize() * (i:GetPhysicsObject():GetMass() * 500), self:GetPos() )
			end
		end
		
		self:EmitSound("explode_9")
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetStart(self:GetPos())
		effectdata:SetMagnitude(3)
		util.Effect( "BigWhomphSplode", effectdata )
		self.Exploded = true
		
		local ShakeIt = ents.Create( "env_shake" )
		ShakeIt:SetName("Shaker")
		ShakeIt:SetKeyValue("amplitude", "200" )
		ShakeIt:SetKeyValue("radius", "600" )
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