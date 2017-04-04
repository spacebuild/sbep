
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
util.PrecacheSound( "SB/Gattling2.wav" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo_2/mini_turret_flamer.mdl" ) 
	self.Entity:SetName("SmallFlamer")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire" } )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	--self.val1 = 0
	--RD_AddResource(self.Entity, "Munitions", 0)

	self.NFTime = 0
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "SF-TinyFlamer" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			self.Active = true
		else
			self.Active = false
		end
			
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	
	if (self.Active == true or self.FTime > CurTime() ) then
		self:SetActive(true)
		if CurTime() >= self.NFTime then
			/*
			NewShell = ents.Create( "FlameGout" )
			if ( !NewShell:IsValid() ) then return end
			NewShell:SetPos( self.Entity:GetPos() + (self:GetForward() * 30) )
			NewShell:SetName("FlamingDeath")
			NewShell.SPL = self.SPL
			NewShell:Spawn()
			NewShell:Initialize()
			NewShell:Activate()
			local SSpeed = 10
			NewShell:GetPhysicsObject():SetVelocity((self.Entity:GetPhysicsObject():GetVelocity() * 0.25) + (self.Entity:GetRight() * math.random(-SSpeed,SSpeed)) + (self.Entity:GetUp() * math.random(-SSpeed,SSpeed))  + (self.Entity:GetForward() * 500)  )
			*/
			for i = 1,6 do
				local Dist = i * math.Rand(65,85)
				util.BlastDamage(self.SPL, self.SPL, self:GetPos() + (self:GetForward() * Dist), (Dist * 0.3) + 40, math.Clamp((320 - Dist) * 0.1,1,100))
				--print((320 - Dist) * 0.1)
				--print((Dist * 0.3) + 40)
			end
			self.NFTime = CurTime() + 0.1
		end
	else
		self:SetActive(false)
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
	self.FTime = CurTime() + 0.1
end