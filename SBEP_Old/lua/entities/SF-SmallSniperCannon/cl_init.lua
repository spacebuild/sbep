include('shared.lua')

function ENT:Initialize()
	self.WInfo = "Small Sniper Rifle"
end

function ENT:Draw()
	
	self.Entity:DrawModel()

end
