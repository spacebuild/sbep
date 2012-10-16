`
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Stat_Turrets/st_turretswivel.mdl" ) 
	self.Entity:SetName("MannedTurret")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	--self.Inputs = Wire_CreateInputs( self.Entity, { "Fire" } )
	
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

	self.DPitch = 0
	self.Pitch = 0	
	self.DYaw = 0
	self.Yaw = 0
	self.MTime = 0
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "MannedTurret" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
		
	local ent2 = ents.Create( "prop_vehicle_prisoner_pod" )
	ent2:SetModel( "models/Spacebuild/strange.mdl" )
	--ent2:SetModel( "models/Slyfo/wheelcycle.mdl" )
	ent2:SetPos( ent:LocalToWorld(Vector(0,0,50)) )
	ent2:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
	ent2:SetKeyValue("limitview", 0)
	
	ent2.HasHardpoints = true
	ent2:Spawn()
	ent2:Activate()
	local TB = ent2:GetTable()
	TB.HandleAnimation = function (vec, ply)
		return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) 
	end 
	ent2:SetTable(TB)
	ent2.SPL = ply
	ent2:SetNetworkedInt( "HPC", 6 )
	ent2.HasHardpoints = true
	ent.HPC			= 6
	ent.HP				= {}
	ent.HP[1]			= {}
	ent.HP[1]["Ent"]	= nil
	ent.HP[1]["Type"]	= { "Medium", "Small", "Tiny" }
	ent.HP[1]["Pos"]	= Vector(0,-60,-20)
	ent.HP[2]			= {}
	ent.HP[2]["Ent"]	= nil
	ent.HP[2]["Type"]	= { "Medium", "Small", "Tiny" }
	ent.HP[2]["Pos"]	= Vector(0,60,-20)
	ent.HP[3]			= {}
	ent.HP[3]["Ent"]	= nil
	ent.HP[3]["Type"]	= { "Small", "Tiny" }
	ent.HP[3]["Pos"]	= Vector(0,-50,10)
	ent.HP[4]			= {}
	ent.HP[4]["Ent"]	= nil
	ent.HP[4]["Type"]	= { "Small", "Tiny" }
	ent.HP[4]["Pos"]	= Vector(0,-50,-50)
	ent.HP[5]			= {}
	ent.HP[5]["Ent"]	= nil
	ent.HP[5]["Type"]	= { "Small", "Tiny" }
	ent.HP[5]["Pos"]	= Vector(0,50,10)
	ent.HP[6]			= {}
	ent.HP[6]["Ent"]	= nil
	ent.HP[6]["Type"]	= { "Small", "Tiny" }
	ent.HP[6]["Pos"]	= Vector(0,50,-50)
	--ent2.Skewed = true
	
	local phys = ent2:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	
	
	local LPos = ent:WorldToLocal(ent2:GetPos() + ent2:GetForward() * 50)
	local Cons = constraint.Ballsocket( ent2, ent, 0, 0, LPos, 0, 0, 1)
	LPos = ent:WorldToLocal(ent2:GetPos() + ent2:GetForward() * -50)
	Cons = constraint.Ballsocket( ent2, ent, 0, 0, LPos, 0, 0, 1)
	
	SpawnPos3 = SpawnPos + Vector(0,0,-5)
	
	ent3 = ents.Create( "prop_physics" )
	ent3:SetModel( "models/props_phx/construct/windows/window_angle360.mdl" ) 
	ent3:SetPos( SpawnPos3 )
	ent3:Spawn()
	ent3:Activate()
	ent.Base = ent3
	
	LPos = ent3:WorldToLocal(ent:GetPos() + ent:GetUp() * 50)
	Cons = constraint.Ballsocket( ent3, ent, 0, 0, LPos, 0, 0, 1)
	LPos = ent3:WorldToLocal(ent:GetPos() + ent:GetUp() * -50)
	Cons = constraint.Ballsocket( ent3, ent, 0, 0, LPos, 0, 0, 1)
	
	
	ent2.Cont = ent	
	ent.Pod2 = ent2
		
	return ent
	
end

function ENT:PhysicsUpdate()

end

function ENT:OnRemove() 

	self.Pod2:Remove()
	self.Base:Remove()
	self:Remove()
	
end

function ENT:Think()
	--self.Entity:SetColor( 0, 0, 255, 255)

	if self.Pod2 and self.Pod2:IsValid() and self.Pod2:IsVehicle() then
		for i = 1, self.HPC do
			if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() then
				self.HP[i]["Ent"]:GetPhysicsObject():SetMass(1)
			end
		end
					
		self.CPL = self.Pod2:GetPassenger()
		if (self.CPL and self.CPL:IsValid()) then
						
			self.CPL:CrosshairEnable()
					
			local CPLA = self.Pod2:WorldToLocalAngles(self.CPL:EyeAngles())
			
			if self.CPL.SBEPYaw ~= 0 and self.CPL.SBEPPitch ~= 0 then
				self.MTime = CurTime() + .2
			end
			
			if CurTime() > self.MTime then
						
				CPLA.y = CPLA.y * 0.95
				CPLA.p = CPLA.p * 0.95
				
				--print(CPLA)
				
				self.CPL:SetEyeAngles(CPLA)
				
			end
			
			
			local physi1 = self.Pod2:GetPhysicsObject()
			local physi2 = self.Entity:GetPhysicsObject()
			physi1:AddAngleVelocity((physi1:GetAngleVelocity() * -1) + Angle(0,CPLA.p * 2,0))
			physi2:AddAngleVelocity((physi2:GetAngleVelocity() * -1) + Angle(0,0,CPLA.y * 5))
			
			
			--self.CPL:SetEyeAngles(self.CPL:EyeAngles() * 0.1)
			
			
			
			if ( self.CPL:KeyDown( IN_ATTACK ) ) then
				if self.HPC and self.HPC > 0 then
					for i = 1, self.HPC do
						local HPC = self.CPL:GetInfo( "SBHP_"..i )
						if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() and (string.byte(HPC) == 49) then
							if self.HP[i]["Ent"].Cont and self.HP[i]["Ent"].Cont:IsValid() then
								self.HP[i]["Ent"].Cont:HPFire()
							else
								self.HP[i]["Ent"].Entity:HPFire()
							end
						end
					end
				end
			end
			
			if (self.CPL:KeyDown( IN_ATTACK2 ) ) then
				if self.HPC and self.HPC > 0 then
					for i = 1, self.HPC do
						local HPC = self.CPL:GetInfo( "SBHP_"..i.."a" )
						if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() and (string.byte(HPC) == 49) then
							if self.HP[i]["Ent"].Cont and self.HP[i]["Ent"].Cont:IsValid() then
								self.HP[i]["Ent"].Cont:HPFire()
							else
								self.HP[i]["Ent"].Entity:HPFire()
							end
						end
					end
				end
			end
			
		else
			
			local PRel = self.Entity:GetPos() + self.Entity:GetForward() * 500
			local FDist = PRel:Distance( self.Entity:GetPos() + self.Base:GetForward() * 100 )
			local BDist = PRel:Distance( self.Entity:GetPos() + self.Base:GetForward() * -100 )
			local Yaw = math.Clamp((FDist - BDist) * 7.75, -1250, 1250)
			
			local PRel = self.Pod2:GetPos() + self.Entity:GetForward() * 500 + self.Entity:GetUp() * 50
			local FDist = PRel:Distance( self.Pod2:GetPos() + self.Pod2:GetUp() * 100 )
			local BDist = PRel:Distance( self.Pod2:GetPos() + self.Pod2:GetUp() * -100 )
			local Pitch = math.Clamp((FDist - BDist) * 7.75, -1250, 1250)
		
			local physi1 = self.Pod2:GetPhysicsObject()
			
			physi1:AddAngleVelocity((physi1:GetAngleVelocity() * -1) + Angle(0,Pitch,0))
			
			local physi2 = self.Entity:GetPhysicsObject()
			
			physi2:AddAngleVelocity((physi2:GetAngleVelocity() * -1) + Angle(0,0,Yaw))
			
			self.Pitch = 0
			self.Yaw = 0
		end
	end

	
	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true	
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

end