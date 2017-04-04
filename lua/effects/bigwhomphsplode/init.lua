
 --[[---------------------------------------------------------
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
---------------------------------------------------------]]

local SmokeRing = function(particle)
	
	particle:SetVelocity( particle:GetVelocity() * 0.99 )
    particle:SetNextThink(CurTime() + 0.1)
    
    return particle  
  
end

function EFFECT:Init( data ) 
 	 
 	-- This is how long the spawn effect
 	-- takes from start to finish.
 	self.Time = 3
 	self.LifeTime = CurTime() + self.Time 
	
 	self.vOffset = data:GetOrigin()
 	self.CRenPos = data:GetOrigin()
 	self.vAng = data:GetAngles()
 	self.vFw = self.vAng:Forward()
 	self.vUp = self.vAng:Up()
 	self.vRi = self.vAng:Right()
	
	self.emitter = ParticleEmitter( self.vOffset )
	
	for i = 0, 360, 10 do
		local particle = self.emitter:Add( "particles/smokey", self.vOffset )
		if (particle) then
			particle:SetVelocity( Vector( math.cos(i) * 800 , math.sin(i) * 800 , 0 ) )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( 2.5, 3 ) )
			particle:SetStartAlpha( math.Rand( 200, 255 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 200 )
			particle:SetEndSize( 120 )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-0.2, 0.2)) 
			particle:SetColor(Color( 220 , 220 , 180 )) 
			particle:SetThinkFunction(SmokeRing)
			particle:SetNextThink(CurTime() + 0.1)
		end
	end
	local scount = math.random(20,25)
	for i = 0, scount do
		
		local particle2 = self.emitter:Add( "particles/flamelet"..math.random(1,5), self.vOffset )
		if (particle2) then
			particle2:SetVelocity( self.vFw * math.Rand(-50, 50) + self.vUp * math.Rand(0, 10) + self.vRi * math.Rand(-50, 50) )
			particle2:SetLifeTime( 0 )
			particle2:SetDieTime( math.Rand( 1, 2 ) )
			particle2:SetStartAlpha( math.Rand( 200, 255 ) )
			particle2:SetEndAlpha( 0 )
			particle2:SetStartSize( 50 )
			particle2:SetEndSize( 40 )
			particle2:SetRoll( math.Rand(0, 360) )
			particle2:SetRollDelta( math.Rand(-0.2, 0.2) )
			particle2:SetColor(Color( 200 , 200 , 200 ))
		end			
	end
		
	//self.emitter:Finish()
	
 	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" ) 
 	self.Entity:SetPos( self.vOffset )  
end

local Mushroom = function(particle)  
  
    if particle:GetLifeTime() >= particle:GetDieTime() * 0.5 then  
    	particle.ZVel = particle.ZVel + 21
    	particle.MVel = 2
    end
    
    if particle:GetLifeTime() >= particle:GetDieTime() * 0.9 then  
    	particle.MVel = 0.1
    end
    
    particle:SetVelocity( particle.BVel * (((particle:GetDieTime()-(particle:GetLifeTime()*2))/particle:GetDieTime()) * particle.MVel) + Vector(0,0,particle.ZVel) )
    
    particle:SetNextThink(CurTime() + 0.1)
    
    return particle  
  
end  


function EFFECT:Think( )
	local LTime = (self.LifeTime - CurTime()) - 1
	self.CRenPos = self.CRenPos + Vector(0,0,7)
	for i = 0, 2 do
		local AOff = math.Rand(0,360)
		local particle = self.emitter:Add( "particles/smokey", self.CRenPos + Vector( math.cos(AOff) * 10 , math.sin(AOff) * 10 , 0 ) )
		if (particle) then
			particle:SetVelocity( Vector( math.cos(AOff) * 10 , math.sin(AOff) * 10 , 0 ) )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( LTime * 0.5, LTime ) )
			particle:SetStartAlpha( math.Rand( 200, 255 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 100 )
			particle:SetEndSize( 60 )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-0.2, 0.2) )
			particle:SetColor(Color( 220 , 220 , 180 ) )
		end
	end
	for i = 0, 4 do
		local AOff = math.Rand(0,360)
		local particle = self.emitter:Add( "particles/smokey", self.CRenPos + Vector( math.cos(AOff) * 60 , math.sin(AOff) * 60 , 0 ) )
		if (particle) then
			particle:SetVelocity( Vector( math.cos(AOff) * 800 , math.sin(AOff) * 800 , 0 ) )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( LTime * 0.5, LTime ) )
			particle:SetStartAlpha( math.Rand( 200, 255 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 100 )
			particle:SetEndSize( 60 )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-0.2, 0.2) )
			particle:SetColor(Color( 220 , 220 , 180 ) )
			particle:SetThinkFunction(Mushroom)
			particle:SetNextThink(CurTime() + 0.1)
			particle.BVel = particle:GetVelocity()
			particle.ZVel = 0
			particle.MVel = 1
		end
	end
	self.Entity:NextThink( CurTime() + 0.1 )
	return ( self.LifeTime > CurTime() )  
end 
   
   
   
 --[[---------------------------------------------------------
    Draw the effect 
 ---------------------------------------------------------]]
function EFFECT:Render() 

end  