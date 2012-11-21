--
-- Created by IntelliJ IDEA.
-- User: Sam Elmer (Selekton99)
-- Date: 19/11/12
-- Time: 8:22 AM
-- Last Updated :  
--



function CreateMenu( )
	if (ServerHaveSBEP() == false ) then return false end
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


	--Stuff to check Server Version
	local ServerCat = vgui.Create("DCollapsibleCategory")
	ServerCat:SetParent(PropSheet)
	ServerCat:SetSize( 200, 25 )
	ServerCat:SetPos( )     --TODO: Figure out pos for Collapsible Category
	ServerCat:SetLabel("Server")

	local ServerCatCg = vgui.Create("DPanelList")
	ServerCatCg:SetAutoSize(true)
	ServerCatCg:SetSpacing( 5 )
	ServerCatCg:EnableHorizontal( false )
	ServerCatCg:EnableVerticalScrollbar( true )







	local ClientCat = vgui.Create("DCollapsibleCategory")
	ClientCat:SetParent(PropSheet)
	ClientCat:SetLabel("Client")





end


if CLIENT then
hook.Add("Initialize","Create SBEP Menu", CreateMenu )
end
