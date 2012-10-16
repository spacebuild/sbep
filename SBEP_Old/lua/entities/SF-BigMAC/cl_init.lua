include('shared.lua')
--killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

function ENT:Initialize()
	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	self.Entity:DrawModel()

end

function ENT:Think()
	if LocalPlayer():GetInfoNum( "SBEPLighting" ) > 0 then
		local dlight = DynamicLight( 0 )
		if ( dlight ) then
			--local r, g, b, a = self:GetColor()
			dlight.Pos = self:GetPos() + (self.Entity:GetForward() * 105) + (self.Entity:GetUp() * 70) 
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
			--local r, g, b, a = self:GetColor()
			dlight.Pos = self:GetPos() + (self.Entity:GetForward() * 150) + (self.Entity:GetUp() * -50) 
			dlight.r = 60
			dlight.g = 140
			dlight.b = 40
			dlight.Brightness = self:GetBrightness() + 2
			dlight.Decay = 900 * 5
			dlight.Size = 900
			dlight.DieTime = CurTime() + 0.2
		end
	end
	self.Entity:NextThink( CurTime() + 0.1 ) 
	return true
end