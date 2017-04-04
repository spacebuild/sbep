
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/items/combine_rifle_ammo01.mdl" )
	self.Entity:SetName("Fuel Cloud")
	--self.Entity:PhysicsInit( SOLID_VPHYSICS )
	local r = 5
	self.Entity:PhysicsInitSphere(r)
	self.Entity:SetCollisionBounds(Vector(-r,-r,-r),Vector(r,r,r))
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup(3)
	self.Ignition = false
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass(1)
		phys:SetMaterial( "gmod_ice" )
	end
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	self.Entity:Fire("kill", "", math.random(25,30))
	
	self.hasdamagecase = true
	
	self.BTime = CurTime()
	self.DTime = 0
	
	self.Entity:SetColor(Color(0,0,0,1))
end

function ENT:Think()
	self.PhysObj:SetVelocity(self.PhysObj:GetVelocity() * 0.90)
	if !self.Ignited then
		local targets = ents.FindInSphere( self.Entity:GetPos(), 50)
		for _,i in pairs(targets) do
			if i:GetClass() == self.Entity:GetClass() then
				--if !i.Ignition then
					i:GetPhysicsObject():ApplyForceCenter((i:GetPos() - self.Entity:GetPos()):GetNormal() * 2)
				--end
			end
			if i:IsOnFire() then
				self.Entity:PreIgnite(0.1)
			end
		end
	else
		local Power = 10
		--local FVec = Vector(0,0,0)
		local targets = ents.FindInSphere( self.Entity:GetPos(), 400)
		for _,i in pairs(targets) do
			if i:GetClass() == self.Entity:GetClass() then
				if !self:IsPuddle() then
					Power = Power + 40
				else
					Power = Power + 1
				end
				--FVec = FVec + (i:GetPos() - self.Entity:GetPos()
				--i:GetPhysicsObject():ApplyForceCenter((i:GetPos() - self.Entity:GetPos()):GetNormal() * Power)
			end
		end
		for _,i in pairs(targets) do
			if i:GetClass() == self.Entity:GetClass() and !i:IsPuddle() then
				i:GetPhysicsObject():ApplyForceCenter((i:GetPos() - self.Entity:GetPos()):GetNormal() * Power)
			end
		end
		if !self.Entity:IsPuddle() then
			util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 200, Power * 100)
		end
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 400, Power * 10)
		--util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 800, Power * 0.1)
	end
	if self.PuddlePrep then
		self.Entity:Puddle()
		if self.PudEnt:IsWorld() then
			self.Entity:SetPos(self.PudLoc)
		else
			self.Entity:SetPos(self.PudEnt:NearestPoint(self.Entity:GetPos()))
		end
		self.Entity:SetAngles((self.PudNorm + Vector(0,0,0.1)):Angle())
		local FWeld = constraint.Weld(self.Entity,self.PudEnt,0,0,0,true)
		self.Entity:GetPhysicsObject():EnableCollisions(false)
		self.Entity:GetPhysicsObject():EnableGravity(false)
		self.PuddlePrep = false
	end
end

function ENT:PhysicsCollide( data, phys )
	if !self.Entity:IsPuddle() and !self.Ignition and !self.Ignited and self.CanPuddle then
		self.PuddlePrep = true
		self.PudNorm = data.HitNormal * -1
		self.PudEnt = data.HitEntity
		self.PudLoc = self.Entity:GetPos()
	else
		NVel = data.OurOldVelocity + (data.HitNormal * (data.Speed * 5))
		phys:SetVelocity(NVel)
	end
end


function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "TFuelSpray" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:OnTakeDamage( info )
	self.Entity:PreIgnite(0.1)
end

function ENT:gcbt_breakactions(damage, pierce)
	self.Entity:PreIgnite(0.1)
end

function ENT:PreIgnite( T )
	T = T or 0
	if !self.Ignition then
		local IgT = math.Rand(0.1 + T, 0.5 + T) -- Best to add a small delay, just so it doesn't nuke the computer by generating several hundred effects in the same frame or something.
		local T = timer.Simple(IgT,function()
			if self:IsValid() then
				self:Whomph()
			end
		end)
	end
	self.Ignition = true
end

function ENT:Whomph()
	self.Entity:EmitSound("ambient/fire/mtov_flame2.wav")
	self.Ignited = true
	self.Entity:Burn()
	if self.efct and self.efct:IsValid() then
		self.efct:Remove()
	end
	self.Entity:Fire("kill", "", math.Rand(2,4))
	--self.DTime = CurTime() + math.Rand(2,4)
	local Power = 50
	local targets = ents.FindInSphere( self.Entity:GetPos(), 250)
	for _,i in pairs(targets) do
		if i:GetClass() == self.Entity:GetClass() then
			Power = Power + 20
		end
	end
	-- I'm running through the targets twice, once to find the power, once to apply it to nearby... victims...
	for _,i in pairs(targets) do
		if i:GetClass() == "prop_physics" then
			local Force = i:GetPhysicsObject():GetMass() * (Power * 2)
				i:GetPhysicsObject():ApplyForceOffset( Vector(500000,500000,500000), self.Entity:GetPos() )
			gcombat.devhit( i, math.random(Power * 0.1,Power * 5), 4 )
		elseif i:IsPlayer() or i:IsNPC() then
			local Force = Power * 10
			i:SetVelocity( Vector(500000,500000,500000) )
		end
	end
	
	util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 300, Power * 100)
	util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 600, Power * 10)
	--cbt_hcgexplode( self.Entity:GetPos(), Power, math.random(Power * 0.1,Power * 5), 5)
	
end