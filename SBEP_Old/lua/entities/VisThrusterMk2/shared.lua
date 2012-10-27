ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Jet Thruster"
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

function ENT:SetSize( val )
	if CurTime() > self.NVT then
		local CVal = self:GetSize() or 0
		if val ~= CVal then
			self:SetNetworkedInt("ClSize",val,true)
			self.NVT = CurTime() + 1
		end
	end
end

function ENT:GetSize()
	return self:GetNetworkedInt("ClSize")
end

function ENT:SetLength( val )
	if CurTime() > self.NVT then
		local CVal = self:GetLength() or 0
		if val ~= CVal then
			self:SetNetworkedInt("ClLength",val,true)
			self.NVT = CurTime() + 1
		end
	end
end

function ENT:GetLength()
	return self:GetNetworkedInt("ClLength")
end