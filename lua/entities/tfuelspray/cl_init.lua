
include('shared.lua')

function ENT:Initialize()
	--self.Matt = Material( "particles/smokey" )
	self.Matt2 = Material( "particles/flamelet"..math.random(1,5) )
	self.Matt = Material( "effects/splash1" )
	self.Matt3 = Material( "effects/splash1" )
	--self.Matt2 = Material( "sprites/light_glow02_add" )
	self.Emitter = ParticleEmitter( self.Entity:GetPos() )
	
	self.NSTime = 0
	
	self.BTime = CurTime()
	self.Roll = 0
end

function ENT:Draw()
	
	if self.Entity:IsBurning() then
		render.SetMaterial( self.Matt2 )	
		local color = Color( 255, 255, 255, 255 )
		render.DrawSprite( self.Entity:GetPos(), 80, 80, color )
	elseif self.Entity:IsPuddle() then
		render.SetMaterial( self.Matt3 )	
		render.DrawQuadEasy( self.Entity:GetPos(), self.Entity:GetForward(), 64, 64, Color( 20 , 20 , 20, 150 ))
		render.DrawQuadEasy( self.Entity:GetPos(), self.Entity:GetPos() - LocalPlayer():GetPos(), 64, 64, Color( 20 , 20 , 20, 150 ), self.Roll )
		self.Roll = math.fmod(self.Roll + 1,360)
	else
		render.SetMaterial( self.Matt )	
		local color = Color( 20 , 20 , 20, 100 )
		render.DrawSprite( self.Entity:GetPos(), 50, 50, color )
	end
end

function ENT:Think()
	if self.Entity:IsBurning() then
		local Vec = Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(-100,100))
		local particle = self.Emitter:Add( "particles/flamelet"..math.random(1,5), self.Entity:GetPos() + Vec )
		if (particle) then
			particle:SetVelocity( ( Vec ) * 0.25 )
			--particle:SetLifeTime( 0 )
			local ADT = self.Entity:GetVelocity():Length() * 0.005
			particle:SetDieTime( ADT + math.Rand( 0.5, 1.5 ) )
			particle:SetStartAlpha( math.Rand( 200, 255 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 80 )
			particle:SetEndSize( 50 )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-3, 3) )
			particle:SetColor(Color( 200 , 200 , 200 ) )
			particle:SetCollide( true )
		end
		
		/*
		local Vec = Vector(math.Rand(-50,50),math.Rand(-50,50),math.Rand(-50,50))
		local particle = self.Emitter:Add( "particles/smokey", self.Entity:GetPos() + Vec )
		if (particle) then
			particle:SetVelocity( ( Vec ) * 1 )
			--particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( 0.5, 0.9 ) )
			particle:SetStartAlpha( math.Rand( 200, 255 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 40 )
			particle:SetEndSize( 20 )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-0.2, 0.2) )
			particle:SetColor(Color( 220 , 220 , 180 ) )
			particle:SetCollide( true )
		end
		*/
	elseif !self.Entity:IsPuddle() then
		if self.NSTime < CurTime() then
			local scount = math.random(1,2)
			for i = 1, scount do
				local particle = self.Emitter:Add( "effects/splash1", self.Entity:GetPos() + Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50)) )
				if (particle) then
					particle:SetVelocity( Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10)) )
					--particle:SetLifeTime( 0 )
					particle:SetDieTime( math.Rand( 0.5, 1 ) )
					particle:SetStartAlpha( math.Rand( 50, 60 ) )
					particle:SetEndAlpha( 70 )
					particle:SetStartSize( 40 )
					particle:SetEndSize( 100 )
					particle:SetRoll( math.Rand(0, 360) )
					particle:SetRollDelta( math.Rand(-3, 3) )
					particle:SetColor(Color( 20 , 20 , 20 ) )
					particle:SetCollide( true )
				end
			end
			self.NSTime = CurTime() + 0.1
		end		
	end
	
	
	
	self.Entity:NextThink( CurTime() + 0.1 ) 
	return true
	
end