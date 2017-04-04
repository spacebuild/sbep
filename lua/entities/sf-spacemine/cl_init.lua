include('shared.lua')
killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

function ENT:Initialize()
	self.Blipping = false
	self.Blip = false
	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	self.Entity:DrawModel()

	render.SetMaterial( self.Matt )	
	local color = Color( 200, 60, 60, 200 )
	if self.Blip then
		render.DrawSprite( self.Entity:GetPos() + self.Entity:GetUp() * 70, 100, 100, color )
		render.DrawSprite( self.Entity:GetPos() + self.Entity:GetUp() * -70, 100, 100, color )
	end
end

function ENT:Think()
	
	if self:GetTracking() then
		
		if !self.Blipping then
			timer.Simple(1.5,function() 
			self.Blip = true 
			timer.Simple(0.1,function() self.Blip = false 
										self.Blipping = false 
							end)
			end)
			self.Blipping = true
		end
			
		if self.Blip then
			if LocalPlayer():GetInfoNum( "SBEPLighting", 1 ) > 0 then
				local dlight = DynamicLight( self:EntIndex() )
				if ( dlight ) then
					--local r, g, b, a = self:GetColor()
					dlight.Pos = self:GetPos() + self:GetUp() * 70
					dlight.r = 200
					dlight.g = 60
					dlight.b = 60
					dlight.Brightness = 5
					dlight.Decay = 200 * 5
					dlight.Size = 200
					dlight.DieTime = CurTime() + 1
				end
				
				local dlight = DynamicLight( self:EntIndex() )
				if ( dlight ) then
					--local r, g, b, a = self:GetColor()
					dlight.Pos = self:GetPos() + self:GetUp() * -70
					dlight.r = 200
					dlight.g = 60
					dlight.b = 60
					dlight.Brightness = 5
					dlight.Decay = 200 * 5
					dlight.Size = 200
					dlight.DieTime = CurTime() + 1
				end
			end
		
		end
	
	end
		
end