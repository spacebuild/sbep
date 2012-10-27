
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/finfunnel.mdl" )
	self:SetName("Thruster")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( 3 )
	--self:SetMaterial("models/props_combine/combinethumper002")
	self.Inputs = Wire_CreateInputs( self, { "Active", "Size", "Length" } )
	
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
	self:SetSize(1)
	
	self.NFire = 0
	self.MCD = 0
	self.CSpeed = 0
	self.Size = 1
	self.Length = 1
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
	elseif (iname == "Size") then
		self.Size = math.Clamp(value,0.1,100)
	
	elseif (iname == "Length") then
		self.Length = math.Clamp(value,0.1,100)
		
	end
end

function ENT:Think()
	
	--self:SetSpeed(math.Clamp(self.CSpeed,0,1000))

	if self:GetParent():IsValid() then
		--self:SetLocalPos(Vector(0,0,0))
		--self:SetLocalAngles(Angle(0,0,0))
	end
	--self.Size = 1
	--self.Length = 1
	self:SetLength(self.Length)
	self:SetSize(self.Size)
	
	--self:NextThink(CurTime() + 0.01)
	
	--return true
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "VisThrusterMk2" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Use( activator, caller )
	if self:GetActive() then
		self:SetActive(false)
	else
		self:SetActive(true)
	end
end