--
-- Created by IntelliJ IDEA.
-- User: Sam Elmer (Selekton99)
-- Date: 19/11/12
-- Time: 8:22 AM
-- Last Updated :  
--

--Australian Localization: (Because my spelling is bad enough, I don't need to be americanised)
panel.SetColour = panel.SetColor
Colour = Color


serverVersion = "Unknown"
print("This server has version: "..serverVersion.."\n")
clientVersion = "Unknown"

function ServerHaveSBEP()
	-- Because I know of at least one SB server without SBEP, Amazing right?
	if (ServerVersion = "Unknown") then
		return false
	else
		return true
end


function CreateMenu( )
	if (ServerHaveSBEP() == false ) then return end
	local ClVersion = GetClientSVN()
	local SvVersion = RequestServerSVN()
	local Latest = GetLatestSVN()

	local Frame = vgui.Create("DFrame")
	frame:SetPos(ScrH / 4,ScrW / 4)
	frame:SetSize( 300, 300 )
	frame:SetTitle( "Welcome to the Spacebuild Enhancement Project")
	frame:SetDraggable(true)
	frame:MakePopup()
	frame:SetVisible( true )      -- Here we setup the base panel that everything else should be connected to.

	--Create a Tab that will contain SVN Versions.

	local PropSheet = vgui.Create("DPRopertySheet")
	PropSheet:SetParent(Frame)
	PropSheet:SetPos(ScrH /4 - 5, ScrW /4 - 5)
	PropSheet:SetSize( 295, 295 )


	--Category to check Server SVN info
	local ServerCat = vgui.Create("DCollapsibleCategory")
	ServerCat:SetParent(PropSheet)
	ServerCat:SetSize( 200, 25 )
	ServerCat:SetPos( )     --TODO: Figure out positions for Collapsible Category
	ServerCat:SetLabel("Server")

	local BackgroundSV = vgui.Create("DPanel")    -- Create Main info stuff
	BackgroundSV:SetPosition()
	BackgroundSV:SetSize()
	BackgroundSV:SetParent(ServerCat)

	--[[ Disabled till the system works as this is just for looks!
	local ColourWarning = vgui.Create("DPanel")
	ColourWarning:SetPosition(0,0) --TODO: Figure out positions
	ColourWarning:SetSize() --TODO:Figure out size
	ColourWarning:SetParent(ServerCat)
	ColourWarning:SetColour(Color(255,0,0,255))
	]]--

	local SVInfo = vgui.Create("DLabel")
	SVInfo:Text("The Server has Version: "..serverVersion.."") -- TODO: Check if this can be autowrapped around. The next line must say The Latest Version is and then The Server is ... behind (or) The Server is up to date.
	SVInfo:SetWrap(true)
	SVInfo:SetParent(ServerCat)
	SVInfo:SetText("The Server has version: "..serverVersion..". \n The latest Version is "..latest..". The Server is "..toint(latest) - toint(serverVersion).. " versions behind."


	-- Then we will change the colour of ColourWarning to notify it is behind (This is purely for looks) In fact it
	-- won't work yet! Because I want to get this menu done with and pretty it up later. (I hate derma)









	local ClientCat = vgui.Create("DCollapsibleCategory")
	ClientCat:SetParent(PropSheet)
	ClientCat:SetLabel("Client")





end
concommand.Add("sbep_menu", CreateMenu, nil, "Open the SBEP welcome menu" )


if CLIENT then
	hook.Add("Initialize","Create SBEP Menu", CreateMenu )
end
