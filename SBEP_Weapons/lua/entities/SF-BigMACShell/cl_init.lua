include('shared.lua')
killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

function ENT:Initialize()
	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	self.Entity:DrawModel()

end

function ENT:Think()
	if LocalPlayer():GetInfoNum( "SBEPLighting" ) > 0 then
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			--local r, g, b, a = self:GetColor()
			dlight.Pos = self:GetPos()
			dlight.r = 60
			dlight.g = 140
			dlight.b = 40
			dlight.Brightness = 10
			dlight.Decay = 500 * 5
			dlight.Size = 500
			dlight.DieTime = CurTime() + 1
		end
	end
end