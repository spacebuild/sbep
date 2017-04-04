AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	
	self.Entity:SetModel( "models/Slyfo/torpedoship1.mdl" ) 
	self.Entity:SetName("LargeTorpedoLauncher")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, { "Fire", "Reload" } )
		self.Outputs = WireLib.CreateOutputs( self, { "Loaded", "ReloadProgress" })
	end

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self.Entity:StartMotionController()
	self.PhysObj = self.Entity:GetPhysicsObject()

	self.ReloadPeriod = 15 -- This is a constant that states how long it takes to automatically reload
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local ent = ents.Create( "SF-TorpTubeL" )
	ent:SetPos( tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50) )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	
	if (iname == "Fire") and (value > 0) then
		self.Entity:HPFire()
		
	elseif (iname == "Reload") then	
		if (value > 0) then
			if !self.Loading then
				self.LTime = CurTime() + self.ReloadPeriod
				self.Loading = true
			end
		end
	end
	
end

function ENT:Think()
	if CurTime() >= self.LTime and self.Loading and !self.Torp then
		local Torp = ents.Create( "SF-TorpBig" )
		if !Torp or !Torp:IsValid() then return end
		Torp:SetPos( self.Entity:GetPos() + self.Entity:GetUp() * 63 + self.Entity:GetForward() * -50)
		Torp:SetAngles( self.Entity:GetAngles() )
		Torp:Spawn()
		Torp:Initialize()
		Torp:Activate()
		self.BWeld = constraint.Weld(Torp, self.Entity, 0, 0, 0, true)
		Torp:SetOwner(self)
		Torp:SetParent( self )
		Torp.Mounted = true
		Torp:GetPhysicsObject():EnableCollisions(false)
		self.Torp = Torp
				
		self.Loading = false
	end
	local LPercent = 0
	if self.LTime > CurTime() and !self.Loaded then
		LPercent = ( ( self.ReloadPeriod - ( self.LTime - CurTime() ) ) / self.ReloadPeriod ) * 100
	else
		LPercent = 0
	end
	if self.Loaded then
		LPercent = 100
	end
	Wire_TriggerOutput( self.Entity, "ReloadProgress", LPercent )
	
	if self.Torp and self.Torp:IsValid() then
		Wire_TriggerOutput( self.Entity, "Loaded", 1 )
		self.Entity:SetLVar(100)
	else
		Wire_TriggerOutput( self.Entity, "Loaded", 0 )
		self.Entity:SetLVar(LPercent)
	end
end

function ENT:PhysicsCollide( data, physobj )

end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Touch( ent )
	if (!self.Torp or !self.Torp:IsValid()) and ent:IsValid() and ent.BigTorp and !ent.Armed and !ent.Mounted then
		self.Torp = ent
		ent:SetPos( self.Entity:GetPos() + self.Entity:GetUp() * 63 + self.Entity:GetForward() * -50)
		ent:SetAngles( self.Entity:GetAngles() )
		constraint.RemoveConstraints( self.Torp, "Weld" )
		self.BWeld = constraint.Weld(self.Torp, self.Entity, 0, 0, 0, true)
		ent:SetOwner(self)
		ent:SetParent( self.Entity )
		ent.Mounted = true
		ent:GetPhysicsObject():EnableCollisions(false)
				
		self.Loading = false
	end
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self.Entity ) end
		timer.Simple(0.1, function() self.Entity:GetPhysicsObject():EnableCollisions(true) end )
		self.Entity:SetParent()
		self.Loading = true
	end
end

function ENT:OnRemove()
	if self.Torp and self.Torp:IsValid() then
		self.Torp:Remove()
	end
end

function ENT:HPFire()
	if self.Torp and self.Torp:IsValid() then
		self.Torp:Arm()
		self.Torp.ATime = CurTime() + 0.5
		self.Torp:SetParent()
		self.Torp.PFire2 = true
		if self.BWeld and self.BWeld:IsValid() then self.BWeld:Remove() end
		self.Torp:SetPos( self.Entity:GetPos() + self.Entity:GetUp() * 63)
		--self.Torp.PhysObj:EnableCollisions(true)
		--self.Torp.PhysObj:EnableGravity(false)
		self.Torp = nil
	end
	if !self.Loading then
		self.LTime = CurTime() + self.ReloadPeriod
		self.Loading = true
	end
end

function ENT:PreEntityCopy()
	local DI = {}

	if (self.Torp) and (self.Torp:IsValid()) then
	    DI.Torp = self.Torp:EntIndex()
	end
	
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self.Entity )
	end
	
	duplicator.StoreEntityModifier(self, "SBEPTorpL", DI)
end
duplicator.RegisterEntityModifier( "SBEPTorpL" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPTorpL

	if (DI.Torp) then
		self.Torp = CreatedEntities[ DI.Torp ]
	end
	
	if(Ent.EntityMods and Ent.EntityMods.SBEPTorpL.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPTorpL.WireData, function(id) return CreatedEntities[id] end)
	end

	self.SPL = pl
end