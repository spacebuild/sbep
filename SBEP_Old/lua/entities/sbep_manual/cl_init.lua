include('shared.lua')

function ENT:Draw()	
   self.Entity:DrawModel() 					
end
   
local function OpenMenu( um )

	SBEPDoc.OpenManual()

end
usermessage.Hook("OpenSBEPManual", OpenMenu )