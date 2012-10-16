AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--util.PrecacheSound( "SB/SteamEngine.wav" )

function ENT:Initialize()
	
	self.Entity:SetModel( "models/Slyfo_2/miscequipmentradiodish.mdl" ) 
	self.Entity:SetName( "Sensor" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass(5)
	end
	self.Entity:StartMotionController()
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	if WireAddon then
		local V,A,N,E,S = "VECTOR","ANGLE","NORMAL","ENTITY","STRING"
		
		self.Inputs = WireLib.CreateSpecialInputs( self,
			{ "Strength" },
			{ N } )
		
		self.Outputs = WireLib.CreateSpecialOutputs( self, 
			{ "Lock1Vec", "Lock1Str" },
			{ V,N } )
	end
	
	self.SensorLocks = {}
	self.SensorStrength = 0
	
end


function ENT:TriggerInput(iname, value)
	
	if (iname == "Strength") then
		self.SensorStrength = value
		--print("Setting strength to", self.SensorStrength)
	end
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "RadialSensor" )
	ent:SetPos( SpawnPos + Vector(0,0,20) )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Think()
	SBEP_S.TrackInSphere( self:GetPos(), self, 0 )
	
	--print("Thinking...")
	--PrintTable(self.SensorLocks)
	local Vec = Vector(0,0,0)
	local Str = 0
	for k,e in pairs(SBEP_S.CurrentLocks(self)) do
		--print(e.TVc)
		--print(type(e.Str))
		Vec = e.TVc
		Str = e.Str	
	end
	Wire_TriggerOutput(self, "Lock1Vec", Vec)
	Wire_TriggerOutput(self, "Lock1Str", Str)
	
	self:NextThink(CurTime() + 0.1)
	return true			
end

function ENT:OnRemove()
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Touch( ent )

end

function ENT:Use( activator, caller )
	
end