include('shared.lua')

local BMat = Material( "tripmine_laser" )
local SMat = Material( "sprites/light_glow02_add" )

ENT.RenderGroup = RENDERGROUP_BOTH

surface.CreateFont ("Trebuchet", { 
font = "TrebuchetH",
size = 25,
weight = 500,
antialias = true,
shadow = false,
} )

function ENT:Initialize()
	self.IncZ = 0
	self.Inc = 0
	self.Alpha = 0
	self.CString = ""
	self.CLDelay = 1
	self.PulseTime = 0
	self.PulseLength = 1
	self.HighClear = 0 --No idea why this is needed, but it is.
	
	self.Boxes = {
			[-22.5] = {
				[1] = -67.5,
				[2] = -22.5,
				[3] =  22.5,
				 OK =  67.5
					},
			[22.5] = {
				[4] = -67.5,
				[5] = -22.5,
				[6] =  22.5,
				[0] =  67.5
					},
			[67.5] = {
				[7] = -67.5,
				[8] = -22.5,
				[9] =  22.5,
				 CL =  67.5
					}
				}
				
	self:SetColors( 200, 200, 230 )
end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:SetupButtons()
	local r,g,b = self:ScaleColor( 17/20 )
    local KCol = Color( r , g , b , self.Alpha * 150 )
    local KColH = Color( self.R , self.G , self.B , self.Alpha * 200 )
	
	self.Buttons = {}
	for y,Row in pairs( self.Boxes ) do
		for label,x in pairs( Row ) do
			local B = holo.Create( "HRect" )
				B:SetSize( 35,35 )
				B:SetColor( KCol )
				B:SetHColor( KColH )
				B:SetPos( x , y )
			self.Buttons[label] = B
		end
	end
end

function ENT:SetColors( R, G, B )

	self.R = R
	self.G = G
	self.B = B
	
	self.BCol = Color( self.R, self.G, self.B , 140 )
	self.SCol = Color( self.R, self.G, self.B , 180 )

	self:SetupButtons()
	
end

function ENT:ScaleColor( fSc )
	local r = math.Clamp( self.R*fSc, 0, 255)
	local g = math.Clamp( self.G*fSc, 0, 255)
	local b = math.Clamp( self.B*fSc, 0, 255)
	
	return r,g,b
end

