AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
util.PrecacheSound( "SB/Artillery2.wav" )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/artycannon.mdl" ) 
	self:SetName("ArtilleryCannon")
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


end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,300)
	
	local ent = ents.Create( "SF-ArtCannon" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			self:HPFire()
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
	local CDown = self:GetNetworkedFloat("ReloadTime")
	if (CurTime() >= CDown) then
		--if (self.val1 >= 1000) then
			local NewShell = ents.Create( "SF-ArtShell" )
			if ( !NewShell:IsValid() ) then return end
			NewShell:SetPos( self:GetPos() + (self:GetUp() * 155) )
			NewShell:SetAngles( self:GetUp():Angle() )
			NewShell.SPL = self.SPL
			NewShell:Spawn()
			NewShell:Initialize()
			NewShell:Activate()
			NewShell:SetOwner(self)
			NewShell.PhysObj:SetVelocity(self:GetUp() * 10000)
			NewShell:Fire("kill", "", 30)
			NewShell.ParL = self
			--RD_ConsumeResource(self, "Munitions", 1000)
			self:SetNetworkedFloat("ReloadTime",CurTime() + 5)
			local phys = self:GetPhysicsObject()  	
			if (phys:IsValid()) then  		
				phys:ApplyForceCenter( self:GetUp() * -10000 ) 
			end 
			
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos() +  self:GetUp() * 150)
			effectdata:SetStart(self:GetPos() +  self:GetUp() * 150)
			util.Effect( "Explosion", effectdata )
			self:EmitSound("SB/Artillery2.wav", 500)
		--end
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