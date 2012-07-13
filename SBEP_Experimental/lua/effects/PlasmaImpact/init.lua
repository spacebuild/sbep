
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
 	 
 	-- This is how long the spawn effect
 	-- takes from start to finish.
 	
 	self.vScale = data:GetScale()
 	
 	self.Time = math.Clamp(self.vScale * 0.05, 0, 3)
 	self.LifeTime = CurTime() + self.Time 
 	
 	self.vOffset = data:GetOrigin()
 	self.vStart = data:GetStart()
 	self.vAng = (self.vOffset - self.vStart):Angle()
 	self.vFw = self.vAng:Forward()
 	self.vUp = self.vAng:Up()
 	self.vRi = self.vAng:Right()
	 	
	self.emitter = ParticleEmitter( self.vOffset )
	local scount = math.random(20,25)
		for i = 0, scount do
			local particle3 = self.emitter:Add( "effects/spark", self.vOffset )
			if (particle3) then
				particle3:SetVelocity( self.vFw * math.Rand(-10, -50) + self.vUp * math.Rand(-50, 50) + self.vRi * math.Rand(-50, 50) )
				particle3:SetLifeTime( 0 )
				particle3:SetDieTime( math.Rand( 2, 2.5 ) )
				particle3:SetStartAlpha( math.Rand( 200, 255 ) )
				particle3:SetEndAlpha( 0 )
				particle3:SetStartSize( self.vScale * 0.1 )
				particle3:SetEndSize( 0 )
				particle3:SetRoll( math.Rand(0, 360) )
				particle3:SetRollDelta( math.Rand(-10.2, 10.2) )
				particle3:SetColor( 255 , 255 , 255 )
			end
			
		end
		
	self.emitter:Finish()
	
	self.Entity:SetRenderBoundsWS( self.vStart, self.vOffset )
	
 	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" ) 
 	self.Entity:SetMaterial("models/alyx/emptool_glow")
 	self.Entity:SetPos( self.vOffset )  
 end 
   
   
 /*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
function EFFECT:Think()

	return ( self.LifeTime > CurTime() )  
 
end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
function EFFECT:Render() 
	local Frac = (self.LifeTime - CurTime()) / self.Time
	local Alph = Lerp(Frac, 0, math.Clamp(150 + (self.vScale * 5),0,255))
	local v = Lerp(Frac, (self.vScale * 0.15), (self.vScale * 0.01))
	self.Entity:SetModelWorldScale( Vector(v,v,v) )
	self.Entity:SetColor(50,150,255,Alph)
	self:DrawModel()
	--print(Wid)
	--print(Frac)
end  