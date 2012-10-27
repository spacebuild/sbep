include('shared.lua')

function ENT:Initialize()
	self.WInfo = "Gigafish"
	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	self.Entity:DrawModel()

	render.SetMaterial( self.Matt )	
	local color = Color( 180, 180, 220, 200 )
	if self:GetArmed() then
		render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * 50, 300, 300, color )
		render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * -30, 300, 300, color )
	end
end

function ENT:Think()
	if LocalPlayer():GetInfoNum( "SBEPLighting" ) > 0 then
		if self:GetArmed() then
		
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				--local r, g, b, a = self:GetColor()
				dlight.Pos = self:GetPos() + self:GetForward() * 50
				dlight.r = 180
				dlight.g = 180
				dlight.b = 220
				dlight.Brightness = 10
				dlight.Decay = 500 * 5
				dlight.Size = 900
				dlight.DieTime = CurTime() + 1
			end
		
		end
	end
end