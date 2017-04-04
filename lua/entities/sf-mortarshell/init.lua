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
	
	self.cbt = {}
	self.cbt.health = 5000
	self.cbt.armor = 500
	self.cbt.maxhealth = 5000
		
    --self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.CAng = self.Entity:GetAngles()
	util.SpriteTrail( self.Entity, 0, Color(50,50,50,50), false, 10, 0, 1, 1, "trails/smoke.vmt" ) --"trails/smoke.vmt"


end

function ENT:PhysicsUpdate(phys)

	local Vel = phys:GetVelocity()
	self.Entity:SetAngles( Vel:Angle() )
	phys:SetVelocity(Vel)

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
	
	if self.RifleNade then
		self.Entity:GetPhysicsObject():SetVelocity(self.Entity:GetForward() * 3000)
	end
	
	local trace = {}
	trace.start = self.Entity:GetPos()
	trace.endpos = self.Entity:GetPos() + (self.Entity:GetVelocity())
	trace.filter = self.Entity
	local tr = util.TraceLine( trace )
	if tr.Hit and tr.HitSky then
		self.Entity:Remove()
	end
	
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
	util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 200, 75)
	--gcombat.hcgexplode( self.Entity:GetPos(), 200, math.Rand(50, 100), 7)

	self.Entity:EmitSound("explode_4")
	
	local effectdata = EffectData()
	effectdata:SetOrigin(self.Entity:GetPos())
	effectdata:SetStart(self.Entity:GetPos())
	effectdata:SetAngles(self.Entity:GetAngles())
	util.Effect( "TinyWhomphSplode", effectdata )
end