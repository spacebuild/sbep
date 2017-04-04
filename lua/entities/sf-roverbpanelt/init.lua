AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
util.PrecacheSound( "SB/Gattling2.wav" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/rover1_backpanelmount.mdl" )
	self.Entity:SetName("SmallMachineGun")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire" } )

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


end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)

	local ent = ents.Create( "SF-RoverBPanelT" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply

	local ent2 = ents.Create( "prop_vehicle_prisoner_pod" )
	ent2:SetModel( "models/Spacebuild/Corvette_Chair.mdl" )
	ent2:SetPos( ent:LocalToWorld(Vector(0,0,36)) )
	ent2:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
	ent2:SetKeyValue("limitview", 0)
	--ent2.HasHardpoints = true
	ent2:Spawn()
	ent2:Activate()
	local TB = ent2:GetTable()
	TB.HandleAnimation = function (vec, ply)
		return ply:SelectWeightedSequence( ACT_HL2MP_SIT )
	end
	ent2:SetTable(TB)
	ent2.SPL = ply
	ent2:SetNetworkedInt( "HPC", 2 )
	ent2.HasHardpoints = true
	ent2.HPC			= 2
	ent2.HP				= {}
	ent2.HP[1]			= {}
	ent2.HP[1]["Ent"]	= nil
	ent2.HP[1]["Type"]	= { "Small", "Tiny" }
	ent2.HP[1]["Pos"]	= Vector(0,-30,0)
	ent2.HP[2]			= {}
	ent2.HP[2]["Ent"]	= nil
	ent2.HP[2]["Type"]	= { "Small", "Tiny" }
	ent2.HP[2]["Pos"]	= Vector(0,30,0)
	--ent2.Skewed = true

	local phys = ent2:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end

	local LPos = ent:WorldToLocal(ent:GetPos() + ent:GetUp() * 10)
	local Cons = constraint.Ballsocket( ent2, ent, 0, 0, LPos, 0, 0, 1)
	LPos = ent:WorldToLocal(ent:GetPos() + ent:GetUp() * -10)
	Cons = constraint.Ballsocket( ent2, ent, 0, 0, LPos, 0, 0, 1)

	local ent3 = ents.Create( "prop_physics" )
	ent3:SetModel( "models/props_bts/ladder_01.mdl" )
	ent3:SetPos( ent:LocalToWorld(Vector(12,0,45)) )

	ent3:Spawn()
	ent3:Activate()
	ent3.SPL = ply
	local phys = ent3:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end



	ent2.Cont = ent2
	ent3:SetParent(ent2)
	ent.Pod2 = ent2
	ent.Bar = ent3

	self.Pod2 = ent2
	self.Bar = ent3

	return ent

end

function ENT:TriggerInput(iname, value)
	if (iname == "Fire") then
		if (value > 0) then
			self.Active = true
		else
			self.Active = false
		end

	end
end

function ENT:PhysicsUpdate()

end

function ENT:OnRemove()

	self.Pod2:Remove()
	self.Bar:Remove()
	self:Remove()

end

function ENT:Think()
	--self.Entity:SetColor(Color( 0, 0, 255, 255)

	if self.Pod2 && self.Pod2:IsValid() && self.Pod2:IsVehicle() then
		for i = 1, self.Pod2.HPC do
			if self.Pod2.HP[i]["Ent"] && self.Pod2.HP[i]["Ent"]:IsValid() then
				self.Pod2.HP[i]["Ent"]:GetPhysicsObject():SetMass(1)
			end
		end

		self.CPL = self.Pod2:GetPassenger(1)
		if (self.CPL && self.CPL:IsValid()) then

			self.CPL:CrosshairEnable()

			local PRel = self.Pod2:GetPos() + self.CPL:GetAimVector() * 500
			local FDist = PRel:Distance( self.Pod2:GetPos() + self.Pod2:GetUp() * 45 )
			local BDist = PRel:Distance( self.Pod2:GetPos() + self.Pod2:GetUp() * -45 )
			local GAng = FDist - BDist
			for i = 1, self.Pod2.HPC do
				if self.Pod2.HP[i]["Ent"] && self.Pod2.HP[i]["Ent"]:IsValid() then
					self.Pod2.HP[i]["Ent"]:SetLocalAngles( Angle(GAng,0,0) )
				end
			end

			FDist = PRel:Distance( self.Pod2:GetPos() + self.Pod2:GetForward() * 100 )
			BDist = PRel:Distance( self.Pod2:GetPos() + self.Pod2:GetForward() * -100 )
			local Yaw = math.Clamp((FDist - BDist) * 1.75, -250, 250)

			local physi1 = self.Pod2:GetPhysicsObject()

			physi1:AddAngleVelocity((physi1:GetAngleVelocity() * -1) + Vector(0,0,-Yaw))

			if ( self.CPL:KeyDown( IN_ATTACK ) ) then
				if self.Pod2.HPC && self.Pod2.HPC > 0 then
					for i = 1, self.Pod2.HPC do
						local HPC = self.CPL:GetInfo( "SBHP_"..i )
						if self.Pod2.HP[i]["Ent"] && self.Pod2.HP[i]["Ent"]:IsValid() && (string.byte(HPC) == 49) then
							if self.Pod2.HP[i]["Ent"].Cont && self.Pod2.HP[i]["Ent"].Cont:IsValid() then
								self.Pod2.HP[i]["Ent"].Cont:HPFire()
							else
								self.Pod2.HP[i]["Ent"].Entity:HPFire()
							end
						end
					end
				end
			end

			if (self.CPL:KeyDown( IN_ATTACK2 ) ) then
				if self.Pod2.HPC && self.Pod2.HPC > 0 then
					for i = 1, self.Pod2.HPC do
						local HPC = self.CPL:GetInfo( "SBHP_"..i.."a" )
						if self.Pod2.HP[i]["Ent"] && self.Pod2.HP[i]["Ent"]:IsValid() && (string.byte(HPC) == 49) then
							if self.Pod2.HP[i]["Ent"].Cont && self.Pod2.HP[i]["Ent"].Cont:IsValid() then
								self.Pod2.HP[i]["Ent"].Cont:HPFire()
							else
								self.Pod2.HP[i]["Ent"].Entity:HPFire()
							end
						end
					end
				end
			end

		else

			local PRel = self.Pod2:GetPos() + self.Entity:GetForward() * 500
			local FDist = PRel:Distance( self.Pod2:GetPos() + self.Pod2:GetForward() * 100 )
			local BDist = PRel:Distance( self.Pod2:GetPos() + self.Pod2:GetForward() * -100 )
			local Yaw = math.Clamp((FDist - BDist) * 7.75, -1250, 1250)

			local physi1 = self.Pod2:GetPhysicsObject()

			physi1:AddAngleVelocity((physi1:GetAngleVelocity() * -1) + Vector(0,0,-Yaw))

			for i = 1, self.Pod2.HPC do
				if self.Pod2.HP[i]["Ent"] && self.Pod2.HP[i]["Ent"]:IsValid() then
					self.Pod2.HP[i]["Ent"]:SetLocalAngles( Angle(0,0,0) )
				end
			end
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

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont && ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self.Entity ) end
		self.Entity:GetPhysicsObject():EnableCollisions(true)
		self.Entity:SetParent()
	end
end

function ENT:HPFire()
	if self.Bar.HP[1]["Ent"] && self.Bar.HP[1]["Ent"]:IsValid() then
		self.Bar.HP[1]["Ent"]:HPFire()
	end
	if self.Bar.HP[2]["Ent"] && self.Bar.HP[2]["Ent"]:IsValid() then
		self.Bar.HP[2]["Ent"]:HPFire()
	end
end
