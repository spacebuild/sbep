 local MOrb = "models/dav0r/hoverball.mdl"
 local MDsc = "models/Effects/intro_vortshield.mdl"
 local MDst = "models/shadertest/predator"
 local MSwv = "models/Effects/portalfunnel.mdl"
 local MFus = "spacebuild/Fusion2"
 local Glow = Material( "sprites/light_glow02_add" )
 
 function EFFECT:Init( data ) 
 	-- This is how long the spawn effect
 	-- takes from start to finish.
 	self.Time = 12
 	self.PreSplode = 5
 	self.STime = CurTime()
 	self.LifeTime = CurTime() + self.Time
	
 	self.vOffset = data:GetOrigin()
 	self.vAng = data:GetAngles()
 	self.vFw = self.vAng:Forward()
 	self.vUp = self.vAng:Up()
 	self.vRi = self.vAng:Right()
 	
 	self.Ent = data:GetEntity()
	
	self.emitter = ParticleEmitter( self.vOffset )
		
	self.emitter:Finish()
	
 	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" ) 
 	self.Entity:SetPos( self.vOffset + self.vFw * 125 )
 	self.Entity:SetAngles( self.vAng * -1 )
	
	self:SetRenderBoundsWS( Vector(20000,20000,20000), Vector(-20000,-20000,-20000) )
 	
 	self.Sz = 0
	self.LTP = 0
 end 
   
