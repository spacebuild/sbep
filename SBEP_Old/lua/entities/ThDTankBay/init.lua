AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/sat_rtankstand.mdl" ) 
	self.Entity:SetName("Fuel Tank")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Inputs = Wire_CreateInputs( self.Entity, { "Vent1", "Vent2", "Eject1", "Eject2", "Disengage1", "Disengage2" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Tank1Fuel", "Tank2Fuel" })
	self.Entity:SetUseType( 3 )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass(50)
	end
	self.Entity:StartMotionController()
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.HasHardpoints = true

	--RD_AddResource(self.Entity, "thfuel", 0)
	
	self.HPC			= 2
	self.HP				= {}
	self.HP[1]			= {}
	self.HP[1]["Ent"]	= nil
	self.HP[1]["Type"]	= "TankS"
	self.HP[1]["Pos"]	= Vector(-38,19,22)
	self.HP[2]			= {}
	self.HP[2]["Ent"]	= nil
	self.HP[2]["Type"]	= "TankS"
	self.HP[2]["Pos"]	= Vector(-38,-19,22)
	
	self.Cont = self.Entity
end

function ENT:TriggerInput(iname, value)		
	
	if (iname == "Vent1") then
		if self.HP[1].Ent and self.HP[1].Ent:IsValid() then
			if (value > 0) then	
				self.HP[1].Ent.Venting = true
			else
				self.HP[1].Ent.Venting = false
			end
		end
		
	elseif (iname == "Vent2") then
		if self.HP[2].Ent and self.HP[2].Ent:IsValid() then
			if (value > 0) then
				self.HP[2].Ent.Venting = true
			else
				self.HP[2].Ent.Venting = false
			end
		end
		
	elseif (iname == "Disengage1") then
		if self.HP[1].Ent and self.HP[1].Ent:IsValid() then
			if (value > 0) then
				self.Venting = true
			else
				self.Venting = false
			end
		end
		
	elseif (iname == "Disengage2") then
		if self.HP[1].Ent and self.HP[1].Ent:IsValid() then
			if (value > 0) then
				self.Venting = true
			else
				self.Venting = false
			end
		end
		
	elseif (iname == "Eject1") then
		if self.HP[1].Ent and self.HP[1].Ent:IsValid() then
			if (value > 0) then
				--print("Ejecting...")
				self.HP[1].Ent:SetParent()
				if self.HP[1].Ent.HPWeld and self.HP[1].Ent.HPWeld:IsValid() then self.HP[1].Ent.HPWeld:Remove() end
				self.HP[1].Ent.THealth = 0
				local phys = self.HP[1].Ent:GetPhysicsObject()
				phys:EnableGravity(true)
				phys:EnableCollisions(true)
				phys:ApplyForceOffset(self.Entity:GetUp() * 30000 + self.Entity:GetForward() * 1000, self.HP[1].Ent:GetPos() + self.Entity:GetForward() * -40)
			end
		end
		
	elseif (iname == "Eject2") then
		if self.HP[2].Ent and self.HP[2].Ent:IsValid() then
			if (value > 0) then
				self.HP[2].Ent:SetParent()
				if self.HP[2].Ent.HPWeld and self.HP[2].Ent.HPWeld:IsValid() then self.HP[2].Ent.HPWeld:Remove() end
				self.HP[2].Ent.THealth = 0
				local phys = self.HP[2].Ent:GetPhysicsObject()
				phys:EnableGravity(true)
				phys:EnableCollisions(true)
				phys:ApplyForceOffset(self.Entity:GetUp() * 30000 + self.Entity:GetForward() * 1000, self.HP[2].Ent:GetPos() + self.Entity:GetForward() * -40)
			end
		end
					
	end
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "ThDTankBay" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Think()
	if self.HP[1].Ent and self.HP[1].Ent:IsValid() then
		Wire_TriggerOutput( self.Entity, "Tank1Fuel", self.HP[1].Ent.Fuel )
	else
		Wire_TriggerOutput( self.Entity, "Tank1Fuel", -1 )
	end
	
	if self.HP[2].Ent and self.HP[2].Ent:IsValid() then
		Wire_TriggerOutput( self.Entity, "Tank2Fuel", self.HP[2].Ent.Fuel )
	else
		Wire_TriggerOutput( self.Entity, "Tank2Fuel", -1 )
	end
end

function ENT:OnTakeDamage( dmg )

end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:Touch( ent )
	
end