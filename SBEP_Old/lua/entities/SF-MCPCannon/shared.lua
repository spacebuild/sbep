ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "SB MCP-Cannon"
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
ENT.APPos			= Vector(40,0,-20)
ENT.APAng			= Angle(0,0,180)

function ENT:SetShots( val )
	local CVal = self.Entity:GetNetworkedInt( "Shots" )
	if CVal ~= val then
		self.Entity:SetNetworkedInt( "Shots", val )
	end
end