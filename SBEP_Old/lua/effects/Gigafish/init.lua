
 --local MOrb = "models/Combine_Helicopter/helicopter_bomb01.mdl"
 local MOrb = "models/dav0r/hoverball.mdl"
 --local MDsc = "models/Effects/combineball.mdl"
 --local MDsc = "models/Effects/intro_vortshield.mdl"
 --local MDsc = "models/props_combine/portalball.mdl"
 local MDsc = "models/Effects/portalfunnel.mdl"
 local MDst = "models/shadertest/predator"
 local MSwv = "models/Effects/portalfunnel.mdl"
 --local MDsc = "models/Effects/combineball.mdl"
 --local MDsc = "models/Combine_Helicopter/helicopter_bomb01.mdl"
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
 	self.vAng = data:GetAngle()
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
   
   
 /*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
function EFFECT:Think()

	self.vAng = self.Ent:GetAngles()
	self.Entity:SetAngles(self.vAng)
	self.vOffset = self.Ent:GetPos()
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
			local particle = self.emitter:Add( "sprites/light_glow02_add", Vec )
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
				particle:SetColor(150, 160, 255)
			end
		end
		
		self.emitter:Finish()
	end
	
	if T < 0.75 then
		if (CurTime() - self.LTP) >= 0.1 then
			WorldSound( "physics/nearmiss/whoosh_large1.wav", self.vOffset,  160,  math.Clamp(T * 300,60,255) )
			self.LTP = CurTime()
		end
		--self.PSS:PlayEx(T, 10)
	else
		--self.PSS:Stop()
	end
	
	if T > 1.03 and !self.ExpPlayed then
		self.ExpPlayed = true
		WorldSound( "ambient/explosions/explode_5.wav", self.vOffset,  160,  100 )
		WorldSound( "ambient/explosions/explode_6.wav", self.vOffset,  160,  100 )
		WorldSound( "ambient/explosions/explode_7.wav", self.vOffset,  160,  100 )
		WorldSound( "ambient/explosions/explode_8.wav", self.vOffset,  160,  100 )
	end	
	
	return ( self.LifeTime > CurTime() )
end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
function EFFECT:Render()
	local Time = ( (CurTime() - self.STime - self.PreSplode) / (self.Time - self.PreSplode) )
	--print(Time)
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
		self.Entity:SetModelScale(Vector(Sz,Sz,Sz))
		self:SetColor(255, 255, 255, 150)
		self.Entity:DrawModel()
		
		/*
		local Ang2 = Angle(0,0,0)
		Ang2.r = self.vAng.r
		Ang2.y = self.vAng.y
		Ang2.p = self.vAng.p
		Ang2:RotateAroundAxis(Ang2:Right(),-90)
		self.Entity:SetAngles( Ang2 )
		
		self.Entity:SetModel(MOrb)
		self.Entity:SetModelScale(Vector(Sz,Sc,Sc))
		self.Entity:SetMaterial("spacebuild/Fusion2")
		self:SetColor(255, 255, 255, 150)
		self.Entity:DrawModel()
		
		self.Entity:SetModel(MOrb)
		self.Entity:SetModelScale(Vector(Sz,Sc,Sc) * 1.2)
		self.Entity:SetMaterial(MDst)
		self:SetColor(255, 255, 255, 150)
		self.Entity:DrawModel()
		*/
	else	
	
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
		
		self:SetPos(self.vOffset + self.vUp * 200)
		self.Entity:SetAngles( Ang2 )
		self.Entity:SetModel(MDsc)
		self.Entity:SetModelScale(Vector(Sz * 10,Sz * 10,Sz * 1))
		self.Entity:SetMaterial("spacebuild/Fusion2")
		self:SetColor(255, 255, 255, Alpha)
		self.Entity:DrawModel()
		
		self.Entity:SetModel(MDsc)
		self.Entity:SetModelScale(Vector(Sz * 10,Sz * 10,Sz * 1) * 1.1)
		self.Entity:SetMaterial(MDst)
		self:SetColor(255, 255, 255, Alpha)
		self.Entity:DrawModel()
		
		
		self:SetPos(self.vOffset + self.vUp * -200)
		Ang2:RotateAroundAxis(Ang2:Right(),-180)
		self.Entity:SetAngles( Ang2 )
		self.Entity:SetModel(MDsc)
		self.Entity:SetModelScale(Vector(Sz * 10,Sz * 10,Sz * 1))
		self.Entity:SetMaterial("spacebuild/Fusion2")
		self:SetColor(255, 255, 255, Alpha)
		self.Entity:DrawModel()
		
		self.Entity:SetModel(MDsc)
		self.Entity:SetModelScale(Vector(Sz * 10,Sz * 10,Sz * 1) * 1.1)
		self.Entity:SetMaterial(MDst)
		self:SetColor(255, 255, 255, Alpha)
		self.Entity:DrawModel()
	end	
	
end