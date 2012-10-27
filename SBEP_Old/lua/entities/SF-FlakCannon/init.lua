AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Spacebuild/Nova/flak1.mdl" ) 
	self:SetName("FlakCannon")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, { "Fire" } )
	end
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self:GetPhysicsObject()
	
	--self.val1 = 0
	--RD_AddResource(self, "Munitions", 0)
	
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
				self:HPFire()
			--end
		end

		
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	--self.val1 = RD_GetResourceAmount(self, "Munitions")

end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
	end
end

function ENT:HPFire()
	if (CurTime() >= self.MCDown) then
		local NewShell = ents.Create( "SF-FlakShell" )
		if ( !NewShell:IsValid() ) then return end
		NewShell:SetPos( self:GetPos() + (self:GetUp() * (14 * self.BMul)) )
		NewShell:SetAngles( self:GetAngles() )
		NewShell.SPL = self.SPL
		NewShell:Spawn()
		NewShell:Initialize()
		NewShell:Activate()
		NewShell:SetOwner(self)
		NewShell.PhysObj:SetVelocity(self:GetForward() * 1000)
		NewShell:Fire("kill", "", 30)
		NewShell.ParL = self
		--RD_ConsumeResource(self, "Munitions", 1000)
		self:SetNetworkedFloat("CDown1",CurTime() + 5)
		self.MCDown = CurTime() + 0.4
		local phys = self:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:ApplyForceCenter( self:GetForward() * -1000 ) 
		end
		
		self.BMul = self.BMul * -1
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos() +  self:GetUp() * (14 * self.BMul))
		effectdata:SetStart(self:GetPos() +  self:GetUp() * (14 * self.BMul))
		util.Effect( "Explosion", effectdata )
	end
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