
include('shared.lua')
--killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))
ENT.RenderGroup = RENDERGROUP_OPAQUE
local matHeatWave = Material( "sprites/heatwave" )

function ENT:Initialize()
	self.CSModels = {}
		
end

function ENT:Draw()
	
	--if !self.Built then self.Entity:DrawModel() end
	self.Entity:DrawModel()

end

function ENT:OnRemove()
	for k,e in pairs(self.CSModels) do
		e:Remove()
	end
end

function MicroShipBuildSegment( um )
	local Ent, Str, Vec, Ang, Scale = um:ReadEntity(), um:ReadString(), um:ReadVector(), um:ReadAngle(), um:ReadFloat()
	
	if !(Ent and Ent:IsValid()) then return end
	
	local e = ClientsideModel( Str, RENDERGROUP_OPAQUE )
	e:SetModelScale(Vector(Scale,Scale,Scale))
	e:SetPos(Ent:GetPos() + (Vec * Scale))
	e:SetAngles(Ang)
	e:SetParent(Ent)
	
	Ent.Built = true
	table.insert(Ent.CSModels,e)
	
	
end
usermessage.Hook("MicroShipBuildSegment", MicroShipBuildSegment)