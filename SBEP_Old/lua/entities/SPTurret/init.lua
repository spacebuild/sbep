
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/smlturretbase.mdl" ) 
	self.Entity:SetName("MannedTurret")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local inNames = { "Active", "Fire", "X", "Y", "Z", "Vector", "Pitch", "Yaw", "Lateral", "Vertical", "Mode" }
	local inTypes = { "NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","VECTOR","NORMAL","NORMAL","NORMAL","NORMAL","NORMAL" }
	self.Inputs = WireLib.CreateSpecialInputs( self.Entity,inNames,inTypes)
	
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
	self.HPC			= 1
	self.HP				= {}
	self.HP[1]			= {}
	self.HP[1]["Ent"]	= nil
	self.HP[1]["Type"]	= { "Tiny", "Small", "Medium", "Large", "Heavy", "GatMid", "GatRight", "GatLeft" }
	self.HP[1]["Pos"]	= Vector(0,0,40)
	self.HP[1]["Angle"] = Angle(0,0,0)
	
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
	
	local ent = ents.Create( "SPTurret" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
			
	return ent
	
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	if self.HP[1]["Ent"] and self.HP[1]["Ent"]:IsValid() then
		local Weap = self.HP[1]["Ent"]
		if self.Active then
			if !self.Angular then
				local Dir = (Vector(self.XCo,self.YCo,self.ZCo) - (self.Entity:GetPos() + self.Entity:GetUp() * 40)):GetNormal()
				local Ang = Dir:Angle()
				local RAng = self.Entity:WorldToLocalAngles(Ang)
				RAng.r = 0
				if Weap.APAng then
					Weap:SetLocalAngles(Weap.APAng + RAng)
				else
					Weap:SetLocalAngles(RAng)
				end
			else
				Ang = Angle(0,0,0)
				Ang.p = self.Pitch
				Ang.y = self.Yaw
				if Weap.APAng then
					Weap:SetLocalAngles(Weap.APAng + Ang)
				else
					Weap:SetLocalAngles(Ang)
				end
			end
		else
			if Weap.APAng then
				Weap:SetLocalAngles(Weap.APAng)
			else
				Weap:SetLocalAngles(Angle(0,0,0))
			end
		end
		Pos = self.Entity:GetPos() + (self.Entity:GetUp() * 40) + (Weap:GetUp() * Weap.APPos.z) + (Weap:GetForward() * Weap.APPos.x) + (Weap:GetRight() * Weap.APPos.y)
		Weap:SetLocalPos(self.Entity:WorldToLocal(Pos))

		if self.Firing then
			Weap:HPFire()
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

	duplicator.StoreEntityModifier(self, "SPTurret", DI)
end
duplicator.RegisterEntityModifier( "SPTurret" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SPTurret

	if (DI.gun) then
		self.HP[1]["Ent"] = CreatedEntities[ DI.gun ]
	end
	
	if(Ent.EntityMods and Ent.EntityMods.SPTurret.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SPTurret.WireData, function(id) return CreatedEntities[id] end)
	end

end