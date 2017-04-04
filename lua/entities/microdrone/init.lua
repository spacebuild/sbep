
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
util.PrecacheSound( "SB/Charging.wav" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Spacebuild/Nova/dronebase.mdl" ) 
	self.Entity:SetName("ShipAI")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
	self.Entity:SetCollisionGroup(3)
	--local V,N,A = "VECTOR","NORMAL","ANGLE"
	--local inNames = {"MoveVector", "TargetVector", "Angle", "Stance", "TargetsFound", "Size", "AlternateTargetVector1", "AlternateTargetVector2", "AlternateTargetVector3", "AlternateTargetVector4", "AlternateTargetVector5"}
	--local inTypes = {V,V,A,N,N,N,V,V,V,V,V}
	--self.Inputs = WireLib.CreateSpecialInputs( self.Entity,inNames,inTypes)
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Pitch", "Yaw", "Roll", "Forward", "Lateral", "Vertical", "WaypointReached", "Stance" })
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 10 )
	end
	
	self.Entity:StartMotionController()
	
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	self.Stance = 3
	self.AVec = Vector(0,0,0)
	self.MVec = Vector(0,0,0)
	self.TVec = Vector(0,0,0)
	self.Alternates = {Vector(0,0,0),Vector(0,0,0),Vector(0,0,0),Vector(0,0,0),Vector(0,0,0)}
	self.MAngle = Angle(0,0,0)
	self.Weaponry = {}
	self.TSClamp = 100
	self.TSpeed = 0.05
	self.SpeedClamp = 500
	self.Reversible = false
	self.Targets = 0
	self.WPRad = 80
	self.Entity:SetNetworkedInt("Size", 50)
	self.Fade = false
	self.Speed = 100
	
	self.SquadNumber = 1
	
	self.PArc = 10
	self.YArc = 10
	self.Range = 5100
	
	self.IsShipController = true
	self.IsDrone = true
	
	self.WaypointReached = 0
	
	self.Forward = 0
	
	self.TFound = false
	
	self.Pitch = 0
	self.Roll = 0
	self.Yaw = 0
	
	self.NextScan = 0
		
	self.Cont 			= self.Entity
	self.HasHardpoints 	= true
	self.HPC			= 2
	self.HP				= {}
	self.HP[1]			= {}
	self.HP[1]["Ent"]	= nil
	self.HP[1]["Type"]	= { "Tiny", "Small" }
	self.HP[1]["Pos"]	= Vector(0,17,16)
	self.HP[1]["Angle"] = Angle(0,0,180)
	self.HP[2]			= {}
	self.HP[2]["Ent"]	= nil
	self.HP[2]["Type"]	= { "Tiny", "Small" }
	self.HP[2]["Pos"]	= Vector(0,-17,16)
	self.HP[2]["Angle"] = Angle(0,0,180)
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "MicroDrone" )
	ent:SetPos( SpawnPos )
	ent:Initialize()
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)
	
	if (iname == "MoveVector") then
		self.MVec = value
		
	elseif (iname == "TargetVector") then
		self.TVec = value
		
	elseif (iname == "Angle") then
		self.MAngle = value
		if value ~= Angle(0,0,0) then
			self.Angling = true
		else
			self.Angling = true
		end
		
	elseif (iname == "Stance") then
		self.Stance = value
		
	elseif (iname == "Size") then
		self.WPRad = math.abs(value)
		self.Entity:SetNetworkedInt("Size", self.WPRad)
		
	elseif (iname == "TargetsFound") then
		if value > 0 then
			self.TFound = true
		else
			self.TFound = false
		end
		self.Targets = value
	
	elseif (iname == "AlternateTargetVector1") then
		self.Alternates[1] = value
		
	elseif (iname == "AlternateTargetVector2") then
		self.Alternates[2] = value
	
	elseif (iname == "AlternateTargetVector3") then
		self.Alternates[3] = value
		
	elseif (iname == "AlternateTargetVector4") then
		self.Alternates[4] = value
		
	elseif (iname == "AlternateTargetVector5") then
		self.Alternates[5] = value
		
	end
end

function ENT:Think()

	self.WaypointReached = 0
	
	self.Forward = 0
	
	self.Pitch = 0
	self.Roll = 0
	self.Yaw = 0
	
	self.Lat = 0
	self.Vert = 0
