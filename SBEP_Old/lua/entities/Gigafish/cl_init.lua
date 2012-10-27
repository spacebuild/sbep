include('shared.lua')

function ENT:Initialize()
	self.WInfo = "Gigafish"
	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	self:DrawModel()

	render.SetMaterial( self.Matt )	
	local color = Color( 180, 180, 220, 200 )
	if self:GetArmed() then
		render.DrawSprite( self:GetPos() + self:GetRight() * 50, 300, 300, color )
		render.DrawSprite( self:GetPos() + self:GetRight() * -30, 300, 300, color )
	end
end

function ENT:Think()
	if LocalPlayer():GetInfoNum( "SBEPLighting" ) > 0 then
		if self:GetArmed() then
		
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				--local c = self:GetColor();  local r,g,b,a = c.r, c.g, c.b, c.a;
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