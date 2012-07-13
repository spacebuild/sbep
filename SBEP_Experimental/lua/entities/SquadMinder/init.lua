
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('entities/base_wire_entity/init.lua') --Thanks to DuneD for this bit.
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/util_tracker.mdl" ) 
	self.Entity:SetName("Squad")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local inNames = {"MaxSquadSize","ObjectiveType","ObjectiveVector","ObjectiveEnt"}
	local inTypes = {"NORMAL","NORMAL","VECTOR","NORMAL"}
	self.Inputs = WireLib.CreateSpecialInputs( self.Entity,inNames,inTypes)
	--self.Outputs = Wire_CreateOutputs( self.Entity, { "ShotsLeft", "CanFire" })
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
		
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
		phys:SetMass( 0.001 )
	end
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.Entity:SetNetworkedInt("Size", 50)
	
	self.ObjectiveType = 1
	self.ObjectiveVec = Vector(0,0,0)
	self.MVec = Vector(0,0,0)
	self.ObjectiveEnt = nil
	self.NSortTime = 0
	
	self.MaxSize = 7
end

function ENT:TriggerInput(iname, value)
	if (iname == "ObjectiveType") then
		if (value > 0) then
			self.ObjectiveType = value
		end
		
	elseif (iname == "ObjectiveVector") then
		self.ObjectiveVec = value
		self.ObjectiveType = 1
		
	elseif (iname == "MaxSquadSize") then
		self.MaxSize = math.Clamp(value,1,7)
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	if CurTime() >= self.NSortTime then
		if self.Members and type(self.Members) == "table" then
			if self.Members[1] ~= self.Alpha then
				print("The alpha ain't first")
				table.sort(self.Members, function(a, b) return a == self.Alpha end)
				for k,e in pairs(self.Members) do
					if e and e:IsValid() then
						--e.SquadNumber = k
					else
						table.remove(self.Members,k)
					end
				end
				for k,e in pairs(self.Members) do
					if e and e:IsValid() then
						e.SquadNumber = k
					end
				end
			end
		end
	end
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

end