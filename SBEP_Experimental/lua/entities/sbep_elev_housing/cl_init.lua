include( "shared.lua" ) 
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Draw()
	
	self.Entity:DrawModel()

end