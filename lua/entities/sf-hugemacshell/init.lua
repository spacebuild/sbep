AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/assault_pod.mdl" )
	self.Entity:SetName("RailSlug")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetMaterial("models/props_combine/combinethumper002")
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end

    self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.CAng = self.Entity:GetAngles()
	util.SpriteTrail( self.Entity, 0,  Color(40,140,60,200), false, 50, 0, 3, 1, "trails/smoke.vmt" )

end

function ENT:PhysicsUpdate()

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
			phys:EnableGravity(false)
			phys:EnableDrag(false)
			phys:EnableCollisions(true)
			phys:EnableMotion(true)
		end
		--self.PhysObj:SetVelocity(self.Entity:GetForward()*3100)

		self.PreLaunch = true
	end
	
	if (self.Exploded ~= true) then
		self.CAng = self.Entity:GetAngles()
	end
	
	if (self.DTimer == true) then
		if (CurTime() >= self.DTime) then
			util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 1500, 500)
			cbt_hcgexplode( self.Entity:GetPos(), 1200, math.random(4000,8000), 10)
 			local targets = ents.FindInSphere( self.Entity:GetPos(), 1000)
		
			for _,i in pairs(targets) do
				if i:GetClass() == "prop_physics" then
					i:GetPhysicsObject():ApplyForceOffset( (i.Entity:NearestPoint(self.Entity:GetPos()) - self.Entity:GetPos()):Normalize() * 500000, data.HitPos )
				end
			end

			local effectdata = EffectData()
			effectdata:SetOrigin( self.Entity:GetPos() )
			effectdata:SetStart( self.Entity:GetPos() )
			effectdata:SetAngles( self.CAng )
			util.Effect( "BigShellSplode", effectdata )
			
			local ShakeIt = ents.Create( "env_shake" )
			ShakeIt:SetName("Shaker")
			ShakeIt:SetKeyValue("amplitude", "200" )
			ShakeIt:SetKeyValue("radius", "200" )
			ShakeIt:SetKeyValue("duration", "5" )
			ShakeIt:SetKeyValue("frequency", "255" )
			ShakeIt:SetPos( self.Entity:GetPos() )
			ShakeIt:Fire("StartShake", "", 0);
			ShakeIt:Spawn()
			ShakeIt:Activate()
			
			ShakeIt:Fire("kill", "", 6)
			
			self.Entity:Remove()
		end
	else
		local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = self.Entity:GetPos() + (self.Entity:GetForward() * 600)
		trace.filter = self.Entity
		local tr = util.TraceLine( trace )
		if !tr.Hit then
			self.Entity:SetPos(self.Entity:GetPos() + self.Entity:GetForward() * 600)
		else
			if tr.HitSky then
				self.Entity:Remove()
			else
				self.PhysObj:SetVelocity(self.Entity:GetForward()*10000)
			end
		end
	end
	
	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	if(!self.Exploded) then
		--self.Exploded = true
		if (data.HitEntity:IsWorld() or data.HitEntity:IsPlayer() or data.HitEntity:IsNPC()) then
			util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 900, 500)
			cbt_hcgexplode( self.Entity:GetPos(), 800, math.random(1500,2500), 8)
			local targets = ents.FindInSphere( self.Entity:GetPos(), 1000)
		
			for _,i in pairs(targets) do
				if i:GetClass() == "prop_physics" then
					i:GetPhysicsObject():ApplyForceOffset( (i.Entity:NearestPoint(self.Entity:GetPos()) - self.Entity:GetPos()):Normalize() * 500000, data.HitPos )
				end
			end
			
			local effectdata = EffectData()
			effectdata:SetOrigin(self.Entity:GetPos())
			effectdata:SetStart(self.Entity:GetPos())
			util.Effect( "BigShellSplode", effectdata )
			self.Exploded = true
			
			local ShakeIt = ents.Create( "env_shake" )
			ShakeIt:SetName("Shaker")
			ShakeIt:SetKeyValue("amplitude", "200" )
			ShakeIt:SetKeyValue("radius", "200" )
			ShakeIt:SetKeyValue("duration", "5" )
			ShakeIt:SetKeyValue("frequency", "255" )
			ShakeIt:SetPos( self.Entity:GetPos() )
			ShakeIt:Fire("StartShake", "", 0);
			ShakeIt:Spawn()
			ShakeIt:Activate()
			
			ShakeIt:Fire("kill", "", 6)
		else	
			if (data.HitEntity ~= self.LastHit) then
				local attack = cbt_dealhcghit( data.HitEntity, 2500, self.PStr, self.Entity:GetPos() , self.Entity:GetPos())
				if (attack == 0) then
					self.Exploded = true
					util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 900, 500)
					cbt_hcgexplode( self.Entity:GetPos(), 800, math.random(1500,2500), 8)
					
					local targets = ents.FindInSphere( self.Entity:GetPos(), 1000)
		
					for _,i in pairs(targets) do
						if i:GetClass() == "prop_physics" then
								i:GetPhysicsObject():ApplyForceOffset( Vector(500000,500000,500000), self.Entity:GetPos() )
						end
					end
		 
					local effectdata = EffectData()
					effectdata:SetOrigin( self.Entity:GetPos() )
					effectdata:SetStart( self.Entity:GetPos() )
					effectdata:SetAngles( self.CAng )
					util.Effect( "BigShellSplode", effectdata )
					
					local ShakeIt = ents.Create( "env_shake" )
					ShakeIt:SetName("Shaker")
					ShakeIt:SetKeyValue("amplitude", "200" )
					ShakeIt:SetKeyValue("radius", "200" )
					ShakeIt:SetKeyValue("duration", "5" )
					ShakeIt:SetKeyValue("frequency", "255" )
					ShakeIt:SetPos( self.Entity:GetPos() )
					ShakeIt:Fire("StartShake", "", 0);
					ShakeIt:Spawn()
					ShakeIt:Activate()
					
					ShakeIt:Fire("kill", "", 6)
				else
					constraint.NoCollide( data.HitEntity, self.Entity, 0, 0 )
					self.Entity:SetAngles( self.CAng )
					self.Entity:SetPos( self.Entity:GetPos() + self.Entity:GetForward() * 30 )
					self.PhysObj:SetVelocity(data.OurOldVelocity)
					self.PStr = self.PStr - 1
					if (self.DTimer ~= true) then
						self.DTimer = true
						self.DTime = CurTime() + 1.5
					end
					self.LastHit = data.HitEntity
					
					data.HitObject:ApplyForceOffset( data.OurOldVelocity * 100000, data.HitPos )
					local effectdata = EffectData()
					effectdata:SetOrigin( self.Entity:GetPos() )
					effectdata:SetStart( self.Entity:GetPos() )
					effectdata:SetAngles( self.Entity:GetAngles() )
					effectdata:SetNormal( self.Entity:GetForward() )
					util.Effect( "ShellDrill", effectdata )
					
					local ShakeIt = ents.Create( "env_shake" )
					ShakeIt:SetName("Shaker")
					ShakeIt:SetKeyValue("amplitude", "100" )
					ShakeIt:SetKeyValue("radius", "120" )
					ShakeIt:SetKeyValue("duration", "2" )
					ShakeIt:SetKeyValue("frequency", "100" )
					ShakeIt:SetPos( self.Entity:GetPos() )
					ShakeIt:Fire("StartShake", "", 0);
					ShakeIt:Spawn()
					ShakeIt:Activate()
					
					ShakeIt:Fire("kill", "", 6)
					
					self.Exploded = true
				end
			else
				constraint.NoCollide( data.HitEntity, self.Entity, 0, 0 )
				self.Entity:SetAngles( self.CAng )
				self.Entity:SetPos( self.Entity:GetPos() + self.Entity:GetForward() * 10 )
				self.PhysObj:SetVelocity(data.OurOldVelocity)
				self.LastHit = data.HitEntity
				
				data.HitObject:ApplyForceOffset( data.OurOldVelocity * 100000, data.HitPos )
				local effectdata = EffectData()
				effectdata:SetOrigin( self.Entity:GetPos() )
				effectdata:SetStart( self.Entity:GetPos() )
				effectdata:SetAngles( self.Entity:GetAngles() )
				effectdata:SetNormal( self.CAng:Forward() )
				util.Effect( "ShellDrill", effectdata )
				
				local ShakeIt = ents.Create( "env_shake" )
				ShakeIt:SetName("Shaker")
				ShakeIt:SetKeyValue("amplitude", "100" )
				ShakeIt:SetKeyValue("radius", "120" )
				ShakeIt:SetKeyValue("duration", "2" )
				ShakeIt:SetKeyValue("frequency", "100" )
				ShakeIt:SetPos( self.Entity:GetPos() )
				ShakeIt:Fire("StartShake", "", 0);
				ShakeIt:Spawn()
				ShakeIt:Activate()
				
				ShakeIt:Fire("kill", "", 6)
			end
		end
	end
end

function ENT:OnTakeDamage( dmginfo )
	/*
	if(!self.Exploded) then
		local expl=ents.Create("env_explosion")
		expl:SetPos(self.Entity:GetPos())
		expl:SetName("Missile")
		expl:SetParent(self.Entity)
		expl:SetOwner(self.SPL)
		expl:SetKeyValue("iMagnitude","100");
		expl:SetKeyValue("iRadiusOverride", 150)
		expl:Spawn()
		expl:Activate()
		expl:Fire("explode", "", 0)
		expl:Fire("kill","",0)
		self.Exploded = true
	end	
	*/
end

function ENT:Use( activator, caller )

end