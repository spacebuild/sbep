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
	self.Entity:SetModelScale(1) 
	self.Entity:SetModel( "models/SmallBridge/Wings/SBwingC1L.mdl" ) 
	self.Entity:DrawModel()
	
	local OPos = self.Entity:GetPos()
	local OAng = self.Entity:GetAngles() + Angle( 0.01, 0.01, 0.01 ) -- The extra angle stops the whole thing from pinwheeling out of control. I have no idea why it works, but it does.
	local SwivPos = (self.Entity:GetPos() + (self.Entity:GetForward() * -28) + (self.Entity:GetRight() * -223) + (self.Entity:GetUp() * 18)) -- The vector the wings rotate around
	
	local CAngle = self.WingAngle
	
	--Position and rotate the upper wing
	self.Entity:SetModel( "models/SmallBridge/Wings/SBwingM1L.mdl" ) 
	local NAng = OAng - Angle( 0.01, 0.01, 0.01 )
	NAng:RotateAroundAxis( self.Entity:GetForward(), -CAngle )
	self.Entity:SetAngles( NAng )
	self.Entity:SetPos( SwivPos + ( self.Entity:GetUp() * 15 ) + NAng:Up() * -18 + NAng:Right() * 111 )
	
	--Draw the upper wing
	self.Entity:SetModelScale(1) 
	self.Entity:DrawModel()
	
	--Position and rotate the lower wing
	self.Entity:SetModel( "models/SmallBridge/Wings/SBwingM1Le.mdl" ) 
	local NAng = OAng - Angle( 0.01, 0.01, 0.01 )
	self.Entity:SetAngles( NAng )
	NAng:RotateAroundAxis( self.Entity:GetForward(), CAngle )
	self.Entity:SetAngles( NAng )
	self.Entity:SetPos( SwivPos + ( self.Entity:GetUp() * -15 ) + NAng:Up() * -18 + NAng:Right() * 111 )
	
	--Draw the lower wing
	self.Entity:SetModelScale(1) 
	self.Entity:DrawModel()
	
	-- Reset the model to its original position
	self.Entity:SetPos( OPos )
	self.Entity:SetAngles( OAng - Angle( 0.01, 0.01, 0.01 ) )
	
end

function ENT:Think()

	if self.Entity:GetFold() then
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

	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true
end