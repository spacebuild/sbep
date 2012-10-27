ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Gold-Fish"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP - Weapons"

ENT.Spawnable		= false
ENT.AdminSpawnable	= true
ENT.Armed			= false
ENT.Exploded		= false
ENT.HPType			= "Heavy"
ENT.APPos			= Vector(0,0,-30)
ENT.APAng			= Angle(0,0,180)

function ENT:SetArmed( val )
	self:SetNetworkedBool("ClArmed",val,true)
end

function ENT:GetArmed()
	return self:GetNetworkedBool("ClArmed")
end