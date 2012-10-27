include('shared.lua')

function ENT:Initialize()
	self.WInfo = "Small Machinegun"
end

function ENT:Draw()
	
	self.Entity:DrawModel()

end
