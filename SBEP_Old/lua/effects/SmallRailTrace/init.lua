
 --[[--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------]] 
 function EFFECT:Init( data ) 
 	 
 	-- This is how long the spawn effect  
 	-- takes from start to finish. 
 	self.Time = 1
 	self.LifeTime = CurTime() + self.Time 
	
 	self.vScale = data:GetScale()
 	self.vOffset = data:GetOrigin()
 	self.vStart = data:GetStart()
	
 	self.TMat = Material( "tripmine_laser" )
 		
	self.Entity:SetRenderBoundsWS( self.vStart, self.vOffset )
	
 	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" ) 
 	self.Entity:SetPos( self.vOffset )  
 end 
   
   
 --[[--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------]] 
 function EFFECT:Think( ) 
   
 	return ( self.LifeTime > CurTime() )  
 	 
 end 
   
   
   
 --[[--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------]] 
function EFFECT:Render() 
	local Alph = Lerp(self.LifeTime - CurTime(), 0, math.Clamp(150 + (self.vScale * 5),0,255))
	local Wid = Lerp(self.LifeTime - CurTime(), (self.vScale * 4), (self.vScale * 2) + 10)
	render.SetMaterial( self.TMat )
	local Scroll = math.fmod(CurTime()*3,128)
	render.DrawBeam( self.vStart, self.vOffset, Wid, Scroll + 5, Scroll, Color( 255, 70, 20, Alph ) ) 
	--print(Wid)
end  