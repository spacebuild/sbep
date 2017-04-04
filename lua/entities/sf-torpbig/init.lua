AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "explode_8" )
util.PrecacheSound( "explode_5" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/torpedo.mdl" )
	self.Entity:SetName("Big Torpedo")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, { "Arm", "Detonate" } )
	end

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end
	
	gcombat.registerent( self.Entity, 60, 6 )

    --self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.CAng = self.Entity:GetAngles()
	
	self.hasdamagecase = true
	self.ATime = 0
end

function ENT:TriggerInput(iname, value)		
	
	if (iname == "Arm") then
		if (value > 0) then
			self.Entity:Arm()
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
		self.PhysObj:SetVelocity(self.Entity:GetForward() * 10000)
		self.PFire = false
		self.Vel = self.Entity:GetForward() * 10000
		self.Entity:Fire("kill", "", 45)
	end
	if (self.PFire2) then
		self.PhysObj:SetVelocity(self.Entity:GetForward() * -10000)
		self.PFire2 = false
		self.Vel = self.Entity:GetForward() * -10000
		self.Entity:Fire("kill", "", 45)
	end
	if self.ATime and CurTime() > self.ATime and self.ATime > 0 then
		self.Entity:GetPhysicsObject():EnableCollisions(true)
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
		if dmginfo:GetInflictor():GetClass() ~= self.Entity:GetClass() then
			gcombat.devhit( self.Entity, dmginfo:GetDamage(), 50 )
		end
	end
	--self.Exploded=true
end

function ENT:Use( activator, caller )

end

function ENT:Arm()
	self.Armed = true
	self.PAngle = self.Entity:GetAngles()
	self.Entity:SetArmed( true )
end

function ENT:Splode()
	if(!self.Exploded) then
		self.Exploded = true
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 1500, 1500)
		SBGCSplash( self.Entity:GetPos(), 1000, math.random(5000,9000), 8, { self.Entity:GetClass() } )
		local targets = ents.FindInSphere( self.Entity:GetPos(), 1000)
	
		for _,i in pairs(targets) do
			if i:GetClass() == "prop_physics" then
				i:GetPhysicsObject():ApplyForceOffset( (i.Entity:NearestPoint(self.Entity:GetPos()) - self.Entity:GetPos()):Normalize() * 500000, self.Entity:GetPos() )
			end
		end
		
		self.Entity:EmitSound("explode_9")
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetStart(self.Entity:GetPos())
		util.Effect( "BigTorpSplode", effectdata )
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
	self.Entity:SetParent()
	if self.HPWeld and self.HPWeld:IsValid() then self.HPWeld:Remove() end
	self.PhysObj:SetVelocity(self.Entity:GetForward()*10000)
	self.Entity:Arm()
	self.ATime = CurTime() + 0.5
	self.PFire = true
	self.PhysObj:EnableCollisions(false)
	self.PhysObj:EnableGravity(false)
end

function ENT:gcbt_breakactions( damage, pierce )
	if !self.Exploded then
		self.Entity:Splode()
	end
	self.Exploded = true
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