AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "explode_8" )
util.PrecacheSound( "explode_5" )

function ENT:Initialize()

	self:SetModel( "models/weapons/w_missile_launch.mdl" )
	self:SetName("HomingMissile")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end

	gcombat.registerent( self, 10, 4 )
	self.Armed = true
	
    --self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	
	self.SpawnTime = CurTime()
	self.LTime = self.LTime or 0
	
	self.XCo = 0
	self.YCo = 0
	self.ZCo = 0
	
	self.TSClamp = 100
	
	self.Yaw = 0
	self.Pitch = 0
	self.Roll = 0
	
	self.NTT = 0
	
	local SpreadSize = 200
	
	self.RSpreadX = math.Rand(-SpreadSize,SpreadSize)
	self.RSpreadY = math.Rand(-SpreadSize,SpreadSize)
	
	self.LeaderLastPos = Vector(0,0,0)
	self.LeaderLastAng = Angle(0,0,0)
	
	self.hasdamagecase = true
	
	util.SpriteTrail( self, 0,  Color(200,100,100,200), false, 10, 0, 1, 1, "trails/smoke.vmt" )
	
	self.InitSuccessful = true
	
end

function ENT:Think()
	print(self.InitSuccessful, self.SpawnTime)
	if CurTime() > self.SpawnTime + self.LTime then
		local TVec = nil
		if self.GType == 1 then
			TVec = Vector(self.XCo, self.YCo, self.ZCo)
			
		elseif self.GType == 2 then
			if self.ParL and self.ParL:IsValid() then
				self.XCo = self.ParL.XCo
				self.YCo = self.ParL.YCo
				self.ZCo = self.ParL.ZCo
			end
			TVec = Vector(self.XCo, self.YCo, self.ZCo)
			
		elseif self.GType == 4 then
			if type(self.TEnt) == "Entity" and self.TEnt and self.TEnt:IsValid() then
				TVec = self.TEnt:GetPos()
			end
			
		elseif self.GType == 3 then
			if self.Target and self.Target:IsValid() then
				TVec = self.Target:GetPos()
			else
				local targets = ents.FindInCone( self:GetPos(), self:GetForward(), 5000, 65)
		
				local CMass = 0
				local CT = nil
							
				for _,i in pairs(targets) do
					if i:GetPhysicsObject() and i:GetPhysicsObject():IsValid() and !i.Autospawned then
						local IMass = i:GetPhysicsObject():GetMass()
						local IDist = (self:GetPos() - i:GetPos()):Length()
						if i.IsFlare == true then IMass = 5000 end
						local TVal = (IMass * 3) - IDist
						if TVal > CMass then
							CT = i
						end
					end
				end
				self.Target = CT
			end
			
		elseif self.GType == 5 or self.GType == 6 then
			if self.ParL and self.ParL:IsValid() then
				if self.ParL.Primary and self.ParL.Primary:IsValid() then
					if self.ParL.Primary == self then
						local Ang = self.ParL.MAngle or Angle(0,0,0)
						self.Pitch = Ang.p
						self.Yaw = Ang.y
						self.Roll = Ang.r
					else
						self.Tertiary = true
						self.LeaderLastPos = self.ParL.Primary:GetPos()
						self.LeaderLastAng = self.ParL.Primary:GetAngles()
						
						TVec = self.LeaderLastPos + (self.LeaderLastAng:Right() * self.RSpreadX ) + (self.LeaderLastAng:Up() * self.RSpreadY)
					end
				else
					self.Tertiary = true
					TVec = self.LeaderLastPos + (self.LeaderLastAng:Right() * self.RSpreadX ) + (self.LeaderLastAng:Up() * self.RSpreadY)
				end
			end
		end
		
		if (self.GType > 0 and self.GType < 5) or (self.GType == 5 and self.Tertiary) then
			if TVec then
				local Pos = self:GetPos()
				self.Pitch = math.Clamp(self:GetUp():DotProduct( TVec - Pos ) * -0.1,-self.TSClamp,self.TSClamp)
				self.Yaw = math.Clamp(self:GetRight():DotProduct( TVec - Pos ) * -0.1,-self.TSClamp,self.TSClamp)
			else
				self.Pitch = 0
				self.Yaw = 0
			end
			
			local physi = self:GetPhysicsObject()
			physi:AddAngleVelocity((physi:GetAngleVelocity() * -1) + Angle(0,self.Pitch,self.Yaw))
			physi:SetVelocity( self:GetForward() * 1000 )
		elseif self.GType == 5 then
			local physi = self:GetPhysicsObject()
			physi:AddAngleVelocity((physi:GetAngleVelocity() * -1) + Angle(-self.Roll * 5,-self.Pitch * 5,-self.Yaw * 5))
			physi:SetVelocity( self:GetForward() * 1000 )
		elseif self.GType == 6 then
			local SAng = self:GetAngles()
			local TAng = Angle(self.Roll,self.Pitch,self.Yaw)
			local AAng = TAng - SAng
			local physi = self:GetPhysicsObject()
			physi:AddAngleVelocity((physi:GetAngleVelocity() * -1) + AAng)
			physi:SetVelocity( self:GetForward() * 1000 )
		end
		
		if self.ParL and self.ParL then
			if self.ParL.Detonating then
				self:Splode()
			end
		end
		
		if CurTime() > self.NTT then
			local trace = {}
			trace.start = self:GetPos()
			trace.endpos = self:GetPos() + (self:GetVelocity())
			trace.filter = self
			local tr = util.TraceLine( trace )
			if tr.Hit and tr.HitSky then
				self:Remove()
			end
			self.NTT = CurTime() + 1
		end
	end
	
	self:NextThink( CurTime() + 0.01 )
	return true
end

function ENT:PhysicsCollide( data, physobj )
	if (!self.Exploded and self.Armed) then
		self:Splode()
	end
	self.Exploded = true
end

function ENT:OnTakeDamage( dmginfo )
	if (!self.Exploded and self.Armed) then
		--self:Splode()
	end
	--self.Exploded = true
end

function ENT:Use( activator, caller )
	--self:Arm()
end

function ENT:Splode()
	if(!self.Exploded) then
		self.Exploded = true
		util.BlastDamage(self, self, self:GetPos(), 150, 150)
		SBGCSplash( self:GetPos(), 100, math.Rand(200, 500), 6, { self:GetClass() } )
		
		--targets = ents.FindInSphere( self:GetPos(), 2000)
		
		self:EmitSound("explode_9")
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetStart(self:GetPos())
		util.Effect( "explosion", effectdata )
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
	end
	self.Exploded = true
	self:Remove()
end

function ENT:Touch( ent )
	if ent.HasHardpoints and !self.Armed then
		--if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
	end
end

function ENT:OnRemove()
	--self.CPL:SetViewEntity()
end

function ENT:gcbt_breakactions( damage, pierce )
	if !self.Exploded then
		self:Splode()
	end
	self.Exploded = true
end