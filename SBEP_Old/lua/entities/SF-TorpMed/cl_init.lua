include('shared.lua')
killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

function ENT:Initialize()
	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	self:DrawModel()

	render.SetMaterial( self.Matt )	
	local color = Color( 200, 200, 60, 200 )
	if self:GetArmed() then
		render.DrawSprite( self:GetPos() + self:GetForward() * 30, 300, 300, color )
		render.DrawSprite( self:GetPos() + self:GetForward() * -40, 300, 300, color )
	end
end

function ENT:Think()
	if LocalPlayer():GetInfoNum( "SBEPLighting" ) > 0 then
		if self:GetArmed() then
		
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				--local c = self:GetColor();  local r,g,b,a = c.r, c.g, c.b, c.a;
				dlight.Pos = self:GetPos() + self:GetRight() * 50
				dlight.r = 200
				dlight.g = 200
				dlight.b = 60
				dlight.Brightness = 10
				dlight.Decay = 500 * 5
				dlight.Size = 900
				dlight.DieTime = CurTime() + 1
			end
		
		end
	end
end