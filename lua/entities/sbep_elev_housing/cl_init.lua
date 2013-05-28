include( "shared.lua" ) 
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Draw()
	
	self.Entity:DrawModel()

end

function ENT:DrawTranslucent()
	self.Entity:DrawModel()
end