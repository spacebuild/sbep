AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "ambient.steam01" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.damaged = 0
	self.vent = false
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "Vent" })
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Oxygen", "Energy", "Water", "Max Oxygen", "Max Energy", "Max Water" })
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "Vent") then
		if (value ~= 1) then
			self.vent = false
		else
			self.vent = true
		end
	end
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
		self.Entity:EmitSound( "PhysicsCannister.ThrusterLoop" )
		self.Entity:EmitSound( "ambient.steam01" )
	end
end

function ENT:Repair()
	self.Entity:SetColor(255, 255, 255, 255)
	self.health = self.maxhealth
	self.damaged = 0
	self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
	self.Entity:StopSound( "ambient.steam01" )
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").LS_Destruct( self.Entity, true )
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
	self.Entity:StopSound( "ambient.steam01" )
end

function ENT:Leak()
	local RD = CAF.GetAddon("Resource Distribution")
	local air = RD.GetResourceAmount(self, "oxygen")
	local energy = RD.GetResourceAmount(self, "energy")
	local coolant = RD.GetResourceAmount(self, "water")
	if (air > 0) then
		if (air >= 100) then
			RD.ConsumeResource(self, "oxygen", 100)
		else
			RD.ConsumeResource(self, "oxygen", air)
			self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
		end
	end
	if (energy > 0) then
		local waterlevel = 0
		if CAF then
			waterlevel = self:WaterLevel2()
		else
			waterlevel = self:WaterLevel()
		end
		if (waterlevel == 0) then
			zapme(self.Entity:GetPos(), 1)
			local tmp = ents.FindInSphere(self.Entity:GetPos(), 600)
			for _, ply in ipairs( tmp ) do
				if (ply:IsPlayer() and ply:WaterLevel() > 0) then --??? wont that be zaping any player in any water??? should do a dist check first and have damage based on dist
					zapme(ply:GetPos(), 1)
					ply:TakeDamage((ply:WaterLevel() * energy / 100), 0)
				end
			end
			self.maxenergy = RD.GetUnitCapacity(self, "energy")
			if (energy >= self.maxenergy) then --??? loose all energy on net when damaged and in water??? that sounds crazy to me
				RD.ConsumeResource(self, "energy", self.maxenergy)
			else
				RD.ConsumeResource(self, "energy", energy)
			end
		else
			if (math.random(1, 10) < 2) then
				zapme(self.Entity:GetPos(), 1)
				local dec = math.random(200, 2000)
				if (energy > dec) then
					RD.ConsumeResource(self, "energy", dec)
				else
					RD.ConsumeResource(self, "energy", energy)
				end
			end
		end
	end
	if (coolant > 0) then
		if (coolant >= 100) then
			RD.ConsumeResource(self, "water", 100)
		else
			RD.ConsumeResource(self, "water", coolant)
			self.Entity:StopSound( "ambient.steam01" )
		end
	end
end

function ENT:UpdateMass()
	--[[local RD = CAF.GetAddon("Resource Distribution")
	local mul = 0.5
	local div = math.Round(RD.GetNetworkCapacity(self, "carbon dioxide")/self.MAXRESOURCE)
	local mass = self.mass + ((RD.GetResourceAmount(self, "carbon dioxide") * mul)/div) -- self.mass = default mass + need a good multiplier
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		if phys:GetMass() ~= mass then
			phys:SetMass(mass)
			phys:Wake()
		end
	end]]
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if (self.damaged == 1 or self.vent) then
		self:Leak()
	end
	
	if not (WireAddon == nil) then 
		self:UpdateWireOutput()
	end
	self:UpdateMass()
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local RD = CAF.GetAddon("Resource Distribution")
	local air = RD.GetResourceAmount(self, "oxygen")
	local energy = RD.GetResourceAmount(self, "energy")
	local coolant = RD.GetResourceAmount(self, "water")
	local maxair = RD.GetNetworkCapacity(self, "oxygen")
	local maxcoolant = RD.GetNetworkCapacity(self, "water")
	local maxenergy = RD.GetNetworkCapacity(self, "energy")
	
	Wire_TriggerOutput(self.Entity, "Oxygen", air)
	Wire_TriggerOutput(self.Entity, "Energy", energy)
	Wire_TriggerOutput(self.Entity, "Water", coolant)
	Wire_TriggerOutput(self.Entity, "Max Oxygen", maxair)
	Wire_TriggerOutput(self.Entity, "Max Energy", maxenergy)
	Wire_TriggerOutput(self.Entity, "Max Water", maxcoolant)
end
