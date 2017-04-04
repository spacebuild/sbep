AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "explode_8" )
util.PrecacheSound( "explode_5" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Punisher239/punisher239_missile_light.mdl" )
	self.Entity:SetName("LightMissile")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, { "Launch", "Arm", "Detonate" } )
	end

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end

    --self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.CAng = self.Entity:GetAngles()
	
	self.MCd = 2
	self.CCd = 0
	
	self.ArmD = .6
	
	self.ATime = 0
	
	self.Accel = 1
	
	
	self.SensorLocks = {}
	self.SensorStrength = 4000
	
	self.TSClamp = 70
	
	self.ProxDist = 300
end

function ENT:TriggerInput(iname, value)		
	
	if (iname == "Arm") then
		if (value > 0) then
			self.Entity:Arm()
		end
		
	elseif (iname == "Launch") then	
		if (value > 0) then
			self.Entity:HPFire()
		end
		
	elseif (iname == "Detonate") then	
		if (value > 0) then
			self.Entity:Splode()
		end
	end
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "PS-LightMissile" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Think()
	if (self.Launched) then
		self.Armed = true
		self.Accel = math.Approach(self.Accel, 60, 2)
		local Phys = self:GetPhysicsObject()
		Phys:ApplyForceCenter(self.Entity:GetForward() * self.Accel * Phys:GetMass())
		Phys:AddAngleVelocity(Phys:GetAngleVelocity() * -0.9)
		
		if CurTime() >= self.ATime then
			Phys:EnableCollisions(true)
		end
		
		SBEP_S.TrackInSphere( self:GetPos(), self, 0 )
	
		--print("Thinking...")
		--PrintTable(self.SensorLocks)
		local TVec
		local Str = 0
		for k,e in pairs(SBEP_S.CurrentLocks(self)) do
			if e.Str > Str then
				--print("Target Acquired")
				TVec = e.TVc
				Str = e.Str
			end
		end
		
		if TVec then
			--print("Orienting...")
			local Pos = self:GetPos()
			local Pitch = math.Clamp(self:GetUp():DotProduct( TVec - Pos ) * -0.1,-self.TSClamp,self.TSClamp)
			local Yaw = math.Clamp(self:GetRight():DotProduct( TVec - Pos ) * -0.1,-self.TSClamp,self.TSClamp)
			
			--print(TVec, Pitch, Yaw)
			
			local physi = self.Entity:GetPhysicsObject()
			physi:AddAngleVelocity(Angle(0,Pitch,Yaw))
			
			if SBEP_S.SqrDist( self:GetPos(), TVec ) < self.ProxDist ^ 2 then
				self:Splode()
			end
		end
	end
	
	if CurTime() >= self.CCd then
		self:SetColor(Color(255,255,255,255))
	end
	
	if self.Exploded and self.Armed then self:Remove() end
	
	
	self:NextThink(CurTime() + 0.01)
	return true
end

function ENT:PhysicsCollide( data, physobj )
	if (!self.Exploded and self.Armed) then
		self:Splode()
	end
end

function ENT:OnTakeDamage( dmginfo )
	if (!self.Exploded and self.Armed) then
		--self:Explode()
	end
	--self.Exploded=true
end

function ENT:Use( activator, caller )

end

function ENT:Arm()
	self.Armed = true
	--util.SpriteTrail( self.Entity, 0,  Color(255,255,80,150), false, 50, 0, 3, 1, "trails/smoke.vmt" )
	self.Entity:SetArmed( true )
	--util.SpriteTrail( self, 0, Color( 190, 210, 255, 255 ), false, 5, 0, 1, 1, "trails/smoke.vmt" )
end

function ENT:Splode()
	if (!self.Exploded) then
		--self.Exploded = true
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 400, 100)
		cbt_hcgexplode( self.Entity:GetPos(), 400, math.random(300,600), 8)
		local targets = ents.FindInSphere( self.Entity:GetPos(), 300)
	
		for _,i in pairs(targets) do
			if i:GetClass() == "prop_physics" then
				i:GetPhysicsObject():ApplyForceOffset( Vector(500000,500000,500000), self.Entity:GetPos() )
			end
		end
		
		self.Entity:EmitSound("explode_9")
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetAngles(self.Entity:GetAngles())
		effectdata:SetScale(30)
		effectdata:SetMagnitude(1)
		util.Effect( "Minnow", effectdata )
		
		
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
	end
	self.Exploded = true
	self.Entity:Remove()
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self.Entity ) end
	end
end

function ENT:HPFire()
	/*
	self.Entity:SetParent()
	constraint.RemoveConstraints( self.Entity, "Weld" )
	constraint.RemoveConstraints( self.Entity, "Ballsocket" )
	self.PhysObj:SetVelocity(self.Entity:GetVelocity())
	self.PFire = true
	self.Entity:GetPhysicsObject():EnableGravity(false)
	timer.Simple(1.5,function()
		if self.Entity:IsValid() then
		self.Entity:GetPhysicsObject():EnableCollisions(true)
		self.Entity:Arm()
		end
	 end)
	 */
	 
	 if CurTime() >= self.CCd then
		local NTorp = ents.Create( "PS-LightMissile" )
		NTorp:SetPos( self:GetPos() + self:GetVelocity() * 0.1)
		NTorp:SetAngles( self:GetAngles() )
		NTorp:Spawn()
		NTorp:Activate()
		local Ph = NTorp:GetPhysicsObject()
		if Ph:IsValid() then
			Ph:SetVelocity(self:GetPhysicsObject():GetVelocity() * 1.5)
			Ph:EnableCollisions(false)
			Ph:EnableGravity(false)
		end
		NTorp.Launched = true
		NTorp.Armed = true
		NTorp:SetArmed( true )
		NTorp.SPL = self.SPL
		NTorp.ATime = CurTime() + self.ArmD
		util.SpriteTrail( NTorp, 0, Color( 210, 230, 255, 200 ), false, 40, 0, 1.5, 10, "effects/strider_muzzle.vmt" )
		
		self.CCd = CurTime() + self.MCd
		
		self:SetColor(Color(0,0,0,0))
	end
end

function ENT:PreEntityCopy()
	if WireAddon then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",WireLib.BuildDupeInfo(self.Entity))
	end
end

function ENT:PostEntityPaste(ply, ent, createdEnts)
	local emods = ent.EntityMods
	if not emods then return end
	if WireAddon then
		WireLib.ApplyDupeInfo(ply, ent, emods.WireDupeInfo, function(id) return createdEnts[id] end)
	end
	ent.SPL = ply
end