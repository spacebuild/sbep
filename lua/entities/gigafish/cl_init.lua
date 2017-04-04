include('shared.lua')

function ENT:Initialize()
	self.WInfo = "Gigafish"
	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	self.Entity:DrawModel()

	render.SetMaterial( self.Matt )	
	local color = Color( 180, 180, 220, 100 )
	if self:GetArmed() then
		render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * 50, 50, 10, color )
		render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * -30, 10, 10, color )
	end
end

function ENT:Think()
	if LocalPlayer():GetInfoNum( "SBEPLighting", 1 ) > 0 then
		if self:GetArmed() then
		
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				--local r, g, b, a = self:GetColor()
				dlight.Pos = self:GetPos() //+ self:GetForward() * 10
				dlight.r = 180
				dlight.g = 180
				dlight.b = 220
				dlight.Brightness = 10
				dlight.Decay = 500 * 5
				dlight.Size = 100
				dlight.DieTime = CurTime() + 1
			end
		
		end
	end
end