function ENT:DrawTranslucent()
		
	if self.IncZ > 0 then
		local incZ = self.IncZ --Z increment for transition
		local inc = self.Inc --increment for transition
		local selfpos = self:GetPos()
		local up = self:GetUp()
		
		local Origin = selfpos + up * 3
		
		local Square = {
			self:LocalToWorld( Vector( inc * incZ /  15 , inc * incZ /  15 , incZ ) ),
			self:LocalToWorld( Vector( inc * incZ / -15 , inc * incZ /  15 , incZ ) ),
			self:LocalToWorld( Vector( inc * incZ / -15 , inc * incZ / -15 , incZ ) ),
			self:LocalToWorld( Vector( inc * incZ /  15 , inc * incZ / -15 , incZ ) )
						}
		
		local BCol = self.BCol
		local SCol = self.SCol
		render.SetMaterial( SMat )	
		render.DrawSprite( Origin, 5, 5, SCol )
		for n, Pos in ipairs( Square ) do
			render.SetMaterial( SMat )	
				render.DrawSprite( Pos, 5, 5, SCol )
			render.SetMaterial( BMat )
				render.DrawBeam( Pos, Origin , 10, 0, 0, BCol )
				render.DrawBeam( Pos, Square[ math.fmod(n, 4) + 1 ], 10, 0, 0, BCol )
		end
				
		if inc >= 10 then
			--render.SetMaterial( QMat )
			--render.DrawQuad(Vec2,Vec1,Vec4,Vec3)
			local eyepos = LocalPlayer():GetShootPos()
			
			local W = eyepos - (selfpos + up * 15)
			local N = up
			local AVec = LocalPlayer():GetAimVector()
			local mx,my = gui.MousePos()
			if mx > 0 or my > 0 then
				AVec = gui.ScreenToVector( gui.MousePos() )
			end
			local U = AVec--LocalPlayer():GetAimVector()
			--(-(self:up.(playershootpos - self:pos)) / (self:up.player:aimvec))
			local Upper = N:DotProduct(W)
			local Lower = N:DotProduct(U)
			
			local RDist = -Upper / Lower
			
			local RPos = eyepos + U * RDist
			
			local R = self:WorldToLocal( RPos )
			local RX, RY = R.x * 10, R.y * -10

			cam.Start3D2D( selfpos + up * (incZ + 0.1), self:GetAngles(), 0.1 )

				local R,G,B = self.R, self.G, self.B
				local r,g,b
				local Alpha = self.Alpha
			
				r,g,b = self:ScaleColor( 15/20 )
				draw.RoundedBox( 6, -90, -90, 180, 180, Color( r , g , b , Alpha * 90) )

				r,g,b = self:ScaleColor( 17/20 )
                local KCol = Color( r , g , b , Alpha * 150 )
                local KColH = Color( R , G , B , Alpha * 200 )

				local PTime = math.Clamp((CurTime() - self.PulseTime),0,1) / self.PulseLength
				
				local PCol = Color(Lerp(PTime,R,r),Lerp(PTime,G,g),Lerp(PTime,B,b),Lerp(PTime,KColH.a,KCol.a))
				draw.RoundedBox( 6, -85, -85, 170, 35, PCol )
				
				local Value = ""
				if self.Encrypt then
					for i = 1, self.CString:len() do
						Value = Value.."*"
					end
				else
					Value = self.CString
				end
				if RX >= -85 and RX <= 85 and RY >= -85 and RY <= -50 then
					draw.RoundedBox( 6, -85, -85, 170, 35, KColH )
						local mc = math.Max( self.R, self.G, self.B)
						r,g,b = self:ScaleColor( 1/mc )
					draw.DrawText( Value , "TrebuchetH", 80, -81, Color(r,g,b, 255*Alpha), TEXT_ALIGN_RIGHT )
					self.ManualInput = true
					self:SetHighlighted( 12 )
				else
					local PTime = math.Clamp((CurTime() - self.PulseTime),0,1) / self.PulseLength
					local PCol = Color(Lerp(PTime,KColH.r,KCol.r),Lerp(PTime,KColH.g,KCol.g),Lerp(PTime,KColH.b,KCol.b),Lerp(PTime,KColH.a,KCol.a))
					draw.RoundedBox( 6, -85, -85, 170, 35, PCol )

					draw.DrawText( Value , "TrebuchetH", 80, -81, Color(R,G,B, 255*Alpha), TEXT_ALIGN_RIGHT )
					self.ManualInput = false
				end
				--draw.DrawText( Value , "TrebuchetH", 80, -81, Color(R,G,B, 255), TEXT_ALIGN_RIGHT )
				local Highlight = -1
				
				for label,B in pairs( self.Buttons ) do
					local XY = B:GetPos()
					if RX >= XY.x-17.5 and RX <= XY.x+17.5 and RY >= XY.y-17.5 and RY <= XY.y+17.5 then
						B:SetHL( true )
						B:SetHAlpha( Alpha * 200 )
						B:Draw()
							local mc = math.Max( self.R, self.G, self.B)
							r,g,b = self:ScaleColor( 1/mc )
						draw.DrawText( label , "TrebuchetH", XY.x, XY.y-13, Color( r , g , b , 255*Alpha), TEXT_ALIGN_CENTER )
						local val = label
						if label == "CL" then
							val = 10
						elseif label == "OK" then
							val = 11
						end
						self:SetHighlighted( val )
						Highlight = val
					else
						B:SetHL( false )
						B:SetAlpha( Alpha * 150 )
						B:Draw()
						draw.DrawText( label , "TrebuchetH", XY.x, XY.y-13, Color( R, G, B, 255*Alpha), TEXT_ALIGN_CENTER )
					end
				end
				
				/*for y,Row in pairs( self.Boxes ) do
					for label,x in pairs( Row ) do
						if RX >= x-17.5 and RX <= x+17.5 and RY >= y-17.5 and RY <= y+17.5 then
							draw.RoundedBox( 12, x-17.5, y-17.5, 35, 35, KColH )
								local mc = math.Max( self.R, self.G, self.B)
								r,g,b = self:ScaleColor( 1/mc )
							draw.DrawText( label , "TrebuchetH", x, y-13, Color( r , g , b , 255*Alpha), TEXT_ALIGN_CENTER )
							local val = label
							if label == "CL" then
								val = 10
							elseif label == "OK" then
								val = 11
							end
							self:SetHighlighted( val )
							Highlight = val
						else
							draw.RoundedBox( 6, x-17.5, y-17.5, 35, 35, KCol )
							draw.DrawText( label , "TrebuchetH", x, y-13, Color( R, G, B, 255*Alpha), TEXT_ALIGN_CENTER )
						end
					end*/
					
					--else
					--	draw.RoundedBox( 6, x-17.5, y-17.5, 35, 35, KCol )
					--	draw.DrawText( label , "TargetID", x, y-9, Color(self.R,self.G,self.B, 255), TEXT_ALIGN_CENTER )
					--end
					if Highlight == -1 then --This bit just stops it from clearing the highlighted button even while you're looking at it.
						self.HighClear = self.HighClear + 1
						if self.HighClear > 15 then
							self:SetHighlighted( -1 )
						end
					else
						self.HighClear = 0
					end
					
					--print(Highlight,self:GetHighlighted())
					
					if Highlight ~= self:GetHighlighted() and Highlight ~= -1 then
						self:SetHighlighted( Highlight )
					end
				--end
			cam.End3D2D()
		end
	end
