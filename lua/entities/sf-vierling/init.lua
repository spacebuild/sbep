--models/Slyfo/flakvierling_base.mdl - models/Slyfo/flakvierling_blasternorm.mdl - models/Slyfo/flakvierling_gunmount.mdl - models/Slyfo/flakvierling_spinner.mdl
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
util.PrecacheSound( "SB/Gattling2.wav" )

function ENT:Initialize()

	--self.Entity:SetModel( "models/Slyfo/smlturrettop.mdl" )
	self.Entity:SetName("SmallMachineGun")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local inNames = {"Active", "Fire", "X", "Y", "Z","Vector", "Mode", "Pitch", "Yaw", "Lateral", "Vertical"}
	local inTypes = {"NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","VECTOR","NORMAL","NORMAL","NORMAL","NORMAL","NORMAL"}
	self.Inputs = WireLib.CreateSpecialInputs( self.Entity,inNames,inTypes)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()

	--self.val1 = 0
	--RD_AddResource(self.Entity, "Munitions", 0)

	self.HPC			= 4
	self.HP				= {}
	self.HP[1]			= {}
	self.HP[1]["Ent"]	= nil
	self.HP[1]["Type"]	= "Small"
	self.HP[1]["Pos"]	= Vector(20,-20,53)
	self.HP[2]			= {}
	self.HP[2]["Ent"]	= nil
	self.HP[2]["Type"]	= "Small"
	self.HP[2]["Pos"]	= Vector(20,-20,23)
	self.HP[3]			= {}
	self.HP[3]["Ent"]	= nil
	self.HP[3]["Type"]	= "Small"
	self.HP[3]["Pos"]	= Vector(20,20,53)
	self.HP[4]			= {}
	self.HP[4]["Ent"]	= nil
	self.HP[4]["Type"]	= "Small"
	self.HP[4]["Pos"]	= Vector(20,20,23)

	self.Mode = 0
	self.Cont = self.Entity
	self.Firing = false
	self.Active = false

	self.Pitch = 0
	self.Yaw = 0
	self.Vertical = 0
	self.Lateral = 0

	self.XCo = 0
	self.YCo = 0
	self.ZCo = 0

	self.NST = 0
	self.CHP = 1
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,70)

	local ent = ents.Create( "SF-Vierling" )
	ent:SetPos( SpawnPos )
	ent:SetModel( "models/Slyfo/flakvierling_gunmount.mdl" )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply

	local LPos = nil
	local Cons = nil

	SpawnPos2 = SpawnPos + (ent:GetForward() * 32) + Vector(0,0,-20)

	ent2 = ents.Create( "prop_physics" )
	ent2:SetModel( "models/Slyfo/flakvierling_spinner.mdl" )
	ent2:SetPos( SpawnPos2 )
	ent2:Spawn()
	ent2:Activate()
	ent.Base = ent2

	LPos = ent:WorldToLocal(ent:GetPos() + ent:GetRight() * 10 + ent:GetUp() * 40)
	Cons = constraint.Ballsocket( ent2, ent, 0, 0, LPos, 0, 0, 1)
	LPos = ent:WorldToLocal(ent:GetPos() + ent:GetRight() * -10 + ent:GetUp() * 40)
	Cons = constraint.Ballsocket( ent2, ent, 0, 0, LPos, 0, 0, 1)

	SpawnPos3 = SpawnPos + Vector(0,0,-38)

	ent3 = ents.Create( "prop_physics" )
	ent3:SetModel( "models/Slyfo/flakvierling_base.mdl" )
	ent3:SetPos( SpawnPos3 )
	ent3:Spawn()
	ent3:Activate()
	ent.Base2 = ent3

	LPos = ent2:WorldToLocal(ent2:GetPos() + ent2:GetForward() * -32 + ent2:GetUp() * 10)
	Cons = constraint.Ballsocket( ent3, ent2, 0, 0, LPos, 0, 0, 1)
	LPos = ent2:WorldToLocal(ent2:GetPos() + ent2:GetForward() * -32 + ent2:GetUp() * -10)
	Cons = constraint.Ballsocket( ent3, ent2, 0, 0, LPos, 0, 0, 1)

	ent.TraceMask = {ent,ent2,ent3}
	ent.TraceData = {filter = ent.TraceMask}

	return ent

end

