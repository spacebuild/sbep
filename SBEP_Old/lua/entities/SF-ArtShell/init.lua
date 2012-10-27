AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Items/AR2_Grenade.mdl" )
	self:SetName("Artillery Shell")
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

    	self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()


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
	

		util.SpriteTrail( self, 0,  Color(255,255,255,255), false, 10, 0, 1, 1, "trails/smoke.vmt" ) 
		--self.PhysObj:SetVelocity(self:GetForward()*3100)

		self.PreLaunch = true
	end
	
	if (self.Exploded ~= true) then
		self.CAng = self:GetAngles()
	end
	
	if (self.DTimer == true) then
		if (CurTime() >= self.DTime) then
			util.BlastDamage(self, self, self:GetPos(), 600, 50)
			cbt_hcgexplode( self:GetPos(), 600, 1000, 2)
 
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetStart(self:GetPos())
			util.Effect( "Explosion", effectdata )
		end
	else
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + (self:GetForward() * 100)
		trace.filter = self
		local tr = util.TraceLine( trace )
		if !tr.Hit then
			self:SetPos(self:GetPos() + self:GetForward() * 100)
		else
			if tr.HitSky then
				self:Remove()
			else
				self.PhysObj:SetVelocity(self:GetForward()*3100)
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
			util.BlastDamage(self, self, self:GetPos(), 100, 50)
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetStart(self:GetPos())
			util.Effect( "Explosion", effectdata )
			self.Exploded = true
		else	
			if (data.HitEntity ~= self.LastHit) then
				local attack = cbt_dealhcghit( data.HitEntity, 300, self.PStr, self:GetPos() , self:GetPos())
				if (attack == 0) then
					self.Exploded = true
					util.BlastDamage(self, self, self:GetPos(), 100, 50)
					cbt_hcgexplode( self:GetPos(), 100, 300, 2)
		 
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetStart(self:GetPos())
					util.Effect( "Explosion", effectdata )
				else
					constraint.NoCollide( data.HitEntity, self, 0, 0 )
					self:SetAngles( self.CAng )
					self:SetPos( self:GetPos() + self:GetForward() * 10 )
					self.PhysObj:SetVelocity(data.OurOldVelocity)
					self.PStr = self.PStr - 1
					if (self.DTimer ~= true) then
						self.DTimer = true
						self.DTime = CurTime() + 0.1
					end
					self.LastHit = data.HitEntity
				end
			else
				constraint.NoCollide( data.HitEntity, self, 0, 0 )
				self:SetAngles( self.CAng )
				self:SetPos( self:GetPos() + self:GetForward() * 10 )
				self.PhysObj:SetVelocity(data.OurOldVelocity)
				self.LastHit = data.HitEntity
			end
		end
	end
end

function ENT:OnTakeDamage( dmginfo )

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
end

function ENT:Use( activator, caller )

end