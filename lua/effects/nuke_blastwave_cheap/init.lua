
function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()
	self.Yield = data:GetMagnitude()
	self.YieldSlow = self.Yield^0.75
	self.YieldSlowest = self.Yield^0.5
	self.YieldInverse = self.Yield^-1

	self.HalfTime = self.Yield*3.2
	self.TimeLeft = CurTime() + self.HalfTime

	self.dustparticles = {}

	local Pos = self.Position
	local emitter = ParticleEmitter( Pos )

	--dust ring
		for i=1, math.ceil(self.YieldSlowest*240) do
			
			local spawnpos = Vector(math.random(-512,512),math.random(-512,512),math.Rand(-2,4))
			local particle = emitter:Add( "particles/smokey", Pos + spawnpos)
			local velvec = spawnpos:GetNormalized()
			local velmult = math.random(3900,4100)
			particle:SetVelocity(velvec*velmult)
			particle:SetDieTime( self.HalfTime*2 )
			particle:SetStartAlpha( 0 )
			particle:SetEndAlpha( 130 )
			particle:SetStartSize( self.YieldSlowest*math.Rand( 800, 1000 ) )
			particle:SetEndSize( self.YieldSlowest*math.Rand( 1100, 1300 ) )
			particle:SetRoll( math.Rand( 480, 540 ) )
			particle:SetRollDelta( math.Rand( -1, 1 )*self.YieldInverse )
			particle:SetColor(Color(160,152,120))
			--particle:VelocityDecay( false )
			
			table.insert(self.dustparticles,particle)
			
		end
		
	emitter:Finish()
		
end

--THINK
-- Returning false makes the entity die
function EFFECT:Think( )
	if self.TimeLeft > CurTime() then 
		return true
	else
		for __,particle in pairs(self.dustparticles) do
		particle:SetStartAlpha( 100 )
		particle:SetEndAlpha( 0 )
		end
		return false	
	end
end


-- Draw the effect
function EFFECT:Render()


end



