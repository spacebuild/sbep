
include('shared.lua')
--killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )


function ENT:Initialize()
	self.Seed = math.Rand( 0, 10000 )
	self.STime = 0
	self.Emitter = ParticleEmitter( self:GetPos() )
end

function ENT:Draw()
	
	self.Entity:DrawModel()

end

function ENT:Think()
	if self:GetActive() then
		local particle = self.Emitter:Add( "particles/flamelet"..math.random(1,5), self:GetPos() + (self:GetForward() * 15))
		if (particle) then
			particle:SetVelocity( self:GetForward() * 700 + (self:GetUp() * math.Rand( -10, 10 )) + (self:GetRight() * math.Rand( -10, 10 )) )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( 0.6, 0.9 )  )
			particle:SetStartAlpha( math.Rand( 150, 250 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand(10,40) )
			particle:SetEndSize( math.Rand(60,100) )
			particle:SetRoll( math.Rand(-360, 360) )
			particle:SetRollDelta( math.Rand(-0.2, 0.2) )
			particle:SetColor( 255 , 255 , 255 )
		end
	end
end