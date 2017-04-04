ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Gold-Fish"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP - Weapons"

ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.Armed			= false
ENT.Exploded		= false
ENT.HPType			= "Heavy"
ENT.APPos			= Vector(0,0,-30)
ENT.APAng			= Angle(0,0,180)

function ENT:SetArmed( val )
	self.Entity:SetNetworkedBool("ClArmed",val,true)
end

function ENT:GetArmed()
	return self.Entity:GetNetworkedBool("ClArmed")
end