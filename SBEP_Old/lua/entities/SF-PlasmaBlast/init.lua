
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Items/combine_rifle_ammo01.mdl" )
	self:SetName("Plasma Burst")
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
	
	self.cbt = {}
	self.cbt.health = 5000
	self.cbt.armor = 500
	self.cbt.maxhealth = 5000
		
    self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	--util.SpriteTrail( self, 0, Color(50,50,200,50), false, 10, 0, 1, 1, "models/effects/splodearc_sheet.vmt" ) --"trails/smoke.vmt"

	self.Power = self.Power or 1
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
	trace.endpos = self:GetPos() + (self:GetForward() * 300)
	trace.filter = self
	local tr = util.TraceLine( trace )
	if !tr.Hit then
		self:SetPos(self:GetPos() + self:GetForward() * 300)
	else
		if tr.HitSky then
			self:Remove()
		else
			self.PhysObj:SetVelocity(self:GetForward()*3100)
		end
	end

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
		--self:GoBang()
	end
end

function ENT:Use( activator, caller )

end

function ENT:GoBang()
	self.Exploded = true
	util.BlastDamage(self, self, self:GetPos(), self.Power * 2, self.Power * 1.5)
	gcombat.nrgexplode( self:GetPos(),  self.Power * 1.5, math.Rand(self.Power, self.Power * 5), 8)

	self:EmitSound("WeaponDissolve.Dissolve")
	
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetStart(self:GetPos())
	effectdata:SetAngle(self:GetAngles())
	effectdata:SetScale(self.Power)
	util.Effect( "PlasmaImpact", effectdata )
end