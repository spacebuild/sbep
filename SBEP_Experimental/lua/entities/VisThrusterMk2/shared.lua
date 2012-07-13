ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Jet Thruster"
ENT.Author			= "Paradukes"
ENT.Category		= "SBEP - Other"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.NVT				= 0


function ENT:SetActive( val )
	self.Entity:SetNetworkedBool("ClActive",val,true)
end

function ENT:GetActive()
	return self.Entity:GetNetworkedBool("ClActive")
end

function ENT:SetSize( val )
	if CurTime() > self.NVT then
		local CVal = self.Entity:GetSize() or 0
		if val ~= CVal then
			self.Entity:SetNetworkedInt("ClSize",val,true)
			self.NVT = CurTime() + 1
		end
	end
end

function ENT:GetSize()
	return self.Entity:GetNetworkedInt("ClSize")
end

function ENT:SetLength( val )
	if CurTime() > self.NVT then
		local CVal = self.Entity:GetLength() or 0
		if val ~= CVal then
			self.Entity:SetNetworkedInt("ClLength",val,true)
			self.NVT = CurTime() + 1
		end
	end
end

function ENT:GetLength()
	return self.Entity:GetNetworkedInt("ClLength")
end