
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Dts Stuff/BF2142 weapons/unl_grenade_frag_2.mdl" )
	self:SetName("Frag Nade")
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
		
    --self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	util.SpriteTrail( self, 0, Color(50,50,50,50), false, 10, 0, 1, 1, "trails/smoke.vmt" ) --"trails/smoke.vmt"
	
	self.DTime = CurTime() + 5


end

function ENT:PhysicsUpdate(phys)

	if(self.Exploded) then
		self:Remove()
		return
	end

end

function ENT:Think()
	
	if CurTime() > self.DTime then
		self:GoBang()
	end
	
	if(self.Exploded) then
		self:Remove()
		return
	end
end

function ENT:Use( activator, caller )

end

function ENT:GoBang()
	self.Exploded = true
	util.BlastDamage(self, self, self:GetPos(), 300, 150)
	gcombat.hcgexplode( self:GetPos(), 200, math.Rand(50, 100), 7)

	self:EmitSound("explode_4")
	
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetStart(self:GetPos())
	effectdata:SetAngle(self:GetAngles())
	util.Effect( "TinyWhomphSplode", effectdata )
	
	self:Remove()
end