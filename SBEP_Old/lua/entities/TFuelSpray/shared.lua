ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Fuel Spray"
ENT.Author			= "Paradukes"
--ENT.Category		= "SBEP-Weapons"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:Burn()
	self:SetNetworkedBool("Burning",true,true)
end

function ENT:IsBurning()
	return self:GetNetworkedBool("Burning")
end

function ENT:Puddle()
	self:SetNetworkedBool("Puddle",true,true)
end

function ENT:IsPuddle()
	return self:GetNetworkedBool("Puddle")
end