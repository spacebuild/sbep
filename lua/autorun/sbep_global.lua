--[[
Copyright (C) 2012-2013 Spacebuild Development Team

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]
--
-- Created by IntelliJ IDEA.
-- User: Sam Elmer (Selekton99)
-- Date: 27/11/12
-- Time: 11:08 AM
-- Last Updated :  
--
SBEP = SBEP or {}

SBEP.Version = "\"1.0.0\"" -- Change this for each update



if SERVER then

	CreateConVar("sv_sbep_debug", 0, FCVAR_SERVER_CAN_EXECUTE, "Enable Debug Messages for the Server")

elseif CLIENT then
	CreateClientConVar("cl_sbep_debug", 0, true, false )

end


function DebugMessage( Message )
	if CLIENT then
		if (GetConVar( "cl_sbep_debug" ):GetInt() == 1 ) then
			print("SBEP Debug (CL): "..Message.."\n")
		end
	elseif SERVER then
		if (GetConVar( "sv_sbep_debug" ):GetInt() == 1) then
			print("SBEP Debug (SV): "..Message.."\n")

			--Send Umsg containing errors to SuperAdmins, Admins and Sam Elmer (SteamID)

		end
	end

end

