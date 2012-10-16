AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "ambient.steam01" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.damaged = 0
	self.lastfire = 0
	self.delay = 0.5
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Air", "Energy", "Coolant", "Max Air", "Max Energy", "Max Coolant" })
	end
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
end

function ENT:Repair()
	self.Entity:SetColor(255, 255, 255, 255)
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Destruct()
	LS_Destruct( self.Entity, true )
end

function ENT:Use( pl)
	if(CurTime() > self.lastfire + self.delay) then
		local ent = ents.Create( "plasma" )
			ent:SetPos( self.Entity:GetPos() + (self.Entity:GetForward() * -80))
			ent:SetAngles( self.Entity:GetAngles( ) )
			ent:SetOwner( ply )
		ent:Spawn( )
		constraint.NoCollide(self.Entity, ent, 0, 0)
		self.lastfire = CurTime()
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
end

function ENT:Think()
	self.BaseClass.Think(self)
	if not (WireAddon == nil) then 
		self:UpdateWireOutput()
	end
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local air = RD_GetResourceAmount(self, "air")
	local energy = RD_GetResourceAmount(self, "energy")
	local coolant = RD_GetResourceAmount(self, "coolant")
	local maxair = RD_GetNetworkCapacity(self, "air")
	local maxcoolant = RD_GetNetworkCapacity(self, "coolant")
	local maxenergy = RD_GetNetworkCapacity(self, "energy")
	
	Wire_TriggerOutput(self.Entity, "Air", air)
	Wire_TriggerOutput(self.Entity, "Energy", energy)
	Wire_TriggerOutput(self.Entity, "Coolant", coolant)
	Wire_TriggerOutput(self.Entity, "Max Air", maxair)
	Wire_TriggerOutput(self.Entity, "Max Energy", maxenergy)
	Wire_TriggerOutput(self.Entity, "Max Coolant", maxcoolant)
end
