include('shared.lua')

language.Add( "Cleanup_warpdrive", "Warp Drive" )
language.Add( "Cleaned_warpdrive", "Cleaned up Warp Drive" )

function ENT:Draw()
   -- self.BaseClass.Draw(self)
   self:DrawEntityOutline( 0.0 ) 			
   self.Entity:DrawModel() 					
end

function ENT:DrawEntityOutline()
return
end