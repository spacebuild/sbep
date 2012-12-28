--
-- Created by IntelliJ IDEA.
-- User: Sam Elmer (Selekton99)
-- Date: 27/11/12
-- Time: 11:08 AM
-- Last Updated :  
--
SBEP = SBEP or {}

--Version:
SBEP.Version = "\"1.1.0\""

if SERVER then

	CreateConVar("sv_sbep_debug", 0, FCVAR_SERVER_CAN_EXECUTE, "Enable Debug Messages for the Server")

elseif CLIENT then
	CreateClientConVar("cl_sbep_debug", 0, true, false )

end


function DebugMessage( Message )
	if CLIENT then
		if (GetConVar( "cl_sbep_debug" ):GetInt() == 1 ) then
			print("SBEP Debug (CL): "..tostring(Message).."\n")
		end
	elseif SERVER then
		if (GetConVar( "sv_sbep_debug" ):GetInt() == 1) then
			print("SBEP Debug (SV): "..tostring(Message).."\n")

			--TODO: Send Umsg containing errors to SuperAdmins, Admins and Sam (SteamID)

		end
	end

end
