AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--util.PrecacheSound( "SB/SteamEngine.wav" )

function ENT:Initialize()
	
	self.Entity:SetModel( "models/Slyfo_2/acc_food_stridernugsml.mdl" ) 
	self.Entity:SetName( "SensorContact" )
	self.Entity:PhysicsInit( 6 )
	self.Entity:SetMoveType( 0 )
	self.Entity:SetSolid( 0 )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
		phys:SetMass(1)
	end
	self.Entity:StartMotionController()
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	self.hasdamagecase = true
	
	self.Energy = self.Energy or 500
	self.FadeRate = self.FadeRate or 1
	self.Size = self.Size or 500
	self.IFF = self.IFF or 0 -- 0 = Unknown, 1 = Neutral, 2 = Friendly, 3 = Hostile
	self.Type = 0 -- 0 = Unknown/Unclassified, 1 = Engine, 2 = Sensor, 3 = Explosion, 4 = Projectile, 5 = Radialogical (Nuke/WMD), 6 = Garbage
	self.Penalty = self.Penalty or 0
	
	self.LTT = CurTime()
end

function ENT:Think()
	local Delta = CurTime() - self.LTT
	self.Energy = self.Energy - (self.FadeRate * Delta)
	if self.Energy <= 0 then self:Remove() end
	
	
	self.LTT = CurTime()
end

function ENT:OnRemove()
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )
	
end

function ENT:gcbt_breakactions(damage, pierce)

end