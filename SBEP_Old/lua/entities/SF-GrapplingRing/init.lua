
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
include('entities/base_wire_entity/init.lua') --Thanks to DuneD for this bit.

function ENT:Initialize()

	self:SetModel( "models/props_borealis/door_wheel001a.mdl" ) 
	self:SetName("Winch")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType(3)
	self.Inputs = Wire_CreateInputs( self, { "Length", "Unhook", "Speed", "Disconnect" } )
	self.Outputs = Wire_CreateOutputs( self, { "CurrentLength" })
		
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:SetMass(10)
	end
	self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self:GetPhysicsObject()
	
	--self.val1 = 0
	--RD_AddResource(self, "Munitions", 0)
	
	self.DLength = 0
	self.LChange = 0
	self.ReelRate = 10
end

function ENT:TriggerInput(iname, value)	
	if (iname == "Length") then
		self.DLength = math.Clamp(value, 10, 5000)
		self.LChange = CurTime()
		if value < 10 then
			self.Coupling = true
		end
		
	elseif (iname == "Disconnect") then
		if value > 0 then
			self.Disengaging = true
		else
			self.Disengaging = false
		end
		
	elseif (iname == "Speed") then
		self.ReelRate = math.Clamp(value, 0.01, 20)
		
	elseif (iname == "Unhook") then
		if value > 0 then
			self.Retracting = true
		else
			self.Retracting = false
		end
		
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	if self.Hook and self.Hook:IsValid() then
		Wire_TriggerOutput(self, "CurrentLength", self.Hook.CLength)
		if self.Hook.CLength <= 15 and self.Coupling and !self.Hook.Impact and !self.Hook.Active then
			if self.Hook.ICD < CurTime() then
				self.Hook:SetPos(self:GetPos() + self:GetForward() * 6)
				local NAng = self:GetAngles()
				NAng:RotateAroundAxis(NAng:Right(),-90)
				self.Hook:SetAngles(NAng)
				self.Hook.HWeld = constraint.Weld(self, self.Hook, 0, 0, 0, true)
				if self.Hook.Rope then
					self.Hook.Elastic:Fire("SetSpringLength",150,0)
					self.Hook.Rope:Fire("SetLength",150,0)
					self.Hook.CLength = 150
				end
				self.Coupling = false
			end
		end
		self.NHTime = CurTime() + 10
	else
		local ent = ents.Create( "SF-GrappleH" )
		ent:SetPos( self:GetPos() + self:GetUp() * 20 )
		ent:Spawn()
		ent:Activate()
		ent.SPL = ply
				
		local minMass = math.min( ent:GetPhysicsObject():GetMass(), self:GetPhysicsObject():GetMass() )
		local const = minMass * 100
		local damp = const * 0.2
		
		ent.Elastic, ent.Rope = constraint.Elastic( ent, self, 0, 0, Vector(-12,0,0), Vector(-3,0,0), const, damp, 0, "cable/rope", 2, true)
		ent.Elastic:Fire("SetSpringLength",150,0)
		ent.Rope:Fire("SetLength",150,0)
		
		ent.ParL = self
		ent.Standalone = true
		self.Hook = ent
	end
	
	self:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )
	self.Coupling = true
	self.DLength = 10
	self.LChange = CurTime()
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
	end
	if ent == self.Hook then
		if self.Hook.ICD < CurTime() then
			self.Hook:SetPos(self:GetPos() + self:GetForward() * 6)
			local NAng = self:GetAngles()
			NAng:RotateAroundAxis(NAng:Right(),-90)
			self.Hook:SetAngles(NAng)
			self.Hook.HWeld = constraint.Weld(self, self.Hook, 0, 0, 0, true)
			if self.Hook.Rope then
				self.Hook.Elastic:Fire("SetSpringLength",150,0)
				self.Hook.Rope:Fire("SetLength",150,0)
				self.Hook.CLength = 150
			end
			self.Coupling = false
		end
	end
end

function ENT:Latch( Hook, Vec, Ent )
	--Hook.Rope = constraint.Rope( self, Hook, 0, 0, Vector(33,0,0), Vector(0,0,0), self:GetPos():Distance(Hook:GetPos()), 0, 0, 2, "cable/rope", false)
	
	--This next bit mostly comes from the Wired Winches. Credit goes to whoever made them.
	--local minMass = math.min( self:GetPhysicsObject():GetMass(), Ent:GetPhysicsObject():GetMass() )
	--local const = minMass * 100
	--local damp = const * 0.2
	
	--Hook.Elastic, Hook.Rope = constraint.Elastic( self, Ent, 0, 0, Vector(0,0,0), Vec, const, damp, 0, "cable/rope", 2, true)
	
	--Hook.CLength = self:GetPos():Distance(Hook:GetPos())
end

function ENT:OnRemove()
	if self.Hook and self.Hook:IsValid() then
		self.Hook:Remove()
	end
end