include('shared.lua')
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Initialize()
	self.WInfo = "Torpedo Tube"
end

function ENT:Draw()
	
	self.Entity:DrawModel()

end

function ENT:Think()
	local LP = self.Entity:GetNetworkedInt("Loading")
	local Suff = ""
	if LP == 0 then
		Suff = "Not Loaded"
	elseif LP == 100 then
		Suff = "Loaded"
	else
		Suff = "Loading: "..math.floor(LP).."%"
	end
	self.WInfo = "Torpedo Tube - "..Suff
end