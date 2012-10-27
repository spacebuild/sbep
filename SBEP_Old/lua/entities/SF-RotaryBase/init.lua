AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/sat_grappler.mdl" ) 
	self.Entity:SetName("RotaryBase")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire", "Rotate" } )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	--self.val1 = 0
	--RD_AddResource(self.Entity, "Munitions", 0)
	
	self.LTT = 0
	self.CGun = 1
	self.Rotating = false
	self.LastFired = 0
	self.AutoCount = 0
	self.CRA = 0 --Current Rotation Angle
	self.CRS = 0 --Current Rotation Speed
	self.MRS = 10 --Max Rotation Speed
	self.OGuns = 0 --The last known number of guns
	
	
	self.Cont 			= self.Entity
	self.HasHardpoints 	= true
	self.HPC			= 8
	self.HP				= {}
	self.HP[1]			= {}
	self.HP[1]["Ent"]	= nil
	self.HP[1]["Type"]	= { "Tiny", "Small", "Medium" }
	self.HP[1]["Pos"]	= Vector(11.21,7,-2.6)
	self.HP[1]["Angle"] = Angle(0,0,0)
	self.HP[2]			= {}
	self.HP[2]["Ent"]	= nil
	self.HP[2]["Type"]	= { "Tiny", "Small", "Medium" }
	self.HP[2]["Pos"]	= Vector(-11.21,7,-2.6)
	self.HP[2]["Angle"] = Angle(0,0,0)
	self.HP[3]			= {}
	self.HP[3]["Ent"]	= nil
	self.HP[3]["Type"]	= { "Tiny", "Small", "Medium" }
	self.HP[3]["Pos"]	= Vector(11.21,2,11.35)
	self.HP[3]["Angle"] = Angle(0,0,0)
	self.HP[4]			= {}
	self.HP[4]["Ent"]	= nil
	self.HP[4]["Type"]	= { "Tiny", "Small", "Medium" }
	self.HP[4]["Pos"]	= Vector(-11.21,2,11.35)
	self.HP[4]["Angle"] = Angle(0,0,0)
	self.HP[5]			= {}
	self.HP[5]["Ent"]	= nil
	self.HP[5]["Type"]	= { "Tiny", "Small", "Medium" }
	self.HP[5]["Pos"]	= Vector(11.21,7,-2.6)
	self.HP[5]["Angle"] = Angle(0,0,0)
	self.HP[6]			= {}
	self.HP[6]["Ent"]	= nil
	self.HP[6]["Type"]	= { "Tiny", "Small", "Medium" }
	self.HP[6]["Pos"]	= Vector(-11.21,7,-2.6)
	self.HP[6]["Angle"] = Angle(0,0,0)
	self.HP[7]			= {}
	self.HP[7]["Ent"]	= nil
	self.HP[7]["Type"]	= { "Tiny", "Small", "Medium" }
	self.HP[7]["Pos"]	= Vector(11.21,2,11.35)
	self.HP[7]["Angle"] = Angle(0,0,0)
	self.HP[8]			= {}
	self.HP[8]["Ent"]	= nil
	self.HP[8]["Type"]	= { "Tiny", "Small", "Medium" }
	self.HP[8]["Pos"]	= Vector(-11.21,2,11.35)
	self.HP[8]["Angle"] = Angle(0,0,0)
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "SF-RotaryBase" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		self.Firing = value > 0
		--if (value > 0) then
		--	self:HPFire()
		--end
	elseif (iname == "Rotate") then
		self.ACyc = value > 0
	end
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then
			HPLink( ent.Cont, ent.Entity, self.Entity )
		end
	end
end

function ENT:HPFire()
	if !self.Rotating then
		self:MainFire()
	else
		if self.FreeSpin then
			self.Prefire = true
		end
	end
	if !self.FreeSpin and self.CRS < 1 then
		self.CRS = 1
	end
end

