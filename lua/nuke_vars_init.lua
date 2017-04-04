if SERVER then
	function SyncNukeVars()
		SetGlobalInt("nuke_yield", GetConVar("nuke_yield"):GetInt())
		SetGlobalInt("nuke_waveresolution", GetConVar("nuke_waveresolution"):GetInt())
		SetGlobalInt("nuke_ignoreragdoll", GetConVar("nuke_ignoreragdoll"):GetInt())
		SetGlobalInt("nuke_breakconstraints", GetConVar("nuke_breakconstraints"):GetInt())
		SetGlobalInt("nuke_disintegration", GetConVar("nuke_disintegration"):GetInt())
		SetGlobalInt("nuke_damage", GetConVar("nuke_damage"):GetInt())
		SetGlobalInt("nuke_epic_blastwave", GetConVar("nuke_epic_blastwave"):GetInt())
		SetGlobalInt("nuke_radiation_duration", GetConVar("nuke_radiation_duration"):GetInt())
		SetGlobalInt("nuke_radiation_damage", GetConVar("nuke_radiation_damage"):GetInt())
	end

	if GetConVarString("nuke_yield") == "" then --if one of them doesn't exists, then they all probably don't exist
		CreateConVar("nuke_yield", 200, bit.bor(FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE))
		CreateConVar("nuke_waveresolution", 0.2, bit.bor(FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE))
		CreateConVar("nuke_ignoreragdoll", 1, bit.bor(FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE))
		CreateConVar("nuke_breakconstraints", 1, bit.bor(FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE))
		CreateConVar("nuke_disintegration", 1, bit.bor(FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE))
		CreateConVar("nuke_damage", 100, bit.bor(FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE))
		CreateConVar("nuke_epic_blastwave", 1, bit.bor(FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE))
		CreateConVar("nuke_radiation_duration", 0, bit.bor(FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE))
		CreateConVar("nuke_radiation_damage", 0, bit.bor(FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE))
	end
	
	cvars.AddChangeCallback("nuke_yield", SyncNukeVars)
	cvars.AddChangeCallback("nuke_waveresolution", SyncNukeVars)
	cvars.AddChangeCallback("nuke_ignoreragdoll", SyncNukeVars)
	cvars.AddChangeCallback("nuke_breakconstraints", SyncNukeVars)
	cvars.AddChangeCallback("nuke_disintegration", SyncNukeVars)
	cvars.AddChangeCallback("nuke_damage", SyncNukeVars)
	cvars.AddChangeCallback("nuke_epic_blastwave", SyncNukeVars)
	cvars.AddChangeCallback("nuke_radiation_duration", SyncNukeVars)
	cvars.AddChangeCallback("nuke_radiation_damage", SyncNukeVars)
	SyncNukeVars()
	
	resource.AddFile("models/player/charple01.mdl")
	resource.AddFile("models/player/charple01.phy")
	resource.AddFile("models/player/charple01.vvd")
	resource.AddFile("models/player/charple01.dx90.vtx")
end