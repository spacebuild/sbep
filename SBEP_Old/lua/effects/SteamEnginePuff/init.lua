
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
	
	self.emitter = ParticleEmitter( self.vOffset )
	local scount = math.random(1,3)
		for i = 0, scount do
		
			local particle = self.emitter:Add( "particles/smokey", self.vOffset )
			if (particle) then
				particle:SetVelocity( self.vAng:Forward() * math.Rand(-100, -10) )
				--particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 2, 3 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 40 )
				particle:SetEndSize( 70 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle:SetColor( 190 , 190 , 190 )
			end
			
			local vec = VectorRand()
			
		end
		
	self.emitter:Finish()
	
 	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" ) 
 	self.Entity:SetPos( self.vOffset )  
 end 
   
   
 /*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
 function EFFECT:Think( ) 
   
 	return ( self.LifeTime > CurTime() )  
 	 
 end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
function EFFECT:Render() 

end  