include('shared.lua')
killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

function ENT:Initialize()
	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	self.Entity:DrawModel()
	
	render.SetMaterial( self.Matt )	
	local color = Color( 200, 200, 60, 200 )
	if self:GetArmed() then
		//render.DrawSprite( self.Entity:GetPos() + (LocalPlayer():GetPos() - self.Entity:GetPos()):GetNormal() * 30, 400, 400, color )
	end

end

function ENT:Think()
	if LocalPlayer():GetInfoNum( "SBEPLighting", 1 ) > 0 then
		if self:GetArmed() then
		
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				--local r, g, b, a = self:GetColor()
				dlight.Pos = self:GetPos() + self:GetRight() * 10
				dlight.r = 200
				dlight.g = 200
				dlight.b = 60
				dlight.Brightness = 10
				dlight.Decay = 500 * 5
				dlight.Size = 100
				dlight.DieTime = CurTime() + 1
			end
		
		end
	end
end