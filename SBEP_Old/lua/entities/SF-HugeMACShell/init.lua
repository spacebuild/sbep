AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/assault_pod.mdl" )
	self:SetName("RailSlug")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMaterial("models/props_combine/combinethumper002")
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end

    self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	util.SpriteTrail( self, 0,  Color(40,140,60,200), false, 50, 0, 3, 1, "trails/smoke.vmt" )

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
			phys:EnableGravity(false)
			phys:EnableDrag(false)
			phys:EnableCollisions(true)
			phys:EnableMotion(true)
		end
		--self.PhysObj:SetVelocity(self:GetForward()*3100)

		self.PreLaunch = true
	end
	
	if (self.Exploded ~= true) then
		self.CAng = self:GetAngles()
	end
	
	if (self.DTimer == true) then
		if (CurTime() >= self.DTime) then
			util.BlastDamage(self, self, self:GetPos(), 1500, 500)
			cbt_hcgexplode( self:GetPos(), 1200, math.random(4000,8000), 10)
 			local targets = ents.FindInSphere( self:GetPos(), 1000)
		
			for _,i in pairs(targets) do
				if i:GetClass() == "prop_physics" then
					i:GetPhysicsObject():ApplyForceOffset( (i.Entity:NearestPoint(self:GetPos()) - self:GetPos()):Normalize() * 500000, data.HitPos )
				end
			end

			local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetStart( self:GetPos() )
			effectdata:SetAngle( self.CAng )
			util.Effect( "BigShellSplode", effectdata )
			
			local ShakeIt = ents.Create( "env_shake" )
			ShakeIt:SetName("Shaker")
			ShakeIt:SetKeyValue("amplitude", "200" )
			ShakeIt:SetKeyValue("radius", "200" )
			ShakeIt:SetKeyValue("duration", "5" )
			ShakeIt:SetKeyValue("frequency", "255" )
			ShakeIt:SetPos( self:GetPos() )
			ShakeIt:Fire("StartShake", "", 0);
			ShakeIt:Spawn()
			ShakeIt:Activate()
			
			ShakeIt:Fire("kill", "", 6)
			
			self:Remove()
		end
	else
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + (self:GetForward() * 600)
		trace.filter = self
		local tr = util.TraceLine( trace )
		if !tr.Hit then
			self:SetPos(self:GetPos() + self:GetForward() * 600)
		else
			if tr.HitSky then
				self:Remove()
			else
				self.PhysObj:SetVelocity(self:GetForward()*10000)
			end
		end
	end
	
	self:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	if(!self.Exploded) then
		--self.Exploded = true
		if (data.HitEntity:IsWorld() or data.HitEntity:IsPlayer() or data.HitEntity:IsNPC()) then
			util.BlastDamage(self, self, self:GetPos(), 900, 500)
			cbt_hcgexplode( self:GetPos(), 800, math.random(1500,2500), 8)
			local targets = ents.FindInSphere( self:GetPos(), 1000)
		
			for _,i in pairs(targets) do
				if i:GetClass() == "prop_physics" then
					i:GetPhysicsObject():ApplyForceOffset( (i.Entity:NearestPoint(self:GetPos()) - self:GetPos()):Normalize() * 500000, data.HitPos )
				end
			end
			
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetStart(self:GetPos())
			util.Effect( "BigShellSplode", effectdata )
			self.Exploded = true
			
			local ShakeIt = ents.Create( "env_shake" )
			ShakeIt:SetName("Shaker")
			ShakeIt:SetKeyValue("amplitude", "200" )
			ShakeIt:SetKeyValue("radius", "200" )
			ShakeIt:SetKeyValue("duration", "5" )
			ShakeIt:SetKeyValue("frequency", "255" )
			ShakeIt:SetPos( self:GetPos() )
			ShakeIt:Fire("StartShake", "", 0);
			ShakeIt:Spawn()
			ShakeIt:Activate()
			
			ShakeIt:Fire("kill", "", 6)
		else	
			if (data.HitEntity ~= self.LastHit) then
				local attack = cbt_dealhcghit( data.HitEntity, 2500, self.PStr, self:GetPos() , self:GetPos())
				if (attack == 0) then
					self.Exploded = true
					util.BlastDamage(self, self, self:GetPos(), 900, 500)
					cbt_hcgexplode( self:GetPos(), 800, math.random(1500,2500), 8)
					
					local targets = ents.FindInSphere( self:GetPos(), 1000)
		
					for _,i in pairs(targets) do
						if i:GetClass() == "prop_physics" then
							i:GetPhysicsObject():ApplyForceOffset( (i.Entity:NearestPoint(self:GetPos()) - self:GetPos()):Normalize() * 500000, data.HitPos )
						end
					end
		 
					local effectdata = EffectData()
					effectdata:SetOrigin( self:GetPos() )
					effectdata:SetStart( self:GetPos() )
					effectdata:SetAngle( self.CAng )
					util.Effect( "BigShellSplode", effectdata )
					
					local ShakeIt = ents.Create( "env_shake" )
					ShakeIt:SetName("Shaker")
					ShakeIt:SetKeyValue("amplitude", "200" )
					ShakeIt:SetKeyValue("radius", "200" )
					ShakeIt:SetKeyValue("duration", "5" )
					ShakeIt:SetKeyValue("frequency", "255" )
					ShakeIt:SetPos( self:GetPos() )
					ShakeIt:Fire("StartShake", "", 0);
					ShakeIt:Spawn()
					ShakeIt:Activate()
					
					ShakeIt:Fire("kill", "", 6)
				else
					constraint.NoCollide( data.HitEntity, self, 0, 0 )
					self:SetAngles( self.CAng )
					self:SetPos( self:GetPos() + self:GetForward() * 30 )
					self.PhysObj:SetVelocity(data.OurOldVelocity)
					self.PStr = self.PStr - 1
					if (self.DTimer ~= true) then
						self.DTimer = true
						self.DTime = CurTime() + 1.5
					end
					self.LastHit = data.HitEntity
					
					data.HitObject:ApplyForceOffset( data.OurOldVelocity * 100000, data.HitPos )
					local effectdata = EffectData()
					effectdata:SetOrigin( self:GetPos() )
					effectdata:SetStart( self:GetPos() )
					effectdata:SetAngle( self:GetAngles() )
					effectdata:SetNormal( self:GetForward() )
					util.Effect( "ShellDrill", effectdata )
					
					local ShakeIt = ents.Create( "env_shake" )
					ShakeIt:SetName("Shaker")
					ShakeIt:SetKeyValue("amplitude", "100" )
					ShakeIt:SetKeyValue("radius", "120" )
					ShakeIt:SetKeyValue("duration", "2" )
					ShakeIt:SetKeyValue("frequency", "100" )
					ShakeIt:SetPos( self:GetPos() )
					ShakeIt:Fire("StartShake", "", 0);
					ShakeIt:Spawn()
					ShakeIt:Activate()
					
					ShakeIt:Fire("kill", "", 6)
				end
			else
				constraint.NoCollide( data.HitEntity, self, 0, 0 )
				self:SetAngles( self.CAng )
				self:SetPos( self:GetPos() + self:GetForward() * 10 )
				self.PhysObj:SetVelocity(data.OurOldVelocity)
				self.LastHit = data.HitEntity
				
				data.HitObject:ApplyForceOffset( data.OurOldVelocity * 100000, data.HitPos )
				local effectdata = EffectData()
				effectdata:SetOrigin( self:GetPos() )
				effectdata:SetStart( self:GetPos() )
				effectdata:SetAngle( self:GetAngles() )
				effectdata:SetNormal( self.CAng:Forward() )
				util.Effect( "ShellDrill", effectdata )
				
				local ShakeIt = ents.Create( "env_shake" )
				ShakeIt:SetName("Shaker")
				ShakeIt:SetKeyValue("amplitude", "100" )
				ShakeIt:SetKeyValue("radius", "120" )
				ShakeIt:SetKeyValue("duration", "2" )
				ShakeIt:SetKeyValue("frequency", "100" )
				ShakeIt:SetPos( self:GetPos() )
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
		expl:SetPos(self:GetPos())
		expl:SetName("Missile")
		expl:SetParent(self)
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