function ENT:MainFire()
	local i = self.CGun
	--print(self.CGun)
	if i >= 1 and i <= 8 then
		if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() then
			self.HP[i]["Ent"]:HPFire()
			self.CGun = i + 1
			if self.CGun > self.OGuns and self.OGuns > 1 then
				self.CGun = 1
			end
			--print(self.LastFired)
			if self.LastFired <= 0.2 then
				self.AutoCount = self.AutoCount + 1
				--print("Counting", self.AutoCount)
			else
				self.AutoCount = 0
			end
		end
	end
	self.Rotating = true
	self.LastFired = 0
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	local Delta = CurTime() - self.LTT
	if !self.Barrel or !self.Barrel:IsValid() then
		local ent = ents.Create( "Prop_Physics" )
		ent:SetModel("models/Slyfo/sat_rfg.mdl")
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:Spawn()
		ent:Activate()
		ent:SetParent(self)
		ent:SetLocalPos(Vector(20,0,0))
		ent:SetSolid(0)
		
		self.Barrel = ent
	end
	
	if !self.FClip or !self.FClip:IsValid() then
		local ent = ents.Create( "Prop_Physics" )
		ent:SetModel("models/Slyfo/sat_grappler.mdl")
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:Spawn()
		ent:Activate()
		ent:SetParent(self)
		ent:SetLocalPos(Vector(40,0,0))
		ent:SetSolid(0)
		
		self.FClip = ent
	end
	
	local TGuns = 0
	for i = 8,1,-1 do
		--print("Gun", i, self.HP[i]["Ent"])
		if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() then
			TGuns = i
			break
		end
	end
	if TGuns ~= self.OGuns then
		self:GunReorder(TGuns)
		self.OGuns = TGuns
	end
	--print(TGuns)
	
	if self.CGun > self.OGuns and self.OGuns > 1 then
		self.CGun = 1
	end
	
	if self.CGun < 1 then
		self.CGun = 1
	end
	
	if self.Accel or self.ACyc then
		self.CRS = math.Approach(self.CRS,10,0.005)
	elseif self.FreeSpin then
		self.CRS = math.Approach(self.CRS,0,0.03)
	end
		
	
	if self.AutoCount >= 3 then
		self.FreeSpin = true
		self.Accel = true
	end
		
	if self.FreeSpin and !self.Prefire then
		self.CRA = math.fmod(self.CRA + self.CRS,360)
		print(self.CRA / (360 / TGuns))
		self.CGun = math.floor(self.CRA / (360 / TGuns)) + 1
		if !self.ACyc then
			self.Accel = false
		end
		--print(self.Accel, self.CRS)
		if !self.Accel and self.CRS <= 0.3 then
			local CTrg = (360 / TGuns) * (self.CGun - 1)
			print(CTrg,self.CGun,self.CRA)
			self.CRS = 0.3
			if math.AngleDifference(self.CRA,CTrg) >= self.CRS then
				self.CRA = CTrg
				self.CRS = 0
				self.Rotating = false
				self.FreeSpin = false
			end
		end			
	else
		if self.CRS > 0 then
			local CTrg = (360 / TGuns) * (self.CGun - 1)
			--print(CTrg)
			--print(math.AngleDifference(self.CRA,CTrg))
			if math.AngleDifference(self.CRA,CTrg) >= self.CRS then
				self.CRA = CTrg
				if !self.FreeSpin or self.CRS <= 0.1 then
					self.CRS = 0
					self.Rotating = false
				else
					if self.Prefire then
						--print("Prefire Ready")
						--print(CGun)
						self:MainFire()
						self.Prefire = false
						self.Accel = true
					else
						self.Rotating = false
						self.Accel = false
					end
				end
			else
				self.CRA = math.fmod(self.CRA + self.CRS,360)
			end
		end
	end
	self.Barrel:SetLocalAngles(Angle(0,0,self.CRA))	
	--end
	if self.CRS <= 0 then
		self.LastFired = self.LastFired + Delta
		
	end
	--print(self.LastFired)
	
	if self.LastFired >= 0.5 then
		self.AutoCount = 0
	end
	
	--self.SPL:PrintMessage( HUD_PRINTCENTER, ""..self.CGun..", "..self.CRA..", "..self.CRS )
	
	if self.Firing then
		self:HPFire()
	end
		
	--print(self.CGun, self.CRA)
	
	
	self.LTT = CurTime()
	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true

end

function ENT:GunReorder(TGuns)
	local SDeg = 360 / TGuns
	--print(SDeg)
	for i = 1,8 do
		--print("Checking number", i)
		if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() then
			--print("Valid at", i)
			local CDeg = (i - 1) * SDeg
			local CRad = math.rad(CDeg)
			local X = math.sin(CRad) * 35
			local Y = math.cos(CRad) * 35
			
			local e = self.HP[i]["Ent"]
			e:SetParent(self.Barrel)
			e:SetLocalPos(Vector(0,X,Y))
			e:SetLocalAngles(Angle(0,0,-CDeg))
		end
	end
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

end