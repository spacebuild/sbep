
include('shared.lua')
--killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))
ENT.RenderGroup = RENDERGROUP_OPAQUE


function ENT:Initialize()
	
	
end

function ENT:Think()
	local Pod = self:GetNetworkedEntity("Pod")
	if Pod and Pod:IsValid() then
		Pod.CalcView = {OffsetUp = 100, OffsetOut = 500}
		--Pod.CalcView.OffsetUp = 5000
		--print(Pod.CalcView)
	end
end

function ENT:Draw()
	
	self.Entity:DrawModel()

end
