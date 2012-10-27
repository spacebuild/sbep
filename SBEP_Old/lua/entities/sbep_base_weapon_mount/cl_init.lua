include('shared.lua')
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Draw()
	
	self:DrawModel()

end

function ENT:Think()
	local HPC = self:GetNetworkedInt("HPC")
	local out = ""
	for HP=1,HPC do
		local Wep = self:GetNetworkedEntity("HPW_"..HP)
		if Wep then
			local Info = Wep.WInfo
			if Info then
				out = out..Info
				if HP ~= HPC then
					out = out..", "
				end
			end
		end
	end
	self.WInfo = out
end
