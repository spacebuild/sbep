--
-- Created by IntelliJ IDEA.
-- User: Sam Elmer (Selekton99)
-- Date: 19/11/12
-- Time: 8:22 AM
-- Last Updated :  
--

--TODO: Html Panel for Error Reporting
--TODO: Create a New way to submit Issues using the Git APi.

CreateClientConVar("sbep_disable_menu", 0, true, false )


local serverVersion = "Unknown"
local LatestVersion = "Unknown"

local ClientMsg, ServerMsg, ClientInfo, hash, behind
local SVTimesPressed = 0
local CheckClientVersion,CheckServerVersion
local buttonPressedCl = false





function RequestSvInfo()
	DebugMessage("SVTimesPressed: "..SVTimesPressed)
	if (SVTimesPressed < 10) then
		net.Start("Requesting SBEP Version Info")
		net.WriteEntity(LocalPlayer())
		net.SendToServer()
		SVTimesPressed = SVTimesPressed + 1
	end
end

net.Receive("Send SV SBEP Info", function(len)
	ServerVersion = net.ReadString()
	GetLatest("server")
end)

function setVersionSV( body, length, headers, code )

	DebugMessage(body)
	local page = string.Explode(",", body )
	local Matches = {}
	for k,v in pairs(page) do
		if (string.match(v,"\"%t%i%t%l%e\"%:")) then
			local tempTable = string.Explode("\"%t%i%t%l%e\"%:",v,true)
			local title = table.concat(tempTable)
			DebugMessage("Found Version: "..title)
			table.insert( Matches, title )
		end
	end
	local highestSoFar = "\"0.0.1\""
	for k,v in pairs(Matches) do
		DebugMessage("Highest So Far is "..highestSoFar)
		DebugMessage("V is "..v)
		if ( v > highestSoFar ) then
			highestSoFar = v
			DebugMessage("Highest So Far is "..highestSoFar)
		end
	end

	--Change the String:
	latestVersion = highestSoFar
	--latestVersion = table.concat(tempTable)
	          --sort by dates or compare all versions

	--The Highest is at the top of the page: therefore k = 1 for the latest
	--LatestString = string.sub( Matches[1], 8)
	if(latestVersion == SBEP.Version) then
		ServerInfo:SetText( "The Server is up-to-date on version: "..SBEP.Version..". \nPlease report this version when reporting issues so we can track it." )
	else
		ServerInfo:SetText( "The Server is behind!! The Server has version: "..SBEP.Version..". \nThe latest version is: "..latestVersion..". \nPlease notify the admin and get him to update before reporting an issues" )
	end
	--Disable the button
	CheckServerVersion:SetDisabled(true)
end


function setVersionCL( body, length, headers, code )
	DebugMessage(body)
	local page = string.Explode(",", body )
	local Matches = {}
	for k,v in pairs(page) do
		if (string.match(v,"\"%t%i%t%l%e\"%:")) then
			local tempTable = string.Explode("\"%t%i%t%l%e\"%:",v,true)
			local title = table.concat(tempTable)
			DebugMessage("Found Version: "..title)
			table.insert( Matches, title )
		end
	end
	local highestSoFar = "\"0.0.1\""
	for k,v in pairs(Matches) do
		DebugMessage("Highest So Far is "..highestSoFar)
		DebugMessage("V is "..v)
		if ( v > highestSoFar ) then
			highestSoFar = v
		    DebugMessage("Highest So Far is "..highestSoFar)
		end
	end
	latestVersion = highestSoFar

	--The Highest is at the top of the page: therefore k = 1 for the latest
	--LatestString = string.sub( Matches[1], 8)

	--Change the String:
	if(latestVersion == SBEP.Version) then
		ClientInfo:SetText( "You are up-to-date on version: "..SBEP.Version..". \nPlease report this version when reporting issues so we can track it." )
	else
		ClientInfo:SetText( "You are behind!! You have version: "..SBEP.Version..". \nThe latest version is: "..latestVersion..". Please update before reporting any issues" )
	end
	
	--Disable the button
	CheckClientVersion:SetDisabled(true)
end

function GetLatest( mode )
	if(mode=="server") then
		DebugMessage("Server Mode")
		http.Fetch("https://api.github.com/repos/SnakeSVx/sbep/milestones?state=closed", setVersionSV)
	elseif (mode=="client") then
		DebugMessage("Client Mode")
		http.Fetch("https://api.github.com/repos/SnakeSVx/sbep/milestones?state=closed", setVersionCL)
	end
end



