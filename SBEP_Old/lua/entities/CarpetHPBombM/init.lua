AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

util.PrecacheSound( "Buttons.snd26" )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/swordreconlauncher.mdl" )
	self:SetName("CarpetBombMount")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetMaterial("models/props_combine/combinethumper002")
	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, { "Drop" } )
	end
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end

    --self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	
	self.CBCount = 0
	self.LBomb = nil
	self.Ready = true
	self.MCDown = 0
	self.BTime = 0
end

function ENT:TriggerInput(iname, value)		
	
	if (iname == "Drop") then
		if (value > 0) then
			self:HPFire()
		end
	end
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "CarpetHPBombM" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Think()
	if !self.Ready then
		if CurTime() > self.MCDown then
			self.Ready = true
			self:EmitSound("Buttons.snd26")
			--self:SetColor(Color(255,255,255,255))
		end
	end
	if self.CBCount > 0 and CurTime() > self.BTime then
		self:BombDrop()
		self.CBCount = self.CBCount - 1
		self.BTime = CurTime() + 0.2
	end
	
	self:NextThink( CurTime() + 0.1 )
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
	if CurTime() > self.MCDown then
		self.CBCount = 20
		self.MCDown = CurTime() + 10
		--self:SetColor(Color(255,255,255,1))
	end
end

function ENT:BombDrop()
	local NewShell = ents.Create( "CarpetHPBomb" )
	if ( !NewShell:IsValid() ) then return end
	NewShell:SetPos( self:GetPos() + (self:GetUp() * -60 ) + self:GetForward() * math.random(-25,25) + self:GetRight() * math.random(-25,25) )
	NewShell:SetAngles( self:GetAngles() )
	NewShell.SPL = self.SPL
	NewShell:Spawn()
	NewShell:Initialize()
	NewShell:Activate()
	NewShell:SetOwner(self)
	NewShell:GetPhysicsObject():SetVelocity((self:GetPhysicsObject():GetVelocity() * 0.5) + self:GetUp() * -100)
	NewShell:Fire("kill", "", 10)
	NewShell.Armed = false
	NewShell:GetPhysicsObject():EnableCollisions(false)
	timer.Simple(1,function()
		if NewShell:IsValid() then
		NewShell:GetPhysicsObject():EnableCollisions(true)
		NewShell.Armed = true
		end
	 end)
	self.Ready = false
end

function ENT:PreEntityCopy()
	if WireAddon then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",WireLib.BuildDupeInfo(self))
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