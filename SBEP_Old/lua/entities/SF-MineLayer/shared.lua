ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Mine Layer"
ENT.Author			= "Paradukes"
ENT.Category		= "SBEP - Weapons"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Owner			= nil
ENT.SPL				= nil
ENT.MCDown			= 0
ENT.CDown1			= true
ENT.CDown1			= 0
ENT.CDown2			= true
ENT.CDown2			= 0
ENT.HPType			= "Medium"
ENT.APPos			= Vector(0,0,-30)
ENT.APAng			= Angle(0,0,180)

function ENT:ShotsAdd(ShotsAdd)
	local Shots = self.Entity:GetNetworkedInt("Shots")
	Shots = Shots + ShotsAdd
	self.Entity:SetNetworkedInt("Shots",Shots)
end