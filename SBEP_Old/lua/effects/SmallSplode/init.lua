
 --[[--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------]] 
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
	
	self.emitter = ParticleEmitter( self.vOffset )
	local scount = math.random(20,25)
		for i = 0, scount do
			
			local particle = self.emitter:Add( "particles/smokey", self.vOffset )
			if (particle) then
				particle:SetVelocity( self.vFw * math.Rand(-250, -50) + self.vUp * math.Rand(-200, 200) + self.vRi * math.Rand(-200, 200) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 2, 3 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 60 )
				particle:SetEndSize( 40 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle:SetColor( 20 , 20 , 20 )
			end
			
			local particle2 = self.emitter:Add( "particles/flamelet"..math.random(1,5), self.vOffset )
			if (particle2) then
				particle2:SetVelocity( self.vFw * math.Rand(-30, -100) + self.vUp * math.Rand(-20, 20) + self.vRi * math.Rand(-20, 20) )
				particle2:SetLifeTime( 0 )
				particle2:SetDieTime( math.Rand( 2, 3 ) )
				particle2:SetStartAlpha( math.Rand( 150, 200 ) )
				particle2:SetEndAlpha( 0 )
				particle2:SetStartSize( 50 )
				particle2:SetEndSize( 40 )
				particle2:SetRoll( math.Rand(0, 360) )
				particle2:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle2:SetColor( 200 , 200 , 200 )
			end
			
			local particle3 = self.emitter:Add( "effects/spark", self.vOffset )
			if (particle3) then
				particle3:SetVelocity( self.vFw * math.Rand(-10, -50) + self.vUp * math.Rand(-50, 50) + self.vRi * math.Rand(-50, 50) )
				particle3:SetLifeTime( 0 )
				particle3:SetDieTime( math.Rand( 1, 1.5 ) )
				particle3:SetStartAlpha( math.Rand( 200, 255 ) )
				particle3:SetEndAlpha( 0 )
				particle3:SetStartSize( 5 )
				particle3:SetEndSize( 0 )
				particle3:SetRoll( math.Rand(0, 360) )
				particle3:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle3:SetColor( 255 , 255 , 255 )
			end
			
		end
		
	self.emitter:Finish()
	
 	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" ) 
 	self.Entity:SetPos( self.vOffset )  
 end 
   
   
 --[[--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------]] 
 function EFFECT:Think( ) 
   
 	return ( self.LifeTime > CurTime() )  
 	 
 end 
   
   
   
 --[[--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------]] 
function EFFECT:Render() 

end  