TOOL.Name			= "#HoloPanel"
TOOL.Category		= "SBEP"
TOOL.Command 		= nil 
TOOL.ConfigName 	= ""

TOOL.ClientConVar[ "model" 		] = "models/Slyfo/util_tracker.mdl"
TOOL.ClientConVar[ "R"  		] = 200
TOOL.ClientConVar[ "G"  		] = 200
TOOL.ClientConVar[ "B"  		] = 230
TOOL.ClientConVar[ "bright" 	] = 255
TOOL.ClientConVar[ "pass"   	] = 1234
TOOL.ClientConVar[ "encrypt"	] = 0
TOOL.ClientConVar[ "persist"	] = 0
TOOL.ClientConVar[ "perma"		] = 0
TOOL.ClientConVar[ "cldelay"	] = 1

local TName = "sbep_holopanel"

if CLIENT then
	language.Add( "Tool_"..TName.."_name"		, "SBEP HoloPanel" 									)
	language.Add( "Tool_"..TName.."_desc"		, "Spawn HoloPanels." 								)
	language.Add( "Tool_"..TName.."_0"			, "Left-click to spawn a holopanel."				)
	language.Add( "undone_SBEP HoloPanel"		, "Undone SBEP HoloPanel"							)
	
	local function SetColors( um )
		local HK = um:ReadEntity()
			local r,g,b, cldel = um:ReadFloat(),um:ReadFloat(),um:ReadFloat(), um:ReadFloat()
			local cry, per, perma = um:ReadBool(), um:ReadBool(), um:ReadBool()
			timer.Simple( 0.1, function()
									HK:SetColors( r,g,b )
									HK.Encrypt = cry
									HK.Persist = per
									HK.CLDelay = cldel
									HK.PermA = perma
								end)
	end
	usermessage.Hook( "SBEPHoloKeypad_SetColors" , SetColors )
end

function TOOL:LeftClick( tr ) 
	if CLIENT then return end
	
	local ply = self:GetOwner()

	local model = self:GetClientInfo( "model" )
	local pos = tr.HitPos

	local HP = ents.Create( "HoloPanel" )
		HP:Spawn()
		
		HP:SetModel( model )
		
		HP:SetPos( pos - tr.HitNormal * HP:OBBMins().z )
		HP:SetAngles( tr.HitNormal:Angle() )
		HP:SetAngles( HP:LocalToWorldAngles( Angle(0,90,90) ) )
		
		/*local B = self:GetClientNumber( "bright" )
		local r = self:GetClientNumber( "R" ) * B/255
		local g = self:GetClientNumber( "G" ) * B/255
		local b = self:GetClientNumber( "B" ) * B/255
		umsg.Start( "SBEPHoloKeypad_SetColors" , RecipientFilter():AddAllPlayers() )
			umsg.Entity( HK )
			umsg.Float( r )
			umsg.Float( g )
			umsg.Float( b )
			local cldel = self:GetClientNumber( "cldelay" )
			if cldel >= 0 then
				umsg.Float( cldel )
			end
			umsg.Bool( self:GetClientNumber( "encrypt" ) == 1 )
			umsg.Bool( self:GetClientNumber( "persist" ) == 1 )
			umsg.Bool( self:GetClientNumber( "perma" ) == 1 )
		umsg.End()*/
		
	undo.Create("SBEP HoloPanel")
		undo.AddEntity( HP )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return true
end 

function TOOL:RightClick( tr ) 
	
end

function TOOL:Reload( tr ) 
	
end

function TOOL.BuildCPanel( panel )
	
	panel:SetSpacing( 10 )
	panel:SetName( "SBEP HoloPanel" )
	
	local tdplc = g_SpawnMenu:GetTable().ToolMenu:GetTable().Items[1].Panel:GetTable().Content
	local w, pd = tdplc:GetWide(), tdplc:GetPadding()
	local W = w - 4*pd
	
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	/*local DCC = vgui.Create( "DColorCircle" )
		DCC:SetSize( W , W )
		DCC.TranslateValues = function( self, x, y )
									x = x - 0.5
									y = y - 0.5
									local angle = math.atan2( x, y )
									local length = math.sqrt( x*x + y*y )
										length = math.Clamp( length, 0, 0.5 )
									x = 0.5 + math.sin( angle ) * length
									y = 0.5 + math.cos( angle ) * length
										self:SetHue( math.Rad2Deg( angle ) + 270 )
										self:SetSaturation( length * 2 )
										self:SetRGB( HSVToColor( self:GetHue(), self:GetSaturation(), 1 ) )
									return x, y
								end
		DCC.OnMouseReleased = function( self )
									self:SetDragging( false )
									self:MouseCapture( false )
									
									RunConsoleCommand( TName.."_R" , self:GetRGB().r )
									RunConsoleCommand( TName.."_G" , self:GetRGB().g )
									RunConsoleCommand( TName.."_B" , self:GetRGB().b )
								end
	panel:AddItem( DCC )
	
	local BNS = vgui.Create( "DNumSlider" )
		BNS:SetText( "Brightness" )
		BNS:SetMin( 0 )
		BNS:SetMax( 255 )
		BNS:SetDecimals( 0 )
		BNS:SetConVar( TName.."_bright" )
	panel:AddItem( BNS )
	
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local Ta = vgui.Create( "HPDTablet" )
		Ta:SetSize( W, 200 )

	local AE = vgui.Create( "DButton" )
		AE:SetSize( 100, 25 )
		AE:SetText( "Add Element" )
		AE.DoClick = function( self )
							local F = Ta:AddItem()
								F:SetPos( 20, 50 )
						end
	panel:AddItem( AE )
	panel:AddItem( Ta )
	
	local IO = vgui.Create( "HPDInOut" )
		Ta:SetIOForm( IO )
		IO:SetTablet( Ta )
	panel:AddItem( IO )
	
	local ICL = vgui.Create( "HPDItemContext" )
		ICL:SetTablet( Ta )
		Ta:SetItemContextList( ICL )
	panel:AddItem( ICL )
	
end