------------------------------------------------------------------------------------------------------------------------------------------------------------
---																Script for finding crap to shoot at														 ---
------------------------------------------------------------------------------------------------------------------------------------------------------------
	--print(self.Squad,self.Squad:IsValid())
	if !self.Squad or !self.Squad:IsValid() then
		--print("Making a new squad")
		self.Squad = self:MakeSquad()
		--print("Our squad is now "..tostring(self.Squad))
	end
	if self.Squad.Alpha == self then --If this drone is the alpha for its squad
		if CurTime() > self.NextScan then
			--print("Scanning...")
			self.Targets = {}
			local ScanResult = ents.FindInSphere(self:GetPos(), 5000)
			for k,e in pairs( ScanResult ) do
				if e ~= self then
					if e.IsDrone and e.Squad ~= self.Squad then
						--print("It's a drone!")
						if e.Squad and e.Squad:IsValid() then
							--print("They're in a squad")
							local OurDroneCount = table.Count(self.Squad.Members)
							local TheirCount = table.Count(e.Squad.Members)
							if OurDroneCount >= TheirCount and OurDroneCount + TheirCount <= self.Squad.MaxSize then
								--print("Our squad is bigger than theirs. They're joining us.")
								for k2,e2 in pairs(e.Squad.Members) do
									--print(e2, e2:IsValid())
									if e2 and e2:IsValid() then
										if e2.Squad and e2.Squad:IsValid() then e2.Squad:Remove() end
										e2.Squad = self.Squad
										--print(self.Squad, e2.Squad)
										table.insert(self.Squad.Members,e2)
										e2.SquadNumber = table.Count(self.Squad.Members)
										--PrintTable(self.Squad.Members)
									end
								end
							end
						else
							--print("They have no squad. They're joining us.")
							local OurDroneCount = table.Count(self.Squad.Members)
							if OurDroneCount < self.Squad.MaxSize then
								e.Squad = self.Squad
								table.insert(self.Squad.Members,e)
								e.SquadNumber = table.Count(self.Squad.Members)
							end
						end
					end
					if self:TargetCriteria(e) then
						table.insert(self.Targets,e)
					end
				end
			end
			self.NextScan = CurTime() + 1
		end
		
		self.Targets = self.Targets or {}
		--PrintTable(self.Targets)
		local TCount = table.Count(self.Targets)
		if TCount > 0 then
			self.TFound = true
			self.TargetCount = math.Clamp(TCount,1,6)
			for k,e in pairs(self.Targets) do
				if k > 1 then 
					if k <= 6 then
						if e and e:IsValid() then
							self.Alternates[k-1] = e:GetPos()
						else
							table.remove(self.Targets,k)
						end
					end
				else
					if e and e:IsValid() then
						self.TVec = e:GetPos()
					else
						table.remove(self.Targets,k)
					end
				end
			end
		else
			self.TFound = false
		end
		
		if self.Squad.ObjectiveType == 1 then
			if self.Squad.MVec and self.Squad.MVec ~= Vector(0,0,0) then
				self.MVec = self.Squad.MVec
				self.MAngle.y = self:GetAngles().y
				self.MAngle.p = 0
				self.MAngle.r = 0
			end
		end
	else
		if self.Squad.Alpha and self.Squad.Alpha:IsValid() then
			self.Targets = self.Squad.Alpha.Targets or {}
			local TCount = table.Count(self.Targets)
			if TCount > 0 then
				self.TFound = true
				self.TargetCount = math.Clamp(TCount,1,6)
				local Assault = math.fmod(self.SquadNumber - 1, self.TargetCount) + 1
				for k,e in pairs(self.Targets) do --We have to iterate through the table to avoid a crash. Currently, referencing an entry in a table that isn't valid by its key causes a crash. This way is relatively safe.
					if k ~= Assault then
						if k <= 6 then
							if e and e:IsValid() then
								self.Alternates[k-1] = e:GetPos()
							else
								table.remove(self.Targets,k)
							end
						end
					else
						if e and e:IsValid() then
							self.TVec = e:GetPos()
						else
							table.remove(self.Targets,k)
						end
					end
				end
			else
				self.TFound = false
			end
			
			--local FormPos = self.SquadNumber
			local FDist = math.floor(self.SquadNumber * 0.5)
			local Side = math.fmod(self.SquadNumber,2)
			if Side < 1 then
				Side = -1
			end
			self.MVec = self.Squad.Alpha:GetPos() + (self.Squad.Alpha:GetForward() * FDist * self.WPRad * -0.5) + (self.Squad.Alpha:GetRight() * FDist * self.WPRad * 1.5 * Side)
			self.Angling = true
			self.MAngle = self.Squad.Alpha:GetAngles()
		else -- If the alpha is dead, we step in as the new alpha
			--print("The king is dead. Long live the king.")
			self.Squad.Alpha = self
			self:AttachSquad(self.Squad)
		end
	end
	
