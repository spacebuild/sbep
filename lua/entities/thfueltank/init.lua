AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/sat_resourcetank.mdl" ) 
	self.Entity:SetName("Fuel Tank")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Inputs = Wire_CreateInputs( self.Entity, { "Vent" } )
	self.Entity:SetUseType( 3 )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass(10)
	end
	self.Entity:StartMotionController()
	self.PhysObj = self.Entity:GetPhysicsObject()

	--RD_AddResource(self.Entity, "thfuel", 0)
	self.LeakPoints = {}
	
	self.Fuel = 600
	self.THealth = 150
	self.hasdamagecase = true
	
end

function ENT:TriggerInput(iname, value)		
	
	if (iname == "Vent") then
		if (value > 0) then
			self.Venting = true
		else
			self.Venting = false
		end
			
	end
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "ThFuelTank" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Think()
	if self.Venting and self.Fuel > 0 then
		local Spray = ents.Create( "TFuelSpray" )
		Spray:SetPos( self.Entity:GetPos() + self.Entity:GetForward() * 40 )
		--Spray:SetAngles( ply:GetAimVector():Angle() + Angle(90, 0, 0))
		Spray:Spawn()
		Spray:GetPhysicsObject():SetVelocity(self.Entity:GetForward() * 1000)
		
		Spray:GetPhysicsObject():EnableGravity(true)
		Spray:SetGravity(0.5)
		
		local Noc = constraint.NoCollide(self.Entity,Spray,0,0)
		
		Spray.CanPuddle = true
		
		self.Fuel = self.Fuel - 10
	end
	
	if self.Leaking and self.Fuel > 0 then
		local Spray = ents.Create( "TFuelSpray" )
		local LPE = math.random(1,table.getn( self.LeakPoints ))
		Spray:SetPos( self.LeakPoints[LPE] + self.Entity:GetPos() )
		--Spray:SetAngles( ply:GetAimVector():Angle() + Angle(90, 0, 0))
		Spray:Spawn()
		Spray:GetPhysicsObject():SetVelocity((Spray:GetPos() - self.Entity:GetPos()) * 100)
		
		--Spray:GetPhysicsObject():EnableGravity(true)
		--Spray:SetGravity(0.5)
		
		local Noc = constraint.NoCollide(self.Entity,Spray,0,0)
		
		--Spray.CanPuddle = true
		
		self.Fuel = self.Fuel - 20
	end
	
	if self.ReadySplode then
		self:Splode()
	end
	
	self.Entity:NextThink( CurTime() + 0.3 ) 
	return true
end

function ENT:OnTakeDamage( dmg )
	--print(dmg:GetDamage())
	self.THealth = self.THealth - dmg:GetDamage()
	if dmg:GetDamage() >= 100 or self.THealth <= 0 then
		self.Entity:Splode()
	elseif dmg:GetDamage() >= 12 then
		self.Leaking = true
		local x, y, z = dmg:GetDamagePosition()
		local LPE = table.getn( self.LeakPoints ) + 1
		self.LeakPoints[LPE] = Vector(x,y,z)
		--print(self.LeakPoints[LPE])
	end
end

function ENT:PhysicsCollide( data, physobj )
	if self.THealth <= 0 then
		self.ReadySplode = true
	end
end

function ENT:Splode()
	if(!self.Exploded) then
		self.Exploded = true
		--util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 400, 400)
		--cbt_hcgexplode( self.Entity:GetPos(), 400, math.random(400,600), 7)
		FCount = math.floor(self.Fuel / 60)
		--print(FCount)
		if FCount >= 1 then
			local SPos = 10
			local SSpeed = 10
			local NewShell = nil
			for i = 1, FCount do
				NewShell = ents.Create( "TFuelSpray" )
				if ( !NewShell:IsValid() ) then return end
				NewShell:SetPos( self.Entity:GetPos() + Vector(math.random(-SPos,SPos),math.random(-SPos,SPos),math.random(-SPos,SPos)) )
				NewShell.SPL = self.SPL
				NewShell:Spawn()
				NewShell:Initialize()
				NewShell:Activate()
				NewShell:GetPhysicsObject():SetVelocity((self.Entity:GetPhysicsObject():GetVelocity() * 0.25) + (self.Entity:GetRight() * math.random(-SSpeed,SSpeed)) + (self.Entity:GetUp() * math.random(-SSpeed,SSpeed))  + (self.Entity:GetForward() * math.random(-SSpeed,SSpeed))  )
			end
			NewShell:PreIgnite(3)
					
			self.Entity:EmitSound("explode_9")
		end
		
		if FCount >= 10 then
			local ShakeIt = ents.Create( "env_shake" )
			ShakeIt:SetName("Shaker")
			ShakeIt:SetKeyValue("amplitude", "200" )
			ShakeIt:SetKeyValue("radius", "600" )
			ShakeIt:SetKeyValue("duration", "5" )
			ShakeIt:SetKeyValue("frequency", "255" )
			ShakeIt:SetPos( self.Entity:GetPos() )
			ShakeIt:Fire("StartShake", "", 0);
			ShakeIt:Spawn()
			ShakeIt:Activate()
			
			ShakeIt:Fire("kill", "", FCount)
		end
		
		local effectdata1 = EffectData()
		effectdata1:SetOrigin(self.Entity:GetPos())
		effectdata1:SetStart(self.Entity:GetPos())
		effectdata1:SetScale( 10 )
		effectdata1:SetRadius( 100 )
		util.Effect( "Explosion", effectdata1 )
	end
	self.Exploded = true
	self.Entity:Remove()
end

function ENT:Touch( ent )
	if ent.HasHardpoints and self.Fuel > 0 then
		if ent.Cont and ent.Cont:IsValid() then
			HPLink( ent.Cont, ent.Entity, self.Entity )
		end
	end
end

function ENT:Use( ply )
	if self.Venting then
		self.Venting = false
	else
		self.Venting = true
	end
end

function ENT:HPFire()

end

function ENT:gcbt_breakactions(damage, pierce)
	self:Splode()
end