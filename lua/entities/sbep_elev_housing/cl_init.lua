include( "shared.lua" ) 
ENT.RenderGroup = RENDERMODE_TRANSCOLOR

function ENT:Draw()
	
	self.Entity:DrawModel()

end