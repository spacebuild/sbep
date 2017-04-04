
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/finfunnel.mdl" )
	self.Entity:SetName("Thruster")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( 3 )
	--self.Entity:SetMaterial("models/props_combine/combinethumper002")
	self.Inputs = Wire_CreateInputs( self.Entity, { "Active", "Force" } )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end
	
    --self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.CAng = self.Entity:GetAngles()
	self.Entity:SetSize(1)
	
	self.NFire = 0
	self.MCD = 0
	self.CSpeed = 0
	self.LForce = 100
	self.Size = 1
	self.Length = 1
end

function ENT:TriggerInput(iname, value)		
	
	if (iname == "Active") then
		if value > 0 then
			self.NBT = CurTime() + 1
			self.Entity:SetActive(true)
		else
			self.NBT = CurTime() + 1
			self.Entity:SetActive(false)
		end
	
	elseif (iname == "Force") then
		if(value > 0)then
			self.LForce = value
		--else self.LForce = 100 
		end
	end	
end

function ENT:PhysicsUpdate()	
	if self.Entity:GetActive()==true then
		self.PhysObj:SetVelocity(self.Entity:GetUp() * self.LForce)
		--//print(self.LForce)
	end
end

function ENT:Think()
	
	--self.Entity:SetSpeed(math.Clamp(self.CSpeed,0,1000))

	if self:GetParent():IsValid() then
		--self.Entity:SetLocalPos(Vector(0,0,0))
		--self.Entity:SetLocalAngles(Angle(0,0,0))
	end
	--self.Size = 1
	--self.Length = 1
	self.Entity:SetLength(self.Length)
	self.Entity:SetSize(self.Size)
	
	--self.Entity:NextThink(CurTime() + 0.01)
	
	--return true
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 20
	
	local ent = ents.Create( "VisThrusterMk2" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Use( activator, caller )
	if self.Entity:GetActive() then
		self.Entity:SetActive(false)
	else
		self.Entity:SetActive(true)
	end
end