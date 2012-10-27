ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Searchlight"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP - Other"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.TogC			= 0
ENT.HPType			= "Small"
ENT.APPos			= Vector(15,0,0)
ENT.WInfo			= "Searchlight"

function ENT:SetActive( val )
	self:SetNetworkedBool("ClActive",val,true)
end

function ENT:GetActive()
	return self:GetNetworkedBool("ClActive")
end
