include('shared.lua')
killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

function ENT:Initialize()
	self.Matt = Material( "sprites/light_glow02_add" )
	self.ESin = 0
	self.ESin2 = 0
	self.FSize = 0
	
	local egg = ClientsideModel( "models/props_phx/misc/egg.mdl" , RENDERGROUP_BOTH )
	egg:SetPos(self:GetPos() + self:GetForward() * -25)
	egg:SetParent(self)
	egg:SetMaterial("spacebuild/Fusion2")
	egg:SetLocalAngles(Angle(-90,0,0))
	egg:SetModelScale(0)
	egg:SetRenderBounds( Vector(50,50,50), Vector(-50,-50,-50) )
	self.JFlame = egg
	
	local egg2 = ClientsideModel( "models/props_phx/misc/egg.mdl" , RENDERGROUP_BOTH )
	egg2:SetPos(self:GetPos() + self:GetForward() * -25)
	egg2:SetParent(self)
	egg2:SetMaterial("models/shadertest/predator")
	egg2:SetLocalAngles(Angle(-90,0,0))
	egg2:SetModelScale(0)
	egg2:SetRenderBounds( Vector(50,50,50), Vector(-50,-50,-50) )
	
	self.JDist = egg2
end

function ENT:Draw()
	self.ESin = math.fmod(self.ESin + 5, 360)
	self.ESin2 = math.fmod(self.ESin2 + 3, 360)
	
	local ESA1 = math.sin(math.rad(self.ESin)) * 70
	local ESA2 = math.sin(math.rad(self.ESin2)) * 60
	
		
	self.Entity:DrawModel()
	
	render.SetMaterial( self.Matt )	
	local color = Color( 190, 210, 255, 255 )
	if self:GetArmed() then
		local Flare = self.FSize * 0.15
		render.DrawSprite( (self.Entity:GetPos() + self:GetForward() * -35), 100 * Flare, (400 + ESA1) * Flare, color )
		render.DrawSprite( (self.Entity:GetPos() + self:GetForward() * -35), (400 - ESA1) * Flare, 100 * Flare, color )
		render.DrawSprite( (self.Entity:GetPos() + self:GetForward() * -35), (200 + ESA2) * Flare, (200 + ESA2) * Flare, color )
		--render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * 100 + self.Entity:GetForward() * 40, 500, 500, color )
		--render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * 100 + self.Entity:GetForward() * -40, 500, 500, color )
		
		self.FSize = math.Approach(self.FSize, 5, 1)
		local FS2 = self.FSize * 1.2
		
		self.JFlame:SetModelScale(math.Clamp(self.FSize,0,0.7))
		self.JDist:SetModelScale(math.Clamp(FS2,0,1.2))
	end

end

function ENT:Think()
	if LocalPlayer():GetInfoNum( "SBEPLighting", 1 ) > 0 then
		if self:GetArmed() then
		
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				--local r, g, b, a = self:GetColor()
				dlight.Pos = self:GetPos() //+ self:GetRight() * 50
				dlight.r = 190
				dlight.g = 210
				dlight.b = 255
				dlight.Brightness = 8
				dlight.Decay = 500 * 5
				dlight.Size = 110
				dlight.DieTime = CurTime() + 1
			end
		
		end
	end
end

function ENT:OnRemove()
	self.JFlame:Remove()
	self.JDist:Remove()
end