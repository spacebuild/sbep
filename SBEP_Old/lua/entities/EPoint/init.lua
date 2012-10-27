AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/jaanus/wiretool/wiretool_range.mdl" ) 
	self:SetName("NCController")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end
	self:StartMotionController()
	self.PhysObj = self:GetPhysicsObject()
	self.Inputs = Wire_CreateInputs( self, { "Priority" } )
	self.CDown = 0
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,10)
	
	local ent = ents.Create( "EPoint" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)
	
	if (iname == "Priority") then
		if (value >= 0) then
			self.EPriority = value
		end
		
	end
	
end

function ENT:Think()
	
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Touch( ent )
	if (ent:IsVehicle()) then
		ent.ExitPoint = self
		self.Vec = ent
	end
	if (ent.Bay) then
		local closest
		local distance = 100000
		for k,v in pairs(ent.Bay) do
			local tdis = self:GetPos():Distance(ent:LocalToWorld(v.pos))
			if (!v.EP or tdis < distance) then
				distance = tdis
				closest = v
			end
		end
		closest.EP = self
	end
end

function ENT:Use( ply )
	if self.Vec and self.Vec:IsValid() then
		if (CurTime() >= self.CDown) then
			ply:EnterVehicle( self.Vec )
		end
	end
end

function ENT:PreEntityCopy()
	local DI = {}

	if (self.Vec) and (self.Vec:IsValid()) then
	    DI.Vec = self.Vec:EntIndex()
	end
	if (self.CDown) then
	    DI.CDown = self.CDown
	end
	
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self )
	end
	
	duplicator.StoreEntityModifier(self, "SBEPEPoint", DI)
end
duplicator.RegisterEntityModifier( "SBEPEPoint" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPEPoint

	if DI.Vec then
		self.Vec = CreatedEntities[ DI.Vec ]
		self.Vec.ExitPoint = self
	end
	
	if(Ent.EntityMods and Ent.EntityMods.SBEPEPoint.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPEPoint.WireData, function(id) return CreatedEntities[id] end)
	end

end