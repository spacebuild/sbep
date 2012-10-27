ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Vortex Thruster"
ENT.Author			= "Paradukes"
ENT.Category		= "SBEP - Other"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.NVT				= 0


function ENT:SetActive( val )
	self:SetNetworkedBool("ClActive",val,true)
end

function ENT:GetActive()
	return self:GetNetworkedBool("ClActive")
end

function ENT:SetSkin( val )
	if CurTime() > self.NVT then
		local CVal = self:GetLength() or 0
		if val ~= CVal then
			self:SetNetworkedInt("ClLength",val,true)
			self.NVT = CurTime() + 1
			print("Setting")
		end
	end
end

function ENT:GetSkin()
	return self:GetNetworkedInt("ClLength")
end