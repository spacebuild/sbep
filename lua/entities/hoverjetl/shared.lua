ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Hover Jet L"
ENT.Author			= "Paradukes"
ENT.Category		= "SBEP - Rover Gear"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Owner			= nil

function ENT:SetActive( val )
	self.Entity:SetNetworkedBool("ClTracking",val,true)
end

function ENT:GetActive()
	return self.Entity:GetNetworkedBool("ClTracking")
end