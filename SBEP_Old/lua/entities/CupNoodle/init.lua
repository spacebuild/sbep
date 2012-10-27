include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	local ent = ents.Create("CupNoodle")
		ent:Spawn()
		
		ent:SetPos(tr.HitPos - Vector(0, 0, ent:OBBMins().z))
	
	return ent
end
	
function ENT:Initialize()

	self:SetModel( "models/slyfo/cup_noodle.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	local phys = self:GetPhysicsObject()
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
	self:Remove()
end