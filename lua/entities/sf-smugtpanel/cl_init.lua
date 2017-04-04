include('shared.lua')
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()

end

function ENT:Draw()
	
	self.Entity:DrawModel()

end
