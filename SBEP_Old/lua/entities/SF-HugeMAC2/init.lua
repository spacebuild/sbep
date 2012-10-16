AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
util.PrecacheSound( "SB/Railgun.wav" )
util.PrecacheSound( "SB/Charging.wav" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Spacebuild/Nova/med-mac2.mdl" ) 
	self.Entity:SetName("Huge MAC")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, {  "ChargeCannon", "Fire" } )
		self.Outputs = WireLib.CreateOutputs( self, { "ChargeLevel", "CanFire" })
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
	
	self.val1 = 0
	--RD_AddResource(self.Entity, "energy", 0)

end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,300)
	
	local ent = ents.Create( "SF-HugeMAC2" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			if (CurTime() >= self.CDown and self.Charge >= 5000) then
				--if (self.val1 >= 1000) then
					local NewShell = ents.Create( "SF-HugeMACShell" )
					if ( !NewShell:IsValid() ) then return end
					NewShell:SetPos( self.Entity:GetPos() + (self.Entity:GetRight() * -200) )
					NewShell:SetAngles( (self.Entity:GetRight()*-1):Angle() )
					NewShell.SPL = self.SPL
					NewShell:Spawn()
					NewShell:Initialize()
					NewShell:Activate()
					NewShell:SetOwner(self)
					NewShell.PhysObj:SetVelocity(self.Entity:GetRight() * -10000)
					NewShell:Fire("kill", "", 30)
					NewShell.ParL = self.Entity
					self.Charge = 0
					self.CDown = CurTime() + 10
					local phys = self.Entity:GetPhysicsObject()  	
					if (phys:IsValid()) then  		
						phys:ApplyForceCenter( self.Entity:GetRight() * 10000 ) 
					end 
					
					--local effectdata = EffectData()
					--effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 150)
					--effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 150)
					--util.Effect( "Explosion", effectdata )
					self.Entity:EmitSound("SB/Railgun.wav", 500)
				--end
			end
		end
	elseif (iname == "ChargeCannon") then
		if ( value > 0 and CurTime() >= self.CDown ) then
			self.Charging = true
		else
			self.Charging = false
		end
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	--self.val1 = RD_GetResourceAmount(self.Entity, "energy")
	self.val1 = 10000
	
	if self.Charging and self.val1 > 100 and self.Charge <= 5100 and CurTime() >= self.CDown then
		--self.Entity:EmitSound("SB/Charging.wav", 150 )
		--RD_ConsumeResource(self.Entity, "energy", 100)
		self.Charge = self.Charge + 50
	else
		if self.Charge >= 10 then
			self.Charge = self.Charge - 5
		end
	end
	
	Wire_TriggerOutput(self.Entity, "ChargeLevel", self.Charge)
	
	if self.Charge >= 5000 and CurTime() >= self.CDown then
		Wire_TriggerOutput(self.Entity, "CanFire", 1)
	else
		Wire_TriggerOutput(self.Entity, "CanFire", 0)
	end
	
	if self.Charge > 0 then
		if CurTime() >= self.SpTime then
			self.SpTime = CurTime() + math.Rand( math.Clamp( (5000 - self.Charge) / 2, 0, 1), 1 )
			
			Sparky = ents.Create("point_tesla")
			Sparky:SetKeyValue("targetname", "teslab")
			Sparky:SetKeyValue("m_SoundName", "DoSpark")
			Sparky:SetKeyValue("texture", "sprites/physbeam.spr")
			Sparky:SetKeyValue("m_Color", "80 160 60")
			Sparky:SetKeyValue("m_flRadius", tostring(self.Charge / 10))
			Sparky:SetKeyValue("beamcount_min", tostring(math.ceil(self.Charge / 1000)))
			Sparky:SetKeyValue("beamcount_max", tostring(math.ceil(self.Charge / 1000)))
			Sparky:SetKeyValue("thick_min", tostring(math.ceil(self.Charge / 5000)))
			Sparky:SetKeyValue("thick_max", tostring(math.ceil(self.Charge / 1000)))
			Sparky:SetKeyValue("lifetime_min", "0.1")
			Sparky:SetKeyValue("lifetime_max", "0.2")
			Sparky:SetKeyValue("interval_min", "0.05")
			Sparky:SetKeyValue("interval_max", "0.08")
			Sparky:SetPos(self.Entity:GetPos() + (self.Entity:GetRight() * -math.Rand(-1347,120)) + (self.Entity:GetRight() * -math.Rand(-125,100)) + (self.Entity:GetForward() * -math.Rand(-90,90)) )
			Sparky:Spawn()
			Sparky:Fire("DoSpark","",0)
			Sparky:Fire("kill","", 2)
			
		end
	end
	
	if CurTime() <= self.CDown then
		if CurTime() >= self.SmTime then
			self.SmTime = CurTime() + math.Rand(0.2,1)
			local effectdata = EffectData()
			effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetRight() * -math.Rand(-1347,120))
			effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetRight() * -math.Rand(-1347,120))
			util.Effect( "MACSmokey", effectdata )
		end
	end
	
	self.Entity:SetBrightness( self.Charge / 1000 )
	
	self.Entity:NextThink( CurTime() + 0.1 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

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