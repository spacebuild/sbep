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
 	 
 	
 	--self:SetRenderBoundsWS( self.Vec1, self.Vec2 )
 	self:SetRenderBounds( Vector(10000,10000,10000), Vector(-10000,-10000,-10000) )--I need to fix this.
 	
 	--self:SetModel( "models/props_combine/portalball.mdl" )
 	--self:SetColor(Color(250,160,255,255))
 	--self:SetMaterial("Models/effects/comball_sphere")
 	self.Heat = Material( "sprites/heatwave" )
 	
 	self.OPos = self:GetPos()
 	self.Spin = 0
 	
 	self.DSPeed = 0
 	
end

function ENT:Draw()
	local Pos = self:GetPos()
	local Ang = self:GetAngles() + Angle( 0.01, 0.01, 0.01 )
	if self:GetActive() then
	
		if self.ExTime <= 0 then
			self.ExTime = CurTime()
			self.CSpeed = 0
		end
		
		local Size = self:GetSize() or 1
		local Length = self:GetLength() or 1
		local Col = Color( 150, 150, 240, 255 )
		local Time = CurTime() - self.ExTime
		local Width = (math.Clamp(Time,0,2) * 0.5) * 8 * Size
		if Width >= 8 then
			local Rate = 0
			if self.DSpeed > self.CSpeed then Rate = 1 else Rate = 5 end
			self.CSpeed = math.Approach(self.CSpeed,self.DSpeed,Rate)
		end
		local Speed = self.CSpeed * 0.07 * Size
		local ScSpeed = -20
		
		local NAng = Ang
		--NAng:RotateAroundAxis(NAng:Right(),90)
		NAng:RotateAroundAxis(Ang:Up(),-self.Spin)
		
		/*
		if !self.Vort then self.Vort = ClientsideModel("models/props_combine/stasisvortex.mdl", RENDERGROUP_OPAQUE) end
		self.Vort:SetModelScale(Vector(Width * 0.05 + (Speed * 0.1),Width * 0.05 + (Speed * 0.1),Width * 0.05 + (Speed * 0.1)))
		self.Vort:SetModel( "models/props_combine/stasisvortex.mdl" )
		self.Vort:SetColor(Color(255,255,255,255))
		self.Vort:SetMaterial("")
		self.Vort:SetPos( Pos )
		self.Vort:SetAngles( NAng )
		*/
		
		self:SetModelScale(Vector(Speed * 0.05 + (Width * 0.05),Speed * 0.05 + (Width * 0.05),(Speed * 0.1 + (Width * 0.01)) * Length))
		--self:SetColor(Color(255,255,255,255))
		--self:SetMaterial( "spacebuild/Fusion2" )
		self:SetMaterial("")
		self:SetModel( "models/Effects/vol_light128x512.mdl" )
		self:DrawModel()
		
		/*
		render.UpdateRefractTexture()
		--self.Heat:SetMaterialFloat( "$refractamount", 0.02 + math.sin(math.rad((CurTime() - self.STime) * 0.01 )) )
		self:SetModel( "models/Effects/combineball.mdl" )
		--self.Heat:SetMaterialFloat( "$bluramount", 10 ) 
		self:SetPos( Pos + self:GetForward() * ((Width * 14) + 55 ))
		self:SetMaterial("sprites/heatwave")
		self:SetModelScale(Vector(Width*0.3,Width,Width ))
		self:DrawModel()
		
		self:SetPos( Pos + self:GetForward() * ((Width * 7) + (Speed * 3) + 55 ))
		self:SetColor(Color(255,255,255,255))
		self:SetModel( "models/Effects/intro_vortshield.mdl" )
		self:SetMaterial("")
		self:SetModelScale(Vector(Width * 0.2 + (Speed * 0.2),Width * 0.2 + (Speed * 0.2),Width * 0.2 + (Speed * 0.2)))
		self:DrawModel()
		*/
		--self:SetAngles( Ang )
		render.UpdateRefractTexture()
		render.SetMaterial( self.Heat )
		render.DrawBeam( Pos, Pos + self:GetUp() * Width * -20, Speed * 25, Time * ScSpeed, 100 + (Time * ScSpeed), Col )
		
	else
		self.ExTime = 0
	end
		
	self:SetPos( Pos )
	
	self:SetModel( "models/Slyfo/finfunnel.mdl" )
	self:SetMaterial("")
	self:SetModelScale(Vector(0.5,0.5,0.5))
	self:DrawModel()
	self:SetPos( Pos )
	--self:SetAngles( Ang )

end

function ENT:Think()

	self.OPos = self.OPos or self:GetPos()

	self.DSpeed = math.Clamp(self:GetPos():Distance(self.OPos),0,150)
	
	--if self.DSpeed > 0 then print(self.DSpeed) end
	
	self.Spin = math.fmod(self.Spin + self.DSPeed + 1, 360)
	
	--print(self.Spin)
	
	self.OPos = self:GetPos()
	
	self:NextThink(CurTime() + 0.1)
	
	return true
end