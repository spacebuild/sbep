AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/props_phx/misc/propeller3x_small.mdl" ) 
	self:SetName("Propeller")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 500 )
	end
	self:StartMotionController()
	self.PhysObj = self:GetPhysicsObject()

end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "SP-Propeller" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Think()

end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:PhysicsUpdate()
	local CSAng = self.PhysObj:GetAngleVelocity()
	self.PhysObj:SetVelocity(self:GetVelocity() + self:GetUp() * (CSAng.z * 0.05) )
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Touch( ent )

end

function ENT:Use( ply )

end