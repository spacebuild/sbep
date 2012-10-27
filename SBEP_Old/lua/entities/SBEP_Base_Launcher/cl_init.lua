include('shared.lua')

function ENT:Initialize()

end

function ENT:Draw()
	
	self:DrawModel()

end

function ENT:Think()
	self.Shots = self:GetNetworkedInt( "Shots" ) or 0
	self.WInfo = "4x Missile Pod - Shots: "..self.Shots
end