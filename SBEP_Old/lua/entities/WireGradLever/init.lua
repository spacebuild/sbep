AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
util.PrecacheSound( "SB/Gattling2.wav" )

function ENT:Initialize()

	self:SetModel( "models/props_wasteland/tram_lever01.mdl" ) 
	self:SetName("Lever")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.Inputs = Wire_CreateInputs( self, { "Min", "Max" } )
	self.Outputs = Wire_CreateOutputs( self, { "Value" })
	
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
	
	self.MinV = 0
	self.MaxV = 1
	self.RTime = 0
	self.Angle = 0
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,70)
	
	local ent = ents.Create( "WireGradLever" )
	ent:SetPos( SpawnPos )
	--ent:SetModel( "models/props_wasteland/tram_lever01.mdl" ) 
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
		
	SpawnPos2 = SpawnPos + Vector(0,0,-20)
	
	ent2 = ents.Create( "prop_physics" )
	ent2:SetModel( "models/props_wasteland/tram_leverbase01.mdl" ) 
	ent2:SetPos( SpawnPos2 )
	ent2:Spawn()
	ent2:Activate()
	ent.Base = ent2
	
	--local LPos = ent:WorldToLocal(ent:GetPos() + ent:GetUp() * 10)
	--local Cons = constraint.Ballsocket( ent2, ent, 0, 0, LPos, 0, 0, 1)
	--LPos = ent:WorldToLocal(ent:GetPos() + ent:GetUp() * -10)
	--Cons = constraint.Ballsocket( ent2, ent, 0, 0, LPos, 0, 0, 1)
	
	constraint.Weld(ent, ent2, 0, 0, 0, true)
	
	ent:SetParent(ent2)
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Min") then
		self.MinV = value
		
	elseif (iname == "Max") then
		self.MaxV = value
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	if !self.Base or !self.Base:IsValid() then
		self:Remove()
		return
	end
	
	if self.CPL and self.CPL:IsValid() and ( self.CPL:KeyDown( IN_USE ) || self.CPL:KeyDown( IN_ATTACK ) ) and self.CPL:GetShootPos():Distance(self:GetPos()) < 200 then
		local Dist = self.CPL:GetShootPos():Distance( self.Base:GetPos() )
		local TargPos = self.CPL:GetShootPos() + self.CPL:GetAimVector() * Dist
		local FDist = TargPos:Distance( self.Base:GetPos() + self.Base:GetForward() * 30 )
		local BDist = TargPos:Distance( self.Base:GetPos() + self.Base:GetForward() * -30 )
		local FPos = (FDist - BDist) * 0.5
		FDist = TargPos:Distance( self.Base:GetPos() )
		BDist = TargPos:Distance( self.Base:GetPos() + self.Base:GetUp() * 40 )
		local HPos = 40 + (((BDist - FDist) * -0.5) - 20)
		
		self.Angle = math.Clamp( math.deg( math.atan2( HPos, FPos ) ) - 90, -45, 45 )
	else
		self.CPL = nil
	end
	
	local Val = Lerp( ( self.Angle + 45 ) / 90 , self.MinV , self.MaxV )
	Wire_TriggerOutput( self, "Value", Val )
	
	--print( Angle..", "..FPos..", "..HPos )
	
	local NAng = self.Base:GetAngles()
	NAng:RotateAroundAxis( NAng:Right(), -self.Angle )
	RAng = self.Base:WorldToLocalAngles(NAng)
	self:SetLocalPos( RAng:Up() * 20 )
	self:SetLocalAngles( RAng )

	self:NextThink( CurTime() + 0.01 ) 
	return true	
end

function ENT:OnRemove( ) 
	self.Base:Remove()
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( ply, caller )
	self.CPL = ply
	if self.RTime > CurTime() then
		--self.Angle = 0
		--self.CPL = nil
	end
	self.RTime = CurTime() + 0.5
end

function ENT:Touch( ent )
	if ent and ent:IsValid() and ent:IsVehicle() then
		self.CPod = ent
	end
end
