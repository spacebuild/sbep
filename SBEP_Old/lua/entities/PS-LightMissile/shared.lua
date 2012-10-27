ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Light Missile"
ENT.Author			= "Paradukes + Punisher"
ENT.Category		= "SBEP - Weapons"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Armed			= false
ENT.Exploded		= false
ENT.HPType			= { "Small", "Tiny" }
ENT.APPos			= Vector(0,0,0)
ENT.WInfo			= "Light Missile"

function ENT:SetArmed( val )
	self.Entity:SetNetworkedBool("ClArmed",val,true)
end

function ENT:GetArmed()
	return self.Entity:GetNetworkedBool("ClArmed")
end