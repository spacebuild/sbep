AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "explode_8" )
util.PrecacheSound( "explode_5" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/spacemine.mdl" )
	self.Entity:SetName("Mine")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, { "Arm" } )
	end

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end

	self.cbt = {}
	self.cbt.health = 5000
	self.cbt.armor = 22
	self.cbt.maxhealth = 5000
	
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
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,60)
	
	local ent = ents.Create( "SF-SpaceMine" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Think()
	local phy = self.Entity:GetPhysicsObject()
	if self.Armed then
		if self.Homer then
			if self.Target and self.Target:IsValid() then
				--if self.Target and self.Target:IsValid() then
					local IMass = self.Target:GetPhysicsObject():GetMass()
					local IDist = (self.Entity:GetPos() - self.Target:GetPos()):Length()
					local TVal = (IMass * 3) - IDist				
					if !self.Entity:GetTracking() then self.Entity:SetTracking( true ) end
					local DVec = self.Target:GetPos() - self.Entity:GetPos()
					--phy:SetVelocity( ((DVec:Normalize() * ((self.Target:GetPhysicsObject():GetVelocity():Length() * 0.1) + (TVal * 0.01) )) + phy:GetVelocity()) )
					--phy:ApplyForceCenter( DVec:Normalize() * ((self.Target:GetPhysicsObject():GetVelocity():Length() * 100) + (TVal * 2000 ) )
					if TVal <= 0 then
						self.Target = nil
					end
				--end
			else
				if self.Entity:GetTracking() then self.Entity:SetTracking( false ) end
				local targets = ents.FindInSphere( self.Entity:GetPos(), 5000)
		
				local CMass = 0
				local CT = nil
							
				for _,i in pairs(targets) do
					if i:GetPhysicsObject() and i:GetPhysicsObject():IsValid() and !i.MineProof and !i:IsPlayer() then
						local IMass = i:GetPhysicsObject():GetMass()
						local IDist = (self.Entity:GetPos() - i:GetPos()):Length()
						local TVal = (IMass * 3) - IDist
						if TVal > CMass then
							CT = i
						end
					end
				end
				self.Target = CT
				phy:SetVelocity( phy:GetVelocity() * 0.9 )
			end
		else
			phy:SetVelocity( phy:GetVelocity() * 0.9 )
		end
	end
	self.Entity:NextThink( CurTime() + 0.1 )
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
	self.Entity:Arm()
end

function ENT:Arm()
	self.Armed = true
	--util.SpriteTrail( self.Entity, 0,  Color(255,255,80,150), false, 50, 0, 3, 1, "trails/smoke.vmt" )
	self.Entity:SetArmed( true )
	self.PhysObj:EnableGravity(false)
	self.Homer = true
end

function ENT:Splode()
	if(!self.Exploded) then
		--self.Exploded = true
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 750, 750)
		local targets = ents.FindInSphere( self.Entity:GetPos(), 500)
		local tooclose = ents.FindInSphere( self.Entity:GetPos(), 5)
		local Mines = ents.FindByClass("SF-SpaceMine")
		
		for _,i in pairs(targets) do
						
			local tracedata = {}
			tracedata.start = self.Entity:GetPos()
			tracedata.endpos = i:LocalToWorld( i:OBBCenter( ) )
			tracedata.filter = tooclose, Mines
			tracedata.mask = MASK_SOLID
			local trace = util.TraceLine(tracedata) 
						
			if trace.Entity == i then
				local hitat = trace.HitPos
				cbt_dealhcghit( i, math.random(4000,8000), 8, hitat, hitat)
			end
		end
		
		targets = ents.FindInSphere( self.Entity:GetPos(), 2000)
	
		for _,i in pairs(targets) do
			if i:GetPhysicsObject() and i:GetPhysicsObject():IsValid() and !i.MineProof and !i:IsPlayer() then
				i:GetPhysicsObject():ApplyForceOffset( Vector(500000,500000,500000), self.Entity:GetPos() )
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
	if ent.HasHardpoints and !self.Armed then
		--if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self.Entity ) end
	end
end

function ENT:HPFire()
	self.Entity:SetParent()
	if self.HPWeld and self.HPWeld:IsValid() then self.HPWeld:Remove() end
	self.Entity:Arm()
	self.PhysObj:EnableCollisions(true)
	self.PhysObj:EnableGravity(false)
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