local matRefraction	= Material( "refract_ring" ) 
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
 	 
 	-- This is how long the spawn effect
 	-- takes from start to finish.
 	
 	self.Refract = 0 
 	 
 	self.Size = 16 
 	
 	self.Time = 1
 	self.LifeTime = CurTime() + self.Time 
	
 	self.vOffset = data:GetOrigin()
 	self.Magg = data:GetMagnitude()
	
	self.emitter = ParticleEmitter( self.vOffset )
	
	local Spew = math.Clamp((self.Magg * 0.2) + math.random(-2,2), 0, 10)
	
		for i = 0, Spew do
		
			local Pos = VectorRand():GetNormalized()
		
			local particle = self.emitter:Add( "particles/smokey", self.vOffset)
			if (particle) then
				particle:SetVelocity( Pos * math.Rand(100, 200) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 2, 3 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Clamp(self.Magg * 5, 10, 100) )
				particle:SetEndSize( 10 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle:SetColor( 40 , 40 , 40 )
			end
			
			local vec = VectorRand()
			
			local particle1 = self.emitter:Add( "particles/flamelet"..math.random(1,5), self.vOffset)
			if (particle1) then
				particle1:SetVelocity(vec * -400 )
				particle1:SetLifeTime( 0 )
				particle1:SetDieTime( 0.3 )
				particle1:SetStartAlpha( math.Rand( 200, 255 ) )
				particle1:SetEndAlpha( 0 )
				particle1:SetStartSize( math.Clamp(self.Magg * 3, 5, 75) )
				particle1:SetEndSize( 5 )
				particle1:SetRoll( math.Rand(0, 360) )
				particle1:SetRollDelta( math.Rand(-10, 10) )
				particle1:SetColor( 255 , 255 , 255 ) 
			end
			
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