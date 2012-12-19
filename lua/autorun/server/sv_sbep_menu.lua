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
-- Created by IntelliJ IDEA.
-- User: Sam Elmer (Selekton99)
-- Date: 26/11/12
-- Time: 12:45 PM
-- Last Updated :  
--

--Contains the Behind the scenes stuff for the menu

net.Receive( "Requesting SBEP Version Info", function (len, ply )

--Send the Table to server
	net.Start("Send SV SBEP Info")
	net.WriteString(SBEP.Version)
	net.Send(ply)

end)


--Precache Net Strings
function CacheNetStrings()
	util.AddNetworkString("Send SV SBEP Info")
	util.AddNetworkString("Requesting SBEP Version Info")
end
hook.Add( "Initialize" , "Precache Net Strings for SBEP", CacheNetStrings )

