

--EFFECT.Mat = Material( "shiny" )

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	local Pos = data:GetOrigin()
		
	self.Entity:SetPos( Pos )
		
	local Life = 0.5
	
	self.LTime = CurTime() + Life
	
	self:SetMaterial("models/shiny")
	self:SetModel("models/props_phx/construct/metal_dome360.mdl")
	
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
	self:SetModel("models/props_phx/construct/metal_dome360.mdl")
	self:SetModelScale(Vector(0.5,0.5,0.5))
	self:DrawModel()
	self:SetModel("models/props_phx/construct/metal_plate_curve360.mdl")
	self:SetModelScale(Vector(2,2,0.1))
	self:DrawModel()
end
