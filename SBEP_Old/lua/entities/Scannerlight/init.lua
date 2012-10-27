AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local ZeroVector = Vector(0,0,0)

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/rover1_spotlight.mdl" )
	self.Entity:SetName("Scanner-Light")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType(3)
	--self.Entity:SetMaterial("models/props_combine/combinethumper002")
	self.Inputs = Wire_CreateInputs( self.Entity, { "Active" } )
	local outNames = {"TargetFound","Target","X","Y","Z","Vector"}
	local outTypes = {"NORMAL","ENTITY","NORMAL","NORMAL","NORMAL","VECTOR"}
	local outDescs = {}
	self.Outputs = WireLib.CreateSpecialOutputs( self.Entity,outNames,outTypes,outDescs)
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end
	
    --self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.CAng = self.Entity:GetAngles()
	
	self.Searching = false
	
	self.Cycle = 0
	self.CycleSpeed = 80
	self.CycleP = 10
	self.CycleY = 0
	self.CycleH = 10
	self.CycleW = 90
	
	self.ScanCD = 0
	
	self.LTT = 0
end
function ENT:TriggerInput(iname, value)		
	
	if (iname == "Active") then
		if (value > 0) then
			self.Active = true
			self.dt.Active = true
		else
			self.Active = false
			self.dt.Active = false
		end
		
	end	
end

