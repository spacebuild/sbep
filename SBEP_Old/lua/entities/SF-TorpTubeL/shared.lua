ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Large Torpedo Launcher"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP - Weapons"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Owner			= nil
ENT.CPL				= nil
ENT.HPType			= "Heavy"
ENT.APPos			= Vector(-55,0,0)
ENT.APAng			= Angle(0,180,0)

ENT.Loaded			= false
ENT.Torp			= nil
ENT.LTime			= 0
ENT.Loading			= false

function ENT:SetLVar( val )
	local CVal = self:GetNetworkedInt( "Loading" )
	if CVal ~= val then
		self:SetNetworkedInt( "Loading", val )
	end
end