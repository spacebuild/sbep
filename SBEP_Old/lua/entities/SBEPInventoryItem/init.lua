
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local SWEPData = list.Get( "SBEP_SWeaponry" )

function ENT:Initialize()
	local Data = SWEPData[ self.ItemType ]
	if Data then
		self:SetModel(Data.Model)
	else
		self:SetModel( "models/props_phx/misc/smallcannonball.mdl" )
	end
	self:SetName("Handle")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType(3)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass(10)
	end
	self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self:GetPhysicsObject()
	
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
	--self:NextThink( CurTime() + 0.01 ) 
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
	
	self:Remove()
end
