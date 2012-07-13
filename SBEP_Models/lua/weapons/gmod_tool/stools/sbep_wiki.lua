TOOL.Category		= "SBEP"
TOOL.Name			= "#SBEP Help" 
TOOL.Command 		= nil 
TOOL.ConfigName 	= ""

if ( CLIENT ) then
	language.Add( "Tool_sbep_wiki_name" , "SBEP Wiki Help Tool" 				)
	language.Add( "Tool_sbep_wiki_desc" , "Look up help and info on SBEP stuff." 		)
	language.Add( "Tool_sbep_wiki_0" 	, "Click something to look it up in the wiki." 	)
end


function TOOL:LeftClick( trace )
	if CLIENT then return end
	if trace.Entity:IsValid() then
		local class = trace.Entity:GetClass()
		print( class )
		
		umsg.Start( "SBEPDocOpenSearch" , RecipientFilter():AddPlayer( self:GetOwner() ) )
			umsg.String( class )
		umsg.End()
		
		return true
	end
end 

function TOOL:RightClick( trace ) 

end  

function TOOL.BuildCPanel( panel )
	
	panel:SetSpacing( 10 )
	panel:SetName( "SBEP Wiki Tool" )
	
	local HelpB = vgui.Create( "DButton" )
		HelpB:SetSize( 100, 50 )
		HelpB.DoClick = function()
								SBEPDoc.OpenManual()
							end
		HelpB:SetText( "Open the SBEP Manual" )
	panel:AddItem( HelpB )
	
	if ConVarExists( "SBEPLighting" ) then
		local LightCB = vgui.Create( "DCheckBoxLabel" )
			LightCB:SetPos( 10,50 )
			LightCB:SetText( "Use Dynamic Lights?" )
			LightCB:SetConVar( "SBEPLighting" )
			LightCB:SetValue( 1 )
			LightCB:SizeToContents()
		panel:AddItem( LightCB )
	end
	
	local DupeFixButton = vgui.Create("DButton")
		DupeFixButton:SetText( "Fix All Dupes" )
		DupeFixButton:SetSize( 100, 20 )
		DupeFixButton.DoClick = function ( btn )
							RunConsoleCommand( "SBEP_FixAllDupes" )
						end
	panel:AddItem( DupeFixButton )
	
 end  