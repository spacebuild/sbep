AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
util.PrecacheSound( "SB/RailgunLight.wav" )
util.PrecacheSound( "SB/Charging.wav" )

function ENT:Initialize()

	self:SetModel( "models/Spacebuild/Nova/macbig.mdl" ) 
	self:SetName("Light MAC")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self, {  "ChargeCannon", "Fire" } )
		self.Outputs = WireLib.CreateOutputs( self, { "ChargeLevel", "CanFire" })
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
	
	self.val1 = 0
	--RD_AddResource(self, "energy", 0)
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,300)
	
	local ent = ents.Create( "SF-MACLight" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			if (CurTime() >= self.CDown and self:GetNetworkedInt("Charge") >= 5000) then
				self:MACFire()
			end
		end
	elseif (iname == "ChargeCannon") then
		if ( value > 0 and CurTime() >= self.CDown ) then
			self:SetNetworkedBool("Charging",true)
		else
			self:SetNetworkedBool("Charging",false)
		end
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	local Charging = self:GetNetworkedBool("Charging")
	local Charge = self:GetNetworkedInt("Charge")
	--self.val1 = RD_GetResourceAmount(self, "energy")
	self.val1 = 10000
	
	if Charging and self.val1 > 100 and Charge <= 5100 and CurTime() >= self.CDown then
		--self:EmitSound("SB/Charging.wav", 150 )
		--RD_ConsumeResource(self, "energy", 100)
		Charge = Charge + 100
		self:SetNetworkedInt("Charge",Charge)
	else
		if Charge >= 10 then
			Charge = Charge - 10
			self:SetNetworkedInt("Charge",Charge)
		end
	end
	
	Wire_TriggerOutput(self, "ChargeLevel", Charge)
	
	if Charge >= 5000 and CurTime() >= self.CDown then
		Wire_TriggerOutput(self, "CanFire", 1)
	else
		Wire_TriggerOutput(self, "CanFire", 0)
	end
	
	if Charge > 0 then
		if CurTime() >= self.SpTime then
			self.SpTime = CurTime() + math.Rand( math.Clamp( (5000 - Charge) / 2, 0, 1), 1 )
			
			Sparky = ents.Create("point_tesla")
			Sparky:SetKeyValue("targetname", "teslab")
			Sparky:SetKeyValue("m_SoundName", "DoSpark")
			Sparky:SetKeyValue("texture", "sprites/physbeam.spr")
			Sparky:SetKeyValue("m_Color", "200 200 255")
			Sparky:SetKeyValue("m_flRadius", tostring(self.Charge / 10))
			Sparky:SetKeyValue("beamcount_min", tostring(math.ceil(self.Charge / 1000)))
			Sparky:SetKeyValue("beamcount_max", tostring(math.ceil(self.Charge / 1000)))
			Sparky:SetKeyValue("thick_min", tostring(math.ceil(self.Charge / 5000)))
			Sparky:SetKeyValue("thick_max", tostring(math.ceil(self.Charge / 1000)))
			Sparky:SetKeyValue("lifetime_min", "0.1")
			Sparky:SetKeyValue("lifetime_max", "0.2")
			Sparky:SetKeyValue("interval_min", "0.05")
			Sparky:SetKeyValue("interval_max", "0.08")
			Sparky:SetPos(self:GetPos() + (self:GetForward() * math.Rand(-566,160)) + (self:GetUp() * math.Rand(-65,55)) + (self:GetRight() * math.Rand(-55,55)) )
			Sparky:Spawn()
			Sparky:Fire("DoSpark","",0)
			Sparky:Fire("kill","", 1)
			
		end
	end
	
	if CurTime() <= self.CDown then
		if CurTime() >= self.SmTime then
			self.SmTime = CurTime() + math.Rand(0.2,1)
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos() +  self:GetForward() * math.Rand(-566,160))
			effectdata:SetStart(self:GetPos() +  self:GetForward() * math.Rand(-566,160))
			util.Effect( "MACSmokey", effectdata )
		end
	end
	
	self:SetBrightness( Charge / 1000 )
	
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
	local Charging = self:GetNetworkedBool("Charging")
	local Charge = self:GetNetworkedInt("Charge")
	if CurTime() >= self.CDown then
		if not Charging then
			self:SetNetworkedBool("Charging",true)
		else
			self:SetNetworkedBool("Charging",false)
		end
		if Charge >= 5000 then
			self:MACFire()
		end
		self.CDown = CurTime() + 10
	end
end

function ENT:MACFire()
--if (self.val1 >= 1000) then
	local NewShell = ents.Create( "SF-MACLightShell" )
	if ( !NewShell:IsValid() ) then return end
	NewShell:SetPos( self:GetPos() + (self:GetForward() * 165) )
	NewShell:SetAngles( self:GetAngles() )
	NewShell.SPL = self.SPL
	NewShell:Spawn()
	NewShell:Initialize()
	NewShell:Activate()
	NewShell:SetOwner(self)
	NewShell.PhysObj:SetVelocity(self:GetForward() * 10000)
	NewShell:Fire("kill", "", 30)
	NewShell.ParL = self
	self:SetNetworkedInt("Charge",0)
	self.CDown = CurTime() + 10
	local phys = self:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self:GetForward() * -10000 ) 
	end 
	
	--local effectdata = EffectData()
	--effectdata:SetOrigin(self:GetPos() +  self:GetUp() * 150)
	--effectdata:SetStart(self:GetPos() +  self:GetUp() * 150)
	--util.Effect( "Explosion", effectdata )
	self:EmitSound("SB/RailgunLight.wav", 500)
--end
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