
 --local MOrb = "models/Combine_Helicopter/helicopter_bomb01.mdl"
 local MOrb = "models/dav0r/hoverball.mdl"
 --local MDsc = "models/Effects/combineball.mdl"
 --local MDsc = "models/Effects/intro_vortshield.mdl"
 --local MDsc = "models/props_combine/portalball.mdl"
 local MDsc = "models/Effects/portalfunnel.mdl"
 local MDst = "models/shadertest/predator"
 local MRef	= Material( "refract_ring" )
 local MSwv = "models/Effects/portalfunnel.mdl"
 --local MDsc = "models/Effects/combineball.mdl"
 --local MDsc = "models/Combine_Helicopter/helicopter_bomb01.mdl"
 local MFus = "spacebuild/Fusion2"
 local Glow = Material( "sprites/light_glow02_add" )
 
 function EFFECT:Init( data ) 
 	 
 	-- This is how long the spawn effect
 	-- takes from start to finish.
 	
	
 	self.vOffset = data:GetOrigin()
 	self.vAng = data:GetAngles()
 	self.vFw = self.vAng:Forward()
 	self.vUp = self.vAng:Up()
 	self.vRi = self.vAng:Right()
 	self.fScale = data:GetScale()
 	self.fDur = data:GetMagnitude()
 	
 	self.Time = self.fDur or 2
 	self.STime = CurTime()
 	self.LifeTime = CurTime() + self.Time
 	
 	--self.Ent = data:GetEntity()
	
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
	local Time = ( (CurTime() - self.STime) / self.Time )
	local MSize = 5000
	local Size = MSize - (Time * MSize)
	--print(Size)

	if LocalPlayer():GetInfoNum( "SBEPLighting", 1 ) > 0 then
		local dlight = DynamicLight( self.STime )
		if ( dlight ) then
			--local r, g, b, a = self:GetColor()
			dlight.Pos = self.vOffset
			dlight.r = 190
			dlight.g = 210
			dlight.b = 255
			dlight.Brightness = 5
			dlight.Decay = Size * 5
			dlight.Size = Size
			dlight.DieTime = CurTime() + 0.2
		end
	end
		
	return ( self.LifeTime > CurTime() )
end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
function EFFECT:Render()
	local Time = ( (CurTime() - self.STime) / self.Time )
	--print(Time)
	local Sz = math.sin(math.rad(Time * 90)) * self.fScale
	local SzA = Time * (self.fScale * 2.2)
	--local SzA = Sz + ((Time ^ 2) * Sz * 7)
	local Alpha = math.Clamp((255 - (Time * 255)) - 50,0,255)
	local Scale = math.Clamp(Alpha * (self.fScale * 0.4),0,5000)
	--self.Sz = self.Sz + Alpha
	
	/*
	MRef:SetMaterialFloat( "$refractamount", math.cos(math.rad(Time * 90)) * 0.05 )
 	render.SetMaterial( MRef ) 
 	render.UpdateRefractTexture()
 	render.DrawSprite( self.vOffset, Scale * 50, Scale * 50, Color(255,255,255,Alpha))
 	*/
 	
 	self:SetPos(self.vOffset)
	self.Entity:SetModel(MOrb)
	self.Entity:SetModelScale(SzA)
	self.Entity:SetMaterial("models/alyx/emptool_glow")
	self:SetColor(Color(100, 100, 200, Alpha))
	self.Entity:DrawModel()
	
	self:SetPos(self.vOffset)
	render.SetMaterial( Glow )	
	local color = Color( 190, 210, 255, Alpha )--math.Clamp(Alpha * 0.1,0,255) )
	
	render.DrawSprite( self.vOffset, Scale, Scale * 0.2, color )
	render.DrawSprite( self.vOffset, Scale * 0.2, Scale, color )
	render.DrawSprite( self.vOffset, Scale, Scale * 0.2, color )
	render.DrawSprite( self.vOffset, Scale * 0.5, Scale * 0.5, color )
	
	
	self:SetPos(self.vOffset)
	self.Entity:SetModel(MOrb)
	self.Entity:SetModelScale(Sz)
	self.Entity:SetMaterial("spacebuild/Fusion2")
	self:SetColor(Color(255, 255, 255, Alpha))
	self.Entity:DrawModel()
	
	self.Entity:SetModel(MOrb)
	self.Entity:SetModelScale(Sz * 1.1)
	self.Entity:SetMaterial(MDst)
	self:SetColor(Color(Alpha, Alpha, Alpha, Alpha))
	self.Entity:DrawModel()
	

end