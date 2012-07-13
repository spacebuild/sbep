
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo_2/mini_turret_base.mdl" ) 
	self.Entity:SetName("BlisterMount")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local inNames = { "Active", "Fire", "X", "Y", "Z", "Vector", "Pitch", "Yaw", "Mode" }
	local inTypes = { "NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","VECTOR","NORMAL","NORMAL","NORMAL" }
	self.Inputs = WireLib.CreateSpecialInputs( self.Entity,inNames,inTypes)
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass(10)
	end
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	--self.val1 = 0
	--RD_AddResource(self.Entity, "Munitions", 0)

	self.Active = false
	
	self.Angular = false
	
	self.Pitch = 0
	self.Yaw = 0
	self.Vertical = 0
	self.Lateral = 0
	
	self.XCo = 0
	self.YCo = 0
	self.ZCo = 0
	
	self.Cont 			= self.Entity
	self.HasHardpoints 	= true
	self.HPC			= 2
	self.HP				= {}
	self.HP[1]			= {}
	self.HP[1]["Ent"]	= nil
	self.HP[1]["Type"]	= { "Tiny" }
	self.HP[1]["Pos"]	= Vector(11.21,4,4.39)
	self.HP[1]["Angle"] = Angle(0,0,0)
	self.HP[2]			= {}
	self.HP[2]["Ent"]	= nil
	self.HP[2]["Type"]	= { "Tiny" }
	self.HP[2]["Pos"]	= Vector(-11.21,4,4.39)
	self.HP[2]["Angle"] = Angle(0,0,0)
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Active") then
		if (value > 0) then
			self.Active = true
		else
			self.Active = false
		end
					
	elseif (iname == "Fire") then
		if (value > 0) then
			self.Firing = true
		else
			self.Firing = false
		end
		
	elseif (iname == "Mode") then
		if (value > 0) then
			self.Angular = true
		else
			self.Angular = false
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

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "SF-TinyTurretx2-1" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	ent2 = ents.Create( "prop_physics" )
	ent2:SetModel( "models/Slyfo_2/mini_turret_swivel.mdl" ) 
	ent2:SetPos( SpawnPos )
	ent2:Spawn()
	ent2:Activate()
	ent2:GetPhysicsObject():SetMass(1)
	ent.Base1 = ent2
	ent2:SetParent(ent)
	ent2:SetLocalPos(Vector(0,0,0))
	
	local W1 = constraint.Weld(ent,ent2)
	
	ent3 = ents.Create( "prop_physics" )
	ent3:SetModel( "models/Slyfo_2/mini_turret_mount1.mdl" ) 
	ent3:SetPos( SpawnPos + Vector(0,0,10) )
	ent3:Spawn()
	ent3:Activate()
	ent3:GetPhysicsObject():SetMass(1)
	ent.Base2 = ent3
	ent3:SetParent(ent)
	ent3:SetLocalPos(Vector(0,0,0))
	
	local W2 = constraint.Weld(ent,ent3)
				
	return ent
	
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	if self.Active then
		if !self.Angular then
			local Dir = (Vector(self.XCo,self.YCo,self.ZCo) - (self.Entity:GetPos() + self.Entity:GetUp() * 10)):GetNormal()
			local Ang = Dir:Angle()
			local RAng = self.Entity:WorldToLocalAngles(Ang)
			RAng.r = 0
			self.Base1:SetLocalAngles(Angle(0,RAng.y,0))
			
			self.Base2:SetLocalAngles(RAng)
			
			Pos = self:GetPos() + (self.Base2:GetUp() * 9) + (self.Base2:GetForward() * -2)
			self.Base2:SetLocalPos(self.Entity:WorldToLocal(Pos))
		else			
			self.Base1:SetLocalAngles(Angle(0,self.Yaw,0))
			
			self.Base2:SetLocalAngles(Angle(self.Pitch,self.Yaw,0))
			
			Pos = self:GetPos() + (self.Base2:GetUp() * 9) + (self.Base2:GetForward() * -2)
			self.Base2:SetLocalPos(self.Entity:WorldToLocal(Pos))
		end
	else
		self.Base1:SetLocalAngles(Angle(0,0,0))
		
		self.Base2:SetLocalAngles(Angle(0,0,0))
		
		Pos = self:GetPos() + (self.Base2:GetUp() * 9) + (self.Base2:GetForward() * -2)
		self.Base2:SetLocalPos(self.Entity:WorldToLocal(Pos))
	end

	for i = 1,self.HPC do
		if self.HP[i]["Ent"] and self.HP[i]["Ent"]:IsValid() then
			local Weap = self.HP[i]["Ent"]
			Weap:GetPhysicsObject():SetMass(1)
			
			if Weap.APAng then
				Weap:SetLocalAngles(Weap.APAng + self.Base2:GetLocalAngles())
			else
				Weap:SetLocalAngles(self.Base2:GetLocalAngles())
			end
			
			local APos = self.HP[i]["Pos"]
			Pos = self.Base2:GetPos() + (self.Base2:GetUp() * APos.z) + (self.Base2:GetForward() * APos.y) + (self.Base2:GetRight() * APos.x) + (Weap:GetUp() * Weap.APPos.z) + (Weap:GetForward() * Weap.APPos.x) + (Weap:GetRight() * Weap.APPos.y)
			Weap:SetLocalPos(self.Entity:WorldToLocal(Pos))
			
			if self.Firing then
				Weap:HPFire()
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

function ENT:PreEntityCopy()
	local DI = {}
		local ent = self.HP[1]["Ent"]
		if ent and ent:IsValid() then
			DI.gun = ent:EntIndex()
		end
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self.Entity )
	end
	duplicator.StoreEntityModifier(self, "SBEPBlister", DI)
end
duplicator.RegisterEntityModifier( "SBEPBlister" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPBlister
	if DI.gun then
		self.HP[1]["Ent"] = CreatedEntities( DI.gun )
		--if (!self.HP[1]["Ent"]) then
		--	self.HP[1]["Ent"] = ents.GetByIndex(  Ent.EntityMods.SBEPBlister.gun )
		--end
	end
	
	if(Ent.EntityMods and Ent.EntityMods.SBEPBlister.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPBlister.WireData, function(id) return CreatedEntities[id] end)
	end
end