function EFFECT:Think()
	self.vAng = self.Entity:GetAngles()
	self.Entity:SetAngles(self.vAng)
	self.vOffset = self.Entity:GetPos()
	self.Entity:SetPos(self.vOffset)	
	local T = ( (CurTime() - self.STime) / self.PreSplode )
	if T <= 0.5 then
		Mul = math.sin(math.rad(T * 180))
	elseif T >= 0.8 then
		Mul = math.cos( math.rad( (T - 0.8) * 450 ) )
	else
		Mul = 1
	end
	
	if T < 0.8 then
		for i = 0, T * 20 do
			local n = math.Rand(0,360)
			local Vec = self.vOffset + (self.vAng:Right() * (math.cos(n) * math.Rand(10,Mul * 5000))) + (self.vAng:Forward() * (math.sin(n) * math.Rand(10,Mul * 5000))) + (self.vAng:Up() * math.Rand(125,655))
			local center = self.Entity:GetPos()
			local em = ParticleEmitter(center)
			local particle = em:Add( "sprites/light_glow02_add", Vec )
			if (particle) then
				particle:SetVelocity( ((self.vOffset + (self.vUp * (Mul * -400))) - Vec) * T * 2 )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Clamp((1 / T) * 0.5, 0.01, 3) )
				particle:SetStartAlpha( math.Rand( 100, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand(50,200) )
				particle:SetEndSize( 1 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle:SetColor(Color(150, 160, 255))
				
				timer.Simple(5, function() em:Finish() end)
			end
		end
	end
	
	if T < 0.75 then
		if (CurTime() - self.LTP) >= 0.1 then
			sound.Play( "physics/nearmiss/whoosh_large1.wav", self.vOffset,  160,  math.Clamp(T * 300,60,255) )
			self.LTP = CurTime()
		end
		--self.PSS:PlayEx(T, 10)
	else
		--self.PSS:Stop()
	end
	
	if T > 1.03 and !self.ExpPlayed then
		self.ExpPlayed = true
		sound.Play( "ambient/explosions/explode_5.wav", self.vOffset,  160,  100 )
		sound.Play( "ambient/explosions/explode_6.wav", self.vOffset,  160,  100 )
		sound.Play( "ambient/explosions/explode_7.wav", self.vOffset,  160,  100 )
		sound.Play( "ambient/explosions/explode_8.wav", self.vOffset,  160,  100 )
	end	
	
	return ( self.LifeTime > CurTime() )
end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
function EFFECT:Render()
	local Time = ( (CurTime() - self.STime - self.PreSplode) / (self.Time - self.PreSplode) )
--	print(Time)
	local Sz = (Time - 0.1) * 3
	local Alpha = math.Clamp((255 - (Time * 255)) - 50,0,255)
	--self.Sz = self.Sz + Alpha
	Sz = (Time * 2) + (Alpha * 0.001) - 0.201
	
	if Time < 0 then
		local T = ( (CurTime() - self.STime) / self.PreSplode )
		if T <= 0.5 then
			Mul = math.sin(math.rad(T * 180))
		elseif T >= 0.8 then
			Mul = math.cos( math.rad( (T - 0.8) * 450 ) )
		else
			Mul = 1
		end
			
		
		Sz = Mul * 100
		local Sc = Sz * (Mul * 0.2)
		
		
		--local Dir = LocalPlayer():GetShootPos() - self:GetPos()
		--self:SetAngles(Dir:Angle())
		local Ang2 = Angle(0,0,0)
		Ang2.r = self.vAng.r
		Ang2.y = self.vAng.y
		Ang2.p = self.vAng.p
		Ang2:RotateAroundAxis(Ang2:Right(),-90)
		self.Entity:SetAngles( Ang2 )
		
		self.Entity:SetModel("models/Effects/combineball.mdl")
		--self.Entity:SetModelScale(Sz)
		self.Entity:OldSetModelScale(Vector(0.1,0.1,0.1))
		self.Entity:DrawModel()
		
	elseif Time > 0 then
	
		self:SetPos(self.vOffset)
		render.SetMaterial( Glow )	
		local color = Color( 190, 210, 255, 255 )--math.Clamp(Alpha * 0.1,0,255) )
		local Scale = math.Clamp(Alpha * 500,1000,50000)
		render.DrawSprite( self.vOffset, Scale, Scale * 0.2, color )
		render.DrawSprite( self.vOffset, Scale * 0.2, Scale, color )
		render.DrawSprite( self.vOffset, Scale, Scale * 0.2, color )
		render.DrawSprite( self.vOffset, Scale * 0.5, Scale * 0.5, color )
		
		
		local Ang2 = Angle(0,0,0)
		Ang2.r = self.vAng.r
		Ang2.y = self.vAng.y
		Ang2.p = self.vAng.p
		Ang2:RotateAroundAxis(Ang2:Right(),-180)
		
		self:SetPos(self.vOffset)
		self.Entity:SetAngles(Angle(270,0,0))
		self.Entity:SetModel(MDsc)
		self.Entity:OldSetModelScale(Vector(Sz * 1,Sz * 10,Sz * 10)*10)
		self.Entity:SetMaterial("spacebuild/Fusion2")
		self.Entity:DrawModel()
		
		self.Entity.Entity:SetModel(MDsc)
		self.Entity.Entity:SetAngles(Angle(90,0,0))
		self.Entity.Entity:OldSetModelScale(Vector(Sz * 1,Sz * 10,Sz * 10) * 10)
		self.Entity.Entity:SetMaterial(MDst)
		self.Entity.Entity:DrawModel()
		
		
		self:SetPos(self.vOffset)
		Ang2:RotateAroundAxis(Ang2:Right(),-180)
		self.Entity:SetAngles(Angle(270,0,0))
		self.Entity:SetModel(MDsc)
		self.Entity:OldSetModelScale(Vector(Sz * 1,Sz * 10,Sz * 10)*10)
		self.Entity:SetMaterial("spacebuild/Fusion2")
		self.Entity:DrawModel()
		
		self.Entity:SetModel(MDsc)
		self.Entity:SetAngles(Angle(90,0,0))
		self.Entity:OldSetModelScale(Vector(Sz * 1,Sz * 10,Sz * 10) * 10)
		self.Entity:SetMaterial(MDst)
		self.Entity:DrawModel()
	end	
	
end

local Entity = FindMetaTable("Entity")
if !Entity then return end

function Entity:OldSetModelScale(scale)
	local mat = Matrix()
	mat:Scale(scale)
	self:EnableMatrix("RenderMultiply", mat)
end