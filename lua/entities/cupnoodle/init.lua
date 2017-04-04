include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	local ent = ents.Create("CupNoodle") 			// Create the entity
		ent:SetPos(tr.HitPos + Vector(0, 0, 10)) 	// Set it to spawn 20 units over the spot you aim at when spawning it
		ent:Spawn()									// Spawn it
		return ent 									// You need to return the entity to make it work
end --SpawnFunction end
	
function ENT:Initialize()

	self.Entity:SetModel( "models/slyfo/cup_noodle.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )

local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end -- if end
end -- Initialize end

function ENT:Use( activator, caller )
	self.Entity:Remove()
	if ( activator:IsPlayer() ) then
		local health = activator:Health()
		activator:SetHealth( health + 25 )
	end -- if end
end -- Use end