AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
util.PrecacheSound( "SB/RailGunSmall.wav" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo_2/drone_railgun.mdl" ) 
	self.Entity:SetName("RailGun")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, { "Fire" } )
		self.Outputs = WireLib.CreateOutputs( self, { "Charge", "Ready" })
	end

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	--self.val1 = 0
	--RD_AddResource(self.Entity, "Munitions", 0)
	
	self.ChSound = CreateSound( self.Entity, "SB/Charging2.wav" )
	self.ChSound:Stop()
	self.ChSPlaying = false
	self.CTime = 0
	self.Charge = 0
	self.CDown = 0
	self.FTime = 0
	self.Firing = false
	self.WCharge = false
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "SF-SRailgun" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			self.WCharge = true
		else
			self.WCharge = false
		end
	end
end

function ENT:RGFire()

	local trace = {}
	trace.start = self.Entity:GetPos() + (self.Entity:GetForward() * 15)
	trace.endpos = self.Entity:GetPos() + (self.Entity:GetForward() * 10000)
	trace.filter = self.Entity
	local tr = util.TraceLine( trace )
	if tr.Hit and !tr.HitSky then
		util.BlastDamage(self.Entity, self.Entity, tr.HitPos, self.Charge * 2.5, self.Charge * 5)
		util.BlastDamage(self.Entity, self.Entity, tr.HitPos, self.Charge, self.Charge * 100)
		local effectdata = EffectData()
		local effectdata = EffectData()
		effectdata:SetStart(self:GetPos())
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetScale(self.Charge)
		util.Effect( "SmallRailImpact", effectdata )
		if tr.Entity and tr.Entity:IsValid() then
			local Phys = tr.Entity:GetPhysicsObject()
			if Phys:IsValid() then			
				Phys:ApplyForceOffset( self.Entity:GetForward() * (self.Charge * 200000), tr.HitPos )
				--print("Thrusting...")
				--Phys:ApplyForceCenter( self.Entity:GetForward() * (self.Charge * 200) )
			end
			local gdmg = math.random(self.Charge * 10,self.Charge * 20)
			attack = cbt_dealdevhit(tr.Entity, gdmg, 5 + (self.Charge * 0.1))
			if (attack ~= nil) then
				if (attack == 2) then
					local wreck = ents.Create( "wreckedstuff" )
					wreck:SetModel( tr.Entity:GetModel() )
					wreck:SetAngles( tr.Entity:GetAngles() )
					wreck:SetPos( tr.Entity:GetPos() )
					wreck:Spawn()
					wreck:Activate()
					tr.Entity:Remove()
					local effectdata1 = EffectData()
					effectdata1:SetOrigin(tr.Entity:GetPos())
					effectdata1:SetStart(tr.Entity:GetPos())
					effectdata1:SetScale( 10 )
					effectdata1:SetRadius( 100 )
					util.Effect( "Explosion", effectdata1 )
				end
			end
		end
	end
		
	local effectdata2 = EffectData()
	effectdata2:SetStart(self:GetPos())
	effectdata2:SetOrigin(tr.HitPos)
	effectdata2:SetScale(self.Charge)
	util.Effect( "SmallRailTrace", effectdata2 )
	
	self.Entity:EmitSound("EnergyBall.KillImpact")
	
	self.CDown = CurTime() + 3
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then
			HPLink( ent.Cont, ent.Entity, self.Entity )
		end
	end
end

function ENT:HPFire()
	--if CurTime() >= self.CDown then
		self.FTime = CurTime() + 0.4
	--end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	if (CurTime() < self.FTime or self.WCharge) and CurTime() >= self.CDown then
		--self.Entity:RGFire()
		self.Charge = math.Clamp( self.Charge + 1, 0, 50 )
	else
		if self.Charge > 0 then
			self.Entity:RGFire()
		end
		self.Charge = 0
	end
	if self.Charge > 0 then
		if !self.ChSPlaying then
			self.ChSound:PlayEx(1,100)
			self.ChSPlaying = true
		end
		self.ChSound:ChangePitch( math.Clamp(100 + (self.Charge * 2.5) + (math.random()*5),0,255) )
	else
		self.ChSound:Stop()
		self.ChSPlaying = false
	end
	
	if CurTime() >= self.CDown then
		Wire_TriggerOutput( self.Entity, "Ready", 1 )
	else
		Wire_TriggerOutput( self.Entity, "Ready", 0 )
	end
	Wire_TriggerOutput( self.Entity, "Charge", self.Charge )
	
	self.Entity:NextThink( CurTime() + 0.1 ) 
	return true

end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

end

function ENT:OnRemove()
	self.ChSound:Stop()
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