------------------------------------------------------------------------------------------------------------------------------------------------------------
---																Script for finding the next direction											 		 ---
------------------------------------------------------------------------------------------------------------------------------------------------------------
	if self.Stance > 0 then --Dear god, this is a mess... I must remember to organize this function better.
		if (self.Stance < 3) or (self.Stance == 3 and !self.TFound) then
			if self.MVec ~= Vector(0,0,0) then
				local MDist = self.Entity:GetPos():Distance(self.MVec)
				if MDist < self.WPRad then
					self.WaypointReached = 1
					if self.Angling then--self.MAngle ~= Angle(0,0,0) then
						self.Pitch = math.AngleDifference(self.Entity:GetAngles().p,self.MAngle.p) * -0.01
						self.Roll = math.AngleDifference(self.Entity:GetAngles().r,self.MAngle.r) * -0.01
						self.Yaw = math.AngleDifference(self.Entity:GetAngles().y,self.MAngle.y) * -0.01
					end
					if MDist > self.WPRad * 0.001 then
						self.Entity:StrafeFinder( self.MVec, self.Entity:GetPos(), self.Entity:GetUp(), self.Entity:GetRight(), self.Entity:GetForward() )
					else
						self.MVec = Vector(0,0,0)
					end
				else
					self.Entity:Orient( self.MVec, self.Entity:GetPos(), self.Entity:GetUp(), self.Entity:GetRight() )
					
					self.Roll = self.Entity:GetAngles().r * -0.005
					
					self.Entity:SpeedFinder( self.MVec, self.Entity:GetPos(), self.Entity:GetForward() )
				end
			end
		elseif self.Stance == 3 and self.TFound then
			local MDist = self.Entity:GetPos():Distance(self.TVec)
			if MDist > 500 then
				self.Entity:Orient( self.TVec, self.Entity:GetPos(), self.Entity:GetUp(), self.Entity:GetRight() )
				self.Entity:SpeedFinder( self.TVec, self.Entity:GetPos(), self.Entity:GetForward() )
			else
				local HighP = 0
				local MainG = 0
				for k,e in pairs( self.Weaponry ) do
					if e and e:IsValid() and e.Priority > 0 and e.Priority > HighP then
						HighP = e.Priority
						MainG = k
					end
				end
				if MainG > 0 then
					self.Entity:Orient( self.TVec, self.Weaponry[MainG]:GetPos(), self.Weaponry[MainG]:GetUp(), self.Weaponry[MainG]:GetRight() )
				else
					self.Entity:Orient( self.TVec, self.Entity:GetPos(), self.Entity:GetUp(), self.Entity:GetRight() )
					
					self.Roll = self.Entity:GetAngles().r * -0.001
					if MDist > 1000 then
						self.Entity:SpeedFinder( self.TVec, self.Entity:GetPos(), self.Entity:GetForward() )
					end
				end
			end
		end
	end
