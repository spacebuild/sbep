include('shared.lua')
killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

function ENT:Initialize()
	local MVar = self.Entity:GetCSModel()
	if !MVar then self.Entity:SetCSModel(0) end
	self.MTable = {}
	self.MTable[0] = "models/Slyfo/rover_tread.mdl"
	self.MTable[1] = "models/Slyfo/rover_tread2.mdl"
	self.MTable[2] = "models/Slyfo/rover_tread2.mdl"
	self.MTable["0I"] = 12
	self.MTable["1I"] = 22
	self.MTable["2I"] = 100
	self.LTable = {}
	self.Entity:SetModel( self.MTable[self.Entity:GetCSModel()] )
	self.Scroll = 0
	self.PrevPos = self.Entity:GetPos()
	self.Straight = true
	self.ILock = self.MTable[self.Entity:GetCSModel().."I"] -- This is the interlock distance for the current tread model
	self.RLimit = 80
end

function ENT:Draw()
	--self.Entity:SetModelScale( Vector(1,1,1) )
	--self.Entity:SetModel( "models/props_phx/construct/metal_plate1.mdl" )
	self.Entity:DrawModel()
	
end

function ENT:Think()
	local Cont = self.Entity:GetCont()
	if Cont and Cont:IsValid() then
		self.Scroll = Cont.Scroll
	else
		
		local Len = (self.Entity:GetLength() * 0.5) + self.Entity:GetRadius() + 10
		local Hei = self.Entity:GetRadius() + (self.Entity:GetSegSize().z * 10)
		local Wid = self.Entity:GetSegSize().y * 100
		--local EPos = self.Entity:GetPos() + (self.Entity:GetForward() * Len)
		--local SPos = self.Entity:GetPos() + (self.Entity:GetForward() * -Len)
		--self.Entity:SetRenderBoundsWS( SPos, EPos )
		
		local FDist = self.PrevPos:Distance( self.Entity:GetPos() + self.Entity:GetForward() * 50 )
		local BDist = self.PrevPos:Distance( self.Entity:GetPos() + self.Entity:GetForward() * -50 )
		self.Scroll = math.fmod(self.Scroll - ((FDist - BDist) * 0.5), self.Entity:GetSegSize().x * self.ILock)
		
		self.PrevPos = self.Entity:GetPos()
		
	end
	
	self.ILock = self.MTable[self.Entity:GetCSModel().."I"]
	
	
	-------------------------------------------------------------------------------------------------------------------------------
	
	local OPos = self.Entity:GetPos()
	local OAng = self.Entity:GetAngles() + Angle( 0.01, 0.01, 0.01 ) -- The extra angle stops the whole thing from pinwheeling out of control. I have no idea why it works, but it does.
	local RCount = 0
	local RModel = self.MTable[self.Entity:GetCSModel()]
	local RAngle = Angle(0,0,0)
			
		--Setting up the origin points for the 4 sections of the tread.
		local LowStrPos = (self.Entity:GetPos() - self.Entity:GetUp() * self.Entity:GetRadius())
		local UppStrPos = (self.Entity:GetPos() + self.Entity:GetUp() * self.Entity:GetRadius())
		local BaCircPos = (self.Entity:GetPos() - self.Entity:GetForward() * self.Entity:GetLength() * 0.5)
		local FrCircPos = (self.Entity:GetPos() + self.Entity:GetForward() * self.Entity:GetLength() * 0.5)
		
		--Drawing the bottom straight section.
		local Scale = self.Entity:GetSegSize()
		local SDist = math.fmod(self.Scroll, Scale.x * self.ILock)
		
		RAngle = self.Entity:GetAngles()
		
		for i = 0 - ((self.ILock * Scale.x) * 0.25), self.Entity:GetLength() + ((self.ILock * Scale.x) * 0.25), Scale.x * self.ILock do
			if self.LTable[RCount] == nil or !self.LTable[RCount]:IsValid() then
				self.LTable[RCount] = ClientsideModel(RModel, RENDERGROUP_OPAQUE)
			end
			self.LTable[RCount]:SetPos( LowStrPos + (self.Entity:GetForward() * (self.Entity:GetLength() * 0.5)) + self.Entity:GetForward() * -i + self.Entity:GetForward() * SDist )
			self.LTable[RCount]:SetModelScale( Scale )
			self.LTable[RCount]:SetAngles( RAngle )
			--self.Entity:DrawModel()
			RCount = RCount + 1
			if RCount > self.RLimit then
				--self.Entity:SetPos( OPos )
				--self.Entity:SetAngles( OAng - Angle( 0.01, 0.01, 0.01 ) )
				break
			end
		end
		
		--Drawing the top straight section.
		local Scale = self.Entity:GetSegSize()
		local SDist = math.fmod(self.Scroll, Scale.x * self.ILock)
		local TAng = OAng - Angle( 0.01, 0.01, 0.01 )
		TAng:RotateAroundAxis( self.Entity:GetRight() , 180 )
		RAngle = TAng
		
		for i = 0 - ((self.ILock * Scale.x) * 0.25), self.Entity:GetLength() + ((self.ILock * Scale.x) * 0.25), Scale.x * self.ILock do
			if self.LTable[RCount] == nil or !self.LTable[RCount]:IsValid() then
				self.LTable[RCount] = ClientsideModel(RModel, RENDERGROUP_OPAQUE)
			end
			self.LTable[RCount]:SetPos( UppStrPos + (self.Entity:GetForward() * (self.Entity:GetLength() * 0.5)) + self.Entity:GetForward() * -i + self.Entity:GetForward() * SDist )
			self.LTable[RCount]:SetModelScale( Scale )
			self.LTable[RCount]:SetAngles(RAngle)
			--self.Entity:DrawModel()
			RCount = RCount + 1
			if RCount > self.RLimit then
				--self.Entity:SetPos( OPos )
				--self.Entity:SetAngles( OAng - Angle( 0.01, 0.01, 0.01 ) )
				break
			end
		end
		
		--Drawing the front curved section.
		local Pie = 3.14159265358 -- Yes, I know it's spelled wrong. Shut up.
		local Scale = self.Entity:GetSegSize()
		--local CircP = (2160 / (Pie * self.Entity:GetRadius()))
		local DegPI = 1 / ((Pie * ( self.Entity:GetRadius() * 2 )) / 360)
		local CircP = DegPI * (Scale.x * self.ILock)
		local SDist = -1 * math.fmod(self.Scroll * DegPI, Scale.x * self.ILock )
		
		for i = 0 + (((self.ILock * Scale.x) * DegPI) * 0.25), 180 - (((self.ILock * Scale.x) * DegPI) * 0.25), CircP do
			if self.LTable[RCount] == nil or !self.LTable[RCount]:IsValid() then
				self.LTable[RCount] = ClientsideModel(RModel, RENDERGROUP_OPAQUE)
			end
			local NAng = OAng - Angle( 0.01, 0.01, 0.01 )
			self.LTable[RCount]:SetAngles( NAng )
			local Sine = math.sin(math.rad(i + SDist)) * self.Entity:GetRadius()
			local CoSine = math.cos(math.rad(i + SDist)) * self.Entity:GetRadius()
			self.LTable[RCount]:SetPos( FrCircPos + (self.Entity:GetForward() * Sine) + (self.Entity:GetUp() * CoSine) )
			NAng:RotateAroundAxis( self.Entity:GetRight(), 180 - (i + SDist) )
			self.LTable[RCount]:SetAngles( NAng )
			self.LTable[RCount]:SetModelScale( Scale )
			--self.Entity:DrawModel()
			RCount = RCount + 1
			if RCount > self.RLimit then
				--self.Entity:SetPos( OPos )
				--self.Entity:SetAngles( OAng - Angle( 0.01, 0.01, 0.01 ) )
				break
			end
		end
		
		--Drawing the back curved section.
		local Pie = 3.14159265358 -- Yes, I know it's spelled wrong. Shut up.
		local Scale = self.Entity:GetSegSize()
		--local CircP = (2160 / (Pie * self.Entity:GetRadius()))
		local DegPI = 1 / ((Pie * ( self.Entity:GetRadius() * 2 )) / 360)
		local CircP = DegPI * (Scale.x * self.ILock)
		local SDist = -1 * math.fmod(self.Scroll * DegPI, Scale.x * self.ILock)
		
		for i = 180 + (((self.ILock * Scale.x) * DegPI) * 0.25), 359 - (((self.ILock * Scale.x) * DegPI) * 0.25), CircP do
			if self.LTable[RCount] == nil or !self.LTable[RCount]:IsValid() then
				self.LTable[RCount] = ClientsideModel(RModel, RENDERGROUP_OPAQUE)
			end
			local NAng = OAng - Angle( 0.01, 0.01, 0.01 )
			self.LTable[RCount]:SetAngles( NAng )
			local Sine = math.sin(math.rad(i + SDist)) * self.Entity:GetRadius()
			local CoSine = math.cos(math.rad(i + SDist)) * self.Entity:GetRadius()
			self.LTable[RCount]:SetPos( BaCircPos + (self.Entity:GetForward() * Sine) + (self.Entity:GetUp() * CoSine) )
			NAng:RotateAroundAxis( self.Entity:GetRight(), 180 - (i + SDist) )
			self.LTable[RCount]:SetAngles( NAng )
			self.LTable[RCount]:SetModelScale( Scale )
			--self.Entity:DrawModel()
			RCount = RCount + 1
			if RCount > self.RLimit then
				--self.Entity:SetPos( OPos )
				--self.Entity:SetAngles( OAng - Angle( 0.01, 0.01, 0.01 ) )
				break
			end
		end
		
		for i = RCount, self.RLimit + 10, 1 do
			if self.LTable[RCount] ~= nil and self.LTable[RCount]:IsValid() then
				self.LTable[i]:Remove()
			end
			self.LTable[i] = nil
		end
		
	--self.Entity:SetPos( OPos )
	--self.Entity:SetAngles( OAng - Angle( 0.01, 0.01, 0.01 ) )
		
	-------------------------------------------------------------------------------------------------------------------------------
	
	self.Entity:NextThink( CurTime() + 0.1 ) 
	return true

end