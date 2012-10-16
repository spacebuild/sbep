ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Engine"
ENT.Author			= "Paradukes + SlyFo"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:SetupDataTables()
	self:DTVar("Float",0,"Speed");
end