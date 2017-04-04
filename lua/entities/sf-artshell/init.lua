AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Items/AR2_Grenade.mdl" )
	self.Entity:SetName("Artillery Shell")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end

    	self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.CAng = self.Entity:GetAngles()


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
			phys:EnableGravity(true)
			phys:EnableDrag(true)
			phys:EnableCollisions(true)
			phys:EnableMotion(true)
		end
	

		util.SpriteTrail( self.Entity, 0,  Color(255,255,255,255), false, 10, 0, 1, 1, "trails/smoke.vmt" ) 
		--self.PhysObj:SetVelocity(self.Entity:GetForward()*3100)

		self.PreLaunch = true
	end
	
	if (self.Exploded ~= true) then
		self.CAng = self.Entity:GetAngles()
	end
	
	if (self.DTimer == true) then
		if (CurTime() >= self.DTime) then
			util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 600, 50)
			cbt_hcgexplode( self.Entity:GetPos(), 600, 1000, 2)
 
			local effectdata = EffectData()
			effectdata:SetOrigin(self.Entity:GetPos())
			effectdata:SetStart(self.Entity:GetPos())
			util.Effect( "Explosion", effectdata )
		end
	else
		local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = self.Entity:GetPos() + (self.Entity:GetForward() * 100)
		trace.filter = self.Entity
		local tr = util.TraceLine( trace )
		if !tr.Hit then
			self.Entity:SetPos(self.Entity:GetPos() + self.Entity:GetForward() * 100)
		else
			if tr.HitSky then
				self.Entity:Remove()
			else
				self.PhysObj:SetVelocity(self.Entity:GetForward()*3100)
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
			util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 50)
			local effectdata = EffectData()
			effectdata:SetOrigin(self.Entity:GetPos())
			effectdata:SetStart(self.Entity:GetPos())
			util.Effect( "Explosion", effectdata )
			self.Exploded = true
		else	
			if (data.HitEntity ~= self.LastHit) then
				local attack = cbt_dealhcghit( data.HitEntity, 300, self.PStr, self.Entity:GetPos() , self.Entity:GetPos())
				if (attack == 0) then
					self.Exploded = true
					util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 50)
					cbt_hcgexplode( self.Entity:GetPos(), 100, 300, 2)
		 
					local effectdata = EffectData()
					effectdata:SetOrigin(self.Entity:GetPos())
					effectdata:SetStart(self.Entity:GetPos())
					util.Effect( "Explosion", effectdata )
				else
					constraint.NoCollide( data.HitEntity, self.Entity, 0, 0 )
					self.Entity:SetAngles( self.CAng )
					self.Entity:SetPos( self.Entity:GetPos() + self.Entity:GetForward() * 10 )
					self.PhysObj:SetVelocity(data.OurOldVelocity)
					self.PStr = self.PStr - 1
					if (self.DTimer ~= true) then
						self.DTimer = true
						self.DTime = CurTime() + 0.1
					end
					self.LastHit = data.HitEntity
				end
			else
				constraint.NoCollide( data.HitEntity, self.Entity, 0, 0 )
				self.Entity:SetAngles( self.CAng )
				self.Entity:SetPos( self.Entity:GetPos() + self.Entity:GetForward() * 10 )
				self.PhysObj:SetVelocity(data.OurOldVelocity)
				self.LastHit = data.HitEntity
			end
		end
	end
end

function ENT:OnTakeDamage( dmginfo )

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
end

function ENT:Use( activator, caller )

end