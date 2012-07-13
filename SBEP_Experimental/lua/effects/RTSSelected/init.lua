
/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	local Pos = data:GetOrigin()
	local Mag = data:GetMagnitude()
	
	self.Scale = Mag / 45
		
	self.Entity:SetPos( Pos )
		
	local Life = 0.1
	
	self.LTime = CurTime() + Life
	
	self:SetMaterial("models/shiny")
	self:SetModel("models/props_phx/construct/metal_plate_curve360.mdl")
	
	self:SetColor(150,255,150,100)
	
	--print("Creating...")
	
end


/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	
	if ( CurTime() > self.LTime ) then return false end
	return true
	
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
	
	self:SetModelScale(Vector(self.Scale,self.Scale,0.1))
	self:DrawModel()

end
