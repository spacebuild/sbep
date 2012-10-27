AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
util.PrecacheSound( "NPC_Ministrider.FireMinigun" )
util.PrecacheSound( "WeaponDissolve.Dissolve" )

function ENT:Initialize()

	self:SetModel( "models/Slyfo_2/mini_turret_pulselaser.mdl" ) 
	self:SetName("TinyPulseCannon")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.Inputs = Wire_CreateInputs( self, { "Fire" } )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self:GetPhysicsObject()
	
	--self.val1 = 0
	--RD_AddResource(self, "Munitions", 0)
	
	self.FTime = 0
	self.NFTime = 0
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "SF-TinyPulseCannon" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			if !(self.Active == true or self.FTime > CurTime()) then
				self.NFTime = CurTime() + math.Rand(0,0.1)
			end
			self.Active = true
		else
			self.Active = false
		end

	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	if ((self.Active == true or self.FTime > CurTime()) and CurTime() >= self.NFTime ) then
	
		local NewShell = ents.Create( "SF-TinyPulseShot" )
		if ( !NewShell:IsValid() ) then return end
		NewShell:SetPos( self:GetPos() + (self:GetForward() * 60 ) )
		NewShell:SetAngles( self:GetForward():Angle() )
		NewShell.SPL = self.SPL
		NewShell:Spawn()
		NewShell:Initialize()
		NewShell:Activate()
		NewShell.PhysObj:SetVelocity(self:GetForward() * 7000)
		NewShell:Fire("kill", "", 1)
		NewShell.ParL = self
				
		self:EmitSound("NPC_Ministrider.FireMinigun")
		
		self.NFTime = CurTime() + 0.15
	end
	self:NextThink( CurTime() + 0.01 )
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
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
	end
end

function ENT:HPFire()
	if !(self.Active == true or self.FTime > CurTime()) then
		self.NFTime = CurTime() + math.Rand(0,0.1)
	end
	self.FTime = CurTime() + 0.1
end