end

function ENT:Think()
	local SDir = (self:GetPos() - LocalPlayer():GetShootPos()):Angle()
	local PDir = LocalPlayer():GetAimVector():Angle() -- Best to get rid of the roll on both angles, just to make sure they're compared fairly.

	local PDif = math.abs(math.AngleDifference(SDir.p, PDir.p))
	local YDif = math.abs(math.AngleDifference(SDir.y, PDir.y))

	local plypos = self:WorldToLocal( LocalPlayer():GetShootPos() )

	if plypos.x >= -100 and plypos.x <= 100 and plypos.y >= -100 and plypos.y <= 100 and plypos.z >= 0 and plypos.z <= 100 and YDif <= 30 and PDif <= 30 then
		if self.PermA then
			self.IncZ = 15
			self.Inc  = 10
		else
			if self.IncZ < 15 then
				self.IncZ = math.Approach(self.IncZ, 15, .3)
			elseif self.Inc < 10 then
				self.Inc = math.Approach(self.Inc, 10, .2)
			end
		end
		if self.IncZ >= 15 and self.Inc >= 10 and self.Alpha < 1 then
			self.Alpha = math.Approach(self.Alpha, 1, .05)
			if !self.Persist then
				self.CString = ""
			end
		end
		
		if LocalPlayer():KeyPressed( IN_USE ) or (input.IsMouseDown(MOUSE_FIRST) and !self.MTog) then
			self.MTog = true
			local val = self:GetHighlighted()
			if val == 10 then
				self.CString = ""
			elseif val == 11 then
				RunConsoleCommand( "HoloPadSetVar" , self:EntIndex() , self.CString )
					if self.CLDelay or self.CLDelay < 0 then
						timer.Simple( self.CLDelay, function() self.CString = "" end)
					end
				self.PulseTime = CurTime()
			else
				if val >= 0 and val <= 9 then
					if string.len( self.CString ) <= 22 then -- 22 seems a reasonable length. Quite generous, in fact...
						self.CString = self.CString..tostring(val)
					end
				end
			end
		elseif !input.IsMouseDown(MOUSE_FIRST) then
			self.MTog = false
		end
		
		if self.ManualInput then
			local Key = -1
			for n = 1,10 do
				--print(n)
			end
		end
	elseif self.IncZ > 0 then
		self.Alpha = math.Approach(self.Alpha, 0, .05)
		if self.PermA then
			self.IncZ = 15
			self.Inc  = 10
		elseif self.Alpha <= 0 then
			self.Inc = math.Approach(self.Inc, 0, .2)
			if self.Inc <= 0 then
				self.IncZ = math.Approach(self.IncZ, 0, .3)
			end
		end
	else
		if self.PermA then
			self.IncZ = 15
			self.Inc  = 10
		else
			self.IncZ = 0
			self.Inc = 0
		end
		self.Alpha = 0
	end
end
