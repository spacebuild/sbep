AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "explode_8" )
util.PrecacheSound( "explode_5" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/warhead.mdl" )
	self.Entity:SetName("Small Torpedo")
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

    --self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.CAng = self.Entity:GetAngles()
	

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
	
	local ent = ents.Create( "SF-TorpSmall" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Think()
	if (self.PFire) then
		self.PhysObj:SetVelocity(self.Entity:GetForward()*10000)
		self.PFire = false
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
	end
	--self.Exploded=true
end

function ENT:Use( activator, caller )

end

function ENT:Arm()
	self.Armed = true
	--util.SpriteTrail( self.Entity, 0,  Color(255,255,80,150), false, 50, 0, 3, 1, "trails/smoke.vmt" )
	self.Entity:SetArmed( true )
end

function ENT:Splode()
	if(!self.Exploded) then
		--self.Exploded = true
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 1500, 1500)
		cbt_hcgexplode( self.Entity:GetPos(), 600, math.random(1000,5000), 8)
		local targets = ents.FindInSphere( self.Entity:GetPos(), 1000)
	
		for _,i in pairs(targets) do
			if i:GetClass() == "prop_physics" then
				i:GetPhysicsObject():ApplyForceOffset( Vector(100000,100000,100000), self.Entity:GetPos() )
			end
		end
		
		self.Entity:EmitSound("explode_9")
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetStart(self.Entity:GetPos())
		effectdata:SetMagnitude(3)
		util.Effect( "PulseSplode", effectdata )
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
	constraint.RemoveConstraints( self.Entity, "Weld" )
	constraint.RemoveConstraints( self.Entity, "Ballsocket" )
	self.PhysObj:SetVelocity(self.Entity:GetForward()*10000)
	self.PFire = true
	self.Entity:GetPhysicsObject():EnableGravity(false)
	timer.Simple(1.5,function()
		if self.Entity:IsValid() then
		self.Entity:GetPhysicsObject():EnableCollisions(true)
		self.Entity:Arm()
		end
	 end)
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