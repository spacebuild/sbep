include('shared.lua')

function ENT:Initialize()

end

function ENT:Draw()
	
	self.Entity:DrawModel()

end

function ENT:Think()
	local Shots = self.Entity:GetNetworkedInt("Shots")
	self.WInfo = "Minelayer - Mines: "..Shots
end