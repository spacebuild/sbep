AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
include('nuke_vars_init.lua')


function ENT:Initialize()


	--performance variables
	self.WaveResolution = GetConVar("nuke_waveresolution"):GetInt() or 0.2
	self.IgnoreRagdoll = util.tobool(GetConVar("nuke_ignoreragdoll"):GetInt() or 1)
	self.BreakConstraints = util.tobool(GetConVar("nuke_breakconstraints"):GetInt() or 1)
	self.DoDisintegration = util.tobool(GetConVar("nuke_disintegration"):GetInt() or 1)
	self.EpicBlastWave = util.tobool(GetConVar("nuke_epic_blastwave"):GetInt() or 1)

	--We need to init physics properties even though this entity isn't physically simulated
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:DrawShadow( false )
	
	self.Entity:SetCollisionBounds( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )
	self.Entity:PhysicsInitBox( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableCollisions( false )		
	end

	self.Entity:SetNotSolid( true )
	util.PrecacheModel("models/player/charple01.mdl")

	self.Yield = (GetConVar("nuke_yield"):GetInt() or 100)/100
	self.YieldSlow = self.Yield^0.75
	self.YieldSlowest = self.Yield^0.5
	self.SplodePos = self.Entity:GetPos() + Vector(0,0,4)

	self.Owner = self.Entity:GetVar("owner",Entity(1))
	self.Weapon = self.Entity
	
	--remove this ent after awhile
	self.Entity:Fire("kill","",6*self.YieldSlow)
	
	local blastradius = 2300*self.YieldSlow
	if blastradius > 14000 then blastradius = 14000 end
	
	if self.Yield > 0.13 then
	
		--start the effect 
		local trace = {}
		trace.start = self.SplodePos 
		trace.endpos = trace.start - Vector(0,0,4096)
		trace.mask = MASK_SOLID_BRUSHONLY
	  
		local traceRes = util.TraceLine(trace)
		local ShortestTraceLength = 4096
		local LongOnes = 0
		
		--we need to do a lot of traces to see if we are on the ground or not
		for i=1,6 do
			for k=-1,1,2 do 
				for j=-1,1,2 do 
					local dist = k*i*j*120
					trace.start = self.SplodePos + Vector(dist,dist,0)
					trace.endpos = trace.start - Vector(dist,dist,4096)
					traceRes = util.TraceLine(trace)
					local TraceLength = traceRes.Fraction*4096
					
					if TraceLength < ShortestTraceLength then --we need to find the closest distance to the ground, so we know where to spawn our nuke
						ShortestTraceLength = TraceLength
					end
					
					if TraceLength > 2048 then
						LongOnes = LongOnes + 1 --we need to see how many of them are long and how many were short to determine if we are in the air or on the ground
					end
				end
			end
		end
		
		local effectdata = EffectData()
		effectdata:SetMagnitude( self.Yield )
		
		if LongOnes > 10 then --if there are more than 10 long traces, we are probably in the air
		
			trace.start = self.SplodePos
			trace.endpos = trace.start - Vector(0,0,23000)
			traceRes = util.TraceLine(trace) --do one more trace to see how high up we really are
		
			effectdata:SetOrigin( self.SplodePos )
			effectdata:SetScale( traceRes.Fraction*23000 )
			util.Effect( "nuke_effect_air", effectdata )
		else --otherwise, we are probably on the ground
			self.SplodePos.z = self.SplodePos.z - ShortestTraceLength
			effectdata:SetOrigin( self.SplodePos )
			effectdata:SetScale( ShortestTraceLength )
			util.Effect( "nuke_effect_ground", effectdata )	
			if self.EpicBlastWave then
				util.Effect( "nuke_blastwave", effectdata )	
			else
				util.Effect( "nuke_blastwave_cheap", effectdata )
			end
		end
		
		--nuke 'em
		self.SplodePos.z = self.SplodePos.z + 384

		for key,found in pairs(ents.FindInSphere(self.SplodePos,blastradius)) do
			
			local foundspecs = self:GetSpecs(found)
			if foundspecs.valid then		
				if foundspecs.npc then
					if self.DoDisintegration then
					
						local effectdata = EffectData()
						effectdata:SetEntity(found)
						util.Effect("nuke_vaporize",effectdata)
						
						found:Fire("kill","","0.1")
                        --self.Owner:AddFrags(1)
					
					else
					
					local entpos = found:GetPos()
					
						if foundspecs.humanoid then
						
							local effectdata = EffectData()
							effectdata:SetOrigin(entpos)
							effectdata:SetNormal(Vector(0,0,1))
							util.Effect( "nuke_disintegrate", effectdata )
							
							found:SetModel("models/player/charple01.mdl")
							
						end
						local attacker
						if IsValid(self.Owner) then attacker = self.Owner
						else attacker = self end
						util.BlastDamage(self, attacker, entpos, 256, 512)
					end
				
				elseif foundspecs.player then
				
					local entpos = found:GetPos()
				
					local effectdata = EffectData()
					effectdata:SetOrigin(entpos)
					effectdata:SetNormal(Vector(0,0,1))
					util.Effect( "nuke_disintegrate", effectdata )
					
					found:SetModel("models/player/charple01.mdl")
					local attacker
					if IsValid(self.Owner) then attacker = self.Owner
					else attacker = self end
                    util.BlastDamage(self, attacker, entpos, 256, 512)
					
					if found == self.Owner then
						--self.Owner:AddFrags(-1)
					else
						--self.Owner:AddFrags(1)
					end
				
				end
			
			end
			
		end
		
		--radiation
		local radiation = ents.Create("sent_nuke_radiation")
		radiation:SetOwner(self.Owner)
		radiation:SetVar("owner",self.Owner)
		radiation:SetPos(self.SplodePos)
		radiation:Spawn()
	
		--earthquake
		local shake = ents.Create("env_shake")
		shake:SetKeyValue("amplitude", "16")
		shake:SetKeyValue("duration", 6*self.YieldSlow)
		shake:SetKeyValue("radius", 16384) 
		shake:SetKeyValue("frequency", 230)
		shake:SetPos(self.SplodePos)
		shake:Spawn()
		shake:Fire("StartShake","","0.6")
		shake:Fire("kill","","8")
		
		--shatter glass
		for k,v in pairs(ents.FindByClass("func_breakable_surf")) do
			local dist = (v:GetPos() - self.SplodePos):Length()
			if dist < 7*blastradius then
				v:Fire("Shatter","",dist/17e3)
			end
		end
		
		for k,v in pairs(ents.FindByClass("func_breakable")) do
			local dist = (v:GetPos() - self.SplodePos):Length()
			if dist < 7*blastradius then
				v:Fire("break","",dist/17e3)
			end
		end
	else
	
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetNormal( Vector(0,0,1) )
		effectdata:SetMagnitude( 1 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 1 )
	
		if self.Yield < 0.04 then
			util.Effect( "StunstickImpact", effectdata )
			util.Effect( "Impact", effectdata )
			util.Effect( "ManhackSparks", effectdata )
			util.Effect( "WheelDust", effectdata )
		else
			util.Effect( "Explosion", effectdata )
		end
	
	self.TimeLeft = CurTime() - 1
	self.DrawFX = false
	
	end
	
	timer.Simple(0.2, function()
		local attacker
		if IsValid(self.Owner) then attacker = self.Owner
		else attacker = self end
		util.BlastDamage(self, attacker, self.SplodePos, blastradius, 4096*self.Yield)
	end)
	
	self.SplodeDist = 100
	self.BaseDamage = (GetConVarNumber("nuke_damage") or 100)*1.5e9*self.Yield
	self.BlastSpeed = 4000
	self.lastThink = CurTime() + 0.2
	self.SplodeTime = self.lastThink + 5*self.Yield
	self.Sploding = true

end


function ENT:Think()

if not self.Sploding then return end

local CurrentTime = CurTime()
local FTime = CurrentTime - self.lastThink

	if FTime < self.WaveResolution then return end
	
	self.SplodeDist = self.SplodeDist + self.BlastSpeed*(FTime)
	self.lastThink = CurrentTime
	
		if self.SplodeTime < CurrentTime then
		self.SplodeTime = 0
		self.SplodeDist = 100
		self.Sploding = false
		end
		
	for key,found in pairs(ents.FindInSphere(self.SplodePos,self.SplodeDist)) do

		local EntSpecs = self:GetSpecs(found)
		if EntSpecs.valid then
			local entpos = EntSpecs.ent:LocalToWorld(EntSpecs.ent:OBBCenter()) --more accurate than getpos
	
			if self:LOS(EntSpecs.ent,entpos) then --we have line-of-sight!
			
				local vecang = entpos - self.SplodePos
				if vecang.z < 0 then vecang.z = 0 end
				vecang:Normalize()
				local DamagePerSecond = self.BaseDamage/(4*math.pi*self.SplodeDist^2) --physics, bitch
				local Damage = DamagePerSecond*FTime
				
				if DamagePerSecond >= 250  then
				
					if EntSpecs.humanoid then --if we've hit a human
						local effectdata = EffectData()
						effectdata:SetOrigin(entpos)
						effectdata:SetNormal(vecang)
						util.Effect( "nuke_disintegrate", effectdata )
						
						EntSpecs.ent:SetModel("models/player/charple01.mdl") --burn it
						EntSpecs.ent:SetHealth(1)
				
					elseif EntSpecs.type == "npc_strider" then --if we've hit a strider...
						EntSpecs.ent:Fire("break","","0.3") --asplode it
					end

				end
				
				if self.BreakConstraints and string.find(EntSpecs.type,"prop") ~= nil then
					EntSpecs.ent:Fire("enablemotion","",0) --bye bye fort that took you 4 hours to make
					constraint.RemoveAll(EntSpecs.ent)
				end
				
				local physobj = EntSpecs.ent:GetPhysicsObject()
				
				if EntSpecs.movetype ~= 6 or not physobj:IsValid() then --if it's not a physics object...
					EntSpecs.ent:SetVelocity(vecang*(100*Damage)) --push it away
				elseif EntSpecs.ragdoll then --if it's a ragdoll...
					physobj:ApplyForceCenter(vecang*(8e4*Damage)) --push it away anyway :D
				else -- if it is a physics object...
					physobj:ApplyForceOffset(vecang*(8e4*Damage),entpos + Vector(math.random(-20,20),math.random(-20,20),math.random(20,40))) --still push it away
				end
				
				local attacker
				if IsValid(self.Owner) then attacker = self.Owner
				else attacker = self end
				util.BlastDamage(self, attacker, entpos - vecang*64, 384, Damage) --splode it
				
			end
		end
	end

end


local HumanModels = {

"[Ss]oldier",
"models/zombie",
"models/player/",
"models/Humans/",
"[Pp]olice.mdl",
"[Aa]lyx.mdl",
"[Bb]arney.mdl",
"[Bb]reen.mdl",
"[Ee]li.mdl",
"[Mm]onk.mdl",
"[Kk]leiner.mdl",
"[Mm]ossman.mdl",
"[Oo]dessa.mdl",
"[Gg]man"

}


function ENT:GetSpecs(entity)

	local enttable = {}
	enttable.ent = entity
	enttable.player = false
	enttable.npc = false
	enttable.humanoid = false
	enttable.ragdoll = false
	enttable.type = ""

	if (not entity:IsValid()) then
		enttable.valid = false
		enttable.movetype = 0
		return enttable
	end

	enttable.movetype = entity:GetMoveType()
	enttable.valid = (enttable.movetype == 2 or enttable.movetype == 3 or enttable.movetype == 5 or enttable.movetype == 6 or enttable.movetype == 9)

	if not enttable.valid then return enttable end

	enttable.type = entity:GetClass()
	enttable.ragdoll = string.find(enttable.type,"ragdoll") ~= nil

	if self.IgnoreRagdoll and enttable.ragdoll then
		enttable.valid = false
		return enttable
	end

	enttable.player = entity:IsPlayer()
	if enttable.player then
		enttable.humanoid = true
		return enttable
	end

	enttable.npc = entity:IsNPC()
	if enttable.npc then
		local entmodel = entity:GetModel()
		if entmodel then
			for k,model in pairs(HumanModels) do
				if string.find(entmodel,model) ~= nil then
					enttable.humanoid = true
					break
				end
			end
		end
	end

	
	return enttable

end

function ENT:LOS(ent,entpos)

	local trace = {}
	trace.start = self.SplodePos
	trace.endpos = entpos
	local traceRes = util.TraceLine(trace)
	
	if (traceRes.Entity ~= ent) and math.abs(self.SplodePos.z - entpos.z) < 800*self.Yield then
		trace.start = Vector(self.SplodePos.x,self.SplodePos.y,entpos.z)
		traceRes = util.TraceLine(trace)
	end

return (traceRes.Entity == ent)

end


