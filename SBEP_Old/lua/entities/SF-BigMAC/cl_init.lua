include('shared.lua')
--killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

function ENT:Initialize()
	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	self:DrawModel()

end

function ENT:Think()
	if LocalPlayer():GetInfoNum( "SBEPLighting" ) > 0 then
		local dlight = DynamicLight( 0 )
		if ( dlight ) then
			--local c = self:GetColor();  local r,g,b,a = c.r, c.g, c.b, c.a;
			dlight.Pos = self:GetPos() + (self:GetForward() * 105) + (self:GetUp() * 70) 
			dlight.r = 60
			dlight.g = 140
			dlight.b = 40
			dlight.Brightness = self:GetBrightness() + 2
			dlight.Decay = 900 * 5
			dlight.Size = 900
			dlight.DieTime = CurTime() + 0.2
		end
		
		local dlight = DynamicLight( 0 )
		if ( dlight ) then
			--local c = self:GetColor();  local r,g,b,a = c.r, c.g, c.b, c.a;
			dlight.Pos = self:GetPos() + (self:GetForward() * 150) + (self:GetUp() * -50) 
			dlight.r = 60
			dlight.g = 140
			dlight.b = 40
			dlight.Brightness = self:GetBrightness() + 2
			dlight.Decay = 900 * 5
			dlight.Size = 900
			dlight.DieTime = CurTime() + 0.2
		end
	end
	self:NextThink( CurTime() + 0.1 ) 
	return true
end