include('shared.lua')
ENT.RenderGroup = RENDERGROUP_OPAQUE
function ENT:Initialize()
end
function ENT:Draw()	
	self:DrawModel()
end
