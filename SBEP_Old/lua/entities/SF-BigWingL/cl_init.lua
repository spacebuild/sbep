include('shared.lua')

function ENT:Initialize()
	self.WingAngle = 0
end

function ENT:Draw()
	--Draw the middle wing
		/*
		You have to modify the model in some way before the engine is willing to redraw it in the same frame. 
		In this case, we're just setting the model scale. Note that you don't actually have to actually change the 
		scale, setting it to the default setting is enough to force a redraw. Even though this is the first time the 
		model is being drawn this frame, it still needs to have the scale set, otherwise the next redraw will overwrite the original.
		Be careful about how many times a model is drawn per frame. Too many can cause serious lag. I learned that to my regret when I made the tank treads.
		*/
	self:SetModelScale( Vector(1,1,1) ) 
	self:SetModel( "models/SmallBridge/Wings/SBwingC1L.mdl" ) 
	self:DrawModel()
	
	local OPos = self:GetPos()
	local OAng = self:GetAngles() + Angle( 0.01, 0.01, 0.01 ) -- The extra angle stops the whole thing from pinwheeling out of control. I have no idea why it works, but it does.
	local SwivPos = (self:GetPos() + (self:GetForward() * -28) + (self:GetRight() * -223) + (self:GetUp() * 18)) -- The vector the wings rotate around
	
	local CAngle = self.WingAngle
	
	--Position and rotate the upper wing
	self:SetModel( "models/SmallBridge/Wings/SBwingM1L.mdl" ) 
	local NAng = OAng - Angle( 0.01, 0.01, 0.01 )
	NAng:RotateAroundAxis( self:GetForward(), -CAngle )
	self:SetAngles( NAng )
	self:SetPos( SwivPos + ( self:GetUp() * 15 ) + NAng:Up() * -18 + NAng:Right() * 111 )
	
	--Draw the upper wing
	self:SetModelScale( Vector(1,1,1) ) 
	self:DrawModel()
	
	--Position and rotate the lower wing
	self:SetModel( "models/SmallBridge/Wings/SBwingM1Le.mdl" ) 
	local NAng = OAng - Angle( 0.01, 0.01, 0.01 )
	self:SetAngles( NAng )
	NAng:RotateAroundAxis( self:GetForward(), CAngle )
	self:SetAngles( NAng )
	self:SetPos( SwivPos + ( self:GetUp() * -15 ) + NAng:Up() * -18 + NAng:Right() * 111 )
	
	--Draw the lower wing
	self:SetModelScale( Vector(1,1,1) ) 
	self:DrawModel()
	
	-- Reset the model to its original position
	self:SetPos( OPos )
	self:SetAngles( OAng - Angle( 0.01, 0.01, 0.01 ) )
	
end

function ENT:Think()

	if self:GetFold() then
		if self.WingAngle < 35 then 
			self.WingAngle = self.WingAngle + 1
		else
			self.WingAngle = 35
		end
	else
		if self.WingAngle > 0 then 
			self.WingAngle = self.WingAngle - 1
		else
			self.WingAngle = 0
		end
	end	

	self:NextThink( CurTime() + 0.01 ) 
	return true
end