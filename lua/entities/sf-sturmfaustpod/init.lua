AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua') --Thanks to DuneD for this bit.
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/missile_sturmfausttube.mdl" ) 
	self.Entity:SetName("Sturm Faust Launcher")
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
	
	self.Faust = ents.Create( "SF-SturmFaust" )
	if ( !self.Faust:IsValid() ) then return end
	self.Faust:SetPos( self.Entity:GetPos() + (self.Entity:GetUp() * -1) + (self.Entity:GetForward() * 30) )
	self.Faust:SetAngles( self.Entity:GetAngles() )
	self.Faust.SPL = self.SPL
	self.Faust:Spawn()
	self.Faust:Initialize()
	self.Faust:Activate()
	self.Faust:SetOwner(self)
	self.Faust:SetParent(self.Entity)
	
	
	self.Fired = false
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "SF-SturmFaustPod" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			self.Entity:HPFire()
		end
			
	end
end

function ENT:Use( activator, caller )
	self.Entity:HPFire()
end

function ENT:Think()

	if !self.Faust then
		self.Entity:SetParent()
		constraint.RemoveConstraints( self.Entity, "Weld" )
		self.Entity:Fire("kill", "", 10)
		self.Entity:SetColor(Color(50,50,50,255))
	end

end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self.Entity ) end
	end
end

function ENT:HPFire()
	if (!self.Fired and self.Faust and self.Faust:IsValid()) then
		self.Faust:SetParent()
		self.Faust.PhysObj:SetAngles(self.Entity:GetAngles())
		self.Faust.PhysObj:SetPos(self.Entity:GetPos() + (self.Entity:GetUp() * -1) + (self.Entity:GetForward() * 30))
		self.Faust.PhysObj:SetVelocity(self.Entity:GetForward() * 5000)
		self.Faust:Fire("kill", "", 30)
		
		
		local RockTrail = ents.Create("env_rockettrail")
		RockTrail:SetAngles( self.Faust:GetAngles() )
		RockTrail:SetPos( self.Faust:GetPos() + self.Faust:GetForward() * -7 )
		RockTrail:SetParent(self.Faust)
		RockTrail:Spawn()
		RockTrail:Activate()
		--RD_ConsumeResource(self, "Munitions", 1000)
		self.Entity:EmitSound("Weapon_RPG.Single")
		
		self.Faust.Armed = true
		self.Faust = nil
		self.Fired = true
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