AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "explode_8" )
util.PrecacheSound( "explode_5" )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/torpedo.mdl" )
	self:SetName("Big Torpedo")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, { "Arm", "Detonate" } )
	end

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end
	
	gcombat.registerent( self, 60, 6 )

    --self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	
	self.hasdamagecase = true
	self.ATime = 0
end

function ENT:TriggerInput(iname, value)		
	
	if (iname == "Arm") then
		if (value > 0) then
			self:Arm()
		end
		
	elseif (iname == "Detonate") then	
		if (value > 0) then
			self:Splode()
		end
	end
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "SF-TorpBig" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Think()
	if self.Armed then
		if self.Vel then
			self.PhysObj:SetVelocity( self.Vel )
		end
		self.PhysObj:AddAngleVelocity(self.PhysObj:GetAngleVelocity() * -1)
	end
	if (self.PFire) then
		self.PhysObj:SetVelocity(self:GetForward() * 10000)
		self.PFire = false
		self.Vel = self:GetForward() * 10000
		self:Fire("kill", "", 45)
	end
	if (self.PFire2) then
		self.PhysObj:SetVelocity(self:GetForward() * -10000)
		self.PFire2 = false
		self.Vel = self:GetForward() * -10000
		self:Fire("kill", "", 45)
	end
	if self.ATime and CurTime() > self.ATime and self.ATime > 0 then
		self:GetPhysicsObject():EnableCollisions(true)
	end
end

function ENT:PhysicsCollide( data, physobj )
	if (!self.Exploded and self.Armed) then
		self:Splode()
	end
end

function ENT:OnTakeDamage( dmginfo )
	if (!self.Exploded and self.Armed) then
		--self:Explode()
		if dmginfo:GetInflictor():GetClass() ~= self:GetClass() then
			gcombat.devhit( self, dmginfo:GetDamage(), 50 )
		end
	end
	--self.Exploded=true
end

function ENT:Use( activator, caller )

end

function ENT:Arm()
	self.Armed = true
	self.PAngle = self:GetAngles()
	--util.SpriteTrail( self, 0,  Color(255,255,80,150), false, 50, 0, 3, 1, "trails/smoke.vmt" )
	self:SetArmed( true )
end

function ENT:Splode()
	if(!self.Exploded) then
		self.Exploded = true
		util.BlastDamage(self, self, self:GetPos(), 1500, 1500)
		SBGCSplash( self:GetPos(), 1000, math.random(5000,9000), 8, { self:GetClass() } )
		local targets = ents.FindInSphere( self:GetPos(), 1000)
	
		for _,i in pairs(targets) do
			if i:GetClass() == "prop_physics" then
				i:GetPhysicsObject():ApplyForceOffset( (i.Entity:NearestPoint(self:GetPos()) - self:GetPos()):Normalize() * 500000, self:GetPos() )
			end
		end
		
		self:EmitSound("explode_9")
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetStart(self:GetPos())
		util.Effect( "BigTorpSplode", effectdata )
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
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
	end
end

function ENT:HPFire()
	self:SetParent()
	if self.HPWeld and self.HPWeld:IsValid() then self.HPWeld:Remove() end
	self.PhysObj:SetVelocity(self:GetForward()*10000)
	self:Arm()
	self.ATime = CurTime() + 0.5
	self.PFire = true
	self.PhysObj:EnableCollisions(false)
	self.PhysObj:EnableGravity(false)
end

function ENT:gcbt_breakactions( damage, pierce )
	if !self.Exploded then
		self:Splode()
	end
	self.Exploded = true
end

function ENT:PreEntityCopy()
	if WireAddon then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",WireLib.BuildDupeInfo(self))
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