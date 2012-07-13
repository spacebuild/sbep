AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--util.PrecacheSound( "SB/SteamEngine.wav" )

function ENT:Initialize()
	
	self.Entity:SetModel( "models/Slyfo/rover_winchhookclosed.mdl" ) 
	self.Entity:SetName( "GrapplingHook" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass(5)
	end
	self.Entity:StartMotionController()
	self.PhysObj = self.Entity:GetPhysicsObject()


	self.ATime = 0
	
	self.Puntable = true
	self.GravyGrabbable = true
	
	self.CLength = 0
	
	self.ITime = 0
	self.ICD = 0
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "SF-GrappleH" )
	ent:SetPos( SpawnPos + Vector(0,0,20) )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	local ent2 = ents.Create( "SF-GrapplingRing" )
	ent2:SetPos( SpawnPos )
	ent2:Spawn()
	ent2:Activate()
	
	--ent.Rope = constraint.Rope( ent, ent2, 0, 0, Vector(-12,0,0), Vector(-3,0,0), 100, 50, 0, 2, "cable/rope", false)
	
	local minMass = math.min( ent:GetPhysicsObject():GetMass(), ent2:GetPhysicsObject():GetMass() )
	local const = minMass * 100
	local damp = const * 0.2
	
	ent.Elastic, ent.Rope = constraint.Elastic( ent, ent2, 0, 0, Vector(-12,0,0), Vector(-3,0,0), const, damp, 0, "cable/rope", 2, true)
	ent.Elastic:Fire("SetSpringLength",150,0)
	ent.Rope:Fire("SetLength",150,0)
	
	ent.ParL = ent2
	ent.Standalone = true
	ent2.Hook = ent
	return ent2
	
end

function ENT:Think()
	if (self.Active and !self.Impact) then
				
		local physi = self.Entity:GetPhysicsObject()
		--physi:SetVelocity(self.Entity:GetForward() * 5000)
		--physi:EnableGravity(false)
		if self.ParL and self.ParL:IsValid() then
			local Dist = self.Entity:GetPos():Distance(self.ParL:GetPos())
			if Dist < 8000 and self.ParL.LChange < self.ITime then
				if self.Elastic and self.Elastic:IsValid() then
					self.Elastic:Fire("SetSpringLength",Dist * 1.4,0)
				end
				if self.Rope and self.Rope:IsValid() then
					self.Rope:Fire("SetLength",Dist * 1.4,0)
				end
				self.CLength = Dist
			end
			
		end
		
		if CurTime() >= self.ATime then
			if self.Entity:GetPhysicsObject():GetVelocity():Length() > 200 then
				local trace = {}
				trace.start = self.Entity:GetPos()
				trace.endpos = self.Entity:GetPos() + self.Entity:GetForward() * 100
				trace.filter = self.Entity
				local tr = util.TraceLine( trace )
				if tr.HitNonWorld and tr.Entity and tr.Entity:IsValid() then
					self.Entity:SetModel("models/Slyfo/rover_winchhookopen.mdl")
					self.Impact = true
					self.ITime = CurTime()
					self.Active = false
					self.Entity:SetPos(tr.HitPos + self.Entity:GetForward() * 7)
					self.HWeld = constraint.Weld(self.Entity, tr.Entity, 0, 0, 0, true)
					if self.ParL and self.ParL:IsValid() then
						local Vec = tr.Entity:WorldToLocal(self.Entity:GetPos() + (self.Entity:GetForward() * -16)) -- 
						self.ParL:Latch( self.Entity, Vec, tr.Entity )
					end
					local phys = self.Entity:GetPhysicsObject()
					if (phys:IsValid()) then
						phys:Wake()
						phys:EnableGravity(false)
						phys:EnableDrag(false)
						phys:EnableCollisions(false)
						phys:SetMass(5)
					end
					local effectdata = EffectData()
					effectdata:SetOrigin( self.Entity:GetPos() )
					effectdata:SetStart( self.Entity:GetPos() )
					effectdata:SetAngle( self.Entity:GetAngles() )
					effectdata:SetNormal( self.Entity:GetForward() )
					util.Effect( "HookImpact", effectdata )
					self.Entity:EmitSound("Metal_Barrel.BulletImpact")
				elseif tr.HitWorld then
					if self.Standalone and self.ParL and self.ParL:IsValid() then
						self.Active = false
					else
						local effectdata = EffectData()
						effectdata:SetOrigin( self.Entity:GetPos() )
						effectdata:SetStart( self.Entity:GetPos() )
						effectdata:SetAngle( self.Entity:GetAngles() )
						effectdata:SetNormal( self.Entity:GetForward() )
						util.Effect( "HookImpact", effectdata )
						self.Entity:EmitSound("Metal_Barrel.BulletImpact")
						self.Entity:Remove()
					end
				end
			else
				self.Active = false
			end
		end
	end
	
	if self.Standalone and self.ParL and self.ParL:IsValid() then
		if self.ParL.LChange > self.ITime and self.Rope and self.Rope:IsValid() then
			self.CLength = math.Approach(self.CLength,self.ParL.DLength,self.ParL.ReelRate)
			self.Elastic:Fire("SetSpringLength",self.CLength,0)
			self.Rope:Fire("SetLength",self.CLength,0)
		end
		if self.ParL.Disengaging then
			if self.Rope and self.Rope:IsValid() then
				self.Rope:Remove()
			end
			if self.Elastic and self.Elastic:IsValid() then
				self.Elastic:Remove()
			end
			self:Fire("kill", "", 5 + math.random() * 5)
		end
	end
	
	if self.Impact then
		if self.ParL and self.ParL:IsValid() then
			if self.ParL.Disengaging then
				if self.Rope and self.Rope:IsValid() then
					self.Rope:Remove()
				end
				if self.Elastic and self.Elastic:IsValid() then
					self.Elastic:Remove()
				end
				self:Fire("kill", "", 5 + math.random() * 5)
			end
			if self.ParL.Retracting then
				self.Entity:Retract()
			end
			if self.Rope and self.Rope:IsValid() then
				if self.ITime < self.ParL.LChange then
					if self.CLength - self.ParL.DLength < self.ParL.ReelRate and self.CLength - self.ParL.DLength > -self.ParL.ReelRate then
						self.CLength = self.ParL.DLength
					end
					if self.CLength > self.ParL.DLength then
						self.CLength = self.CLength - self.ParL.ReelRate
					elseif self.CLength < self.ParL.DLength then
						self.CLength = self.CLength + self.ParL.ReelRate
					end
					self.Elastic:Fire("SetSpringLength",self.CLength,0)
					self.Rope:Fire("SetLength",self.CLength,0)
				end
			end
		else
			self:Fire("kill", "", 15 + math.Rand(0,15))
		end
	end

	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:Punt( ply )
	--print("PUNT!")
	if !self.Impact then
		if self.Elastic and self.Elastic:IsValid() then
			self.Elastic:Fire("SetSpringLength",5000,0)
		end
		if self.Rope and self.Rope:IsValid() then
			self.Rope:Fire("SetLength",5000,0)
		end
		DropEntityIfHeld( self.Entity )
		self.Entity:SetAngles(ply:GetAimVector():Angle())
		self.Active = true
		self.Entity:GetPhysicsObject():SetVelocity(self.Entity:GetForward() * 5000)
		self.ITime = CurTime()
	end
	DropEntityIfHeld( self.Entity )
	return false
