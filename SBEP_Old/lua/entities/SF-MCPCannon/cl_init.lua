include('shared.lua')

function ENT:Initialize()

end

function ENT:Draw()
	
	self:DrawModel()

end

function ENT:Think()
	local Shots = self:GetNetworkedInt("Shots") or 0
	self.WInfo = "MCP Cannon - Shots: "..Shots
end