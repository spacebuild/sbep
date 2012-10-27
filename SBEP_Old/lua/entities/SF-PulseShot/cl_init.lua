include('shared.lua')
killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

function ENT:Initialize()
	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	render.SetMaterial( self.Matt )	
	local color = Color( 50, 50, 200, 200 )
	render.DrawSprite( self.Entity:GetPos(), 100, 100, color )
	
end

function ENT:Think()
		
end