end

function ENT:GravyGrab( ply )
	self.Entity:Retract()
	self.Entity:SetAngles(ply:GetAimVector():Angle())
	self.ITime = CurTime()
	if self.CLength < 400 then
		self.CLength = 400
		if self.Elastic and self.Elastic:IsValid() then
			self.Elastic:Fire("SetSpringLength",400,0)
		end
		if self.Rope and self.Rope:IsValid() then
			self.Rope:Fire("SetLength",400,0)
		end
	end
		
		
end

--function ENT:SetActive()
--	self.Active = true
--	self.ATime = CurTime() + 0.5
--	self.Entity:GetPhysicsObject():Wake()
--	self.Entity:GetPhysicsObject():EnableMotion( true )
--end

function ENT:PhysicsCollide( data, physobj )

end

function ENT:OnRemove()
	if self.Rope and self.Rope:IsValid() then
		self.Rope:Remove()
	end
	if self.Elastic and self.Elastic:IsValid() then
		self.Elastic:Remove()
	end
end

function ENT:OnTakeDamage( dmginfo )
	self.Entity:Retract()
end

function ENT:Touch( ent )

end

function ENT:Retract()
	self.Entity:SetModel( "models/Slyfo/rover_winchhookclosed.mdl" ) 
	constraint.RemoveConstraints( self.Entity, "Weld" )
	self.Impact = false
	self.Active = false
	self.ICD = CurTime() + .5
	self.Entity:SetPos(self.Entity:GetPos() + self.Entity:GetForward() * -30)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
end

function ENT:Use( activator, caller )
	self.Entity:Retract()
end

function ENT:PhysicsUpdate( phys )
	if self.Active and !self.Impact then
		local Vel = phys:GetVelocity()
		self.Entity:SetAngles( Vel:Angle() )
		phys:SetVelocity(Vel)
	end
end