function ENT:TriggerInput(iname, value)
	if (iname == "Active") then
		if (value > 0) then
			self.Active = true
		else
			self.Active = false
		end

	elseif (iname == "Mode") then
		if (value == 0) then
			self.Mode = 0
		else
			self.Mode = 1
		end

	elseif (iname == "Fire") then
		if (value > 0) then
			self.Firing = true
		else
			self.Firing = false
		end

	elseif (iname == "X") then
		self.XCo = value

	elseif (iname == "Y") then
		self.YCo = value

	elseif (iname == "Z") then
		self.ZCo = value

	elseif (iname == "Vector") then
		self.XCo = value.x
		self.YCo = value.y
		self.ZCo = value.z

	elseif (iname == "Pitch") then
		self.Pitch = value

	elseif (iname == "Yaw") then
		self.Yaw = value

	elseif (iname == "Lateral") then
		self.Lateral = value

	elseif (iname == "Vertical") then
		self.Vertical = value

	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think() -- Note to self: Redo this bit. It could do with a little reordering.
	local TargPos = nil
	if (!self.Active and self.Base2:IsValid()) then
		TargPos = self.Base2:GetPos() + self.Base2:GetForward() * 200 + self.Base2:GetUp() * 60
	end
	if self.CPod && self.CPod:IsValid() then
		self.CPL = self.CPod:GetPassenger(1)
		if (self.CPL && self.CPL:IsValid()) then

			if (self.CPL:KeyDown( IN_ATTACK )) then
				self.Entity:HPFire()
			end

			self.CPL:CrosshairEnable()

			--TargPos = self.CPL:GetEyeTrace().HitPos
			--Get the target position with a custom trace to ignore the turret, vehicle and guns
			self.TraceData.start 	= self.CPL:GetPos()
			self.TraceData.endpos	= self.TraceData.start + self.CPL:GetAimVector() * 10000
			TargPos = util.TraceLine(self.TraceData).HitPos
		end
	end
	if self.Active then
		if self.Mode == 0 then
			TargPos = Vector(self.XCo,self.YCo,self.ZCo)
		elseif self.Mode == 1 then
			self.Pitch = self.Pitch + self.Vertical
			self.Yaw = self.Yaw + self.Lateral

			local TAngle = Angle(0,0,0)
			TAngle.r = self.Base2:GetAngles().r
			TAngle.p = math.fmod(self.Base2:GetAngles().p + self.Pitch,360)
			TAngle.y = math.fmod(self.Base2:GetAngles().y + self.Yaw,360)

			TargPos = self.Entity:GetPos() + TAngle:Forward() * 1000
		end
	end
	if TargPos then
		local FDist = TargPos:Distance( self.Entity:GetPos() + self.Entity:GetUp() * 120 ) --100 with compensation
		local BDist = TargPos:Distance( self.Entity:GetPos() + self.Entity:GetUp() * -80 )
		local Pitch = math.Clamp((FDist - BDist) * 7.75, -1050, 1050)
		FDist = TargPos:Distance( self.Entity:GetPos() + self.Entity:GetRight() * 100 )
		BDist = TargPos:Distance( self.Entity:GetPos() + self.Entity:GetRight() * -100 )
		local Yaw = math.Clamp((BDist - FDist) * 7.75, -1050, 1050)

		local physi = ent2:GetPhysicsObject()
		local physi2 = self.Entity:GetPhysicsObject()

		physi:AddAngleVelocity((physi:GetAngleVelocity() * -1) + Vector(0,0,-Yaw))
		physi2:AddAngleVelocity((physi2:GetAngleVelocity() * -1) + Vector(0,Pitch,0))
	end

	if CurTime() >= self.NST then --This just cycles through the guns, to make sure every weapon gets fired, but not all at once. The timing is synchronized for the aa-blaster cannon.
		self.NST = CurTime() + 0.15
		self.CHP = self.CHP + 1
		if self.CHP > 4 then
			self.CHP = 1
		end
	end

	if self.Firing then
		self.Entity:HPFire()
	end

	self.Entity:NextThink( CurTime() + 0.01 )
	return true
end

function ENT:OnRemove( )
	if self.Base && self.Base:IsValid() then
		self.Base:Remove()
	end
	if self.Base2 && self.Base2:IsValid() then
		self.Base2:Remove()
	end
end

function ENT:PhysicsCollide( data, physobj )

end

function ENT:OnTakeDamage( dmginfo )

end

function ENT:Use( activator, caller )

end

function ENT:Touch( ent )
	if ent && ent:IsValid() && ent:IsVehicle() then
		self.CPod = ent
		if not table.HasValue(self.TraceMask,ent) then
			table.insert(self.TraceMask,ent)
		end
	end
end

function ENT:HPFire()
	if self.HP[self.CHP]["Ent"] && self.HP[self.CHP]["Ent"]:IsValid() then
		self.HP[self.CHP]["Ent"]:HPFire()
	end
end

function ENT:OnHPLink(weap)
	table.insert(self.TraceMask,weap)
end

function ENT:PreEntityCopy()
	local DI = {}

	if (self.CPod) and (self.CPod:IsValid()) then
	    DI.cpod = self.CPod:EntIndex()
	end
	DI.guns = {}
	for k,v in pairs(self.HP) do
		if (v["Ent"]) and (v["Ent"]:IsValid()) then
			DI.guns[k] = v["Ent"]:EntIndex()
		end
	end
	if (self.Base) and (self.Base:IsValid()) then
		DI.Base = self.Base:EntIndex()
	end
	if (self.Base2) and (self.Base2:IsValid()) then
		DI.Base2 = self.Base2:EntIndex()
	end

	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self.Entity )
	end

	duplicator.StoreEntityModifier(self, "SBEPVierling", DI)
end
duplicator.RegisterEntityModifier( "SBEPVierling" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPVierling

	if (DI.cpod) then
		self.CPod = CreatedEntities[ DI.cpod ]
	end
	if (DI.Base) then
		self.Base = CreatedEntities[ DI.Base ]
	end
	if (DI.Base2) then
		self.Base2 = CreatedEntities[ DI.Base2 ]
	end
	self.TraceMask = {self.Entity,self.Base,self.Base2,self.CPod}
	self.TraceData = {filter = self.TraceMask}
	if (DI.guns) then
		for k,v in pairs(DI.guns) do
			self.HP[k]["Ent"] = CreatedEntities[ v ]
			--table.insert(self.TraceMask,gun)
		end
	end

	if(Ent.EntityMods and Ent.EntityMods.SBEPVierling.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPVierling.WireData, function(id) return CreatedEntities[id] end)
	end

end
