
include('shared.lua')
--killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))



function ENT:Initialize()
	self.BSize = 200
	self.BGrow = true
end

function ENT:Draw()
	
	self.Entity:DrawModel()

end


function ENT:Think()
	
	if self:GetActive() and self:GetPod() and self:GetPod():IsValid() then
		local Pod = self:GetPod()
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			--local r, g, b, a = self:GetColor()
			dlight.Pos = Pod:GetPos()
			dlight.r = 200
			dlight.g = 60
			dlight.b = 60
			dlight.Brightness = 5
			dlight.Decay = 200 * 5
			dlight.Size = 200
			dlight.DieTime = CurTime() + 1
		end
		
		if self.BGrow then
			if self.BSize < 200 then
				BSize = BSize + 10
			else
				self.BGrow = false
			end
		else
			if self.BSize > 10 then
				BSize = BSize - 10
			else
				self.BGrow = true
			end
		end
		
	end
		
		
end