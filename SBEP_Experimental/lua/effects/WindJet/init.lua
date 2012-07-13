
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
 	 
 	-- This is how long the spawn effect
 	-- takes from start to finish.
 	self.Time = 1
 	self.LifeTime = CurTime() + self.Time 
	
 	self.vOffset = data:GetOrigin()
 	self.vAng = data:GetAngle()
 	self.vFw = self.vAng:Forward()
 	self.vUp = self.vAng:Up()
 	self.vRi = self.vAng:Right()
 	self.iMag = math.Clamp(data:GetMagnitude(),0,10000) * 0.0001 or 0
	
	LocalPlayer().MasterPresEmitter = LocalPlayer().MasterPresEmitter or ParticleEmitter( self.vOffset ) --This is probably a very bad thing to do. I don't advise doing it again.
	
	for i = 0, math.random(1,10) * self.iMag do
		local particle = LocalPlayer().MasterPresEmitter:Add( "particles/smokey", self.vOffset + (self.vUp * math.Rand(-55,55)) + (self.vRi * math.Rand(-65,65)) + (self.vFw * math.Rand(-65,self.iMag * 65)) )
		if (particle) then
			particle:SetVelocity( self.vFw * 100 )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( self.iMag + math.Rand( 0.2, 0.5 )  )
			particle:SetStartAlpha( math.Rand( 10, 40 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand(1,30) )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-0.2, 0.2) )
			particle:SetColor( 255 , 255 , 255 )
		end
	end
		
	LocalPlayer().MasterPresEmitter:Finish()
	
 	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" ) 
 	self.Entity:SetPos( self.vOffset )  
 end 
   
   
 /*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
function EFFECT:Think( ) 
   return false
 	--return ( self.LifeTime > CurTime() )  
 	 
end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
function EFFECT:Render() 

end  