
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Slyfo_2/weap_gigafish.mdl" )
	self:SetName("Gigafish")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetMaterial("models/props_combine/combinethumper002")
	self.Inputs = Wire_CreateInputs( self, { "Arm","Detonate" } )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	
    --self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	
	self.NFire = 0
	self.MCD = 0
	self.FSTime = 0
	self.FETime = 0
end

function ENT:TriggerInput(iname, value)		
	
	if (iname == "Arm") then
		if value > 0 then
			self:Arm()
		end
		
	elseif (iname == "Detonate") then
		if value > 0 then
			self:Splode()
		end
	end	
end

function ENT:Think()

	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "Gigafish" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Use( activator, caller )
	
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then
			HPLink( ent.Cont, ent.Entity, self )
		end
	end
end

function ENT:Splode()
	if(!self.Exploded) then
		local Splode = ents.Create("Gigasplosion")
		Splode:SetPos(self:GetPos())
		Splode:Spawn()
	end
	self.Exploded = true
	self:Remove()
end

function ENT:HPFire()
	
end

function ENT:Arm()
	self.Armed = true
	self:SetArmed( true )
end

function ENT:PhysicsCollide( data, physobj )
	if (!self.Exploded and self.Armed) then
		self:Splode()
	end
end