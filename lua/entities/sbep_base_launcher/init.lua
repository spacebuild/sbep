AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua') --Thanks to DuneD for this bit.
include( 'shared.lua' )
--util.PrecacheSound( "NPC_Ministrider.FireMinigun" )
--util.PrecacheSound( "WeaponDissolve.Dissolve" )


local SBEP_LauncherData = {

	[ "4X Launcher" ] = {
				Model = "models/Slyfo/smlmissilepod.mdl", 
				Shots = 4,
				BLength = 40,
				Rows = { -4 , 4 },
				Cols = { -4 , 4 }
				},
	[ "8X Launcher"	] = {
				Model = "models/Slyfo/missile_pod_8.mdl", 
				Shots = 8,
				BLength = 45,
				Rows = { -4 , 4 },
				Cols = { -12 , -4, 4, 12 }
				},
	[ "10X Launcher" ] = {
				Model = "models/Slyfo/missile_pod_10.mdl", 
				Shots = 10,
				BLength = 65,
				Rows = { -5 , 5 },
				Cols = { -16 , -8, 0, 8, 16 }
				}
	}
	
for k,v in pairs( SBEP_LauncherData ) do
	if v ~= {} then
		list.Set( "SBEP_LauncherData", k , v )
	end
end

function ENT:Initialize()
	self.LType = self.LType or "4X Launcher"
	local LauncherData = list.Get( "SBEP_LauncherData" )
	local Data = LauncherData[self.LType]
	self.Entity:SetModel( Data.Model ) 
	self.Entity:SetName(self.Type)
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		local V,N,A,E = "VECTOR","NORMAL","ANGLE","ENTITY"
		self.Inputs = WireLib.CreateSpecialInputs( self,
			{"Fire","GuidanceType","LockTime","X","Y","Z","Vector","WireGuidanceOnly","TargetEntity","Detonate","ManualPitch","ManualYaw","ManualRoll","ManualAngle"},
			{N,N,N,N,N,N,V,N,E,N,N,N,N,A}
		)
		self.Outputs = WireLib.CreateSpecialOutputs( self, 
			{ "ShotsLeft", "CanFire", "PrimaryMissileActive", "PrimaryMissilePos", "PrimaryMissileAngle", "PrimaryMissileVelocity","PrimaryMissile" },
			{N,N,N,V,A,V,E})
	end

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.Entity:SetNetworkedInt( "Shots", 4 )
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	--self.val1 = 0
	--RD_AddResource(self.Entity, "Munitions", 0)
	
	self.CDL = {}
	self.Shots = Data.Shots
	for x = 1,self.Shots do
		self.CDL[x] = 0
	end
	self.Rows = Data.Rows
	self.Cols = Data.Cols
	
	self.BLength = Data.BLength
	
	self.XCo = 0
	self.YCo = 0
	self.ZCo = 0
	
	self.GType = 0
	self.WireG = false
	
	self.TEnt = nil
	
	self.MAngle = Angle(0,0,0)
	
	self.LTime = 0
end
/*
function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "SF-SmallMissilePod" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end
*/
function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			self.Entity:HPFire()
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
	
	elseif (iname == "TargetEntity") then	
		self.TEnt = value
		
	elseif (iname == "LockTime") then
		self.LTime = value
		
	elseif (iname == "Detonate") then
		self.Detonating = value > 0
		
	elseif (iname == "ManualPitch") then
		self.MAngle.p = value
		
	elseif (iname == "ManualYaw") then
		self.MAngle.y = value
	
	elseif (iname == "ManualRoll") then
		self.MAngle.r = value
		
	elseif (iname == "ManualAngle") then
		self.MAngle = value
	
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	local MCount = 0
	for n = 1, self.Shots do
		if CurTime() >= self.CDL[n] then
			if self.CDL[n] ~= 0 then
				self.CDL[n] = 0
				self.Entity:EmitSound("Buttons.snd26")
			end
			MCount = MCount + 1
		end
	end
	
	Wire_TriggerOutput(self.Entity, "ShotsLeft", MCount)
	self.Entity:SetShots(MCount)
	if MCount > 0 then 
		Wire_TriggerOutput(self.Entity, "CanFire", 1) 
	else
		Wire_TriggerOutput(self.Entity, "CanFire", 0) 
	end
	
	if self.Pod and self.Pod:IsValid() and !self.WireG and self.Pod.Trace then
		local HPos = self.Pod.Trace.HitPos
		self.XCo = HPos.x
		self.YCo = HPos.y
		self.ZCo = HPos.z
	end
	
	if self.Primary and self.Primary:IsValid() then
		Wire_TriggerOutput(self.Entity, "PrimaryMissileActive", 1)
		Wire_TriggerOutput(self.Entity, "PrimaryMissilePos", self.Primary:GetPos() )
		Wire_TriggerOutput(self.Entity, "PrimaryMissileAngle", self.Primary:GetAngles())
		Wire_TriggerOutput(self.Entity, "PrimaryMissileVelocity", self.Primary:GetPhysicsObject():GetVelocity())
		Wire_TriggerOutput(self.Entity, "PrimaryMissile", self.Primary)
		
	else
		Wire_TriggerOutput(self.Entity, "PrimaryMissileActive", 0)
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
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self.Entity ) end
	end
end

function ENT:HPFire()
	if (CurTime() >= self.MCDown) then
		for n = 1, self.Shots do
			if (CurTime() >= self.CDL[n]) then
				self.Entity:FFire(n)
				return
			end
		end
	end
end

function ENT:FFire( CCD )
	local NewShell = ents.Create( "SF-HomingMissile" )
	if ( !NewShell:IsValid() ) then return end
	local CVel = self.Entity:GetPhysicsObject():GetVelocity()
	local Row = table.Random(self.Rows)
	local Col = table.Random(self.Cols)
	NewShell:SetPos( self.Entity:GetPos() + (self:GetUp() * Row) + (self:GetRight() * Col) + (self.Entity:GetForward() * self.BLength) + CVel )
	NewShell:SetAngles( self.Entity:GetAngles() )
	NewShell.SPL = self.SPL
	NewShell:Spawn()
	NewShell:Initialize()
	NewShell:Activate()
	NewShell:SetOwner(self)
	NewShell.PhysObj:SetVelocity(self.Entity:GetForward() * 1000)
	NewShell:Fire("kill", "", 30)
	NewShell.TEnt = self.TEnt
	local Trace = nil
	if self.Pod and self.Pod:IsValid() and self.Pod:IsVehicle() then
		local CPL = self.Pod:GetPassenger(1)
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
	
	NewShell.ParL = self.Entity
	NewShell.XCo = self.XCo
	NewShell.YCo = self.YCo
	NewShell.ZCo = self.ZCo
	NewShell.GType = self.GType
	NewShell.LTime = self.LTime
	/*
	local RockTrail = ents.Create("env_rockettrail")
	RockTrail:SetAngles( NewShell:GetAngles()  )
	RockTrail:SetPos( NewShell:GetPos() + NewShell:GetForward() * -7 )
	RockTrail:SetParent(NewShell)
	RockTrail:Spawn()
	RockTrail:Activate()
	*/
	
	if !self.Primary or !self.Primary:IsValid() then
		self.Primary = NewShell
	end
	--RD_ConsumeResource(self, "Munitions", 1000)
	self.Entity:EmitSound("Weapon_RPG.Single")
	self.MCDown = CurTime() + 0.1 + math.Rand(0,0.2)
	self.CDL[CCD] = CurTime() + 7
end

function ENT:PreEntityCopy()
	if WireAddon then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",WireLib.BuildDupeInfo(self.Entity))
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