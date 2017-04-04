include('shared.lua')
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
function ENT:Initialize()
	
 	-- This is how long the spawn effect
 	-- takes from start to finish.
 	self.Time = 15
 	self.ESTime = CurTime() + 3.5
 	self.EFTime = CurTime() + 14
 	self.LifeTime = CurTime() + self.Time
 	self.STime = CurTime()
 	self.CSpeed = 0
 	self.Skin = 2
 	
 	self.emitter = ParticleEmitter( self.Entity:GetPos() )
 	
 	--self:SetRenderBoundsWS( self.Vec1, self.Vec2 )
 	self:SetRenderBounds( Vector(1000,1000,1000), Vector(-1000,-1000,-1000) )--I need to fix this.
 	
 	--self.Entity:SetModel( "models/props_combine/portalball.mdl" )
 	--self.Entity:SetColor(Color(250,160,255,255)
 	--self.Entity:SetMaterial("Models/effects/comball_sphere")
 	self.Heat = Material( "sprites/heatwave" )
 	
 	self.OPos = self.Entity:GetPos()
 	self.Speed = 0
 	
end

function ENT:Draw()
	local Pos = self.Entity:GetPos()
	if self.Entity:GetActive() then
		self.Skin = self.Entity:GetSkin() or 1
	
		if self.ExTime <= 0 then
			self.ExTime = CurTime()
			self.CSpeed = 0
		end
		
		local Col = Color( 150, 150, 240, 255 )
		local Time = CurTime() - self.ExTime
		local Width = (math.Clamp(Time,0,2) * 0.5) * 8
		if Width >= 8 then
			local Rate = 0
			if self.DSpeed > self.CSpeed then Rate = 1 else Rate = 5 end
			self.CSpeed = math.Approach(self.CSpeed,self.DSpeed,Rate)
		end
		self.Width = Width
		local Speed = self.CSpeed * 0.07
		self.Speed = Speed
		--print(self.Speed)
		local ScSpeed = -20
		
		self.Entity:SetModelScale(Width * 0.05 + (Speed * 0.05))
		self.Entity:SetModel( "models/props_combine/portalball.mdl" )
		if self.Skin == 1 then
			self.Entity:SetColor(Color( 240, 120, 50, 255 ))
		elseif self.Skin == 2 then
			self.Entity:SetColor(Color( 150, 150, 240, 255 ))
		elseif self.Skin == 3 then
			self.Entity:SetColor(Color( 100, 240, 100, 255 ))
		elseif self.Skin == 4 then
			self.Entity:SetColor(Color( 100, 100, 200, 255 ))
		elseif self.Skin == 5 then
			self.Entity:SetColor(Color( 240, 120, 120, 255 ))
		else
			self.Entity:SetColor(Color( 255, 255, 255, 255 ))
		end
		self.Entity:SetMaterial("")
		self.Entity:SetPos( Pos + self.Entity:GetForward() * 55 )
		self.Entity:DrawModel()
		
		self.Entity:SetModelScale(Speed * 1.5)
		--self.Entity:SetColor(Color(255,255,255,255)
		if self.Skin > 1 then
			self.Entity:SetMaterial( "spacebuild/Fusion"..self.Skin or 0 )
		else
			self.Entity:SetMaterial( "spacebuild/Fusion" )
		end
		--self.Entity:SetMaterial( self.Entity:GetMaterial() )
		self.Entity:SetModel( "models/dav0r/hoverball.mdl" )
		self.Entity:DrawModel()
		
		render.UpdateRefractTexture()
		--self.Heat:SetFloat( "$refractamount", 0.02 + math.sin(math.rad((CurTime() - self.STime) * 0.01 )) )
		self.Entity:SetModel( "models/Effects/combineball.mdl" )
		self.Heat:SetFloat( "$bluramount", 0 ) 
		self.Entity:SetPos( Pos + self.Entity:GetForward() * ((Width * 9) + 55 ))
		self.Entity:SetMaterial("sprites/heatwave")
		self.Entity:SetMaterial(self.Heat)
		self.Entity:SetModelScale(Width*0.3)
		self.Entity:DrawModel()
		
		self.Entity:SetPos( Pos + self.Entity:GetForward() * ((Width * 7) + (Speed * 3) + 55 ))
		--self.Entity:SetColor(Color(250,160,255,255)
		self.Entity:SetModel( "models/Effects/intro_vortshield.mdl" )
		self.Entity:SetMaterial("")
		self.Entity:SetModelScale(Width * 0.2 + (Speed * 0.2))
		self.Entity:DrawModel()
		
		render.UpdateRefractTexture()
		render.SetMaterial( self.Heat )
		render.DrawBeam( Pos, Pos + self.Entity:GetForward() * Width * 5, Speed * 15, Time * ScSpeed, 100 + (Time * ScSpeed), Color(255,255,255) )
		
	else
		self.ExTime = 0
	end
		
	self.Entity:SetPos( Pos )
	
	self.Entity:SetModel( "models/Items/AR2_Grenade.mdl" )
	self.Entity:SetMaterial("")
	self.Entity:SetModelScale(1)
	self.Entity:DrawModel()
	self.Entity:SetPos( Pos )

end

function ENT:Think()

	self.OPos = self.OPos or self.Entity:GetPos()

	self.DSpeed = math.Clamp(self.Entity:GetPos():Distance(self.OPos),0,120)
	
	--if self.DSpeed > 0 then print(self.DSpeed) end
	
	self.OPos = self.Entity:GetPos()
	
	
	if self.Entity:GetActive() then
		for i = 0, self.Speed do
			local n = math.Rand(0,360)
			local Vec = self.Entity:GetPos() + (self.Entity:GetForward() * (50 + math.Rand(0,10)) + (self.Entity:GetUp() * self.Speed * math.cos(n) * 20) + (self.Entity:GetRight() * self.Speed * math.sin(n) * 20))
			local particle = self.emitter:Add( "sprites/light_glow02_add", Vec )
			if (particle) then
				particle:SetVelocity( (self.Entity:GetForward() * self.Speed * math.Rand( 5, 20 )) + (self.Entity:GetUp() * self.Speed * math.cos(n) * 10) + (self.Entity:GetRight() * self.Speed * math.sin(n) * 10))
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Clamp(self.Speed * 2,0,3) )
				particle:SetStartAlpha( math.Rand( 100, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand(5,30) )
				particle:SetEndSize( 1 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-0.2, 0.2) )
				--particle:SetColor(Color(140, 140, 255)
				particle:SetColor(self.Entity:GetColor())
			end
		end
		
		--self.emitter:Finish()
	end
	
	
	self.Entity:NextThink(CurTime() + 0.1)
	
	return true
end