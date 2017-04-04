AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Spacebuild/Nova/flak1.mdl" ) 
	self.Entity:SetName("FlakCannon")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, { "Fire" } )
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
	
	self.MCDown = 0
	
	self.BMul = 1


end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,100)
	
	local ent = ents.Create( "SF-FlakCannon" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		
		if (value > 0) then
			--if (self.val1 >= 1000) then
				self.Entity:HPFire()
			--end
		end

		
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	--self.val1 = RD_GetResourceAmount(self.Entity, "Munitions")

end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self.Entity ) end
	end
end

function ENT:HPFire()
	if (CurTime() >= self.MCDown) then
		local NewShell = ents.Create( "SF-FlakShell" )
		if ( !NewShell:IsValid() ) then return end
		NewShell:SetPos( self.Entity:GetPos() + (self.Entity:GetUp() * (14 * self.BMul)) )
		NewShell:SetAngles( self.Entity:GetAngles() )
		NewShell.SPL = self.SPL
		NewShell:Spawn()
		NewShell:Initialize()
		NewShell:Activate()
		NewShell:SetOwner(self)
		NewShell.PhysObj:SetVelocity(self.Entity:GetForward() * 1000)
		NewShell:Fire("kill", "", 30)
		NewShell.ParL = self.Entity
		--RD_ConsumeResource(self, "Munitions", 1000)
		self.Entity:SetNetworkedFloat("CDown1",CurTime() + 5)
		self.MCDown = CurTime() + 0.4
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:ApplyForceCenter( self.Entity:GetForward() * -1000 ) 
		end
		
		self.BMul = self.BMul * -1
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * (14 * self.BMul))
		effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * (14 * self.BMul))
		util.Effect( "Explosion", effectdata )
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