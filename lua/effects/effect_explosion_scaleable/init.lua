
local tMats = {}
tMats.Glow1 = CreateMaterial("glow1", "UnlitGeneric", {["$basetexture"] = "sprites/light_glow02", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
tMats.Glow2 = CreateMaterial("glow2", "UnlitGeneric", {["$basetexture"] = "sprites/flare1", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})

--[[for _,mat in pairs(tMats) do
	mat:SetInt("$spriterendermode",9)
	mat:SetInt("$ignorez",1)
	mat:SetInt("$illumfactor",8)
	mat:SetInt("$vertexcolor",1)
	mat:SetInt("$vertexalpha",1)
end]]--

local SmokeParticleUpdate = function(particle)

	if particle:GetStartAlpha() == 0 and particle:GetLifeTime() >= 0.5*particle:GetDieTime() then
		particle:SetStartAlpha(particle:GetEndAlpha())
		particle:SetEndAlpha(0)
		particle:SetNextThink(-1)
	else
		particle:SetNextThink(CurTime() + 0.1)
	end

	return particle

end


function EFFECT:Init(data)

	self.Scale = data:GetScale()
	self.ScaleSlow = math.sqrt(self.Scale)
	self.ScaleSlowest = math.sqrt(self.ScaleSlow)
	self.Normal = data:GetNormal()
	self.RightAngle = self.Normal:Angle():Right():Angle()
	self.Position = data:GetOrigin() - 12*self.Normal
	self.Position2 = self.Position + self.Scale*64*self.Normal

	local CurrentTime = CurTime()
	self.Duration = 0.5*self.Scale 
	self.KillTime = CurrentTime + self.Duration
	self.GlowAlpha = 200
	self.GlowSize = 100*self.Scale
	self.FlashAlpha = 100
	self.FlashSize = 0

	local emitter = ParticleEmitter(self.Position)
	if emitter then

	--fire ball
		for i=1,math.ceil(self.Scale*12) do
			
			local vecang = (self.Normal + VectorRand()*math.Rand(0,0.7)):GetNormalized()
			local velocity = math.Rand(700,1100)*vecang*self.Scale
			local particle = emitter:Add("effects/fire_cloud"..math.random(1,2), self.Position + vecang*math.Rand(0,70)*self.Scale)
			particle:SetVelocity(velocity)
			particle:SetGravity(VectorRand()*math.Rand(200,400) + Vector(0,0,math.Rand(500,700)))
			particle:SetAirResistance(250)
			particle:SetDieTime(math.Rand(0.7,1.1)*self.Scale)
			particle:SetStartAlpha(math.Rand(230,250))
			particle:SetStartSize(math.Rand(110,140)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(150,190)*self.ScaleSlow)
			particle:SetRoll(math.Rand(150,180))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(Color(255,255,255))

		end
		
	--fire puff
		for i=1,math.ceil(self.Scale*25) do
		
			local vecang = self.RightAngle
			vecang:RotateAroundAxis(self.Normal,math.Rand(0,360))
			vecang = vecang:Forward() + VectorRand()*0.1
			local velocity = math.Rand(256,1800)*vecang
			local particle = emitter:Add("effects/fire_cloud"..math.random(1,2), self.Position + vecang*16*self.Scale)
			particle:SetVelocity(velocity*self.Scale)
			particle:SetGravity(VectorRand()*math.Rand(200,400))
			particle:SetAirResistance(300)
			particle:SetDieTime(math.Rand(0.6,0.8)*self.Scale)
			particle:SetStartAlpha(math.Rand(230,250))
			particle:SetStartSize(math.Rand(100,130)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(140,180)*self.ScaleSlow)
			particle:SetRoll(math.Rand(150,180))
			particle:SetRollDelta(0.4*math.random(-1,1))
			particle:SetColor(Color(255,255,255))
			
		end
		
	--fire burst
		for i=1,math.ceil(self.Scale*8) do
			
			local vecang = (self.Normal + VectorRand()*math.Rand(0.5,1.5)):GetNormalized()
			local velocity = math.Rand(1200,1400)*vecang*self.Scale
			local particle = emitter:Add("effects/fire_cloud"..math.random(1,2), self.Position - vecang*32*self.Scale)
			particle:SetVelocity(velocity)
			particle:SetDieTime(math.Rand(0.26,0.4))
			particle:SetStartAlpha(math.Rand(230,250))
			particle:SetStartSize(math.Rand(30,40)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(40,50)*self.ScaleSlow)
			particle:SetStartLength(math.Rand(370,400)*self.ScaleSlow)
			particle:SetEndLength(math.Rand(40,50)*self.ScaleSlow)
			particle:SetColor(Color(255,255,255))

		end
		
	--embers
		for i=1,math.ceil(self.Scale*18) do
			
			local vecang = (self.Normal + VectorRand()*math.Rand(0.2,1.2)):GetNormalized()
			local particle = emitter:Add("effects/fire_embers"..math.random(1,3), self.Position + vecang*math.random(80,240)*self.ScaleSlow)
			particle:SetVelocity(VectorRand()*math.Rand(32,96))
			particle:SetAirResistance(1)
			particle:SetDieTime(math.Rand(2,2.4)*self.ScaleSlow)
			particle:SetStartAlpha(math.Rand(250,255))
			particle:SetStartSize(math.Rand(16,21)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(16,21)*self.ScaleSlow)
			particle:SetColor(Color(255,255,255))

		end
		
	--flying embers	
		for i=1,math.ceil(math.Rand(10,16)*self.ScaleSlow) do
			
			local vecang = (self.Normal + VectorRand()*math.Rand(0,2.5)):GetNormalized()
			local particle = emitter:Add("effects/fire_embers"..math.random(1,3), self.Position + vecang*64*self.Scale)
			particle:SetVelocity(vecang*math.Rand(350,800)*self.ScaleSlow)
			particle:SetGravity(Vector(0,0,-600))
			particle:SetAirResistance(1)
			particle:SetDieTime(math.Rand(1.9,2.3)*self.ScaleSlow)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.Rand(11,15)*self.ScaleSlow)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(150,170))
			particle:SetRollDelta(0.7*math.random(-1,1))
			particle:SetCollide(true)
			particle:SetBounce(0.9)
			particle:SetColor(Color(255,180,100))


		end

	--dust puff
		for i=1,math.ceil(self.Scale*57) do

			local vecang = self.RightAngle
			vecang:RotateAroundAxis(self.Normal,math.Rand(0,360))
			vecang = vecang:Forward() + VectorRand()*0.1
			local velocity = math.Rand(1200,2800)*vecang
			local particle = emitter:Add("particle/particle_smokegrenade", self.Position - vecang*64*self.Scale - self.Normal*32)
			local dietime = math.Rand(2.5,2.9)*self.Scale
			particle:SetVelocity(velocity*self.Scale)
			particle:SetGravity((self.Normal - 1.3e-3*velocity):GetNormalized()*200)
			particle:SetAirResistance(250)
			particle:SetDieTime(dietime)
			particle:SetLifeTime(math.Rand(-0.12,-0.08))
			particle:SetStartAlpha(0)
			particle:SetEndAlpha(200)
			particle:SetThinkFunction(SmokeParticleUpdate)
			particle:SetNextThink(CurrentTime + 0.5*dietime)
			particle:SetStartSize(math.Rand(90,110)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(130,150)*self.ScaleSlow)
			particle:SetRoll(math.Rand(150,180))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(Color(152,142,126))
			
		end
		
	--pillar of dust
		for i=1,math.ceil(self.Scale*12) do

			local vecang = (self.Normal + VectorRand()*math.Rand(0,0.5)):GetNormalized()
			local velocity = math.Rand(-300,500)*vecang*self.Scale
			local particle = emitter:Add("particle/particle_smokegrenade", self.Position + vecang*math.Rand(-50,75)*self.Scale)
			local dietime = math.Rand(2.8,3.4)*self.Scale
			particle:SetVelocity(velocity)
			particle:SetGravity(Vector(0,0,math.Rand(50,250)))
			particle:SetAirResistance(65)
			particle:SetDieTime(dietime)
			particle:SetLifeTime(math.Rand(-0.12,-0.08))
			particle:SetStartAlpha(0)
			particle:SetEndAlpha(200)
			particle:SetThinkFunction(SmokeParticleUpdate)
			particle:SetNextThink(CurrentTime + 0.5*dietime)
			particle:SetStartSize(math.Rand(90,140)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(240,280)*self.ScaleSlow)
			particle:SetRoll(math.Rand(150,170))
			particle:SetRollDelta(0.7*math.random(-1,1))
			particle:SetColor(Color(152,142,126))
			
		end
		
	--dust cloud
		for i=1,math.ceil(self.Scale*8) do

			local vecang = (self.Normal + VectorRand()*math.Rand(0.3,0.7)):GetNormalized()
			local velocity = math.Rand(150,300)*vecang*self.Scale
			local particle = emitter:Add("particle/particle_smokegrenade", self.Position + vecang*math.Rand(20,80)*self.Scale)
			local dietime = math.Rand(2.9,3.5)*self.Scale
			particle:SetVelocity(velocity)
			particle:SetGravity(Vector(0,0,math.Rand(200,240)))
			particle:SetAirResistance(65)
			particle:SetDieTime(dietime)
			particle:SetLifeTime(math.Rand(-0.2,-0.15))
			particle:SetStartAlpha(0)
			particle:SetEndAlpha(200)
			particle:SetThinkFunction(SmokeParticleUpdate)
			particle:SetNextThink(CurrentTime + 0.5*dietime)
			particle:SetStartSize(math.Rand(90,140)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(240,280)*self.ScaleSlow)
			particle:SetRoll(math.Rand(180,200))
			particle:SetRollDelta(0.85*math.random(-1,1))
			particle:SetColor(Color(152,142,126))
			
		end
		
	--dirt
		for i=1,math.ceil(math.Rand(9,13)*self.ScaleSlow) do
			
			local vecang = (self.Normal + VectorRand()*math.Rand(0,3)):GetNormalized()
			local particle = emitter:Add("effects/fleck_cement"..math.random(1,2), self.Position + vecang*64*self.Scale)
			local size = math.Rand(5,9)
			particle:SetVelocity(vecang*math.Rand(600,1100)*self.ScaleSlow)
			particle:SetGravity(Vector(0,0,-600))
			particle:SetAirResistance(1)
			particle:SetDieTime(math.Rand(2.8,3.5)*self.ScaleSlow)
			particle:SetStartAlpha(math.Rand(140,170))
			particle:SetEndAlpha(0)
			particle:SetStartSize(size)
			particle:SetEndSize(size)
			particle:SetRoll(math.Rand(400,500))
			particle:SetRollDelta(math.Rand(-24,24))
			particle:SetCollide(true)
			particle:SetBounce(0.9)
			particle:SetColor(Color(173,160,143) )

		end
		

		if self.Scale > 6 then
		
		--shock wave
			for i=1,math.ceil(self.Scale*55) do

				local vecang = Vector(math.Rand(-1,1),math.Rand(-1,1),0):GetNormalized()
				local velocity = math.Rand(8900,9100)*vecang
				local particle = emitter:Add("sprites/heatwave", self.Position - vecang*64*self.Scale - Vector(0,0,80*self.ScaleSlowest))
				local dietime = 0.08*self.Scale
				particle:SetVelocity(velocity)
				particle:SetDieTime(dietime)
				particle:SetLifeTime(0)
				particle:SetStartAlpha(60)
				particle:SetEndAlpha(0)
				particle:SetStartSize(160*self.ScaleSlowest)
				particle:SetEndSize(200*self.ScaleSlowest)
				particle:SetColor(Color(255,255,255))
				
			end
		
		end

	emitter:Finish()
	end
	
	if self.Scale > 4 then
		surface.PlaySound("ambient/explosions/explode_8.wav")
		self.Entity:EmitSound("ambient/explosions/explode_4.wav")

	elseif self.Scale > 11 then
		surface.PlaySound("ambient/explosions/explode_8.wav")
		self.Entity:EmitSound("ambient/explosions/explode_1.wav")
	
	elseif self.Scale > 23 then
		surface.PlaySound("ambient/explosions/exp1.wav")
		surface.PlaySound("ambient/explosions/explode_4.wav")
		
	elseif self.Scale > 35 then
		surface.PlaySound("ambient/explosions/exp2.wav")
		surface.PlaySound("ambient/explosions/explode_6.wav")
	
	else
		self.Entity:EmitSound("ambient/explosions/explode_4.wav")
	end
	
end


--THINK
-- Returning false makes the entity die
function EFFECT:Think()
	local TimeLeft = self.KillTime - CurTime()
	local TimeScale = TimeLeft/self.Duration
	local FTime = FrameTime()
	if TimeLeft > 0 then 

		self.FlashAlpha = self.FlashAlpha - 200*FTime
		self.FlashSize = self.FlashSize + 60000*FTime
		
		self.GlowAlpha = 200*TimeScale
		self.GlowSize = TimeLeft*self.Scale

		return true
	else
		return false	
	end
end


-- Draw the effect
function EFFECT:Render()

--base glow
render.SetMaterial(tMats.Glow1)
render.DrawSprite(self.Position2,7000*self.GlowSize,5500*self.GlowSize,Color(255,240,220,self.GlowAlpha))

--blinding flash
	if self.FlashAlpha > 0 then
		render.SetMaterial(tMats.Glow2)
		render.DrawSprite(self.Position2,self.FlashSize,self.FlashSize,Color(255,245,215,self.FlashAlpha))
	end


end



