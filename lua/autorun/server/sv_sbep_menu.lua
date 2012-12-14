--
-- Created by IntelliJ IDEA.
-- User: Sam Elmer (Selekton99)
-- Date: 26/11/12
-- Time: 12:45 PM
-- Last Updated :  
--

--Contains the Behind the scenes stuff for the menu
version = "UnavaliableFrom"
function SetSBEPVersion()
	local Type = "EXPORTED"
	--[[
	if the folder .git exists then version is from GIT
	 	Get version
	 elseif the folder .svn exists then
	 	version is SVN
	 else
	  Version = Exported
	 ]]--
	if (file.Exists( ".git", "GAME")) then
		type = "Git"
		version = GetVersion( type )
	elseif (file.Exists(".svn"), "GAME") then
		type = "SVN"
		version = GetVersion( type )
	else
		type = "Unknown"
		version = GetVersion( type )
	end


end

function GetVersion( type )

	if (type == "Git") then
		file.Read("", "GAME\sbep\.git\\") --TODO: Figure out paths and editing this file etc.


	elseif (type == "SVN" ) then
		file.Read("", "GAME\sbep\.git\\")

	else
		return "Unknown"
	end
end


function SetPlyVersion( ply, ip )
	timer.Create("Wait", 1, 1, function ( ply, ip )
		ply:SendLua("serverVersion = "..version.."")
		DebugMessage("Sent Message to player")
	end)

end
hook.Add("PlayerConnect","Send SBEP Version to the client",SetPlyVersion)

