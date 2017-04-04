ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Gigafish"
ENT.Author			= "Paradukes"
ENT.Category		= "SBEP - Weapons"

ENT.Spawnable		= true
ENT.AdminOnly 		= true
ENT.TogC			= 0

ENT.HPType			= "Heavy"
ENT.APPos			= Vector(10,0,0)
ENT.APAng			= Angle(0,0,90)

function ENT:SetArmed( val )
	self.Entity:SetNetworkedBool("ClArmed",val,true)
end

function ENT:GetArmed()
	return self.Entity:GetNetworkedBool("ClArmed")
end