include('shared.lua')

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
			dlight.Pos = self:GetPos() + (self:GetForward() * 160) + (self:GetUp() * 30) 
			dlight.r = 50
			dlight.g = 50
			dlight.b = 200
			dlight.Brightness = self:GetBrightness()
			dlight.Decay = 900 * 5
			dlight.Size = 900
			dlight.DieTime = CurTime() + 0.2
		end
		
		local dlight = DynamicLight( 0 )
		if ( dlight ) then
			--local c = self:GetColor();  local r,g,b,a = c.r, c.g, c.b, c.a;
			dlight.Pos = self:GetPos() + (self:GetForward() * 175) + (self:GetUp() * -20) 
			dlight.r = 50
			dlight.g = 50
			dlight.b = 200
			dlight.Brightness = self:GetBrightness()
			dlight.Decay = 900 * 5
			dlight.Size = 900
			dlight.DieTime = CurTime() + 0.2
		end
	end
	local Charging = self:GetNetworkedBool( "Charging" ) or false
	local Charge = self:GetNetworkedInt("Charge") or 0
	self.WInfo = "Light MAC - "..(Charging and "" or "Not ").."Charging, Charge:"..Charge
	self:NextThink( CurTime() + 0.1 ) 
	return true
end