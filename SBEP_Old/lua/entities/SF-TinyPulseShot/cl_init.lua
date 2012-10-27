include('shared.lua')
killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

Matt = Material( "sprites/light_glow02_add" )
Matt2 = Material( "models/effects/comball_glow1" )

function ENT:Initialize()

end

function ENT:Draw()
	
	render.SetMaterial( Matt )	
	local color = Color( 255, 180, 180, 150 )
	render.DrawSprite( self.Entity:GetPos(), 150, 150, color )
	
	render.SetMaterial( Matt2 )	
	local color = Color( 255, 255, 255, 255 )
	render.DrawSprite( self.Entity:GetPos(), 15, 15, color )
	
	/*
	if !self.DModel then
		self.DModel = ClientsideModel("models/Effects/combineball.mdl", RENDERGROUP_OPAQUE)
	end
	self.DModel:SetModelScale(Vector(0.5,0.5,0.5))
	self.DModel:SetAngles((LocalPlayer():GetPos() - self:GetPos()):GetNormal():Angle())
	self.DModel:SetPos(self:GetPos())
	*/
end

function ENT:Think()
	
end

function ENT:OnRemove()
	if self.DModel then
		self.DModel:Remove()
	end
end