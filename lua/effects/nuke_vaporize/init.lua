

function EFFECT:Init( data )

self.Position = data:GetOrigin()

local height = 2*self.Entity:BoundingRadius()
local width = height/3
local negwidth = width*-1

local emitter = ParticleEmitter( self.Position )
	
	if emitter then
		for i=1,math.ceil(height) do
			local particle = emitter:Add( "effects/fleck_antlion"..math.random(1,2), self.Position + Vector(math.Rand(negwidth,width),math.Rand(negwidth,width),math.Rand(2,height)))
				particle:SetVelocity( VectorRand()*96 )
				particle:SetDieTime( math.Rand(0.4, 0.8) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 1.5, 1.7) )
				particle:SetEndSize( math.Rand( 1.8, 2) )
				particle:SetRoll( math.Rand( 360, 520 ) )
				particle:SetRollDelta( math.random( -2, 2 ) )
				particle:SetColor(Color(30, 30, 30) )	
		end
		
		for i=1,math.ceil(width) do
			local particle = emitter:Add( "particles/smokey", self.Position + Vector(math.Rand(negwidth,width),math.Rand(negwidth,width),math.Rand(2,height)))
				particle:SetVelocity( Vector(math.Rand(-24,24),math.Rand(-24,24),math.Rand(32,64)) )
				particle:SetDieTime( math.Rand(0.4, 0.8) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 12, 16) )
				particle:SetEndSize( math.Rand( 32, 48) )
				particle:SetRoll( math.Rand( 360, 520 ) )
				particle:SetRollDelta( math.random( -2, 2 ) )
				particle:SetColor(Color(20, 20, 20) )	
		end

		emitter:Finish()
	end
	
	--become a dark stain on the floor
	local trace = {}
	trace.startpos = self.Position + Vector(0,0,32)
	trace.endpos = trace.startpos - Vector(0,0,64)
	trace.filter = self.Entity
	local traceRes = util.TraceLine(trace)
	util.Decal("Scorch", traceRes.HitPos + traceRes.HitNormal, traceRes.HitPos - traceRes.HitNormal )
	
	for i=1,8 do
		trace.endpos = trace.startpos + Vector(math.Rand(-48,48),math.Rand(-48,48),-64)
		traceRes = util.TraceLine(trace)
		util.Decal("Blood", traceRes.HitPos + traceRes.HitNormal, traceRes.HitPos - traceRes.HitNormal )
	end

end


function EFFECT:Think( )

	return false

end


function EFFECT:Render()

	
end



