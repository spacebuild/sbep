local matRefraction	= Material( "refract_ring" ) 
 --[[---------------------------------------------------------
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------]]
 function EFFECT:Init( data ) 
 	 
 	-- This is how long the spawn effect
 	-- takes from start to finish.
 	
 	self.Refract = 0 
 	 
 	self.Size = 16 
 	
 	self.Time = 1
 	self.LifeTime = CurTime() + self.Time 
	
 	self.vOffset = data:GetOrigin()
	
	self.emitter = ParticleEmitter( self.vOffset )
	
		for i=0, (25) do
		
			local Pos = VectorRand():GetNormalized()
		
			local particle = self.emitter:Add( "particles/smokey", self.vOffset + Pos * math.Rand(100, 300 ))
			if (particle) then
				particle:SetVelocity( Pos * math.Rand(100, 200) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 2, 3 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 450 )
				particle:SetEndSize( 400 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle:SetColor(Color(40 , 40 , 40) )
			end
			
			local vec = VectorRand()
			
			local particle1 = self.emitter:Add( "particles/flamelet"..math.random(1,5), self.vOffset + vec * math.Rand(300,400))
			if (particle1) then
				particle1:SetVelocity(vec * -400 )
				particle1:SetLifeTime( 0 )
				particle1:SetDieTime( 0.3 )
				particle1:SetStartAlpha( math.Rand( 200, 255 ) )
				particle1:SetEndAlpha( 0 )
				particle1:SetStartSize( 500 )
				particle1:SetEndSize( 30 )
				particle1:SetRoll( math.Rand(0, 360) )
				particle1:SetRollDelta( math.Rand(-10, 10) )
				particle1:SetColor(Color(255 , 255 , 255) ) 
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
   
 	self.Refract = self.Refract + 2.0 * FrameTime() 
 	self.Size = 512 * self.Refract^(0.2) 
 	 
 	if ( self.Refract >= 1 ) then return false end 
 	 
 	return true
 	 
 end 
   
   
   
 --[[---------------------------------------------------------
    Draw the effect 
 ---------------------------------------------------------]]
 function EFFECT:Render() 
 
 	local Distance = EyePos():Distance( self.Entity:GetPos() ) 
 	local Pos = self.Entity:GetPos() + (EyePos()-self.Entity:GetPos()):GetNormal() * Distance * (self.Refract^(0.3)) * 0.8 
   
 	matRefraction:SetFloat( "$refractamount", math.sin( self.Refract * math.pi ) * 0.1 ) 
 	render.SetMaterial( matRefraction ) 
 	render.UpdateRefractTexture() 
 	render.DrawSprite( Pos, self.Size, self.Size )
 	
 end  