------------------------------------------------------------------------------------------------------------------------------------------------------------
---																		Script for guns and aiming														 ---
------------------------------------------------------------------------------------------------------------------------------------------------------------
	for i = 1, self.HPC do
		if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() then
			local Weap = self.HP[i]["Ent"]
			Weap:GetPhysicsObject():SetMass(1)
		end
	end
	if self.TFound then
		for i = 1, self.HPC do
			--print("HPC "..i)
			--print(self.HP[i]["Ent"]:IsValid())
			if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() then
				--print("Weapon "..i)
				local Weap = self.HP[i]["Ent"]
				Weap:GetPhysicsObject():SetMass(1)
				local RAng = (self.TVec - self.Entity:GetPos()):Angle()
				local SAng = self:LocalToWorldAngles(self.HP[i]["Angle"])
				--print(self:GetAngles(),SAng,RAng)
				--print(math.abs(math.AngleDifference(SAng.p,RAng.p)) < self.PArc)
				--print(math.abs(math.AngleDifference(SAng.y,RAng.y)) < self.YArc)
				--print(self.Entity:GetPos():Distance(self.TVec) < self.Range)
				if math.abs(math.AngleDifference(SAng.p,RAng.p)) < self.PArc and math.abs(math.AngleDifference(SAng.y,RAng.y)) < self.YArc and self.Entity:GetPos():Distance(self.TVec) < self.Range then
					local Dir = (self.TVec - (self.Entity:GetPos() + (self.Entity:GetUp() * self.HP[i]["Pos"].z) + (self.Entity:GetForward() * self.HP[i]["Pos"].x) + (self.Entity:GetRight() * -self.HP[i]["Pos"].y))):GetNormal()
					local Ang = Dir:Angle()
					local WAng = self.Entity:WorldToLocalAngles(Ang) -- It stands for "Weapon Angle". If I get even one "Wang" joke, I swear there will be bloodshed.
					--print(WAng)
					WAng.r = 0
					if Weap.APAng then
						Weap:SetLocalAngles(Weap.APAng + WAng)
					else
						Weap:SetLocalAngles(WAng)
					end
					--print("Ready to fire"..i)
					if self.Stance > 1 then
						Weap:HPFire()
						--print("Firing..."..i)
					end
					--print("Main Target Available")
				else
					--print("Cheking Alternates")
					local Aiming = false
					for n = 1,5 do
						--print("Alternate "..i)
						RAng = (self.Alternates[n] - self.Entity:GetPos()):Angle()
						if math.abs(math.AngleDifference(SAng.p,RAng.p)) < self.PArc and math.abs(math.AngleDifference(SAng.y,RAng.y)) < self.YArc and self.Entity:GetPos():Distance(self.TVec) < self.Range and self.TargetCount > i then
							--print("Found one")
							local Dir = (self.Alternates[n] - (self.Entity:GetPos() + (self.Entity:GetUp() * self.HP[i]["Pos"].z) + (self.Entity:GetForward() * self.HP[i]["Pos"].x) + (self.Entity:GetRight() * -self.HP[i]["Pos"].y))):GetNormal()
							local Ang = Dir:Angle()
							local WAng = self.Entity:WorldToLocalAngles(Ang)
							WAng.r = 0
							if Weap.APAng then
								Weap:SetLocalAngles(Weap.APAng + WAng)
							else
								Weap:SetLocalAngles(WAng)
							end
							if self.Stance > 1 then
								Weap:HPFire()
							end
							Aiming = true
							break
						end
					end
					
					if !Aiming then
						if Weap.APAng then
							Weap:SetLocalAngles(Weap.APAng)
						else
							Weap:SetLocalAngles(Angle(0,0,0))
						end
					end
				end
			end
		end
	end
