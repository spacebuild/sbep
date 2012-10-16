ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Vortex Thruster"
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

function ENT:SetSkin( val )
	if CurTime() > self.NVT then
		local CVal = self.Entity:GetLength() or 0
		if val ~= CVal then
			self.Entity:SetNetworkedInt("ClLength",val,true)
			self.NVT = CurTime() + 1
			print("Setting")
		end
	end
end

function ENT:GetSkin()
	return self.Entity:GetNetworkedInt("ClLength")
end