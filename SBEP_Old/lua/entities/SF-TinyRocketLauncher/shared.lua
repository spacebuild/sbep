ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Tiny Rocket Launcher"
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
ENT.HPType			= "Tiny"
ENT.APPos			= Vector(0,0,0)
ENT.WInfo			= "Swarmer Missiles"
ENT.Range 			= 1000

function ENT:SetShots( val )
	local CVal = self:GetNetworkedInt( "Shots" )
	if CVal ~= val then
		self:SetNetworkedInt( "Shots", val )
	end
end