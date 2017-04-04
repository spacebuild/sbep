ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Medium Torpedo"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP - Weapons"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Armed			= false
ENT.Exploded		= false
ENT.HPType			= "Medium"
ENT.APPos			= Vector(0,0,-13)
ENT.APAng			= Angle(0,0,180)
ENT.WInfo			= "Medium Torpedo"

function ENT:SetArmed( val )
	self.Entity:SetNetworkedBool("ClArmed",val,true)
end

function ENT:GetArmed()
	return self.Entity:GetNetworkedBool("ClArmed")
end