------------------------------------------------------------------------------------------------------------------------------------------------------------
---																		Script for movement																 ---
------------------------------------------------------------------------------------------------------------------------------------------------------------

	Wire_TriggerOutput( self.Entity, "WaypointReached", self.WaypointReached )			
	
	Wire_TriggerOutput( self.Entity, "Forward", self.Forward )
	
	Wire_TriggerOutput( self.Entity, "Lateral", self.Lat )
	Wire_TriggerOutput( self.Entity, "Vertical", self.Vert )
	
	local Phys = self.Entity:GetPhysicsObject()
	
	Phys:SetVelocity((self.Entity:GetForward() * self.Forward) + (self.Entity:GetRight() * self.Lat) + (self.Entity:GetUp() * self.Vert))
	
	if self.TFound and self.Stance > 1 and self.Squad.Alpha ~= self then
		local AVDir = Vector(0,0,0)
		for k,e in pairs(self.Squad.Members) do
			--print("Checking members...")
			if e and e:IsValid() and e ~= self then
				--print("They're valid, and they're not us...")
				local Dist = math.abs(self:GetPos().x - e:GetPos().x) + math.abs(self:GetPos().y - e:GetPos().y) + math.abs(self:GetPos().y - e:GetPos().y)
				--print("Distance..."..Dist)
				if Dist < 300 then
					AVDir = AVDir + (self:GetPos() - e:GetPos()):GetNormal()
				end
			end
		end
		Phys:SetVelocity(Phys:GetVelocity() + (AVDir * self.Speed * 2))
	end
	
	local Sp = Phys:GetMass()
	
	Phys:AddAngleVelocity((Phys:GetAngleVelocity() * -0.9))
	
	Phys:ApplyForceOffset(self.Entity:GetUp() * -self.Pitch * Sp,self.Entity:GetForward() * 100)
	Phys:ApplyForceOffset(self.Entity:GetUp() * self.Pitch * Sp,self.Entity:GetForward() * -100)
	Phys:ApplyForceOffset(self.Entity:GetForward() * self.Yaw * Sp,self.Entity:GetRight() * 100)
	Phys:ApplyForceOffset(self.Entity:GetForward() * -self.Yaw * Sp,self.Entity:GetRight() * -100)
	Phys:ApplyForceOffset(self.Entity:GetUp() * -self.Roll * Sp,self.Entity:GetRight() * 100)
	Phys:ApplyForceOffset(self.Entity:GetUp() * self.Roll * Sp,self.Entity:GetRight() * -100)
	
	Wire_TriggerOutput( self.Entity, "Pitch", self.Pitch )
	Wire_TriggerOutput( self.Entity, "Roll", self.Roll )
	Wire_TriggerOutput( self.Entity, "Yaw", self.Yaw )
	
	Wire_TriggerOutput( self.Entity, "Stance", self.Stance )
		
	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )
	
end

function ENT:Touch( ent )
	
end
--I should really merge the next two functions together
function ENT:Orient( Vec, Pos, Up, Right )
	local Angle = self:WorldToLocalAngles((Vec - Pos):Angle())
	self.Yaw = Angle.y * self.TSpeed
	self.Pitch = Angle.p * self.TSpeed
end

function ENT:StrafeFinder( Vec, Pos, Up, Right, Forward )
	self.Lat = math.Clamp(self:GetRight():DotProduct( Vec - Pos ) * 2,-self.SpeedClamp,self.SpeedClamp)
	self.Forward = math.Clamp(self:GetForward():DotProduct( Vec - Pos )* 2,-self.SpeedClamp,self.SpeedClamp)
	self.Vert = math.Clamp(self:GetUp():DotProduct( Vec - Pos )* 2,-self.SpeedClamp,self.SpeedClamp)	
end


function ENT:SpeedFinder( Vec, Pos, Forward )
	self.Forward = math.Clamp(self:GetForward():DotProduct( Vec - Pos ),0,self.SpeedClamp)
end

function ENT:MakeSquad()
	local ent = ents.Create( "SquadMinder" )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	
	ent.Members = { self }
	ent.Alpha = self
	
	self:AttachSquad(ent)
	
	return ent
end

function ENT:AttachSquad(ent)
	
	ent:SetParent()
	constraint.RemoveConstraints( ent, "Weld" )
	ent:SetPos(self:GetPos() + (self:GetForward() * 19) + (self:GetUp() * 20))
	local Ang = self:GetAngles()
	Ang:RotateAroundAxis(self:GetRight(),-90)
	ent:SetAngles(Ang)
	local Weld = constraint.Weld(self,ent)
	ent:SetParent(self)
	
end

function ENT:TargetCriteria(ent)
	if ent:IsNPC() then 
		return true
	end
	if ent:GetClass() == "infestor" then
		return true
	end
	if ent:GetClass() == "sf-spacemine" then
		return true
	end
	--if ent:GetClass() == "microdrone" then
	--	if ent.Squad ~= self.Squad then
	--		return true
	--	end
	--end
	return false
end

function ENT:OnRemove()
	
	if self.Squad and self.Squad:IsValid() then
		if table.Count(self.Squad.Members) > 1 then
			for k,e in pairs(self.Squad.Members) do
				--print("Checking members...")
				if e and e:IsValid() and e ~= self then
					--print("They're valid, and they're not us...")
					e:AttachSquad(self.Squad)
					break
				end
			end
		end
	end
	
end