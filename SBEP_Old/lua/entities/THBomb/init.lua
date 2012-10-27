
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "explode_8" )
util.PrecacheSound( "explode_5" )

function ENT:Initialize()

	self:SetModel( "models/props_phx/torpedo.mdl" )
	self:SetName("SmallBomb")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if !self.Armed then
		self.Inputs = Wire_CreateInputs( self, { "Arm", "Detonate" } )
	end
	
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

function ENT:TriggerInput(iname, value)		
	
	if (iname == "Arm") then
		if (value > 0) then
			self.Armed = true
		end
		
	elseif (iname == "Detonate") then
		if (value > 0) then
			self:Splode()
		end
	
	end
	
end

function ENT:Think()

end

function ENT:PhysicsCollide( data, physobj )
	if (self.Armed and !self.Exploded) then
		self:Splode()
	end
end

function ENT:PhysicsUpdate( phys )
	if self.Armed then
		local Vel = phys:GetVelocity()
		self:SetAngles( Vel:Angle() )
		phys:SetVelocity(Vel)
	end
end

function ENT:Splode()
	if(!self.Exploded) then
		--self.Exploded = true
		--util.BlastDamage(self, self, self:GetPos(), 400, 400)
		--cbt_hcgexplode( self:GetPos(), 400, math.random(400,600), 7)
		
		local SSpeed = 10
		local NewShell = nil
		for i = 0, 10 do
			NewShell = ents.Create( "TFuelSpray" )
			if ( !NewShell:IsValid() ) then return end
			NewShell:SetPos( self:GetPos() + Vector(math.random(-SSpeed,SSpeed),math.random(-SSpeed,SSpeed),math.random(-SSpeed,SSpeed)) )
			NewShell.SPL = self.SPL
			NewShell:Spawn()
			NewShell:Initialize()
			NewShell:Activate()
			NewShell:GetPhysicsObject():SetVelocity((self:GetPhysicsObject():GetVelocity() * 0.25) + (self:GetRight() * math.random(-100,100)) + (self:GetUp() * math.random(-100,100)) )
		end
		NewShell:PreIgnite(3)
		local targets = ents.FindInSphere( self:GetPos(), 1000)
	
		for _,i in pairs(targets) do
			if i:GetClass() == "prop_physics" then
				i:GetPhysicsObject():ApplyForceOffset( (i.Entity:NearestPoint(self:GetPos()) - self:GetPos()):Normalize() * (i:GetPhysicsObject():GetMass() * 500), self:GetPos() )
			end
		end
		
		
		self:EmitSound("explode_9")
		
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