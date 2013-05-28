AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local DCDT = list.Get( "SBEP_DockingClampModels" )
local DD = list.Get( "SBEP_DoorControllerModels" )

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
	self.Inputs = Wire_CreateInputs( self.Entity, { "Dock", "UndockDelay" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Status" })
	self.Entity:SetNWInt( "DMode", self.DMode )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self.Entity:StartMotionController()
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.Entity:SetNetworkedEntity( "LinkLock", nil )
		
	self.LinkLock = nil
	self.UDD = false
	self.Usable = true
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Dock") then
		if (value > 0) then
			self.DMode = 2		
			self.Entity:EmitSound("Buttons.snd1")
		else
			self.Entity:EmitSound("Buttons.snd19")
			if self.UDD then
				self.DMode = 0
				self.DTime = CurTime() + 2
			else
				self.DMode = 1
				self:Disengage()
			end			
		end
		
	elseif (iname == "UndockDelay") then
		if (value > 0) then
			self.UDD = true
		else
			self.UDD = false
		end
	end
end

function ENT:AddDockDoor()

	local Data = DD[ string.lower( self.Entity:GetModel() ) ]
	if !Data then return end
	
	self.Doors = self.Doors or {}
	for n,Door in ipairs( Data ) do
		local D = ents.Create( "sbep_base_door" )
			D:Spawn()
			D:Initialize()
			local ct = D:SetDoorType( Door.type )
		D:Attach( self.Entity , Door.V , Door.A )
		table.insert( self.Doors , D )
	end
end

function ENT:SetDockType( strType )
	if !strType then return false end
	local DT = DCDT[ string.lower( self.Entity:GetModel() ) ]
	if !DT then return false end

	self.ALType  = strType
	self.Entity:SetName( strType )
	self.CompatibleLocks = DT.Compatible
end

function ENT:Think()
	if self.Doors then
		if self.DMode == 4 then
			for m,n in ipairs( self.Doors ) do
				n.OpenTrigger = true
			end
		else
			for m,n in ipairs( self.Doors ) do
				n.OpenTrigger = false
			end
		end
	end
	
	if self.DMode == 0 then
		if self.DTime > CurTime() then
			self:Disengage()
			self.DMode = 1
		end
	end
	
	if self.DMode == 2 then
	
		--local mn, mx = self.Entity:WorldSpaceAABB()
		--mn = mn - Vector(20, 20, 20)
		--mx = mx + Vector(20, 20, 20)
		--local T = ents.FindInBox(mn, mx)
		local T = ents.FindInSphere( self.Entity:GetPos(), self.ScanDist)
		
		for _,i in pairs( T ) do
			if( i.Entity and i.Entity:IsValid() and i.Entity ~= self.Entity and i.IsAirLock and i.DMode == 2) then
				local RollMatch = false
				local PitchMatch = false
				local YawMatch = false
				local TypeMatch = false
			
				for k,e in pairs( self.CompatibleLocks ) do
					if i.ALType == e.Type then
						TypeMatch = true
						
						self.APitch		= e.APitch or 0
						self.AYaw		= e.AYaw or 0
						self.ARoll		= e.ARoll or 0
						self.AF			= e.AF or 0
						self.AR			= e.AR or 0
						self.AU			= e.AU or 0
						self.MF			= e.MF or 700
						self.MR			= e.MR or 700
						self.MU			= e.MU or 700
						self.MPitch		= e.MPitch or 10
						self.MYaw		= e.MYaw or 10
						self.MRoll		= e.MRoll or 10
						self.MDist		= e.MDist or 35
						self.RPitch		= e.RPitch or 0
						self.RYaw		= e.RYaw or 0
						self.RRoll		= e.RRoll or 0
						
						self.CType = k
						
						break
					end
				end
							
				if self.RRoll > 0 then
					for n = 0, 360, self.RRoll do
						if math.AngleDifference(math.fmod((i.Entity:GetAngles().r + self.ARoll + n), 360),self.Entity:GetAngles().r) <= self.MRoll * 3 and math.AngleDifference(math.fmod((i.Entity:GetAngles().r + self.ARoll + n), 360),self.Entity:GetAngles().r) >= self.MRoll * -3 then
							RollMatch = true
							self.CRoll = n
							break
						end
					end
				else
					if math.AngleDifference(math.fmod((i.Entity:GetAngles().r + self.ARoll), 360),self.Entity:GetAngles().r) <= self.MRoll * 3 and math.AngleDifference(math.fmod((i.Entity:GetAngles().r + self.ARoll), 360),self.Entity:GetAngles().r) >= self.MRoll * -3 then
						RollMatch = true
					end
				end
				
				if self.RPitch > 0 then
					for n = 0, 360, self.RPitch do
						if math.AngleDifference(math.fmod((i.Entity:GetAngles().p + self.APitch + n), 360),self.Entity:GetAngles().p) <= self.MPitch * 3 and math.AngleDifference(math.fmod((i.Entity:GetAngles().p + self.APitch + n), 360),self.Entity:GetAngles().p) >= self.MPitch * -3 then
							PitchMatch = true
							self.CPitch = n
							break
						end
					end
				else
					if math.AngleDifference(math.fmod((i.Entity:GetAngles().p + self.APitch), 360),self.Entity:GetAngles().p) <= self.MPitch * 3 and math.AngleDifference(math.fmod((i.Entity:GetAngles().p + self.APitch), 360),self.Entity:GetAngles().p) >= self.MPitch * -3 then
						PitchMatch = true
					end
				end
				
				if self.RYaw > 0 then
					for n = 0, 360, self.RYaw do
						if math.AngleDifference(math.fmod((i.Entity:GetAngles().y + self.AYaw + n), 360),self.Entity:GetAngles().y) <= self.MYaw * 3 and math.AngleDifference(math.fmod((i.Entity:GetAngles().y + self.AYaw + n), 360),self.Entity:GetAngles().y) >= self.MYaw * -3 then
							YawMatch = true
							self.CYaw = n
							break
						end
					end
				else
					if math.AngleDifference(math.fmod((i.Entity:GetAngles().y + self.AYaw), 360),self.Entity:GetAngles().y) <= self.MYaw * 3 and math.AngleDifference(math.fmod((i.Entity:GetAngles().y + self.AYaw), 360),self.Entity:GetAngles().y) >= self.MYaw * -3 then
						YawMatch = true
					end
				end
								
				if YawMatch and PitchMatch and RollMatch then
					self.LinkLock = i
					i.LinkLock = self.Entity
					self.Entity:SetNetworkedEntity( "LinkLock", self.LinkLock )
					self.LinkLock:SetNetworkedEntity( "LinkLock", self.Entity )
					self.DMode = 3
					i.CPitch = -self.CPitch
					i.CRoll = -self.CRoll
					i.CYaw = -self.CYaw
					i.DMode = 3
					i:TypeSet( self.ALType )
					self.Entity:EmitSound("Building_Teleporter.Send")
					return
				end
			end
		end
	end
	
	if self.DMode == 3 and self.LinkLock and self.LinkLock:IsValid() and self.LinkLock:GetPhysicsObject():IsMoveable() then
		local RollMatch = false
		local PitchMatch = false
		local YawMatch = false
		
		--print("Entity Found")
		if math.AngleDifference(math.fmod((self.LinkLock:GetAngles().r + self.ARoll + self.CRoll), 360),self.Entity:GetAngles().r) <= self.MRoll * 1 and math.AngleDifference(math.fmod((self.LinkLock:GetAngles().r + self.ARoll + self.CRoll), 360),self.Entity:GetAngles().r) >= self.MRoll * -1 then
			--print("Roll Match")
			if math.AngleDifference(math.fmod((self.LinkLock:GetAngles().p + self.APitch + self.CPitch), 360),self.Entity:GetAngles().p) <= self.MPitch * 1 and math.AngleDifference(math.fmod((self.LinkLock:GetAngles().p + self.APitch + self.CPitch), 360),self.Entity:GetAngles().p) >= self.MPitch * -1 then
				--print("Pitch Match")
				if math.AngleDifference(math.fmod((self.LinkLock:GetAngles().y + self.AYaw + self.CYaw), 360),self.Entity:GetAngles().y) <= self.MYaw * 1 and math.AngleDifference(math.fmod((self.LinkLock:GetAngles().y + self.AYaw + self.CYaw), 360),self.Entity:GetAngles().y) >= self.MYaw * -1 then
					--print("Yaw Match")
					if (self.Entity:GetPos() + (self.Entity:GetForward() * self.AF) + (self.Entity:GetRight() * self.AR) + (self.Entity:GetUp() * self.AU)):Distance(self.LinkLock:GetPos() + (self.LinkLock:GetForward() * self.LinkLock.AF) + (self.LinkLock:GetRight() * self.LinkLock.AR) + (self.LinkLock:GetUp() * self.LinkLock.AU)) <= self.MDist then
						self.LinkLock.Entity:SetAngles(self.Entity:LocalToWorldAngles(Angle(math.fmod(self.LinkLock.APitch - self.CPitch, 360),math.fmod(self.LinkLock.AYaw - self.CYaw, 360),math.fmod(self.LinkLock.ARoll - self.CRoll, 360))))
						self.LinkLock.Entity:SetPos( self.Entity:GetPos() + (self.Entity:GetForward() * self.AF) + (self.Entity:GetRight() * self.AR) + (self.Entity:GetUp() * self.AU ) + (self.LinkLock:GetForward() * -self.LinkLock.AF) + (self.LinkLock:GetRight() * -self.LinkLock.AR) + (self.LinkLock:GetUp() * -self.LinkLock.AU) )
						self.AWeld = constraint.Weld(self.LinkLock.Entity, self.Entity, 0, 0, 0, true)
						self.LinkLock.AWeld = self.AWeld
						self.DMode = 4
						self.LinkLock.DMode = 4
						self.Entity:EmitSound("Building_Teleporter.Ready")
					end
				end
			end
		end
	end
	
	if self.DMode == 4 and self.LinkLock and self.LinkLock:IsValid() then
		if !self.AWeld or !self.AWeld:IsValid() then
			if self.LinkLock.AWeld and self.LinkLock.AWeld:IsValid() then
				self.AWeld = self.LinkLock.AWeld
			else
				self.AWeld = constraint.Weld(self.LinkLock.Entity, self.Entity, 0, 0, 0, true)
				self.LinkLock.AWeld = self.AWeld
			end
		end
	end
	
	if self.DMode == 3 then
		if self.LinkLock and self.LinkLock:IsValid() then
			local Physy = self.Entity:GetPhysicsObject()
			
			Physy:Wake()		
			
			local Pos = self.Entity:GetPos()
			local Pos2 = self.LinkLock:GetPos()
			local Vel = Physy:GetVelocity()
			
			local Distance = self.LinkLock:GetPos():Distance(self.Entity:GetPos())
			
			local YawBreak = false
			local RollBreak = false
			local PitchBreak = false
			
			if math.AngleDifference(math.fmod((self.LinkLock:GetAngles().r + self.ARoll + self.CRoll), 360),self.Entity:GetAngles().r) >= self.MRoll * 3 or math.AngleDifference(math.fmod((self.LinkLock:GetAngles().r + self.ARoll + self.CRoll), 360),self.Entity:GetAngles().r) <= self.MRoll * -3 then
				RollBreak = true
			end
			if math.AngleDifference(math.fmod((self.LinkLock:GetAngles().p + self.APitch + self.CPitch), 360),self.Entity:GetAngles().p) >= self.MPitch * 3 or math.AngleDifference(math.fmod((self.LinkLock:GetAngles().p + self.APitch + self.CPitch), 360),self.Entity:GetAngles().p) <= self.MPitch * -3 then
				PitchBreak = true
			end
			if math.AngleDifference(math.fmod((self.LinkLock:GetAngles().y + self.AYaw + self.CYaw), 360),self.Entity:GetAngles().y) >= self.MYaw * 3 or math.AngleDifference(math.fmod((self.LinkLock:GetAngles().y + self.AYaw + self.CYaw), 360),self.Entity:GetAngles().y) <= self.MYaw * -3 then
				YawBreak = true
			end
			
			if Distance > self.ScanDist or YawBreak or RollBreak or PitchBreak then
				self.LinkLock.DMode = 2
				self.LinkLock.LinkLock = nil
				self.LinkLock:SetNetworkedEntity( "LinkLock", nil )
				self.Entity:SetNetworkedEntity( "LinkLock", nil )
				self.LinkLock = nil
				self.DMode = 2
				self.Entity:EmitSound("Building_Teleporter.Receive")
				return
			end
						
			if self.LinkLock.DMode ~= 3 then
				self.Entity:SetNetworkedEntity( "LinkLock", nil )
				self.LinkLock = nil
				self.DMode = 2
				self.Entity:EmitSound("Building_Teleporter.Receive")
				return
			end
			
			TVec = (self.LinkLock:GetPos() + self.LinkLock:GetForward() * self.LinkLock.AF + self.LinkLock:GetRight() * self.LinkLock.AR + self.LinkLock:GetUp() * self.LinkLock.AU ) - (self:GetPos() + self:GetForward() * self.AF + self:GetRight() * self.AR + self:GetUp() * self.AU )
			
			--OVec = Vel * -1
			
			--MVec = OVec + TVec
			
			local Linear = TVec:GetNormal() * math.Clamp(Distance * 10, 0, 100)
			
			
			Physy:SetVelocity( Linear )
			
			local Roll = math.AngleDifference(self.LinkLock:GetAngles().r, math.fmod(self.Entity:GetAngles().r + self.ARoll - self.CRoll,360))
			local Pitch = math.AngleDifference(self.LinkLock:GetAngles().p, math.fmod(self.Entity:GetAngles().p + self.APitch - self.CPitch,360))
			local Yaw = math.AngleDifference(self.LinkLock:GetAngles().y, math.fmod(self.Entity:GetAngles().y + self.AYaw - self.CYaw,360))
			
			Physy:AddAngleVelocity((Physy:GetAngleVelocity() * -1))
			--Physy:AddAngleVelocity((Physy:GetAngleVelocity() * -1) + Angle(Pitch,Yaw,Roll)) --FIXME
		else
			self.Entity:EmitSound("Building_Teleporter.Receive")
			self.DMode = 2
		end
	end
	
	Wire_TriggerOutput( self.Entity, "Status", self.DMode )
	if self.ClDMode ~= self.DMode then
		self.Entity:SetNWInt( "DMode", self.DMode )
		self.ClDMode = self.DMode
		--print("Changing DMode to "..self.DMode)
	end
end

function ENT:PhysicsCollide( data, physobj )

end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Touch( ent )

end

function ENT:OnRemove()

end

function ENT:Use( activator, caller )
	if self.Usable then
		if (self.DMode < 2) then
			self.DMode = 2		
			self.Entity:EmitSound("Buttons.snd1")
		else
			self.Entity:EmitSound("Buttons.snd19")
			if self.UDD then
				self.DMode = 0
				self.DTime = CurTime() + 2		
			else
				self.DMode = 1
				self:Disengage()
			end
		end
	end
end

function ENT:TypeSet( Type )
	for k,e in pairs( self.CompatibleLocks ) do
		if e.Type == Type then
			TypeMatch = true
			
			self.APitch		= e.APitch or 0
			self.AYaw		= e.AYaw or 0
			self.ARoll		= e.ARoll or 0
			self.AF			= e.AF or 0
			self.AR			= e.AR or 0
			self.AU			= e.AU or 0
			self.MF			= e.MF or 700
			self.MR			= e.MR or 700
			self.MU			= e.MU or 700
			self.MPitch		= e.MPitch or 10
			self.MYaw		= e.MYaw or 10
			self.MRoll		= e.MRoll or 10
			self.MDist		= e.MDist or 35
			self.RPitch		= e.RPitch or 0
			self.RYaw		= e.RYaw or 0
			self.RRoll		= e.RRoll or 0
			
			self.CType = k
			
			break
		end
	end
end

function ENT:PreEntityCopy()
	local DI = {}
	
	DI.Type 	= self.ALType
	DI.Usable 	= self.Usable
	
	DI.EfPoints = {}
	for i = 1,10 do
		local Vec = self.Entity:GetNetworkedVector("EfVec"..i)
		if Vec and Vec ~= Vector(0,0,0) then
			DI.EfPoints[i] = {}
			DI.EfPoints[i].x = Vec.x
			DI.EfPoints[i].y = Vec.y
			DI.EfPoints[i].z = Vec.z
			DI.EfPoints[i].sp = self.Entity:GetNetworkedInt("EfSp"..i) or 0
		end
	end
	
	DI.Doors = {}
	if self.Doors then
		for n,D in ipairs( self.Doors ) do
			if D and D:IsValid() then
				DI.Doors[n] = D:EntIndex()
			end
		end
	end

	if self.AWeld and self.AWeld:IsValid() then
		self.AWeld:Remove()
	end
	
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self.Entity )
	end
	
	DI.CompatibleLocks = self.CompatibleLocks
	DI.DMode = self.DMode
	if self.LinkLock and self.LinkLock:IsValid() then
		DI.LinkLock = self.LinkLock:EntIndex()
	end
	
	duplicator.StoreEntityModifier(self, "SBEPDCI", DI)
end
duplicator.RegisterEntityModifier( "SBEPDCI" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)

	local DI = Ent.EntityMods.SBEPDCI
	
	if !DI then return end
	
	self:SetDockType( DI.Type )
	self.Usable = DI.Usable
	
	for k,v in ipairs( DI.EfPoints ) do
		self.Entity:SetNetworkedVector("EfVec"..k, Vector( v.x , v.y , v.z ) )
		self.Entity:SetNetworkedInt("EfSp"..k, v.sp)
	end

	self.Doors = {}
	for n,I in ipairs( DI.Doors ) do
		self.Doors[n] = CreatedEntities[I]
	end
	
	self.AWeld = CreatedEntities[ DI.AWeld ]
	self.CompatibleLocks = DI.CompatibleLocks
	self.DMode = DI.DMode
	if DI.LinkLock then
		self.LinkLock = CreatedEntities[ DI.LinkLock ]
	end
	
	if self.DMode == 4 then
		self.AWeld = constraint.Weld(self.LinkLock.Entity, self.Entity, 0, 0, 0, true)
	end
	
	if DI.WireData then
		WireLib.ApplyDupeInfo( pl, Ent, DI.WireData, function(id) return CreatedEntities[id] end)
	end

end

function ENT:Disengage()
	if self.LinkLock and self.LinkLock:IsValid() then
		if self.LinkLock.DMode == 3 or self.LinkLock.DMode == 4 then
			self.LinkLock.DMode = 1
		end
		self.LinkLock.LinkLock = nil
		self.LinkLock:SetNetworkedEntity( "LinkLock", nil )
		self.Entity:SetNetworkedEntity( "LinkLock", nil )
	end
	self.LinkLock = nil
	if self.AWeld then
		if self.AWeld:IsValid() then
			self.AWeld:Remove()
		end
	end
end