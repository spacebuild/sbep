AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua') --Thanks to DuneD for this bit.
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/missile_sturmfausttube.mdl" ) 
	self:SetName("Sturm Faust Launcher")
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
	
	self.Faust = ents.Create( "SF-SturmFaust" )
	if ( !self.Faust:IsValid() ) then return end
	self.Faust:SetPos( self:GetPos() + (self:GetUp() * -1) + (self:GetForward() * 30) )
	self.Faust:SetAngles( self:GetAngles() )
	self.Faust.SPL = self.SPL
	self.Faust:Spawn()
	self.Faust:Initialize()
	self.Faust:Activate()
	self.Faust:SetOwner(self)
	local WD = constraint.Weld( self, self.Faust )
	self.Faust:SetParent(self)
	
	
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
			self:HPFire()
		end
			
	end
end

function ENT:Use( activator, caller )
	self:HPFire()
end

function ENT:Think()

	if !self.Faust then
		self:SetParent()
		constraint.RemoveConstraints( self, "Weld" )
		self:Fire("kill", "", 10)
		self:SetColor(Color(50,50,50,255))
	end

end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
	end
end

function ENT:HPFire()
	if (!self.Fired and self.Faust and self.Faust:IsValid()) then
		self.Faust:SetParent()
		constraint.RemoveConstraints( self.Faust, "Weld" )
		self.Faust.PhysObj:SetVelocity(self:GetForward() * 5000)
		self.Faust:Fire("kill", "", 30)
		
		
		local RockTrail = ents.Create("env_rockettrail")
		RockTrail:SetAngles( self.Faust:GetAngles() )
		RockTrail:SetPos( self.Faust:GetPos() + self.Faust:GetForward() * -7 )
		RockTrail:SetParent(self.Faust)
		RockTrail:Spawn()
		RockTrail:Activate()
		--RD_ConsumeResource(self, "Munitions", 1000)
		self:EmitSound("Weapon_RPG.Single")
		
		self.Faust.Armed = true
		self.Faust = nil
		self.Fired = true
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