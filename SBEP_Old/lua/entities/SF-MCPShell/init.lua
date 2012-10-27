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

    	self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	util.SpriteTrail( self, 0,  Color(50,50,50,100), false, 10, 0, 1, 1, "trails/smoke.vmt" )


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
		self.CAng = self:GetAngles()
	end
	
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:GetPos() + (self:GetForward() * 500)
	trace.filter = self
	local tr = util.TraceLine( trace )
	if !tr.Hit then
		self:SetPos(self:GetPos() + self:GetForward() * 500)
	else
		if tr.HitSky then
			self:Remove()
		else
			self.PhysObj:SetVelocity(self:GetForward()*3100)
		end
	end

	self.TCount = self.TCount + 1
	self:NextThink( CurTime() + 0.01 )
	return true
end

function ENT:PhysicsCollide( data, physobj )
	if(!self.Exploded) then
		self:GoBang()
	end
end

function ENT:OnTakeDamage( dmginfo )
	if(!self.Exploded) then
		self:GoBang()
	end
end

function ENT:Use( activator, caller )

end

function ENT:GoBang()
	self.Exploded = true
	util.BlastDamage(self, self, self:GetPos(), 700, 75)
	cbt_hcgexplode( self:GetPos(), 700, math.Rand(500, 1000), 6)

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetStart(self:GetPos())
	util.Effect( "Explosion", effectdata )
end