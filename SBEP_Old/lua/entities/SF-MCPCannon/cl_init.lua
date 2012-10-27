include('shared.lua')

function ENT:Initialize()

end

function ENT:Draw()
	
	self.Entity:DrawModel()

end

function ENT:Think()
	local Shots = self.Entity:GetNetworkedInt("Shots") or 0
	self.WInfo = "MCP Cannon - Shots: "..Shots
end