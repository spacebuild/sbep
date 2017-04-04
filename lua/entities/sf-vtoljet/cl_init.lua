include('shared.lua')

function ENT:Initialize()
 	
 	self.Matt = Material( "sprites/light_glow02_add" )
	self.ESin = 0
	self.ESin2 = 0
	self.FSize = 0
	
	local e = ClientsideModel( "models/props_phx/misc/egg.mdl" , RENDERGROUP_BOTH )
	e:SetPos(self:GetPos() + (self:GetForward() * -25) + (self:GetUp() * 32))
	e:SetParent(self)
	e:SetMaterial("spacebuild/Fusion")
	e:SetLocalAngles(Angle(-90,0,0))
	e:SetModelScale(0)
	e:SetRenderBounds( Vector(50,50,50), Vector(-50,-50,-50) )
	
	self.JFlame = e
	
	local e = ClientsideModel( "models/props_phx/misc/egg.mdl" , RENDERGROUP_BOTH )
	e:SetPos(self:GetPos() + (self:GetForward() * -25) + (self:GetUp() * 32))
	e:SetParent(self)
	e:SetMaterial("models/shadertest/predator")
	e:SetLocalAngles(Angle(-90,0,0))
	e:SetModelScale(0)
	e:SetRenderBounds( Vector(50,50,50), Vector(-50,-50,-50) )
	
	self.JDist = e
end

function ENT:Draw()
	self.ESin = math.fmod(self.ESin + 5, 360)
	self.ESin2 = math.fmod(self.ESin2 + 3, 360)
	
	local ESA1 = math.sin(math.rad(self.ESin)) * 70
	local ESA2 = math.sin(math.rad(self.ESin2)) * 60
	
	self.Entity:DrawModel()
	
	render.SetMaterial( self.Matt )	
	local color = Color( 255, 200, 100, 255 )
	if self.dt.Speed > 0 then
	
		self.FSize = math.Clamp(self.dt.Speed * 0.3, 0, 50)
		
		local fw = (40 + (self.FSize * 0.6)) * -1
		local v = self:GetPos() + (self:GetForward() * fw) + (self:GetUp() * 32)
		
		local Flare = self.FSize * 0.15
		render.DrawSprite( v, 100 * Flare, (400 + ESA1) * Flare, color )
		render.DrawSprite( v, (400 - ESA1) * Flare, 100 * Flare, color )
		render.DrawSprite( v, (200 + ESA2) * Flare, (200 + ESA2) * Flare, color )
		--render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * 100 + self.Entity:GetForward() * 40, 500, 500, color )
		--render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * 100 + self.Entity:GetForward() * -40, 500, 500, color )
		
		local FS1 = self.FSize * 0.3
		local FS2 = self.FSize * 0.2
		
		local FSW = 0.4
		local FSL = 1
		
		self.JFlame:SetModelScale(FS1 * FSW)
		self.JDist:SetModelScale(FS2 * FSL)
	end
end


function ENT:OnRemove()
	self.JFlame:Remove()
	self.JDist:Remove()
end