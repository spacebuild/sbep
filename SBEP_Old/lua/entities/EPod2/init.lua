AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/SmallBridge/Station Parts/SBbayDPs.mdl" )
	self:SetName("AmmoCrate")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetMaterial("models/props_combine/combinethumper002");
	self.Outputs = Wire_CreateOutputs( self, { "Occupied" })
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	
	self.LAX = 0
	self.LAY = 0
    self:SetKeyValue("rendercolor", "255 255 255")
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,100)
	
	local ent = ents.Create( "EPod2" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Think()
	if self.NPod and self.NPod:IsValid() then
		if (self.PR) then
			--self.CPL:PrintMessage( HUD_PRINTTALK, self.LAX)
			local phy = self.NPod:GetPhysicsObject()
			phy:SetVelocity(self:GetUp() * -2000)
			self.NPod.Entity:SetParent()
			--self.NPod.Entity:GetPhysicsObject():ApplyForceCenter( self:GetForward() * 1000 )
			--self.NPod.Entity:GetPhysicsObject():ApplyForceCenter( self:GetUp() * self.LAY )
			self.NPod = nil
			self.PR = false
			Wire_TriggerOutput( self, "Occupied", 0 )
		end
	end
	if self.NPod and self.NPod:IsValid() then
		self.CPL = self.NPod:GetPassenger()
		if (self.CPL and self.CPL:IsValid()) then
			Wire_TriggerOutput( self, "Occupied", 1 )
			if (self.CPL:KeyDown( IN_RELOAD )) then		
				if (self.WD and self.WD:IsValid()) then
					self.WD:Remove()
				end
				self.PR = true
				self.NPod:Fire("kill", "", 20)
			end
		else
			Wire_TriggerOutput( self, "Occupied", 0 )
		end
	else
		Wire_TriggerOutput( self, "Occupied", 0 )
	end
end

local PodOffset = Vector(-55,0,-55)

function ENT:Use(activator)
	if (self.NPod == nil or !self.NPod:IsValid()) then
		self.NPod = ents.Create( "prop_vehicle_prisoner_pod" )
		if ( !self.NPod:IsValid() ) then return end
		self.NPod:SetModel( "models/SmallBridge/Vehicles/SBVdroppod1.mdl" )
		self.NPod:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		self.NPod:SetKeyValue("limitview", 0)
		--self.NPod:SetMembers(HandleAnimation, HandleSBMPSitAnimation)
		self.NPod:SetPos( self:LocalToWorld(PodOffset) )
		self.NPod:SetAngles( self:GetAngles() )
		self.NPod:Spawn()
		self.NPod:Activate()
		self.NPod:SetSkin(self:GetSkin())
		local TB = self.NPod:GetTable()
		TB.HandleAnimation = function (vec, ply)
			return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) 
		end 
		self.NPod:SetTable(TB)
		local NC = constraint.NoCollide(self, self.NPod, 0, 0)
		self.WD = constraint.Weld(self, self.NPod, 0, 0, 0)
		--self.NPod.Entity:SetParent(self)
	end
end