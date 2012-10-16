ENT.Type			      = "anim"
ENT.Base                  = "base_gmodentity"
ENT.PrintName		      = "Elevator System"
ENT.Author			      = "Hysteria"
ENT.Category			  = "SBEP"

ENT.Spawnable			  = false
ENT.AdminSpawnable		  = false

ENT.Purpose 		      = ""

function ENT:SetupDataTables()

	self:DTVar( "Int", 1, "ActivePart" );
	-- self:DTVar( "Bool", 0, "On" );
	-- self:DTVar( "Vector", 0, "vecTrack" );
	-- self:DTVar( "Entity", 0, "entTrack" );

end