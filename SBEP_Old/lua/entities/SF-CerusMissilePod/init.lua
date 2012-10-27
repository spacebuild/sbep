AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua') --Thanks to DuneD for this bit.
include( 'shared.lua' )
--util.PrecacheSound( "NPC_Ministrider.FireMinigun" )
--util.PrecacheSound( "WeaponDissolve.Dissolve" )

function ENT:Initialize()

	self:SetModel( "models/Stat_Turrets/st_turretmissile.mdl" ) 
	self:SetName("CerusMissilePod")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateSpecialInputs( self,
			{"Fire","GuidanceType","X","Y","Z","Vector","WireGuidanceOnly"},
			{[6] = "VECTOR"}
		)
		self.Outputs = WireLib.CreateOutputs( self, { "ShotsLeft", "CanFire" })
	end

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = phys
	
	--self.val1 = 0
	--RD_AddResource(self, "Munitions", 0)
	
	self.CDL = {}
	self.CDL[1] = 0
	self.CDL[2] = 0
	self.CDL[3] = 0
	self.CDL[4] = 0
	self.CDL["1r"] = true
	self.CDL["2r"] = true
	self.CDL["3r"] = true
	self.CDL["4r"] = true
	
	self.XCo = 0
	self.YCo = 0
	self.ZCo = 0
	
	self.GType = 0
	self.WireG = false
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0, 0, 40)
	
	local ent = ents.Create( "SF-CerusMissilePod" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			self:HPFire()
		end
		
	elseif (iname == "GuidanceType") then
		self.GType = value
	
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
		
	elseif (iname == "WireGuidanceOnly") then
		if (value > 0) then
			self.WireG = true
		else
			self.WireG = false
		end
	
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	local MCount = 0
	for n = 1, 4 do
		if (CurTime() >= self.CDL[n]) then
			if self.CDL[n.."r"] == false then
				self.CDL[n.."r"] = true
				self:EmitSound("Buttons.snd26")
			end
			MCount = MCount + 1
		end
	end
	
	Wire_TriggerOutput(self, "ShotsLeft", MCount)
	if MCount > 0 then 
		Wire_TriggerOutput(self, "CanFire", 1) 
	else
		Wire_TriggerOutput(self, "CanFire", 0) 
	end
	
	if self.Pod and self.Pod:IsValid() and !self.WireG and self.Pod.Trace then
		local HPos = self.Pod.Trace.HitPos
		self.XCo = HPos.x
		self.YCo = HPos.y
		self.ZCo = HPos.z
	end
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
	end
end

function ENT:HPFire()
	if (CurTime() >= self.MCDown) then
		for n = 1, 4 do
			if (CurTime() >= self.CDL[n]) then
				self:FFire(n)
				return
			end
		end
	end
end

function ENT:FFire( CCD )
	local NewShell = ents.Create( "SF-HomingMissile" )
	if ( !NewShell:IsValid() ) then return end
	local CVel = self:GetPhysicsObject():GetVelocity():Length()
	NewShell:SetPos( self:GetPos() + (self:GetUp() * 10) + (self:GetForward() * (115 + CVel)) )
	NewShell:SetAngles( self:GetAngles() )
	NewShell.SPL = self.SPL
	NewShell:Spawn()
	NewShell:Initialize()
	NewShell:Activate()
	NewShell:SetOwner(self)
	NewShell.PhysObj:SetVelocity(self:GetForward() * 5000)
	NewShell:Fire("kill", "", 30)
	local Trace = nil
	if self.Pod and self.Pod:IsValid() and self.Pod:IsVehicle() then
		local CPL = self.Pod:GetPassenger()
		if CPL and CPL:IsValid() then
			--CPL.CamCon = true
			--CPL:SetViewEntity( NewShell )
		end
		
		if self.Trace then
			Trace = self.Pod.CTrace
			NewShell.TEnt = Trace.HitEnt
		end
		NewShell.Pod = self.Pod
	end
	
	NewShell.ParL = self
	NewShell.XCo = self.XCo
	NewShell.YCo = self.YCo
	NewShell.ZCo = self.ZCo
	NewShell.GType = self.GType
	
	local RockTrail = ents.Create("env_rockettrail")
	RockTrail:SetAngles( NewShell:GetAngles()  )
	RockTrail:SetPos( NewShell:GetPos() + NewShell:GetForward() * -7 )
	RockTrail:SetParent(NewShell)
	RockTrail:Spawn()
	RockTrail:Activate()
	--RD_ConsumeResource(self, "Munitions", 1000)
	self:EmitSound("Weapon_RPG.Single")
	self.MCDown = CurTime() + 0.1 + math.Rand(0,0.2)
	self.CDL[CCD] = CurTime() + 10
	self.CDL[CCD.."r"] = false
end

function ENT:PreEntityCopy()
	if WireAddon then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",WireLib.BuildDupeInfo(self))
	end
end

function ENT:PostEntityPaste(ply, ent, createdEnts)
	local emods = ent.EntityMods
	if not emods then return end
	if WireAddon then
		WireLib.ApplyDupeInfo(ply, ent, emods.WireDupeInfo, function(id) return createdEnts[id] end)
	end
	ent.SPL = ply
end