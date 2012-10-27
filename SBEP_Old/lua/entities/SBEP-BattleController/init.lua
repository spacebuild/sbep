
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/powercrystal.mdl" ) 
	self:SetName("BattleComputer")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetMaterial("models/props_combine/combinethumper002");

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
	self.FTab = { self }
	self.ATog = false
end


function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "SBEP-BattleController" )
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
				
		self.CPL = self.Pod:GetPassenger()
		if (self.CPL and self.CPL:IsValid()) then
			self.Ready = true
			if self.Active then
				self.CPL:SetEyeAngles(Angle( 0, 90, 0))
			end		
			
			if (self.CPL:KeyDown( IN_JUMP )) then
				if !self.ATog then
					if self.Active then
						self.Active = false
						self:SetNetworkedBool( "BattleComputerActive", false )
						self.Pod:EmitSound( "Buttons.snd19" )
						--self.CPL:Freeze( false )
					else
						self.Active = true
						self:SetNetworkedBool( "BattleComputerActive", true )
						self.Pod:EmitSound( "Buttons.snd40" )
						--self.CPL:Freeze( true )
					end
				end
				self.ATog = true
			else
				self.ATog = false
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

function ENT:Touch( ent )
	if (ent:IsVehicle() and ent ~= self.Pod) then
		self.Pod = ent
		self.Pod:SetNetworkedEntity( "BattleComputer", self )
		self:SetNetworkedEntity( "BattleComputerPod", self.Pod )
	end
end
