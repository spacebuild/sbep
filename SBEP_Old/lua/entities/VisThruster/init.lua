
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Items/AR2_Grenade.mdl" )
	self:SetName("Thruster")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( 3 )
	--self:SetMaterial("models/props_combine/combinethumper002")
	self.Inputs = Wire_CreateInputs( self, { "Active", "Skin" } )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
	end
	
    --self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	
	self.NFire = 0
	self.MCD = 0
	self.CSpeed = 0
	self.Skin = 1
	self:SetSkin(self.Skin)
end

function ENT:TriggerInput(iname, value)		
	
	if (iname == "Active") then
		if value > 0 then
			self.NBT = CurTime() + 1
			self:SetActive(true)
		else
			self.NBT = CurTime() + 1
			self:SetActive(false)
		end
	
	elseif (iname == "Skin") then
		self.Skin = math.Clamp(value,0,5)
	end	
end

function ENT:Think()
	
	self:SetSkin(self.Skin)

	if self:GetParent():IsValid() then
		self:SetLocalPos(Vector(0,0,0))
		self:SetLocalAngles(Angle(0,0,0))
	end
	
	--self:NextThink(CurTime() + 0.01)
	
	--return true
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "VisThruster" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Use( ply, caller )
	if ply:KeyDown( IN_SPEED ) then
		self.Skin = self.Skin + 1
		if self.Skin > 5 then
			self.Skin = 1
		end
		print(self.Skin)
	else
		if self:GetActive() then
			self:SetActive(false)
		else
			self:SetActive(true)
		end
	end
end