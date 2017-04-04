ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "SB Light MAC"
ENT.Author			= "Paradukes"
ENT.Category		= "SBEP - Weapons"

ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.Owner			= nil
ENT.SPL				= nil
ENT.CDown			= true
ENT.CDown			= 0
ENT.Charge			= 0
ENT.Charging		= false
ENT.SmTime			= 0
ENT.SpTime			= 0

ENT.HPType			= "Huge"
ENT.APPos			= Vector(275,0,50)
ENT.APAng			= Angle(0,0,0)

function ENT:SetBrightness( _in_ )
	self:SetNetworkedVar( "Brightness", _in_ )
end
function ENT:GetBrightness()
	return self:GetNetworkedVar( "Brightness", 1 )
end
