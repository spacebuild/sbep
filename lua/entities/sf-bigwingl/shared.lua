ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "S-Foils - Left"
ENT.Author			= "Paradukes"
ENT.Category		= "SBEP - Other"

ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.Owner			= nil
ENT.SPL				= nil
ENT.HPType			= "RLeftPanel"
ENT.APPos			= Vector(0,-223,18)
ENT.APAng			= Angle(0,0,180)
ENT.HasHardpoints	= true


function ENT:SetFold( val )
	self:SetNetworkedBool( "FoldA", val )
end
function ENT:GetFold()
	return self:GetNetworkedBool( "FoldA" )
end