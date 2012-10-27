include('shared.lua')

function ENT:Initialize()

end

function ENT:Draw()
	
	self:DrawModel()

end

function ENT:Think()
	local Shots = self:GetNetworkedInt("Shots")
	self.WInfo = "Stinger Mortar - Shots: "..Shots
end