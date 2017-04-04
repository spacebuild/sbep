
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
function EFFECT:Init( data ) 
 	 
 	-- This is how long the spawn effect
 	-- takes from start to finish.
 	self.Time = 0.2
 	self.LifeTime = CurTime() + self.Time
 	
 	self.Vec1 = data:GetOrigin()
 	self.Vec2 = data:GetStart() 	
 	self.Magn = data:GetMagnitude() or 1
 		
 	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
 	self.Entity:SetMaterial("models/alyx/emptool_glow")
 	self.Entity:SetPos( self.Vec1 )
 	self.Matt = Material( "tripmine_laser" )
end 
   
   
 /*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
function EFFECT:Think( )
	
	self.Entity:NextThink( CurTime() + 0.01 )
	return ( self.LifeTime > CurTime() )  	 
end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
function EFFECT:Render()
	render.SetMaterial( self.Matt )
	render.DrawBeam( self.Vec1, self.Vec2, 10, 0, 0, Color( 100, 255, 100, 255 ) ) 
end  