function CreateMenu( )

	-- Main Frame
	local frame = vgui.Create("DFrame")
		--x, y (x being width,
	frame:SetPos( ScrW() / 2 - (ScreenScale(400) / 2), (ScrH() / 6)  )   --   X = , Y= 200 =
	frame:SetSize( ScreenScale(400), (ScrH() / 4) * 3)      -- X= , 6
	frame:SetTitle( "Welcome to the Spacebuild Enhancement Project")
	frame:SetDraggable(true)
	frame:SetVisible( true )
	frame:MakePopup()

	local Disable = vgui.Create("DCheckBoxLabel")
	Disable:SetParent(frame)
	Disable:SetPos( 5 , (ScrH() / 4) * 3- 20)         -- 900 - 20
	Disable:SetText("Stop Opening this Menu when Joining a Server?")
	Disable:SetConVar("sbep_disable_menu" )
	Disable:SetValue( 1 )
	Disable:SizeToContents()

	local PropSheet = vgui.Create("DPropertySheet")
	PropSheet:SetParent(frame)
	PropSheet:SetPos( ScrW() / 76.8 , ScrH() / 40) -- = 25,30
	PropSheet:SetSize( ScreenScale(400) - 50, ScrH() / 2 + 250 ) -- X; 1150, 850

	local VersionPanel = vgui.Create("DPanel")
	VersionPanel:SetParent(frame)

	--Category to check Server SVN info
	local ServerCat = vgui.Create("DCollapsibleCategory")
	ServerCat:SetParent(VersionPanel)
	ServerCat:SetSize( ScrW() / 3.2 - 60 , ScrH() / 48 )    -- 540, 25
	ServerCat:SetPos( ScrW() / 96, ScrH() / 60 )
	ServerCat:SetLabel("Server")


	CheckServerVersion = vgui.Create("DButton")
	CheckServerVersion:SetParent(ServerCat)
	CheckServerVersion:SetText("Get Server Version")
	CheckServerVersion:SetPos(0,ScrH() / 40)
	CheckServerVersion:SetSize( ScrW() / 19.2 ,ScrH() / 12)
    CheckServerVersion.DoClick = function()
		RequestSvInfo()
	end

	local ServerPanel = vgui.Create("DPanel")
	ServerPanel:SetParent(ServerCat)
	ServerPanel:SetSize(ScrW() - 500,ScrH() / 12 )
	ServerPanel:SetPos(ScrW() / 16,ScrH() / 40)  --120,30

	ServerInfo = vgui.Create("DLabel",ServerPanel)
	ServerInfo:ColorTo(Color(255,0,0,255), 1, 0)
	ServerInfo:SetWrap(true)
	ServerInfo:SetSize(ScrW() - 1500,ScrH() / 12)  -- 420, 100
	ServerInfo:SetPos(ScrW() / 384,0)
	ServerMsg = "Press the Button to get the latest Version and the Server's Version"
	ServerInfo:SetText( ServerMsg )


	                 --TODO: Keep re-factorising

	--Start Of Client Buttons,etc
	local ClientCat = vgui.Create("DCollapsibleCategory")
	ClientCat:SetParent(VersionPanel)
	ClientCat:SetSize( ScrW() - 1380, ScrH() / 48 )
	ClientCat:SetPos( (ScrW() / 3.2) - 30, ScrH() / 60 )
	ClientCat:SetLabel("Client")

	local ClientPanel = vgui.Create("DPanel")
	ClientPanel:SetParent(ClientCat)
	ClientPanel:SetSize(420,100)
	ClientPanel:SetPos(120,30)

	ClientInfo = vgui.Create("DLabel",ClientPanel)
	ClientInfo:ColorTo(Color(255,0,0,255), 1, 0)
	ClientInfo:SetWrap(true)
	ClientInfo:SetSize(ScrW() - 500 ,ScrH() / 12)
	ClientInfo:SetPos(ScrW() / 384,0)
	ClientMsg = "Your Version is :"..(SBEP.Version)..".\nPlease report this Hash Code when reporting errors.\n\n Press the Button to get the latest Version"
	ClientInfo:SetText( ClientMsg )


	CheckClientVersion = vgui.Create("DButton")
	CheckClientVersion:SetParent(ClientCat)
	CheckClientVersion:SetText("Get Latest Version")
	CheckClientVersion:SetPos(0,ScrH() / 40 )
	CheckClientVersion:SetSize( ScrW() / 19.2,ScrH() / 12)
	CheckClientVersion.DoClick = function () GetLatest("client")end

	HTMLWindow = vgui.Create("HTML")
	HTMLWindow:SetParent(VersionPanel)
	HTMLWindow:OpenURL("https://github.com/SnakeSVx/sbep/issues")
	HTMLWindow:SetPos( ScrW() - 1900, ScrH() / 7.5  )
	HTMLWindow:SetSize( ScrW() - 840, ScrH() / 1.875 )
	PropSheet:AddSheet( "Error Reporting", VersionPanel, "gui/silkicons/user",false,false, "Use this Tab to Report Errors and Get the Latest Version of SBEP")
	 --Add to our Version Check Tab

end



function MenuWrapper() 
	if (GetConVar("sbep_disable_menu"):GetInt() == 0) then 
		CreateMenu()
	else end
end


concommand.Add("sbep_menu", CreateMenu, nil, "Open the SBEP welcome menu" )


if CLIENT then
	hook.Add("Initialize","Create SBEP Menu", MenuWrapper )
end

