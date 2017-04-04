local sndWaveBlast = Sound("ambient/levels/streetwar/city_battle11.wav")
local sndWaveIncoming = Sound("ambient/levels/labs/teleport_preblast_suckin1.wav")
local sndSplode = Sound("ambient/explosions/explode_6.wav")
local sndRumble = Sound("ambient/explosions/exp1.wav")
local sndPop = Sound("weapons/pistol/pistol_fire3.wav")


function ENT:Initialize()

self.Yield = (GetGlobalInt("nuke_yield") or 100)/100
self.SplodeDist = 1000
self.BlastSpeed = 4000
self.lastThink = CurTime() + 0.2
self.SplodeTime = self.lastThink + 7*self.Yield

	if self.Yield > 0.13 then

		self.HasPlayedIncomingSnd = false
		self.HasPlayedBlastSnd = false
		self.HasPlayedSlopdeSnd = false

		surface.PlaySound(sndRumble)

	else
	
		self.HasPlayedIncomingSnd = true
		self.HasPlayedBlastSnd = true
		self.HasPlayedSlopdeSnd = true
		self.SplodeTime = 0
		self.lastThink = CurTime() + 999
		
		timer.Simple(0.05, function() PlayPopSound(self.Entity) end)
	
	end

end


function ENT:Think()

	if CurTime() - self.lastThink < 0.1  then return end
	local FTime = CurTime() - self.lastThink
	self.lastThink = CurTime()

	self.SplodeDist = self.SplodeDist + self.BlastSpeed*FTime
	
	local EntPos = EntPos or self.Entity:GetPos()
	local CurDist = (EntPos - LocalPlayer():GetPos()):Length()

	if CurDist < 900 + self.BlastSpeed then
		self.HasPlayedIncomingSnd = true
	end
	
	if not self.HasPlayedSlopdeSnd then
		timer.Simple(CurDist/18e3, function() PlaySplodeSound(7e5/CurDist) end)
		self.HasPlayedSlopdeSnd = true
	end
	
	if self.lastThink < self.SplodeTime then
	
		if (not self.HasPlayedIncomingSnd) and self.SplodeDist + self.BlastSpeed*1.6 > CurDist then
			surface.PlaySound(sndWaveIncoming)
			self.HasPlayedIncomingSnd = true
		end
		
		if (not self.HasPlayedBlastSnd) and self.SplodeDist + self.BlastSpeed*0.2 > CurDist then
			surface.PlaySound(sndWaveBlast)
			self.HasPlayedBlastSnd = true
		end
	
	end

end



function PlaySplodeSound(volume)

	if volume > 400 then 
		surface.PlaySound(sndSplode)
		return
	end

	if volume < 60 then volume = 60 end

	LocalPlayer():EmitSound(sndSplode,volume,100)
	

end

function PlayPopSound(ent)

	ent:EmitSound(sndPop,500,100)

end


function ENT:Draw()

end

include('shared.lua')


