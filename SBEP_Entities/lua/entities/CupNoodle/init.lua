include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	local ent = ents.Create("CupNoodle")
		ent:Spawn()
		
		ent:SetPos(tr.HitPos - Vector(0, 0, ent:OBBMins().z))
	
	return ent
end
	
function ENT:Initialize()

	self.Entity:SetModel( "models/slyfo/cup_noodle.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Use( activator, caller )

	if ( activator:IsPlayer() ) then
		local health = activator:Health()
		if health < 101 then
			activator:SetHealth( health + 25 )
		elseif health < 125 then
			activator:SetHealth( 125 )
		end
	end
	self.Entity:Remove()
end