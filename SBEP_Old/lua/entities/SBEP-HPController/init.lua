AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "k_lab.ambient_powergenerators" )
util.PrecacheSound( "ambient/machines/thumper_startup1.wav" )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/powercrystal.mdl" ) 
	self:SetName("GenericAircraft")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetMaterial("models/props_combine/combinethumper002");
	self.Inputs = Wire_CreateInputs( self, { "Hardpoints" } )
	self.Outputs = Wire_CreateOutputs( self, { "X", "Y", "Z", "HP1", "HP2", "HP3", "HP4", "HP5", "HP6", "HP7", "HP8", "HP9" })

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self:StartMotionController()
    self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self:GetPhysicsObject()
	self.BMode = false
	self.HPC = 0
	self.FTab = { self }
end


function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,20)
	
	local ent = ents.Create( "SBEP-HPController" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)
	
	if (iname == "Hardpoints") then
		if (value > 0) then
			self.HPC = math.Clamp( value, 0, 9 )
		end
		
	elseif (iname == "ButtonMode") then
		if (value > 0) then
			self.BMode = true
		else
			self.BMode = false
		end
	
		
	end
	
end

function ENT:Think()
	if self.Pod and self.Pod:IsValid() then
		
		local CHP = self.Pod:GetNetworkedInt( "HPC" )
		if CHP ~= self.HPC then
			self.Pod:SetNetworkedInt( "HPC", self.HPC )
		end
		
		self.CPL = self.Pod:GetPassenger()
		if (self.CPL and self.CPL:IsValid()) then
			self.Active = true			
			
			local trace = {}
			trace.start = self.CPL:GetShootPos()
			trace.endpos = self.CPL:GetShootPos() + self.CPL:GetAimVector() * 65535
			trace.filter = self.FTab
			local tr = util.TraceLine( trace )
			Wire_TriggerOutput(self, "X", tr.HitPos.x)
			Wire_TriggerOutput(self, "Y", tr.HitPos.y)
			Wire_TriggerOutput(self, "Z", tr.HitPos.z)
						
			for i = 1, self.HPC do
				local HPCP = self.CPL:GetInfo( "SBHP_"..i )
				local HPCA = self.CPL:GetInfo( "SBHP_"..i.."a" )
				if string.byte(HPCP) == 49 and self.CPL:KeyDown( IN_ATTACK ) then
					Wire_TriggerOutput(self, "HP"..i, 1)
				elseif string.byte(HPCA) == 49 and self.CPL:KeyDown( IN_ATTACK2 ) then
					Wire_TriggerOutput(self, "HP"..i, 1)
				else
					Wire_TriggerOutput(self, "HP"..i, 0)
				end
			end
			
			if ( self.CPL:KeyDown( IN_ATTACK ) and self.BMode ) then
				local trace = self.CPL:GetEyeTrace()
				if trace.Entity and trace.Entity:IsValid() then
					trace.Entity:Use(self.CPL, self.CPL)
				end				
			end
			
		end
	end

	self:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Link( hitEnt )
	if (hitEnt:IsVehicle()) then
		self.Pod = hitEnt
	end

end

function ENT:Touch( ent )
	if (ent:IsVehicle()) then
		self.Pod = ent
	end
end

function ENT:Use( activator, caller )
	local CEnts = constraint.GetAllConstrainedEntities( self )
	self.FTab = { self }
	for _, constr in pairs( CEnts ) do
		table.insert( self.FTab, constr.Entity )
	end
end

function ENT:OnRemove()
	self:StopSound( "k_lab.ambient_powergenerators" )
end

function ENT:PreEntityCopy()
	local DI = {}

	DI.LTab = {}
	for k,v in pairs(self.LTab) do
		DI.LTab[k] = v:EntIndex()
	end
	DI.Pod = self.Pod:EntIndex()
	
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self )
	end
	
	duplicator.StoreEntityModifier(self, "SBEPHPCont", DI)
end
duplicator.RegisterEntityModifier( "SBEPHPCont" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPHPCont

	if (DI.Pod) then
		self.Pod = CreatedEntities[ DI.Pod ]
		--[[local TB = self.Pod:GetTable()
		TB.HandleAnimation = function (vec, ply)
			return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) 
		end 
		self.Pod:SetTable(TB)
		self.Pod:SetKeyValue("limitview", 0)]]
	end
	self.LTab = self.LTab or {}
	for k,v in pairs(DI.LTab) do
		self.LTab[k] = CreatedEntities[ v ]
	end
	
	if(Ent.EntityMods and Ent.EntityMods.SBEPHPCont.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPHPCont.WireData, function(id) return CreatedEntities[id] end)
	end

end