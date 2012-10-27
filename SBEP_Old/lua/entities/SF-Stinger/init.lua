AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
--util.PrecacheSound( "NPC_Ministrider.FireMinigun" )
--util.PrecacheSound( "WeaponDissolve.Dissolve" )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/rover_stinger.mdl" ) 
	self:SetName("Stinger Mortar")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, { "Fire" } )
	end
	
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
	
	self.CDL = {}
	self.CDL[1] = 0
	self.CDL[2] = 0
	self.CDL[3] = 0
	self.CDL[4] = 0
	self.CDL[5] = 0
	self.CDL[6] = 0
	self.CDL[7] = 0
	self.CDL[8] = 0
	self.CDL[9] = 0
	self.CDL[10] = 0
	self.CDL["1r"] = true
	self.CDL["2r"] = true
	self.CDL["3r"] = true
	self.CDL["4r"] = true
	self.CDL["5r"] = true
	self.CDL["6r"] = true
	self.CDL["7r"] = true
	self.CDL["8r"] = true
	self.CDL["9r"] = true
	self.CDL["10r"] = true
	self:SetNetworkedInt("Shots",10)
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "SF-Stinger" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			self:HPFire()
		end
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	local MCount = 0
	for n = 1, 10 do
		if (CurTime() >= self.CDL[n]) then
			if self.CDL[n.."r"] == false then
				self.CDL[n.."r"] = true
				self:EmitSound("Buttons.snd26")
			end
			MCount = MCount + 1
		end
	end
	self:SetShots(MCount)
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
		for n = 1, 10 do
			if (CurTime() >= self.CDL[n]) then
				self:FFire(n)
				return
			end
		end
	end
end

function ENT:FFire( CCD )
	local NewShell = ents.Create( "SF-MortarShell" )
	if ( !NewShell:IsValid() ) then return end
	local CVel = self:GetPhysicsObject():GetVelocity():Length()
	NewShell:SetPos( self:GetPos() + (self:GetUp() * 10) + (self:GetForward() * (115 + CVel)) )
	NewShell:SetAngles( self:GetAngles() )
	NewShell.SPL = self.SPL
	NewShell:Spawn()
	NewShell:Initialize()
	NewShell:Activate()
	NewShell:GetPhysicsObject():EnableGravity(true)
	NewShell:GetPhysicsObject():EnableDrag(true)
	NewShell:SetOwner(self)
	NewShell.PhysObj:SetVelocity(self:GetForward() * 5000)
	NewShell:Fire("kill", "", 30)
	NewShell.ParL = self
	--RD_ConsumeResource(self, "Munitions", 1000)
	self:EmitSound("Weapon_GrenadeLauncher.Single")
	self.MCDown = CurTime() + 0.1 + math.Rand(0,0.2)
	self.CDL[CCD] = CurTime() + 6
	self.CDL[CCD.."r"] = false
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