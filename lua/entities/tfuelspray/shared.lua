ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Fuel Spray"
ENT.Author			= "Paradukes"
--ENT.Category		= "SBEP-Weapons"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:Burn()
	self.Entity:SetNetworkedBool("Burning",true,true)
end

function ENT:IsBurning()
	return self.Entity:GetNetworkedBool("Burning")
end

function ENT:Puddle()
	self.Entity:SetNetworkedBool("Puddle",true,true)
end

function ENT:IsPuddle()
	return self.Entity:GetNetworkedBool("Puddle")
end