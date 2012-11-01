if (SERVER) then
	player_manager.AddValidModel( "SBEPRedHEV", "models/SBEP Player Models/redhevsuit.mdl" ) 
	player_manager.AddValidModel( "SBEPBlueHEV", "models/SBEP Player Models/bluehevsuit.mdl" )
	player_manager.AddValidModel( "SBEPOrangeHEV", "models/SBEP Player Models/orangehevsuit.mdl" )
	player_manager.AddValidModel( "female_01_jumpsuit",		"models/player/Female/female_01_jumpsuit.mdl" )
	AddCSLuaFile( "sbep_player_models.lua" )
end

list.Set( "PlayerOptionsModel",  "SBEPRedHEV", "models/SBEP Player Models/redhevsuit.mdl" )
list.Set( "PlayerOptionsModel",  "SBEPBlueHEV", "models/SBEP Player Models/bluehevsuit.mdl" )
list.Set( "PlayerOptionsModel",  "SBEPOrangeHEV", "models/SBEP Player Models/orangehevsuit.mdl" )
list.Set( "PlayerOptionsModel", "female_01_jumpsuit", "models/player/Female/female_01_jumpsuit.mdl" )

local NPC =
{
	Name = "Red HEVSuit Guy",
	Class = "npc_citizen",
	KeyValues =
	{
		citizentype = 4
	},
	Model = "models/SBEP Player Models/redhevsuit.mdl",
	Health = "150",
	Category = "Humans + Resistance"
}

list.Set( "NPC", "npc_redhevsuit", NPC )

local NPC =
{
	Name = "Blue HEVSuit Guy",
	Class = "npc_citizen",
	KeyValues =
	{
		citizentype = 4
	},
	Model = "models/SBEP Player Models/bluehevsuit.mdl",
	Health = "150",
	Category = "Humans + Resistance"
}

list.Set( "NPC", "npc_bluehevsuit", NPC )

local NPC =
{
	Name = "Orange HEVSuit Guy",
	Class = "npc_citizen",
	KeyValues =
	{
		citizentype = 4
	},
	Model = "models/SBEP Player Models/orangehevsuit.mdl",
	Health = "150",
	Category = "Humans + Resistance"
}

list.Set( "NPC", "npc_orangehevsuit", NPC )

local NPC =
{
	Name = "Female 01 Jumpsuit",
	Class = "npc_citizen",
	KeyValues =
	{
		citizentype = 4
	},
	Model = "models/player/Female/female_01_jumpsuit.mdl",
	Health = "150",
	Category = "Humans + Resistance"
}

list.Set( "NPC", "npc_female_01_jumpsuit", NPC )