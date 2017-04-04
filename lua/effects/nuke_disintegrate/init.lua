function EFFECT:Init( data )
	
self.Position = data:GetOrigin()
self.Angle = data:GetNormal()
self.Angle.z = 0.4*self.Angle.z

local Emitter = ParticleEmitter(self.Position)

	if Emitter then
		for i=1,50 do
			local particle = Emitter:Add( "effects/fleck_antlion"..math.random(1,2), self.Position + Vector(math.Rand(-8,8),math.Rand(-8,8),math.Rand(-32,32)))
				particle:SetVelocity( self.Angle*math.Rand(256,385) + VectorRand()*64)
				particle:SetLifeTime( math.Rand(-0.3, 0.1) )
				particle:SetDieTime( math.Rand(0.7, 1) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 1.5, 1.7) )
				particle:SetEndSize( math.Rand( 1.8, 2) )
				particle:SetRoll( math.Rand( 360, 520 ) )
				particle:SetRollDelta( math.random( -2, 2 ) )
				particle:SetColor(Color(30, 30, 30) )	
		end
		
		for i=1,20 do
			local particle = Emitter:Add( "particles/smokey", self.Position + Vector(math.Rand(-8,9),math.Rand(-8,8),math.Rand(-32,32)) - self.Angle*8)
				particle:SetVelocity( self.Angle*math.Rand(256,385) + VectorRand()*64  )
				particle:SetDieTime( math.Rand(0.4, 0.8) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 8, 12) )
				particle:SetEndSize( math.Rand( 24, 32) )
				particle:SetRoll( math.Rand( 360, 520 ) )
				particle:SetRollDelta( math.random( -2, 2 ) )
				particle:SetColor(Color(20, 20, 20) )	
		end

		Emitter:Finish()
	end

end


function EFFECT:Think()

	return false
	
end


function EFFECT:Render()

	
end
