
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
include('entities/base_wire_entity/init.lua') --Thanks to DuneD for this bit.

function ENT:Initialize()

	self:SetModel( "models/Slyfo/sat_grappler.mdl" ) 
	self:SetName("Winch")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.Inputs = Wire_CreateInputs( self, { "Launch", "Length", "Disengage", "Speed" } )
	self.Outputs = Wire_CreateOutputs( self, { "CanLaunch", "CurrentLength" })
		
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass(500)
	end
	self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self:GetPhysicsObject()
	
	--self.val1 = 0
	--RD_AddResource(self, "Munitions", 0)
	
	self.DLength = 0
	self.LChange = 0
	self.ReelRate = 5
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "SF-Winch" )
	ent:SetPos( SpawnPos )
	ent:Initialize()
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)	
	if (iname == "Launch") then
		if (value > 0) then
			self:WFire()
		end
		
	elseif (iname == "Length") then
		self.DLength = math.Clamp(value, 100, 5000)
		self.LChange = CurTime()
		
	elseif (iname == "Disengage") then
		if value > 0 then
			self.Disengaging = true
		else
			self.Disengaging = false
		end
		
	elseif (iname == "Speed") then
		self.ReelRate = math.Clamp(value, 0.01, 20)
		
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	if self.CHook and self.CHook:IsValid() then
	
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
		local NewShell = ents.Create( "SF-GrappleH" )
		if ( !NewShell:IsValid() ) then return end
		NewShell:SetPos( self:GetPos() + (self:GetForward() * 50) )
		NewShell:SetAngles( self:GetAngles() )
		NewShell.SPL = self.SPL
		NewShell:Spawn()
		NewShell:Initialize()
		NewShell:Activate()
		local NC = constraint.NoCollide(self, NewShell, 0, 0)
		NewShell.PhysObj:SetVelocity(self:GetForward() * 5000)
		NewShell.Active = true
		NewShell.ATime = 0
		NewShell:Fire("kill", "", 120)
		NewShell.ParL = self
		NewShell:Think()
		self.MCDown = CurTime() + 1
		return
	end
end

function ENT:WFire()
	if (CurTime() >= self.MCDown) then
		local NewShell = ents.Create( "SF-GrappleH" )
		if ( !NewShell:IsValid() ) then return end
		NewShell:SetPos( self:GetPos() + (self:GetForward() * 50) )
		NewShell:SetAngles( self:GetAngles() )
		NewShell.SPL = self.SPL
		NewShell:Spawn()
		NewShell:Initialize()
		NewShell:Activate()
		local NC = constraint.NoCollide(self, NewShell, 0, 0)
		NewShell.PhysObj:SetVelocity(self:GetForward() * 5000)
		NewShell.Active = true
		NewShell.ATime = 0
		NewShell:Fire("kill", "", 120)
		NewShell.ParL = self
		NewShell:Think()
		self.MCDown = CurTime() + 1
		return
	end
end

function ENT:Latch( Hook, Vec, Ent )
	--Hook.Rope = constraint.Rope( self, Hook, 0, 0, Vector(33,0,0), Vector(0,0,0), self:GetPos():Distance(Hook:GetPos()), 0, 0, 2, "cable/rope", false)
	
	--This next bit mostly comes from the Wired Winches. Credit goes to whoever made them.
	local minMass = math.min( self:GetPhysicsObject():GetMass(), Ent:GetPhysicsObject():GetMass() )
	local const = minMass * 100
	local damp = const * 0.2
	
	Hook.Elastic, Hook.Rope = constraint.Elastic( self, Ent, 0, 0, Vector(33,0,0), Vec, const, damp, 0, "cable/rope", 2, true)
	
	Hook.CLength = self:GetPos():Distance(Hook:GetPos())
end