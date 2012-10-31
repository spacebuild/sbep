include( "shared.lua" ) 
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:DrawModel()
end