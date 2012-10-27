ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Space Mine"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP - Weapons"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Armed			= false
ENT.Exploded		= false
ENT.MineProof		= true
--ENT.HPType		= "Large"
--ENT.APPos			= Vector(-100,100,-30)
ENT.Tracking		= false
ENT.Target			= nil


function ENT:SetArmed( val )
	self:SetNetworkedBool("ClArmed",val,true)
end

function ENT:GetArmed()
	return self:GetNetworkedBool("ClArmed")
end

function ENT:SetTracking( val )
	self:SetNetworkedBool("ClTracking",val,true)
end

function ENT:GetTracking()
	return self:GetNetworkedBool("ClTracking")
end