function ENT:Think()
	local Delta = CurTime() - self.LTT
	-- THE FOLLOWING CODE WAS NICKED FROM THE LS3 LAMP. I TAKE NO CREDIT FOR IT! --
	if self.Active and !self.flashlight then
		--local angForward = self.Entity:GetAngles() + Angle( 90, 0, 0 )
		self.flashlight = ents.Create( "env_projectedtexture" )
		self.flashlight:SetParent( self.Entity )

		-- The local positions are the offsets from parent..
		self.flashlight:SetLocalPos( Vector(8,0,0) )
		self.flashlight:SetLocalAngles( Angle(0,0,0) )

		-- Looks like only one flashlight can have shadows enabled!
		self.flashlight:SetKeyValue( "enableshadows", 1 )
		self.flashlight:SetKeyValue( "farz", 2048 )
		self.flashlight:SetKeyValue( "nearz", 8 )

		--the size of the light
		self.flashlight:SetKeyValue( "lightfov", 70 )

		-- Color.. white is default
		self.flashlight:SetKeyValue( "lightcolor", "255 255 255" )
		self.flashlight:Spawn()
		self.flashlight:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )
	elseif !self.Active and self.flashlight then
		SafeRemoveEntity( self.flashlight )
		self.flashlight = nil
	end
	-- END OF CODE THEFT --
	
	
	
	
	if self.Active then
		if CurTime() >= self.ScanCD then
			if !self.Target or !self.Target:IsValid() then
				local T = ents.FindInCrappyCone(self:GetPos(),Vector(2000,.8,.8),self:GetAngles())
				for k,e in pairs(T) do
					--e:SetColor(math.Rand(0,255),math.Rand(0,255),math.Rand(0,255),255)
					if (e:IsPlayer() and e:Team() ~= self.SPL:Team()) or e:IsNPC() or e.IsInfestor then
						self.Target = e
						local Pos = self.Target:GetPos()
						Wire_TriggerOutput(self.Entity, "TargetFound", 1)
						Wire_TriggerOutput(self.Entity, "Target", self.Target)
						Wire_TriggerOutput(self.Entity, "X", Pos.x)
						Wire_TriggerOutput(self.Entity, "Y", Pos.y)
						Wire_TriggerOutput(self.Entity, "Z", Pos.z)
						Wire_TriggerOutput(self.Entity, "Vector",Pos)
					end
				end
				if !self.Target or !self.Target:IsValid() then
					Wire_TriggerOutput(self.Entity, "TargetFound", 0)
					Wire_TriggerOutput(self.Entity, "Target", WireLib.DT.ENTITY.Zero)
				end
			else
				local T = ents.FindInCrappyCone(self:GetPos(),Vector(2000,.5,.5),self:GetAngles())
				if table.HasValue( T, self.Target ) then
					local Pos = self.Target:GetPos()
					Wire_TriggerOutput(self.Entity, "TargetFound", 1)
					Wire_TriggerOutput(self.Entity, "Target", self.Target)
					Wire_TriggerOutput(self.Entity, "X", Pos.x)
					Wire_TriggerOutput(self.Entity, "Y", Pos.y)
					Wire_TriggerOutput(self.Entity, "Z", Pos.z)
					Wire_TriggerOutput(self.Entity, "Vector",Pos)
				else
					self.Target = nil
					Wire_TriggerOutput(self.Entity, "TargetFound", 0)
					Wire_TriggerOutput(self.Entity, "Target", WireLib.DT.ENTITY.Zero)
				end
			end
			
			self.ScanCD = CurTime() + 0.3
		end
		
		if self.Target and self.Target:IsValid() then
			local Pos = self.Target:GetPos()
			if self.Pod and self.Pod:IsValid() then
				self.Pod.Active = true
				self.Pod.Angular = false
				self.Pod.Firing = true
				self.Pod.XCo = Pos.x
				self.Pod.YCo = Pos.y
				self.Pod.ZCo = Pos.z				
			end
			Wire_TriggerOutput(self.Entity, "TargetFound", 1)
			Wire_TriggerOutput(self.Entity, "Target", self.Target)
			Wire_TriggerOutput(self.Entity, "X", Pos.x)
			Wire_TriggerOutput(self.Entity, "Y", Pos.y)
			Wire_TriggerOutput(self.Entity, "Z", Pos.z)
			Wire_TriggerOutput(self.Entity, "Vector",Pos)
		else
			if self.Pod and self.Pod:IsValid() then
				self.Pod.Active = true
				self.Pod.Angular = true
				self.Pod.Firing = false
								
				self.Cycle = math.fmod(self.Cycle + (Delta * self.CycleSpeed), 360)
				local Rad = math.rad(self.Cycle)
				local Pitch = (math.sin(Rad) * self.CycleH) + self.CycleP
				local Yaw = (math.cos(Rad) * self.CycleW) + self.CycleY
				
				self.Pod.Pitch = -Pitch
				self.Pod.Yaw = Yaw
				
				--local Ang = Angle(Pitch,Yaw,0)
				--local A2 = self.Pod:WorldToLocalAngles(Ang)
				--local Vec = self.Pod:GetPos() + A2:Forward() * 100
				--local EPL = WorldToLocal( self.Pod:GetPos(), self.Pod:GetAngles(), Vec, Ang)
				--print(Vec)
				
				Wire_TriggerOutput(self.Entity, "TargetFound", 0)
				Wire_TriggerOutput(self.Entity, "Target", WireLib.DT.ENTITY.Zero)
				Wire_TriggerOutput(self.Entity, "X", 0)
				Wire_TriggerOutput(self.Entity, "Y", 0)
				Wire_TriggerOutput(self.Entity, "Z", 0)
				Wire_TriggerOutput(self.Entity, "Vector",ZeroVector)
			end
		end
	
	
	
	
	
	/*
		if self.Target and self.Target:IsValid() then
			local trace = {}
			trace.start = self.Entity:GetPos() + self.Entity:GetForward() * 10
			trace.endpos = self.Entity:GetPos() + self.Entity:GetForward() * 5000
			if self.Pod and self.Pod:IsValid() then
				trace.filter = { self.Entity, self.Pod }
			else
				trace.filter = self.Entity
			end
			trace.mask = -1
			local tr = util.TraceLine( trace )
			local LWidth = self.Entity:GetPos():Distance(tr.HitPos) * math.tan(75) -- Once again, Hysteria comes to my rescue :)
			--print(LWidth)
			local targets = ents.FindInSphere( tr.HitPos, LWidth )
			--local targets = ents.FindInCone( self.Entity:GetPos(), self.Entity:GetForward(), 4000, 360)
			if table.HasValue( targets, self.Target ) then
				local trace = {}
				trace.start = self.Entity:GetPos() + self.Entity:GetForward() * 10
				trace.endpos = self.Target:GetPos()
				trace.filter = self.Entity
				trace.mask = -1
				local tr = util.TraceLine( trace )
				local Dist = tr.HitPos:Distance(self.Target:GetPos())
				if Dist < 50 then
					local Pos = self.Target:GetPos()
					Wire_TriggerOutput(self.Entity, "TargetFound", 1)
					Wire_TriggerOutput(self.Entity, "Target", self.Target)
					Wire_TriggerOutput(self.Entity, "X", Pos.x)
					Wire_TriggerOutput(self.Entity, "Y", Pos.y)
					Wire_TriggerOutput(self.Entity, "Z", Pos.z)
					Wire_TriggerOutput(self.Entity, "Vector",Pos)
				end
			else
				self.Target = nil
			end
		else
			Wire_TriggerOutput(self.Entity, "TargetFound", 0)
			Wire_TriggerOutput(self.Entity, "Target", WireLib.DT.ENTITY.Zero)
			Wire_TriggerOutput(self.Entity, "X", 0)
			Wire_TriggerOutput(self.Entity, "Y", 0)
			Wire_TriggerOutput(self.Entity, "Z", 0)
			Wire_TriggerOutput(self.Entity, "Vector",ZeroVector)
			
			--I really wish ents.FindInCone was working properly...
			local trace = {}
			trace.start = self.Entity:GetPos() + self.Entity:GetForward() * 10
			trace.endpos = self.Entity:GetPos() + self.Entity:GetForward() * 5000
			trace.filter = self.Entity
			trace.mask = -1
			local tr = util.TraceLine( trace )
			local LWidth = self.Entity:GetPos():Distance(tr.HitPos) * math.tan(70)
			--print(LWidth)
			local targets = ents.FindInSphere( tr.HitPos, LWidth )
			--local targets = ents.FindInCone( self.Entity:GetPos(), self.Entity:GetForward(), 4000, 360)
					
			for _,i in pairs(targets) do
				if i:IsPlayer() or i:IsNPC() then
					local trace = {}
					trace.start = self.Entity:GetPos() + self.Entity:GetForward() * 10
					trace.endpos = i:GetPos()
					trace.filter = self.Entity
					trace.mask = -1
					local tr = util.TraceLine( trace )
					local Dist = tr.HitPos:Distance(i:GetPos())
					if Dist < 50 then
						self.Target = i
						return
					end
				end
			end			
		end
		
		*/
	else
		Wire_TriggerOutput(self.Entity, "TargetFound", 0)
		Wire_TriggerOutput(self.Entity, "Target", WireLib.DT.ENTITY.Zero)
		Wire_TriggerOutput(self.Entity, "X", 0)
		Wire_TriggerOutput(self.Entity, "Y", 0)
		Wire_TriggerOutput(self.Entity, "Z", 0)
		Wire_TriggerOutput(self.Entity, "Vector",ZeroVector)
	end
	
	self.LTT = CurTime()
	
	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true
end

function ents.FindInCrappyCone(Pos,Size,Ang) --Technically this is more like a pyramid, but f*** it. It's a bit faster than an actual cone.
			
	local XB, YB, ZB = Size.x * 0.5, Size.y * 0.5, Size.z * 0.5
	local Results = {}
	for k,e in pairs(ents.GetAll()) do
		local EP = e:GetPos()
		
		local EPL = WorldToLocal( EP, Angle(0,0,0), Pos, Ang)
		local X,Y,Z = EPL.x, EPL.y, EPL.z
		
		if (X <= Size.x and X >= 0) and (Y <= YB * X and Y >= -YB * X) and (Z <= ZB * X and Z >= -ZB * X) then
			table.insert(Results, e)
		end
	end
	return Results
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "Scannerlight" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Use( activator, caller )
	self.Active = !self.Active
	self.dt.Active = self.Active
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then
			HPLink( ent.Cont, ent.Entity, self.Entity )
			self.Active = true
			self.dt.Active = true
		end
	end
end

function ENT:HPFire()
	
end