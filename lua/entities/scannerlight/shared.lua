ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Turret Light"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP - Other"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.TogC			= 0
ENT.HPType			= "Tiny"
ENT.APPos			= Vector(5,0,0)
ENT.WInfo			= "Searchlight"

function ENT:SetupDataTables()
	self:DTVar("Bool",0,"Active");
end