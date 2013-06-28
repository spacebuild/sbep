
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )
util.PrecacheSound( "common/warning.wav" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	self:CreateEnvironment(1, 1, 1, 0, 0, 0, 0, 0)
	self.currentsize = self:BoundingRadius()
	self.maxsize = self:BoundingRadius()
	self.maxO2Level = 100
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Gravity", "Max O2 level" })
		self.Outputs = Wire_CreateOutputs(self, { "On", "Oxygen-Level", "Temperature", "Gravity" })
	else
        self.Inputs = { { Name = "On" }, { Name = "Radius" }, { Name = "Gravity" }, { Name = "Max O2 level" } }
    end
	CAF.GetAddon("Resource Distribution").RegisterNonStorageDevice(self)
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self:EmitSound( "apc_engine_start" )
		self.Active = 1
		self:UpdateSize(self.sbenvironment.size, self.currentsize) --We turn the forcefield that contains the environment on
		if self.environment and not self.environment:IsSpace() then --Fill the environment with air if the surounding environment has o2, replace with CO2
			self.sbenvironment.air.o2 = self.sbenvironment.air.o2 + self.environment:Convert(0, -1, math.Round(self.sbenvironment.air.max/18))
		end
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(1)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self:StopSound( "apc_engine_start" )
		self:EmitSound( "apc_engine_stop" )
		self.Active = 0
		if self.environment then --flush all resources into the environment if we are in one (used for the slownes of the SB updating process, we don't want errors do we?)
			if self.sbenvironment.air.o2 > 0 then
                local left = self:SupplyResource("oxygen", self.sbenvironment.air.o2)
                self.environment:Convert(-1, 0, left)
            end
            if self.sbenvironment.air.co2 > 0 then
                local left = self:SupplyResource("carbon dioxide", self.sbenvironment.air.co2)
                self.environment:Convert(-1, 1, left)
            end
            if self.sbenvironment.air.n > 0 then
                local left = self:SupplyResource("nitrogen", self.sbenvironment.air.n)
                self.environment:Convert(-1, 2, left)
            end
            if self.sbenvironment.air.h > 0 then
                local left = self:SupplyResource("hydrogen", self.sbenvironment.air.h)
                self.environment:Convert(-1, 3, left)
            end
		end
		self.sbenvironment.temperature = 0
        self:UpdateSize(self.sbenvironment.size, 0) --We turn the forcefield that contains the environment off!
        if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
        self:SetOOO(0)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	elseif (iname == "Gravity") then
        local gravity = value
        if value <= 0 then
            gravity = 0
        end
        self.sbenvironment.gravity = gravity
    elseif (iname == "Max O2 level") then
        local level = 100
        level = math.Clamp(math.Round(value), 0, 100)
        self.maxO2Level = level
    end
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
	if ((self.Active == 1) and (math.random(1, 10) <= 3)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self:SetColor(255, 255, 255, 255)
	self.damaged = 0
end

function ENT:Destruct()
    CAF.GetAddon("Spacebuild").RemoveEnvironment(self)
    CAF.GetAddon("Life Support").LS_Destruct(self, true)
end

function ENT:OnRemove()
    CAF.GetAddon("Spacebuild").RemoveEnvironment(self)
    self.BaseClass.OnRemove(self)
    self:StopSound("apc_engine_start")
end

--[[
function ENT:CreateEnvironment(gravity, atmosphere, pressure, temperature, o2, co2, n, h)
	--Msg("CreateEnvironment: "..tostring(gravity).."\n")
	--set Gravity if one is given
	if gravity and type(gravity) == "number" then
		if gravity < 0 then
			gravity = 0
		end
		self.sbenvironment.gravity = gravity
	end
	--set atmosphere if given
	if atmosphere and type(atmosphere) == "number" then
		if atmosphere < 0 then
			atmosphere = 0
		elseif atmosphere > 1 then
			atmosphere = 1
		end
		self.sbenvironment.atmosphere = atmosphere
	end
	--set pressure if given
	if pressure and type(pressure) == "number" and pressure >= 0 then
		self.sbenvironment.pressure = pressure
	else 
		self.sbenvironment.pressure = math.Round(self.sbenvironment.atmosphere * self.sbenvironment.gravity)
	end
	--set temperature if given
	if temperature and type(temperature) == "number" then
		self.sbenvironment.temperature = temperature
	end
	--set o2 if given
	if o2 and type(o2) == "number" and o2 > 0 then
		
		if o2 > 100 then o2 = 100 end
		self.sbenvironment.air.o2per = o2
		self.sbenvironment.air.o2 = math.Round(o2 * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	else 
		o2 = 0
		self.sbenvironment.air.o2per = 0
		self.sbenvironment.air.o2 = 0
	end
	--set co2 if given
	if co2 and type(co2) == "number" and co2 > 0 then
		
		if (100 - o2) < co2 then co2 = 100-o2 end
		self.sbenvironment.air.co2per = co2
		self.sbenvironment.air.co2 = 0
	else 
		co2 = 0
		self.sbenvironment.air.co2per = 0
		self.sbenvironment.air.co2 = 0
	end
	--set n if given
	if n and type(n) == "number" and n > 0 then
		
		if ((100 - o2)-co2) < n then n = (100-o2)-co2 end
		self.sbenvironment.air.nper = n
		self.sbenvironment.air.n = 0
	else 
		n = 0
		self.sbenvironment.air.n = 0
		self.sbenvironment.air.n = 0
	end
	--set h if given
	if h and type(h) == "number" then
		
		if (((100 - o2)-co2)-n) < h then h = ((100-o2)-co2)-n end
		self.sbenvironment.air.hper = h
		self.sbenvironment.air.h = math.Round(h * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	else 
		h = 0
		self.sbenvironment.air.h = 0
		self.sbenvironment.air.h = 0
	end
	if o2 + co2 + n + h < 100 then
		local tmp = 100 - (o2 + co2 + n + h)
		self.sbenvironment.air.empty = math.Round(tmp * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
		self.sbenvironment.air.emptyper = tmp
	elseif o2 + co2 + n + h > 100 then
		local tmp = (o2 + co2 + n + h) - 100
		if co2 > tmp then
			self.sbenvironment.air.co2 = math.Round((co2 - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.co2per = co2 + tmp
		elseif n > tmp then
			self.sbenvironment.air.n = math.Round((n - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.nper = n + tmp
		elseif h > tmp then
			self.sbenvironment.air.h = math.Round((h - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.hper = h + tmp
		elseif o2 > tmp then
			self.sbenvironment.air.o2 = math.Round((o2 - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.o2per = o2 - tmp
		end
	end
	self.sbenvironment.air.max = math.Round(100 * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	self:PrintVars()
end
-- ]]

--[[
function ENT:UpdateSize(oldsize, newsize)
	if oldsize == newsize then return end
	if oldsize and newsize and type(oldsize) == "number" and type(newsize) == "number" and oldsize >= 0 and newsize >= 0 then
		if oldsize == 0 then
			self.sbenvironment.air.o2 = 0
			self.sbenvironment.air.co2 = 0
			self.sbenvironment.air.n = 0
			self.sbenvironment.air.h = 0
			self.sbenvironment.air.empty = 0
			self.sbenvironment.size = newsize
		elseif newsize == 0 then
			local tomuch = self.sbenvironment.air.o2
			if self.environment then
				tomuch = self.environment:Convert(-1, 0, tomuch)
			end
			tomuch = self.sbenvironment.air.co2
			if self.environment then
				tomuch = self.environment:Convert(-1, 1, tomuch)
			end
			tomuch = self.sbenvironment.air.n
			if self.environment then
				tomuch = self.environment:Convert(-1, 2, tomuch)
			end
			tomuch = self.sbenvironment.air.h
			if self.environment then
				tomuch = self.environment:Convert(-1, 3, tomuch)
			end
			self.sbenvironment.air.o2 = 0
			self.sbenvironment.air.co2 = 0
			self.sbenvironment.air.n = 0
			self.sbenvironment.air.h = 0
			self.sbenvironment.air.empty = 0
			self.sbenvironment.size = 0
		else
			self.sbenvironment.air.o2 = (newsize/oldsize) * self.sbenvironment.air.o2
			self.sbenvironment.air.co2 = (newsize/oldsize) * self.sbenvironment.air.co2
			self.sbenvironment.air.n = (newsize/oldsize) * self.sbenvironment.air.n
			self.sbenvironment.air.h = (newsize/oldsize) * self.sbenvironment.air.h
			self.sbenvironment.air.empty = (newsize/oldsize) * self.sbenvironment.air.empty
			self.sbenvironment.size = newsize
		end
		self.sbenvironment.air.max = math.Round(100 * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
		if self.sbenvironment.air.o2 > self.sbenvironment.air.max then
			local tomuch = self.sbenvironment.air.o2 - self.sbenvironment.air.max
			if self.environment then
				tomuch = self.environment:Convert(-1, 0, tomuch)
				self.sbenvironment.air.o2 = self.sbenvironment.air.max + tomuch
			end
		end
		if self.sbenvironment.air.co2 > self.sbenvironment.air.max then
			local tomuch = self.sbenvironment.air.co2 - self.sbenvironment.air.max
			if self.environment then
				tomuch = self.environment:Convert(-1, 1, tomuch)
				self.sbenvironment.air.co2 = self.sbenvironment.air.max + tomuch
			end
		end
		if self.sbenvironment.air.n > self.sbenvironment.air.max then
			local tomuch = self.sbenvironment.air.n - self.sbenvironment.air.max
			if self.environment then
				tomuch = self.environment:Convert(-1, 2, tomuch)
				self.sbenvironment.air.n = self.sbenvironment.air.max + tomuch
			end
		end
		if self.sbenvironment.air.h > self.sbenvironment.air.max then
			local tomuch = self.sbenvironment.air.h - self.sbenvironment.air.max
			if self.environment then
				tomuch = self.environment:Convert(-1, 3, tomuch)
				self.sbenvironment.air.h = self.sbenvironment.air.max + tomuch
			end
		end
	end
end

--]]

function ENT:Climate_Control()
	local temperature = 0
	local pressure = 0
	if self.environment then
		temperature = self.environment:GetTemperature(self)
		pressure = self.environment:GetPressure()
		--Msg("Found environment, updating\n")
	end
	--Msg("Temperature: "..tostring(temperature)..", pressure: " ..tostring(pressure).."\n")
	if self.Active == 1 then --Only do something if the device is on
		self.energy = self:GetResourceAmount("energy")
		if self.energy == 0 or self.energy <  3 * math.ceil(self.maxsize/1024) then --Don't have enough power to keep the controler\'s think process running, shut it all down
			self:TurnOff()
			return
			--Msg("Turning of\n")
		else
			self.air = self:GetResourceAmount("oxygen")
			self.coolant = self:GetResourceAmount("water")
			self.coolant2 = self:GetResourceAmount("nitrogen")
			self.energy = self:GetResourceAmount("energy")
			--First let check our air supply and try to stabilize it if we got oxygen left in storage at a rate of 10 oxygen per second
			if self.sbenvironment.air.o2 < self.sbenvironment.air.max * (self.maxO2Level/100) then
				--We need some energy to fire the pump!
				local energyneeded =  5 * math.ceil(self.maxsize/1024)
				local mul = 1
				if self.energy < energyneeded then
					mul = self.energy/energyneeded
					self:ConsumeResource("energy", self.energy)
				else
					self:ConsumeResource("energy", energyneeded)
				end
				local air = math.ceil(1500 * mul)
				if self.air < air then air = self.air end
				if self.sbenvironment.air.co2 > 0 then
					local actual = self:Convert(1, 0, air)
					self:ConsumeResource("oxygen", actual)
					self:SupplyResource("carbon dioxide", actual)
				elseif self.sbenvironment.air.n > 0 then
					local actual = self:Convert(2, 0, air)
					self:ConsumeResource("oxygen", actual)
					self:SupplyResource("nitrogen", actual)
				elseif self.sbenvironment.air.h > 0 then
					local actual = self:Convert(3, 0, air)
					self:ConsumeResource("oxygen", actual)
					self:SupplyResource("hydrogen", actual)
				else	
					self:ConsumeResource("oxygen", air)
					self.sbenvironment.air.o2 = self.sbenvironment.air.o2 + air
				end
			elseif self.sbenvironment.air.o2 > self.sbenvironment.air.max then
				local tmp = self.sbenvironment.air.o2 - self.sbenvironment.air.max
				self:SupplyResource("oxygen", tmp)
			end
			--Now let's check the pressure, if pressure is larger then 1 then we need some more power to keep the climate_controls environment stable. We don\' want any leaks do we?
			if pressure > 1 then
				self:ConsumeResource("energy", (pressure-1) *  2 * math.ceil(self.maxsize/1024))
			end
			if temperature < self.sbenvironment.temperature then
				local dif = self.sbenvironment.temperature - temperature
				dif = math.ceil(dif/100) --Change temperature depending on the outside temperature, 5° difference does a lot less then 10000° difference
				self.sbenvironment.temperature = self.sbenvironment.temperature - dif
			elseif temperature > self.sbenvironment.temperature then
				local dif = temperature - self.sbenvironment.temperature
				dif = math.ceil(dif / 100)
				self.sbenvironment.temperature = self.sbenvironment.temperature + dif
			end
			--Msg("Temperature: "..tostring(self.sbenvironment.temperature).."\n")
			if self.sbenvironment.temperature < 288 then
				--Msg("Heating up?\n")
				if self.sbenvironment.temperature + 60 <= 303 then
					self:ConsumeResource("energy",  24 * math.ceil(self.maxsize/1024))
					self.energy = self:GetResourceAmount("energy")
					if self.energy >  60 * math.ceil(self.maxsize/1024) then
						--Msg("Enough energy\n")
						self.sbenvironment.temperature = self.sbenvironment.temperature + 60
						self:ConsumeResource("energy",  60 * math.ceil(self.maxsize/1024))
					else
						--Msg("not Enough energy\n")
						self.sbenvironment.temperature = self.sbenvironment.temperature + math.ceil((self.energy/ 60 * math.ceil(self.maxsize/1024))*60)
						self:ConsumeResource("energy", self.energy)
					end
				elseif self.sbenvironment.temperature + 30 <= 303 then
					self:ConsumeResource("energy",  12 * math.ceil(self.maxsize/1024))
					self.energy = self:GetResourceAmount("energy")
					if self.energy >  30 * math.ceil(self.maxsize/1024) then
						--Msg("Enough energy\n")
						self.sbenvironment.temperature = self.sbenvironment.temperature + 30
						self:ConsumeResource("energy",  30 * math.ceil(self.maxsize/1024))
					else
						--Msg("not Enough energy\n")
						self.sbenvironment.temperature = self.sbenvironment.temperature + math.ceil((self.energy/ 30 * math.ceil(self.maxsize/1024))*30)
						self:ConsumeResource("energy", self.energy)
					end
				elseif self.sbenvironment.temperature + 15 <= 303 then
					self:ConsumeResource("energy",  6 * math.ceil(self.maxsize/1024))
					self.energy = self:GetResourceAmount("energy")
					if self.energy >  15 * math.ceil(self.maxsize/1024) then
						--Msg("Enough energy\n")
						self.sbenvironment.temperature = self.sbenvironment.temperature + 15
						self:ConsumeResource("energy",  15 * math.ceil(self.maxsize/1024))
					else
						--Msg("not Enough energy\n")
						self.sbenvironment.temperature = self.sbenvironment.temperature + math.ceil((self.energy/ 15 * math.ceil(self.maxsize/1024))*15)
						self:ConsumeResource("energy", self.energy)
					end
				else
					self:ConsumeResource("energy",  2 * math.ceil(self.maxsize/1024))
					self.energy = self:GetResourceAmount("energy")
					if self.energy >  5 * math.ceil(self.maxsize/1024) then
						--Msg("Enough energy\n")
						self.sbenvironment.temperature = self.sbenvironment.temperature + 5
						self:ConsumeResource("energy",  5 * math.ceil(self.maxsize/1024))
					else
						--Msg("not Enough energy\n")
						self.sbenvironment.temperature = self.sbenvironment.temperature + math.ceil((self.energy/ 5 * math.ceil(self.maxsize/1024))*5)
						self:ConsumeResource("energy", self.energy)
					end
				end
			elseif self.sbenvironment.temperature > 303 then
				if self.sbenvironment.temperature - 60 >= 288 then
					self:ConsumeResource("energy",  24 * math.ceil(self.maxsize/1024))
					if self.coolant2 >  12 * math.ceil(self.maxsize/1024) then
						self.sbenvironment.temperature = self.sbenvironment.temperature - 60
						self:ConsumeResource("nitrogen",  12 * math.ceil(self.maxsize/1024))
					elseif self.coolant >  60 * math.ceil(self.maxsize/1024) then
						self.sbenvironment.temperature = self.sbenvironment.temperature - 60
						self:ConsumeResource("water",  60 * math.ceil(self.maxsize/1024))
					else
						if self.coolant2 > 0 then
							self.sbenvironment.temperature = self.sbenvironment.temperature - math.ceil((self.coolant2/ 12 * math.ceil(self.maxsize/1024))*60)
							self:ConsumeResource("nitrogen", self.coolant2)
						elseif self.coolant > 0 then
							self.sbenvironment.temperature = self.sbenvironment.temperature - math.ceil((self.coolant/ 60 * math.ceil(self.maxsize/1024))*60)
							self:ConsumeResource("water", self.coolant)
						end
					end
				elseif self.sbenvironment.temperature - 30 >= 288 then
					self:ConsumeResource("energy",  12 * math.ceil(self.maxsize/1024))
					if self.coolant2 >  6 * math.ceil(self.maxsize/1024) then
						self.sbenvironment.temperature = self.sbenvironment.temperature - 30
						self:ConsumeResource("nitrogen",  6 * math.ceil(self.maxsize/1024))
					elseif self.coolant >  30 * math.ceil(self.maxsize/1024) then
						self.sbenvironment.temperature = self.sbenvironment.temperature - 30
						self:ConsumeResource("water",  30 * math.ceil(self.maxsize/1024))
					else
						if self.coolant2 > 0 then
							self.sbenvironment.temperature = self.sbenvironment.temperature - math.ceil((self.coolant2/ 6 * math.ceil(self.maxsize/1024))*30)
							self:ConsumeResource("nitrogen", self.coolant2)
						elseif self.coolant > 0 then
							self.sbenvironment.temperature = self.sbenvironment.temperature - math.ceil((self.coolant/ 30 * math.ceil(self.maxsize/1024))*30)
							self:ConsumeResource("water", self.coolant)
						end
					end
				elseif self.sbenvironment.temperature - 15 >= 288 then
					self:ConsumeResource("energy",  6 * math.ceil(self.maxsize/1024))
					if self.coolant2 >  3 * math.ceil(self.maxsize/1024) then
						self.sbenvironment.temperature = self.sbenvironment.temperature - 15
						self:ConsumeResource("nitrogen",  3 * math.ceil(self.maxsize/1024))
					elseif self.coolant >  15 * math.ceil(self.maxsize/1024) then
						self.sbenvironment.temperature = self.sbenvironment.temperature - 15
						self:ConsumeResource("water",  15 * math.ceil(self.maxsize/1024))
					else
						if self.coolant2 > 0 then
							self.sbenvironment.temperature = self.sbenvironment.temperature - math.ceil((self.coolant2/ 3 * math.ceil(self.maxsize/1024))*15)
							self:ConsumeResource("nitrogen", self.coolant2)
						elseif self.coolant > 0 then
							self.sbenvironment.temperature = self.sbenvironment.temperature - math.ceil((self.coolant/ 15 * math.ceil(self.maxsize/1024))*15)
							self:ConsumeResource("water", self.coolant)
						end
					end
				else
					self:ConsumeResource("energy",  2 * math.ceil(self.maxsize/1024))
					if self.coolant2 >  1 * math.ceil(self.maxsize/1024) then
						self.sbenvironment.temperature = self.sbenvironment.temperature - 5
						self:ConsumeResource("nitrogen",  1 * math.ceil(self.maxsize/1024))
					elseif self.coolant >  5 * math.ceil(self.maxsize/1024) then
						self.sbenvironment.temperature = self.sbenvironment.temperature - 5
						self:ConsumeResource("water",  5 * math.ceil(self.maxsize/1024))
					else
						if self.coolant2 > 0 then
							self.sbenvironment.temperature = self.sbenvironment.temperature - math.ceil((self.coolant2/ 1 * math.ceil(self.maxsize/1024))*5)
							self:ConsumeResource("nitrogen", self.coolant2)
						elseif self.coolant > 0 then
							self.sbenvironment.temperature = self.sbenvironment.temperature - math.ceil((self.coolant/ 5 * math.ceil(self.maxsize/1024))*5)
							self:ConsumeResource("water", self.coolant)
						end
					end
				end
			end
		end
	end
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self, "Oxygen-Level", tonumber(self:GetO2Percentage()))
		Wire_TriggerOutput(self, "Temperature", tonumber(self.sbenvironment.temperature))
		Wire_TriggerOutput(self, "Gravity", tonumber(self.sbenvironment.gravity))
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:Climate_Control()
	self:NextThink(CurTime() + 1)
	return true
end

--[[
function ENT:OnEnvironment(ent)
	if not ent then return end
	if ent == self then return end
	local pos = ent:GetPos()
	local dist = pos:Distance(self:GetPos())
	if dist < self:GetSize() then
		local min, max = ent:WorldSpaceAABB()
		if table.HasValue(ents.FindInBox( min, max ), ent) then
			if not ent.environment then
				ent.environment = self
				--self:UpdateGravity(ent)
			else
				if ent.environment:GetPriority() < self:GetPriority() then
					ent.environment = self
					--self:UpdateGravity(ent)
				elseif ent.environment:GetPriority() == self:GetPriority() then
					if ent.environment:GetSize() != 0 then
						if self:GetSize() <= ent.environment:GetSize() then
							ent.environment = self
							--self:UpdateGravity(ent)
						else
							if dist < pos:Distance(ent.environment:GetPos()) then
								ent.environment = self
							end
						end
					else
						ent.environment = self
						--self:UpdateGravity(ent)
					end
				end
			end
		end
	end			
end
]]


