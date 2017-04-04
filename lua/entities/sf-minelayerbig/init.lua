AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/minelayer.mdl" ) 
	self.Entity:SetName("Big Minelayer")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, { "Fire", "Force"} )
	end
	
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
	
	self.MineProof = true
	self.LForce = 0
	
	self.CDL = {}
	self.CDL[1] = 0
	self.CDL[2] = 0
	self.CDL[3] = 0
	self.CDL[4] = 0
	self.CDL[5] = 0
	self.CDL[6] = 0


end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "SF-MineLayerBig" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			self.Entity:HPFire()
		end
	
	elseif (iname == "Force") then
		if (value > 0) then
			self.LForce = value
		end		
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	for n = 1, 6 do
		if (CurTime() >= self.CDL[n]) then
			if self.CDL[n.."r"] == false then
				self.CDL[n.."r"] = true
				self.Entity:EmitSound("Buttons.snd26")
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

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then
			HPLink( ent.Cont, ent.Entity, self.Entity ) 
			ent.Cont.MineProof = true
			ent.MineProof = true
		end
	end
end

function ENT:HPFire()
	if (CurTime() >= self.MCDown) then
		for n = 1, 6 do
			if (CurTime() >= self.CDL[n]) then
				self.Entity:FFire(n)
				return
			end
		end
	end
end

function ENT:LaunchMine( CCD, Offset )
	local NewShell = ents.Create( "SF-SpaceMine" )
	if ( !NewShell:IsValid() ) then return end
	NewShell:SetPos( self.Entity:LocalToWorld(Offset) )
	--NewShell:SetAngles( self.Entity:GetForward():Angle() )
	NewShell.SPL = self.SPL
	NewShell:Spawn()
	NewShell:Initialize()
	NewShell:Activate()
	NewShell:SetOwner(self)
	NewShell.PhysObj:SetVelocity(self.Entity:GetUp() * -self.LForce)
	--NewShell:Fire("kill", "", 30)
	NewShell.ParL = self.Entity
	--RD_ConsumeResource(self, "Munitions", 1000)
	self.CDL[CCD] = CurTime() + 6
	self.MCDown = CurTime() + 0.4
	self.Entity:EmitSound("Buttons.snd24")
	NewShell:GetPhysicsObject():EnableGravity(false)
	if self.Homer then NewShell.Homer = true end
	
	timer.Simple(2,function() if(NewShell:IsValid()) then NewShell:Arm() end 
	end)	
	--local effectdata = EffectData()
	--effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 14)
	--effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 14)
	--util.Effect( "Explosion", effectdata )
end

function ENT:FFire( CCD )
	self.Entity:LaunchMine( CCD, Vector(100, 100, -100) )
	self.Entity:LaunchMine( CCD, Vector(100, -100, -100) )
	self.Entity:LaunchMine( CCD, Vector(-100, 100, -100) )
	self.Entity:LaunchMine( CCD, Vector(-100, -100, -100) )
end

function ENT:PreEntityCopy()
	if WireAddon then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",WireLib.BuildDupeInfo(self.Entity))
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