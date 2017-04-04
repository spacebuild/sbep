include('shared.lua')
killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

function ENT:Initialize()
	self.Blipping = false
	self.Blip1 = 0
	self.Blip2 = 0
	self.LBlip = 1
	self.Matt = Material( "sprites/light_glow02_add" )
end

function ENT:Draw()
	
	self.Entity:DrawModel()

	render.SetMaterial( self.Matt )	
	
	if self.Blip1 > 0 then
		local color = Color( 200, 60, 60, self.Blip1 )
		render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * 35 + self.Entity:GetForward() * 10, self.Blip1 * 0.5, self.Blip1 * 0.5, color )
		--self.Blip1 = self.Blip1 - 50
	end
	if self.Blip2 > 0 then
		local color = Color( 60, 60, 200, self.Blip2 )
		render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * -35 + self.Entity:GetForward() * 10, self.Blip2 * 0.5, self.Blip2 * 0.5, color )
		--self.Blip2 = self.Blip2 - 50
	end
end

function ENT:Think()
	
	if self:GetActive() then
		
		if !self.Blipping then
			if self.LBlip == 2 then
				timer.Simple(0.5,function() 
				self.Blip1 = 255 
				timer.Simple(0.5,function() self.Blipping = false end)
				end)
				self.Blipping = true
				self.LBlip = 1
			else
				timer.Simple(0.5,function() 
				self.Blip2 = 255
				timer.Simple(0.5,function() self.Blipping = false end)
				end)
				self.Blipping = true
				self.LBlip = 2
			end
		end
			
		if self.Blip1 == 255 then
			
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				--local r, g, b, a = self:GetColor()
				dlight.Pos = self:GetPos() + self:GetRight() * 35
				dlight.r = 200
				dlight.g = 60
				dlight.b = 60
				dlight.Brightness = 5
				dlight.Decay = 200 * 4
				dlight.Size = 1500
				dlight.DieTime = CurTime() + 1
			end
			
		end
		if self.Blip2 == 255 then
			
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				--local r, g, b, a = self:GetColor()
				dlight.Pos = self:GetPos() + self:GetRight() * -35
				dlight.r = 60
				dlight.g = 60
				dlight.b = 200
				dlight.Brightness = 5
				dlight.Decay = 200 * 4
				dlight.Size = 1500
				dlight.DieTime = CurTime() + 1
			end
		
		end
		
	end
	
	if self.Blip1 > 0 then
		self.Blip1 = self.Blip1 - 10
	end
	if self.Blip2 > 0 then
		self.Blip2 = self.Blip2 - 10
	end
end