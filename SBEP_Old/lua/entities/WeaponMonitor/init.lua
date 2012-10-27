
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/props_combine/combine_emitter01.mdl" ) 
	self:SetName("ShipAIWeap")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--local inNames = {"MoveVector", "TargetVector", "Angle", "Stance"}
	--local inTypes = {"VECTOR","VECTOR","ANGLE","NORMAL"}
	--self.Inputs = WireLib.CreateSpecialInputs( self,inNames,inTypes)
	self.Inputs = Wire_CreateInputs( self, { "Priority", "CanFire", "Range", "PitchArc", "YawArc" } )
	self.Outputs = WireLib.CreateSpecialOutputs(self, { "Firing", "TVec", "InRange" }, { "NORMAL", "VECTOR", "NORMAL" })
		
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass( 1 )
	end
	
	self:StartMotionController()
	
	self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self:GetPhysicsObject()
	
	self.hasdamagecase = true
	
	self.Priority = 0
	self.FReady = true
	self.Range = 4000
	self.PArc = 15
	self.YArc = 15
	self.Master = nil
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "WeaponMonitor" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)
	
	if (iname == "Priority") then
		self.Priority = value
		
	elseif (iname == "CanFire") then
		if value > 0 then
			self.FReady = true
		else
			self.FReady = false
		end
		
	elseif (iname == "Range") then
		self.Range = value
		
	elseif (iname == "PitchArc") then
		self.PArc = value
		
	elseif (iname == "YawArc") then
		self.YArc = value
		
	end
end

function ENT:Think()

	local InRange = 0	
	local Firing = 0

	if self.Master and self.Master:IsValid()  then
		if self.Master.TFound then
			local RAng = (self.Master.TVec - self:GetPos()):Angle()
			local SAng = self:GetAngles()
			if math.abs(math.AngleDifference(SAng.p,RAng.p)) < self.PArc and math.abs(math.AngleDifference(SAng.y,RAng.y)) < self.YArc and self:GetPos():Distance(self.Master.TVec) < self.Range then
				Wire_TriggerOutput( self, "TVec", self.Master.TVec )
				InRange = 1
				if self.Master.Stance > 1 and self.FReady then
					Firing = 1
				end
				--print("Main Target Available")
			else
				--print("Cheking Alternates")
				for i = 1,5 do
					--print("Alternate "..i)
					RAng = (self.Master.Alternates[i] - self:GetPos()):Angle()
					if math.abs(math.AngleDifference(SAng.p,RAng.p)) < self.PArc and math.abs(math.AngleDifference(SAng.y,RAng.y)) < self.YArc and self:GetPos():Distance(self.Master.TVec) < self.Range and self.Master.Targets > i then
						--print("Found one")
						Wire_TriggerOutput( self, "TVec", self.Master.Alternates[i] )
						InRange = 1
						if self.Master.Stance > 1 and self.FReady then
							Firing = 1
						end
						break
					end
				end
			end
		end
		if self.Master.Fade then
			self:SetColor(Color(255,255,255,20))
			self:SetNotSolid( true )
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		else
			self:SetColor(Color(255,255,255,255))
			self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
			self:SetNotSolid( false )
		end
	else
		self:SetColor(Color(255,255,255,255))
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		self:SetNotSolid( false )
	end
	
	
	
	Wire_TriggerOutput( self, "Firing", 0 )
	Wire_TriggerOutput( self, "Firing", Firing )
	Wire_TriggerOutput( self, "InRange", InRange )
	
	
	self:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:Touch( ent )
	--print("Touching")
	if ent.IsShipController and (!self.Master or !self.Master:IsValid()) then
		table.insert(ent.Weaponry,self)
		self.Master = ent
		--print("Linking")
	end
end

function ENT:gcbt_breakactions(damage, pierce)
	
end

function ENT:PreEntityCopy()
	local DI = {}
		if self.Master and self.Master:IsValid() then
			DI.master = self.Master:EntIndex()
		end
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self )
	end
	duplicator.StoreEntityModifier(self, "SBEPWepMon", DI)
end
duplicator.RegisterEntityModifier( "SBEPWepMon" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)

	local DI = Ent.EntityMods.SBEPWepMon

	if DI.master then
		self.Master = CreatedEntities[ DI.master ]
		/*if (!self.Master) then
			self.Master = ents.GetByIndex(DI.master)
		end*/
	end
	if(Ent.EntityMods and Ent.EntityMods.SBEPWepMon.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPWepMon.WireData, function(id) return CreatedEntities[id] end)
	end
end