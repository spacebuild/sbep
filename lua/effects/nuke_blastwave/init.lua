

function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()
	self.Yield = data:GetMagnitude()
	self.YieldSlow = self.Yield^0.75
	self.YieldSlowest = self.Yield^0.5
	
	self.TimeLeft = CurTime() + self.Yield*6
	
	self.SplodeDist = 2000
	self.BlastSpeed = 4000
	self.WaveResolution = 0.01
	self.lastThink = CurTime() + 0.75

	self.Emitter = ParticleEmitter(self.Position)

end


--THINK
-- Returning false makes the entity die
function EFFECT:Think( )

	if self.TimeLeft > CurTime() then 

		if self.lastThink < CurTime() then
			self.lastThink = CurTime() + self.WaveResolution
			
			self.SplodeDist = self.SplodeDist + self.BlastSpeed*(self.WaveResolution + FrameTime())
			local Intensity = -8.2e-5*self.SplodeDist + 2.5
		
			if self.Emitter then
				-- big dust wave
				for i=1, math.ceil(70/Intensity) do
				
					local vecang = Vector(math.Rand(-32,32),math.Rand(-32,32),0):GetNormalized()
					local startpos = self.Position + vecang*math.Rand(0.97*self.SplodeDist,1.03*self.SplodeDist)
					startpos.z = startpos.z - self.YieldSlowest*650
					local particle = self.Emitter:Add( "particles/smokey",  startpos )
					particle:SetVelocity(math.Rand(600,640)*Intensity*vecang + Vector(0,0,math.Rand(30,40)*((4 - Intensity)^2 + 15)))
					particle:SetDieTime( self.YieldSlowest*Intensity )
					particle:SetStartAlpha( 110 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( self.YieldSlowest*math.Rand( 500, 600 ) )
					particle:SetEndSize( self.YieldSlowest*math.Rand( 700, 800 ) )
					particle:SetRoll( math.Rand( 480, 540 ) )
					particle:SetRollDelta( math.random( -1, 1 ) )
					particle:SetColor(Color(160,152,120))
					--particle:VelocityDecay( true )
					
				end
			end
		
		end
		
		return true
	else
		if self.Emitter then self.Emitter:Finish() end
		return false	
	end
end


-- Draw the effect
function EFFECT:Render()


end



