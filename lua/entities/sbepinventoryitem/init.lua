
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local SWEPData = list.Get( "SBEP_SWeaponry" )

function ENT:Initialize()
	local Data = SWEPData[ self.ItemType ]
	if Data then
		self.Entity:SetModel(Data.Model)
	else
		self.Entity:SetModel( "models/props_phx/misc/smallcannonball.mdl" )
	end
	self.Entity:SetName("Handle")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType(3)
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass(10)
	end
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	--self.Ammo = 0
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,70)
	
	local ent = ents.Create( "SBEPInventoryItem" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	
	return ent
	
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	Data = SWEPData[ self.ItemType ]
	if !Data then
		print("No data. Removing.")
		self:Remove()
	end
	--self.Entity:NextThink( CurTime() + 0.01 ) 
	--return true	
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( ply, caller )
	umsg.Start("SBEPInventoryAdd", ply )
    umsg.String( self.ItemType )
	umsg.Float( self.Ammo )
	umsg.End()
	
	
	ply.Inventory = ply.Inventory or {}
	table.insert(ply.Inventory, { Type = self.ItemType, Ammo = self.Ammo } )
	--print("Server Inventory:")
	--PrintTable(ply.Inventory)
	
	self.Entity:Remove()
end
