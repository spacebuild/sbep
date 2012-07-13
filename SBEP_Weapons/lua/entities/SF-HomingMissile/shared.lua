ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Homing Missile"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP - Weapons"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Armed			= false
ENT.Exploded		= false
ENT.MineProof		= true
--ENT.HPType		= "Large"
--ENT.APPos			= Vector(-100,100,-30)
ENT.Tracking		= false
ENT.Target			= nil


function ENT:SetArmed( val )
	self.Entity:SetNetworkedBool("ClArmed",val,true)
end

function ENT:GetArmed()
	return self.Entity:GetNetworkedBool("ClArmed")
end

function ENT:SetTracking( val )
	self.Entity:SetNetworkedBool("ClTracking",val,true)
end

function ENT:GetTracking()
	return self.Entity:GetNetworkedBool("ClTracking")
end