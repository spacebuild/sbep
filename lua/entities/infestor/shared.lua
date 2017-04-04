ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Infestor"
ENT.Author			= "Paradukes"
ENT.Category		= "SBEP - Other"

ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.Owner			= nil
ENT.SPL				= nil

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Mutation");
	self:DTVar("Float",0,"Energy");
	self:DTVar("Bool",0,"Deploy");
	self:DTVar("Vector",0,"Target");
	self:DTVar("Vector",1,"Origin");
end