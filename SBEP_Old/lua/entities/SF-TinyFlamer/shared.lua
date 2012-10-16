ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Tiny Flamer"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP - Weapons"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Owner			= nil
ENT.SPL				= nil
ENT.HPType			= "Tiny"
ENT.APPos			= Vector(0,0,0)
ENT.FTime			= 0
ENT.WInfo			= "Tiny Flamer"
ENT.Range 			= 400

function ENT:SetActive( val )
	if val ~= self.Entity:GetNetworkedBool("ClActive") then
		self.Entity:SetNetworkedBool("ClActive",val,true)
	end
end

function ENT:GetActive()
	return self.Entity:GetNetworkedBool("ClActive")
end