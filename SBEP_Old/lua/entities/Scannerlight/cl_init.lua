include('shared.lua')

function ENT:Initialize()

	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	self.Entity:DrawModel()
	
	if self.dt.Active then
		local color = Color( 255, 255, 255, 100 )
		render.SetMaterial( self.Matt )	
		render.DrawSprite( self.Entity:GetPos() + self.Entity:GetForward() * 8, 25, 25, color )
	end

end

