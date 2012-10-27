
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Slyfo_2/rocketpod_smallrocket.mdl" )
	self:SetName("Drunk Shell")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(GROUP_PROJECTILE)
	
	local phys = self:GetPhysicsObject()
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
		
    --self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	util.SpriteTrail( self, 0, Color(50,50,50,50), false, 10, 0, 1, 1, "trails/smoke.vmt" ) --"trails/smoke.vmt"

	self.Drunk = self.Drunk or 1
	self.CSAng = math.random(0,360)
	self.CSSpeed = math.Clamp(math.random(-100 * self.Drunk,100 * self.Drunk),-100,100)
	self.CSXSp = math.random(0,10 * self.Drunk)
	self.CSYSp = math.random(0,10 * self.Drunk)
	self.STime = CurTime()
end

function ENT:PhysicsUpdate(phys)
	
	if(self.Exploded) then
		self:Remove()
		return
	end

end

function ENT:Think()

	local LTime = CurTime() - self.STime
	local DistTime = 10000
	if self.Distance then
		DistTime = self.Distance * 0.001
	end
	--print(self.Distance, DistTime, LTime)
	if LTime > 10 or LTime > DistTime then
		self:GoBang()
		--print(self.Distance, DistTime, LTime)
	end

	self.CSAng = math.fmod(self.CSAng + self.CSSpeed,360)
	--print(self.CSAng)
	local XShift = math.sin(math.rad( self.CSAng )) * self.CSXSp
	local YShift = math.cos(math.rad( self.CSAng )) * self.CSYSp
	--print(XShift, YShift)

	self:GetPhysicsObject():SetVelocity((self:GetForward() * (1000)) + (self:GetRight() * XShift)+ (self:GetUp() * YShift))
	
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:GetPos() + (self:GetVelocity())
	trace.filter = self
	local tr = util.TraceLine( trace )
	if tr.Hit and tr.HitSky then
		self:Remove()
	end
	
	self:NextThink(CurTime() + 0.1)
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
	local LTime = CurTime() - self.STime
	if LTime > 0.5 then
		util.BlastDamage(self, self, self:GetPos(), 400, 50)
		--gcombat.hcgexplode( self:GetPos(), 200, math.Rand(50, 100), 7)
	
		self:EmitSound("explode_4")
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetStart(self:GetPos())
		effectdata:SetAngle(self:GetAngles())
		util.Effect( "TinyWhomphSplode", effectdata )
	end
end