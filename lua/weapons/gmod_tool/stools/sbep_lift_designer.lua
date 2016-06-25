TOOL.Category		= "SBEP"
TOOL.Tab 			= "Spacebuild"
TOOL.Name			= "#Lift System Designer"
TOOL.Command		= nil
TOOL.ConfigName 	= ""

local BMT = {
	{ type = "M"		} ,
	{ type = "ME"		} ,
	{ type = "MEdh"	 	} ,
	{ type = "MEdw"	 	} ,
	{ type = "MR"		} ,
	{ type = "MT"		} ,
	{ type = "MX"		} ,
	{ type = "S"		}
			}

local SMT = {
	{ type = "MV"		} ,
	{ type = "H"		}
			}

local LHMT = list.Get( "SBEP_LiftHousingModels" )

local BEM = { S = true , S2 = true , H = true }
			
if CLIENT then
	language.Add( "tool.sbep_lift_designer.name", "SBEP Lift System Designer" 		)
	language.Add( "tool.sbep_lift_designer.desc", "Create a lift system." 			)
	language.Add( "tool.sbep_lift_designer.0"	, "Left click somewhere to begin."  ) --, or right click an existing lift shaft to start from there." 	)
	language.Add( "undone_SBEP Lift System"		, "Undone SBEP Lift System"			)
end

local ConVars = {
		editing 		= 0,
		skin			= 0,
		enableuse		= 0,
		doors			= 0,
		size			= 1,
		type			= "M"
				}
for k,v in pairs(ConVars) do
	TOOL.ClientConVar[k] = v
end

local LD = {}
local CL = {}
local LiftSystem_SER = {}


if CLIENT then
	
	LiftSystem = nil
	
	function CreateSBEPLiftDesignerMenu()
	
		local LDT = {}
		LDT.Frame = vgui.Create( "DFrame" )
			LDT.Frame:SetPos( 30,30 )
			LDT.Frame:SetSize( 325, 548 )
			LDT.Frame:SetTitle( "SBEP Lift System Designer" )
			LDT.Frame:SetVisible( false )
			LDT.Frame:SetDraggable( false )
			LDT.Frame:SetMouseInputEnabled( true )
			LDT.Frame:ShowCloseButton( false )
			LDT.Frame:MakePopup()
		
		LDT.SFrame = vgui.Create( "DFrame" )
			LDT.SFrame:SetPos( 360,193 )
			LDT.SFrame:SetSize( 165,85 )
			LDT.SFrame:SetTitle( " " )
			LDT.SFrame:SetBackgroundBlur( true )
			LDT.SFrame:SetVisible( false )
			LDT.SFrame:SetDraggable( false )
			LDT.SFrame:SetMouseInputEnabled( true )
			LDT.SFrame:ShowCloseButton( false )
			LDT.SFrame:MakePopup()
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--					MENU CONTROLS
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		LDT.SButtons = {}
		
		LDT.SButtons.Close = vgui.Create("DButton", LDT.Frame )
			LDT.SButtons.Close:SetPos( 285 , 4 )   
			LDT.SButtons.Close:SetSize( 35 , 13 )   
			LDT.SButtons.Close:SetText( "close" )
			LDT.SButtons.Close.DoClick = function()
												RunConsoleCommand( "SBEP_LiftCancelMenu_ser" )
												CL.LiftDes.SBEPLDDM = nil
												LDT.Frame:Remove()
												LDT.SFrame:Remove()
												LiftSystem = nil
											end
		
		LDT.SButtons.finish = vgui.Create("DImageButton", LDT.Frame )
			LDT.SButtons.finish:SetPos( 5 , 508 )
			LDT.SButtons.finish:SetSize( 315 , 35 )
			LDT.SButtons.finish:SetImage( "sbep_icons/finish.vmt" )
			LDT.SButtons.finish.DoClick = function()
												RunConsoleCommand( "SBEP_LiftFinishSystem_ser" )
												LDT.Frame:Remove()
												LDT.SFrame:Remove()
											end
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--					MODEL CONTROLS
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		LDT.PButtons = {}
		LDT.PButtons.Part = {}
		
		for k,v in ipairs(BMT) do
			LDT.PButtons.Part[k] = vgui.Create("DImageButton", LDT.Frame )
				LDT.PButtons.Part[k]:SetImage( "sbep_icons/"..v.type..".vmt" )
				LDT.PButtons.Part[k]:SetPos( 5 + 80 * ((k - 1)%4) , 28 + 80 * math.floor((k - 1)/ 4))
				LDT.PButtons.Part[k]:SetSize( 75 , 75 )
				LDT.PButtons.Part[k].DoClick = function()
														RunConsoleCommand( "SBEP_LiftSys_SetLiftPartType_ser" , v.type )
													end
		end
		
		LDT.PButtons.Special = {}
		LDT.PButtons.Special.Part = {}
		
		LDT.PButtons.Special.B = vgui.Create("DImageButton", LDT.Frame )
			LDT.PButtons.Special.B:SetPos( 165 , 188 )   
			LDT.PButtons.Special.B:SetSize( 155 , 35 )
			LDT.PButtons.Special.B:SetImage( "sbep_icons/special.vmt" )
			LDT.PButtons.Special.B.DoClick = function()
													LDT.SFrame.visible = !LDT.SFrame.visible 
													LDT.SFrame:SetVisible( LDT.SFrame.visible )
												end
		
		LDT.PButtons.Special.Part[1] = vgui.Create("DImageButton", LDT.SFrame )
			LDT.PButtons.Special.Part[1]:SetImage( "sbep_icons/mv.vmt" )
			LDT.PButtons.Special.Part[1]:SetPos( 5 , 5 )
			LDT.PButtons.Special.Part[1]:SetSize( 75 , 75 )
			LDT.PButtons.Special.Part[1].DoClick = function()
													LDT.SFrame.visible = false
													LDT.SFrame:SetVisible( LDT.SFrame.visible )
													RunConsoleCommand( "SBEP_LiftSys_SetLiftPartType_ser" , SMT[1].type )
												end

		LDT.PButtons.Special.Part[2] = vgui.Create("DImageButton", LDT.SFrame )
			LDT.PButtons.Special.Part[2]:SetImage( "sbep_icons/h.vmt" )
			LDT.PButtons.Special.Part[2]:SetPos( 85 , 5 )
			LDT.PButtons.Special.Part[2]:SetSize( 75 , 75 )
			LDT.PButtons.Special.Part[2].DoClick = function()
													LDT.SFrame.visible = false
													LDT.SFrame:SetVisible( LDT.SFrame.visible )
													RunConsoleCommand( "SBEP_LiftSys_SetLiftPartType_ser" , SMT[2].type )
												end

		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--					CONSTRUCTION CONTROLS
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		LDT.BButtons = {}
		
		LDT.BButtons.Construct = vgui.Create("DImageButton", LDT.Frame )
			LDT.BButtons.Construct:SetPos( 5 , 268 )
			LDT.BButtons.Construct:SetSize( 155 , 195 )
			LDT.BButtons.Construct:SetImage( "sbep_icons/construct.vmt" )
			LDT.BButtons.Construct.DoClick = function()
													local pos = CL.LiftDes.LiftSystem:GetNWInt("ActivePart")
													pos = pos + 1
													RunConsoleCommand( "SBEP_LiftConstructPart_ser" , pos )
											end
		
		LDT.BButtons.up = vgui.Create("DImageButton", LDT.Frame )
			LDT.BButtons.up:SetPos( 45 , 228 )   
			LDT.BButtons.up:SetSize( 75 , 35 )   
			LDT.BButtons.up:SetImage( "sbep_icons/arrowup.vmt" )
			LDT.BButtons.up.DoClick = function()
													local pos = CL.LiftDes.LiftSystem:GetNWInt("ActivePart")
													CL.LiftDes.DIR = "UP"
													pos = math.Clamp( pos + 1 , 1 , CL.LiftDes.LiftSystem:GetNWInt( "SBEP_LiftPartCount" ) )
													CL.LiftDes.LiftSystem:SetNWInt("ActivePart", pos )
													RunConsoleCommand( "SBEP_LiftGetCamHeight_ser", pos )
											end
		
		LDT.BButtons.down = vgui.Create("DImageButton", LDT.Frame )
			LDT.BButtons.down:SetPos( 45 , 468 )   
			LDT.BButtons.down:SetSize( 75 , 35 )   
			LDT.BButtons.down:SetImage( "sbep_icons/arrowdown.vmt" )
			LDT.BButtons.down.DoClick = function()
													local pos = CL.LiftDes.LiftSystem:GetNWInt("ActivePart")
													--[[if pos == 1 then 
														CL.LiftDes.DIR = "DOWN"
														RunConsoleCommand( "SBEP_LiftConstructPart_ser" , 1 , "DOWN" )
													end]]
													pos = math.Clamp( pos - 1 , 1 , CL.LiftDes.LiftSystem:GetNWInt( "SBEP_LiftPartCount" ) )
													CL.LiftDes.LiftSystem:SetNWInt("ActivePart", pos )
													RunConsoleCommand( "SBEP_LiftGetCamHeight_ser", pos )
											end
		
		LDT.BButtons.inv = vgui.Create("DImageButton", LDT.Frame )
			LDT.BButtons.inv:SetPos( 45 , 188 )   
			LDT.BButtons.inv:SetSize( 75 , 35 )   
			LDT.BButtons.inv:SetImage( "sbep_icons/invert.vmt" )
			LDT.BButtons.inv.DoClick = function()
											RunConsoleCommand( "SBEP_LiftSys_InvertLiftPart_ser" )
										end

		LDT.BButtons.RotC = vgui.Create("DImageButton", LDT.Frame )
			LDT.BButtons.RotC:SetPos( 5 , 188 )   
			LDT.BButtons.RotC:SetSize( 35 , 35 )
			LDT.BButtons.RotC:SetImage( "sbep_icons/rotc.vmt" )
			LDT.BButtons.RotC.DoClick = function()
											RunConsoleCommand( "SBEP_LiftSys_SetLiftPartYaw_ser" , 270 )
										end
		
		LDT.BButtons.RotAC = vgui.Create("DImageButton", LDT.Frame )
			LDT.BButtons.RotAC:SetPos( 125 , 188 )   
			LDT.BButtons.RotAC:SetSize( 35 , 35 )
			LDT.BButtons.RotAC:SetImage( "sbep_icons/rotac.vmt" )
			LDT.BButtons.RotAC.DoClick = function()
											RunConsoleCommand( "SBEP_LiftSys_SetLiftPartYaw_ser" , 90 )
										end
		
		LDT.BButtons.Delete = vgui.Create("DImageButton", LDT.Frame )
			LDT.BButtons.Delete:SetPos( 125 , 228 )   
			LDT.BButtons.Delete:SetSize( 35 , 35 )
			LDT.BButtons.Delete:SetImage( "sbep_icons/delete.vmt" )
			LDT.BButtons.Delete.DoClick = function()
											RunConsoleCommand( "SBEP_LiftDeletePart_ser" )	
										end
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--					CAMERA CONTROLS
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		LDT.CButtons = {}
		
		LDT.CButtons.up = vgui.Create("DImageButton", LDT.Frame )
			LDT.CButtons.up:SetPos( 205 , 348 )   
			LDT.CButtons.up:SetSize( 75 , 35 )   
			LDT.CButtons.up:SetImage( "sbep_icons/arrowup.vmt" )
			LDT.CButtons.up.Hold = true
			LDT.CButtons.up.OnMousePressed  = function() LDT.CButtons.up.Pressed = true  end
			LDT.CButtons.up.OnMouseReleased = function() LDT.CButtons.up.Pressed = false end
			LDT.CButtons.up.DoClick = function()
												CL.LiftDes.MVPitch = math.Clamp( CL.LiftDes.MVPitch + 0.1 , -89 , 89 )
												CL.LiftDes.CVPitch = CL.LiftDes.MVPitch
												LD.ReCalcViewAngles()
											end
		
		LDT.CButtons.down = vgui.Create("DImageButton", LDT.Frame )
			LDT.CButtons.down:SetPos( 205 , 468 )   
			LDT.CButtons.down:SetSize( 75 , 35 )   
			LDT.CButtons.down:SetImage( "sbep_icons/arrowdown.vmt" )
			LDT.CButtons.down.Hold = true
			LDT.CButtons.down.OnMousePressed  = function() LDT.CButtons.down.Pressed = true  end
			LDT.CButtons.down.OnMouseReleased = function() LDT.CButtons.down.Pressed = false end
			LDT.CButtons.down.DoClick = function()
												CL.LiftDes.MVPitch = math.Clamp( CL.LiftDes.MVPitch - 0.1 , -89 , 89 )
												CL.LiftDes.CVPitch = CL.LiftDes.MVPitch
												LD.ReCalcViewAngles()
											end
		
		LDT.CButtons.left = vgui.Create("DImageButton", LDT.Frame )
			LDT.CButtons.left:SetPos( 165 , 388 )   
			LDT.CButtons.left:SetSize( 35 , 75 )
			LDT.CButtons.left:SetImage( "sbep_icons/arrowleft.vmt" )
			LDT.CButtons.left.Hold = true
			LDT.CButtons.left.OnMousePressed  = function() LDT.CButtons.left.Pressed = true  end
			LDT.CButtons.left.OnMouseReleased = function() LDT.CButtons.left.Pressed = false end
			LDT.CButtons.left.DoClick = function()
												CL.LiftDes.MVYaw = CL.LiftDes.MVYaw - 0.1
												CL.LiftDes.CVYaw = CL.LiftDes.MVYaw
												LD.ReCalcViewAngles()
											end
		
		LDT.CButtons.right = vgui.Create("DImageButton", LDT.Frame )
			LDT.CButtons.right:SetPos( 285 , 388 )   
			LDT.CButtons.right:SetSize( 35 , 75 )
			LDT.CButtons.right:SetImage( "sbep_icons/arrowright.vmt" )
			LDT.CButtons.right.Hold = true
			LDT.CButtons.right.OnMousePressed  = function() LDT.CButtons.right.Pressed = true  end
			LDT.CButtons.right.OnMouseReleased = function() LDT.CButtons.right.Pressed = false end
			LDT.CButtons.right.DoClick = function()
												CL.LiftDes.MVYaw = CL.LiftDes.MVYaw + 0.1
												CL.LiftDes.CVYaw = CL.LiftDes.MVYaw
												LD.ReCalcViewAngles()
											end

		LDT.CButtons.default = vgui.Create("DImageButton", LDT.Frame )
			LDT.CButtons.default:SetPos( 205 , 388 )   
			LDT.CButtons.default:SetSize( 75 , 75 ) 
			LDT.CButtons.default:SetImage( "sbep_icons/camera.vmt" )		
			LDT.CButtons.default.DoClick = function()
												LD.SetBaseViewAngles()
											end
		
		LDT.CButtons.Zplus = vgui.Create("DImageButton", LDT.Frame )
			LDT.CButtons.Zplus:SetPos( 285 , 348 )   
			LDT.CButtons.Zplus:SetSize( 35 , 35 )
			LDT.CButtons.Zplus:SetImage( "sbep_icons/zoomin.vmt" )
			LDT.CButtons.Zplus.Hold = true
			LDT.CButtons.Zplus.OnMousePressed  = function() LDT.CButtons.Zplus.Pressed = true  end
			LDT.CButtons.Zplus.OnMouseReleased = function() LDT.CButtons.Zplus.Pressed = false end
			LDT.CButtons.Zplus.DoClick = function()
												CL.LiftDes.MVRange = CL.LiftDes.MVRange - 0.007
												CL.LiftDes.CVRange = CL.LiftDes.MVRange
												LD.ReCalcViewAngles()
											end
		
		LDT.CButtons.Zminus = vgui.Create("DImageButton", LDT.Frame )
			LDT.CButtons.Zminus:SetPos( 165 , 348 )   
			LDT.CButtons.Zminus:SetSize( 35 , 35 )
			LDT.CButtons.Zminus:SetImage( "sbep_icons/zoomout.vmt" )
			LDT.CButtons.Zminus.Hold = true
			LDT.CButtons.Zminus.OnMousePressed  = function() LDT.CButtons.Zminus.Pressed = true  end
			LDT.CButtons.Zminus.OnMouseReleased = function() LDT.CButtons.Zminus.Pressed = false end
			LDT.CButtons.Zminus.DoClick = function()
												CL.LiftDes.MVRange = CL.LiftDes.MVRange + 0.007
												CL.LiftDes.CVRange = CL.LiftDes.MVRange
												LD.ReCalcViewAngles()
											end
		
		LDT.CButtons.RotC = vgui.Create("DImageButton", LDT.Frame )
			LDT.CButtons.RotC:SetPos( 165 , 468 )   
			LDT.CButtons.RotC:SetSize( 35 , 35 )
			LDT.CButtons.RotC:SetImage( "sbep_icons/rotc.vmt" )
			LDT.CButtons.RotC.DoClick = function()
												CL.LiftDes.MVYaw = CL.LiftDes.MVYaw - 90
												LD.ReCalcViewAngles()
											end
		
		LDT.CButtons.RotAC = vgui.Create("DImageButton", LDT.Frame )
			LDT.CButtons.RotAC:SetPos( 285 , 468 )   
			LDT.CButtons.RotAC:SetSize( 35 , 35 )
			LDT.CButtons.RotAC:SetImage( "sbep_icons/rotac.vmt" )
			LDT.CButtons.RotAC.DoClick = function()
												CL.LiftDes.MVYaw = CL.LiftDes.MVYaw + 90
												LD.ReCalcViewAngles()
											end
	
		return LDT
	
	end

		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--					CLIENT FUNCTIONS
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		function LD.SBEP_OpenLiftDesignMenu(entLift)
			CL = LocalPlayer()
			CL.LiftDes = {}
			if not (IsEntity(entLift) and IsValid(entLift)) then
				return
			end

			LiftSystem = entLift
			CL.LiftDes.LiftSystem = LiftSystem
			CL.LiftDes.SBEPLDDM = CreateSBEPLiftDesignerMenu()
			CL.LiftDes.DIR = "UP"

			CL.LiftDes.SBEPLDDM.Frame.visible = true
			CL.LiftDes.SBEPLDDM.Frame:SetVisible( true )
			
			CL.LiftDes.StartPos 	= (CL.LiftDes.LiftSystem:GetPos() + 60.45*CL.LiftDes.LiftSystem:GetUp()) or Vector(0,0,0)
			
			LD.SetBaseViewAngles()
			CL.LiftDes.CVYaw   		= CL.LiftDes.MVYaw
			CL.LiftDes.CVPitch 		= CL.LiftDes.MVPitch
			CL.LiftDes.CVRange 		= CL.LiftDes.MVRange
			CL.LiftDes.CBRange 		= 168.15
			CL.LiftDes.MBRange 		= 168.15
			CL.LiftDes.CHOffset		= 0
			CL.LiftDes.PHOffset		= 0
			LD.SetBaseViewAngles()
			CL.LiftDes.PC = CL.LiftDes.LiftSystem:GetNWInt( "SBEP_LiftPartCount" )
			LD.SBEPDisableButtonsFirstTime()
			
		end
		net.Receive("SBEP_OpenLiftDesignMenu_cl", LD.SBEP_OpenLiftDesignMenu)
		
		function LD.SBEP_CloseLiftDesignMenu()
			CL.LiftDes.SBEPLDDM.SFrame:Remove()
			CL.LiftDes.SBEPLDDM.Frame:Remove()
			CL.LiftDes.SBEPLDDM = nil
		end
		net.Receive("SBEP_CloseLiftDesignMenu_cl", LD.SBEP_CloseLiftDesignMenu)
		
		function LD.SBEPDisableButtons()
			local size	= GetConVarNumber( "sbep_lift_designer_size" )
			
			local pos	= net.ReadInt( 16 )
			CL.LiftDes.PC = net.ReadInt( 16 )
			local CanDown = net.ReadBit()
			local type1 = net.ReadString()
			local type2 = net.ReadString()
			local typeC = net.ReadString()

			CL.LiftDes.SBEPLDDM.PButtons.Part[4]:SetDisabled( size == 2 )
			CL.LiftDes.SBEPLDDM.PButtons.Special.B:SetDisabled( size == 2 )
			CL.LiftDes.SBEPLDDM.PButtons.Part[8]:SetDisabled( pos == 1 )
			CL.LiftDes.SBEPLDDM.PButtons.Special.Part[2]:SetDisabled( pos == 1 )
			CL.LiftDes.SBEPLDDM.BButtons.Delete:SetDisabled( CL.LiftDes.PC == 1 or (pos == 1 and BEM[type2]) )
			CL.LiftDes.SBEPLDDM.BButtons.down:SetDisabled( pos == 1 )
			CL.LiftDes.SBEPLDDM.BButtons.up:SetDisabled( pos == CL.LiftDes.PC )
			CL.LiftDes.SBEPLDDM.BButtons.Construct:SetDisabled( pos ~= CL.LiftDes.PC )
			CL.LiftDes.SBEPLDDM.SButtons.finish:SetDisabled( (CL.LiftDes.PC < 3) or BEM[type1] or BEM[typeC] )
		end
		net.Receive("SBEPDisableButtons_cl", LD.SBEPDisableButtons)

		function LD.SBEPDisableButtonsFirstTime() --merge this into the other function somehow
			local size	= GetConVarNumber( "sbep_lift_designer_size" )
			CL.LiftDes.SBEPLDDM.PButtons.Part[4]:SetDisabled( size == 2 )
			CL.LiftDes.SBEPLDDM.PButtons.Part[8]:SetDisabled( true )
			CL.LiftDes.SBEPLDDM.PButtons.Special.B:SetDisabled( size == 2 )
			CL.LiftDes.SBEPLDDM.BButtons.Delete:SetDisabled( true )
			CL.LiftDes.SBEPLDDM.BButtons.down:SetDisabled( true )
			CL.LiftDes.SBEPLDDM.BButtons.up:SetDisabled( true )
			CL.LiftDes.SBEPLDDM.SButtons.finish:SetDisabled( true )
		end
		
		function LD.SetBaseViewAngles()
			CL.LiftDes.MVYaw = 45
			CL.LiftDes.MVPitch = 20
			CL.LiftDes.MVRange = 2.35
			LD.ReCalcViewAngles()
		end

		function LD.ReCalcViewAngles()
			if  not net.BytesWritten() == 0 then CL.LiftDes.MBRange = net:ReadFloat() end
			if LiftSystem and CL.LiftDes.LiftSystem and IsValid(CL.LiftDes.LiftSystem) then
				CL.LiftDes.StartPos	= (CL.LiftDes.LiftSystem:GetPos() + 60.45*CL.LiftDes.LiftSystem:GetUp() or Vector(0,0,0)) --breaks stuff
			end
		end
		net.Receive("SBEP_ReCalcViewAngles_LiftDesignMenu_cl", LD.ReCalcViewAngles)
		
		
		hook.Add("InitPostEntity", "GetSBEPLocalPlayer", function()
			CL = LocalPlayer()
			CL.LiftDes = {}
		end)

		function LD.SBEPSetPHOffset()
			CL.LiftDes.PHOffset = net:ReadFloat()
		end
		net.Receive("SBEP_SetPHOffsetLiftDesignMenu_cl", LD.SBEPSetPHOffset)
		
		local function SBEP_LiftCalcView( ply, origin, angles, fov )
		if not CL or not CL.LiftDes then return end
		if not CL.LiftDes.MVYaw then LD.SetBaseViewAngles() end
			if LiftSystem and CL then
				if CL.LiftDes.CVYaw and CL.LiftDes.SBEPLDDM and CL.LiftDes.SBEPLDDM.Frame and CL.LiftDes.SBEPLDDM.Frame.visible then
					local view = {}
						CL.LiftDes.CVYaw   	= CL.LiftDes.CVYaw   	+ math.Clamp( CL.LiftDes.MVYaw   	- CL.LiftDes.CVYaw   	, -2.5 	, 2.5	)
						CL.LiftDes.CVPitch 	= CL.LiftDes.CVPitch 	+ math.Clamp( CL.LiftDes.MVPitch 	- CL.LiftDes.CVPitch 	, -2.5 	, 2.5	)
						CL.LiftDes.CVRange 	= CL.LiftDes.CVRange 	+ math.Clamp( CL.LiftDes.MVRange 	- CL.LiftDes.CVRange 	, -5    , 5		)
						CL.LiftDes.CBRange 	= CL.LiftDes.CBRange 	+ math.Clamp( CL.LiftDes.MBRange 	- CL.LiftDes.CBRange 	, -5    , 5 	)
						CL.LiftDes.CHOffset = CL.LiftDes.CHOffset 	+ math.Clamp( CL.LiftDes.PHOffset 	- CL.LiftDes.CHOffset 	, -5 	, 5 	)
						
						CL.LiftDes.CRVec = Vector( 1 , 0 , 0 )
							CL.LiftDes.CRAng = Angle( -1 * CL.LiftDes.CVPitch , CL.LiftDes.CVYaw , CL.LiftDes.CVPitch )
							CL.LiftDes.CRVec:Rotate( CL.LiftDes.CRAng )
						CL.LiftDes.MVOffset = CL.LiftDes.CVRange * CL.LiftDes.CRVec * CL.LiftDes.CBRange
						
						view.origin = CL.LiftDes.StartPos + CL.LiftDes.MVOffset + Vector(0,0,1)*CL.LiftDes.CHOffset
						view.angles = (-1 * CL.LiftDes.MVOffset):Angle()
						
					return view
				end
			end
		end
		hook.Add("CalcView", "SBEP_LiftDesigner_CalcView", SBEP_LiftCalcView)

		--[[function TOOL:GetViewModelPosition( pos , ang )
			if GetConVarNumber( "sbep_lift_designer_editing" ) == 1 then
				return Vector(0, 0, -1000), ang
			else
				return pos, ang
			end
		end]]
		
		local function CLSendLift( entLift )
			if entLift:GetNWBool( "Sendable" ) then
				LD.SBEP_OpenLiftDesignMenu( entLift )
				RunConsoleCommand( "SBEP_LiftGetCamHeight_ser" )
				return true
			end
		end
		
		local function CLDelayLift( entLift )
			timer.Simple( 0.1 , function() timerFunc(entLift)
									if !CLSendLift( entLift ) then
										CLDelayLift( entLift )
									end
								end)
		end
		
		local function CLNWLift( entLift )
			timer.Simple( 0.2, function()  
				if entLift:GetNWBool( "Sendable" ) and IsValid(entLift) and LocalPlayer() == entLift:GetOwner() then
					LD.SBEP_OpenLiftDesignMenu( entLift )
					RunConsoleCommand( "SBEP_LiftGetCamHeight_ser" )
					return true
				end
			end )
		end
		hook.Add("OnEntityCreated", "SBEPLiftCreateDelay", CLNWLift )
end

function TOOL:Think()
	if CLIENT then
		if CL and CL.LiftDes and CL.LiftDes.SBEPLDDM then
			for n,B in pairs( CL.LiftDes.SBEPLDDM.CButtons ) do
				if B.Hold and B.Pressed then
					B:DoClick()
				end
			end
		end
	end	
end

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--					SERVER FUNCTIONS
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


if SERVER then

util.AddNetworkString("SBEP_OpenLiftDesignMenu_cl")
util.AddNetworkString("SBEP_CloseLiftDesignMenu_cl")
util.AddNetworkString("SBEPDisableButtons_cl")
util.AddNetworkString("SBEP_ReCalcViewAngles_LiftDesignMenu_cl")
util.AddNetworkString("SBEP_SetPHOffsetLiftDesignMenu_cl")

	function SBEP_SetLiftPartType( ply , cmd , args )
		local n = LiftSystem_SER[ply]:GetNWInt("ActivePart")
		local type = tostring( args[1] )
		if !LiftSystem_SER[ply].PartTable[n] then return end
		
		ply:ConCommand( "sbep_lift_designer_type "..type )
		LiftSystem_SER[ply].PartTable[n]:SetPartType( type )
		LiftSystem_SER[ply]:RefreshParts( n )
		
		ply:ConCommand( "SBEP_LiftGetCamHeight_ser" )
	end
	concommand.Add( "SBEP_LiftSys_SetLiftPartType_ser" , SBEP_SetLiftPartType )
	
	function SBEP_InvertLiftPart( ply , cmd , args )
		local n = LiftSystem_SER[ply]:GetNWInt("ActivePart")
			if !LiftSystem_SER[ply].PartTable[n] then return end
		LiftSystem_SER[ply].PartTable[n]:Invert()
		ply:ConCommand( "SBEP_LiftGetCamHeight_ser" )
	end
	concommand.Add( "SBEP_LiftSys_InvertLiftPart_ser" , SBEP_InvertLiftPart )	

	function SBEP_SetLiftPartYaw( ply , cmd , args )
		local n = LiftSystem_SER[ply]:GetNWInt("ActivePart")
			if !LiftSystem_SER[ply].PartTable[n] then return end
		LiftSystem_SER[ply].PartTable[n]:RotatePartYaw( tonumber( args[1] ) )
	end
	concommand.Add( "SBEP_LiftSys_SetLiftPartYaw_ser" , SBEP_SetLiftPartYaw )	
	
	function SBEP_LiftCancelMenu( ply , cmd , args )
		LiftSystem_SER[ply]:Remove()
		ply:ConCommand( "sbep_lift_designer_editing 0" )
	end
	concommand.Add( "SBEP_LiftCancelMenu_ser" , SBEP_LiftCancelMenu )	
	
	function SBEP_LiftGetCamHeight( ply , cmd , args )
		local n = tonumber(args[1])
		if not n then
			n = LiftSystem_SER[ply]:GetNWInt("ActivePart")
		end
		LiftSystem_SER[ply]:SetNWInt("ActivePart", n)

		local C = LiftSystem_SER[ply]:GetNWInt("SBEP_LiftPartCount")
		net.Start( "SBEP_SetPHOffsetLiftDesignMenu_cl")
			net.WriteFloat(LiftSystem_SER[ply].PartTable[ n ].PartData.HO)
		net.Send(ply)
		for k,v in ipairs( LiftSystem_SER[ply].PartTable ) do
			v:SetRenderMode( RENDERMODE_TRANSCOLOR )
			v:SetColor( Color( 255 , 255 , 255 , 255 ))
		end
		if n == C then
			LiftSystem_SER[ply].PartTable[ n ]:SetRenderMode( RENDERMODE_TRANSCOLOR )
			LiftSystem_SER[ply].PartTable[ n ]:SetColor( Color( 255 , 255 , 255 , 180 ))
		else
			LiftSystem_SER[ply].PartTable[ n ]:SetRenderMode( RENDERMODE_TRANSCOLOR )
			LiftSystem_SER[ply].PartTable[ n ]:SetColor( Color( 200  , 255 , 200 , 255 ))
			LiftSystem_SER[ply].PartTable[ C ]:SetRenderMode( RENDERMODE_TRANSCOLOR )
			LiftSystem_SER[ply].PartTable[ C ]:SetColor( Color(255 , 255 , 255 ,  180  ))
		end
		
		net.Start("SBEP_ReCalcViewAngles_LiftDesignMenu_cl")
		net.WriteFloat(LiftSystem_SER[ply].PartTable[ n ]:OBBMaxs():Length())
		net.Send(ply)
		
		LiftSystem_SER[ply].CanDown = false
		if n == 1 and LiftSystem_SER[ply].MDB then
			local tracedata = {}
				tracedata.start = LiftSystem_SER[ply].PartTable[1]:GetPos()
				if LiftSystem_SER[ply].PartTable[1].PartData.Inv then
					tracedata.endpos = tracedata.start + 200*LiftSystem_SER[ply].PartTable[1]:GetUp()
				else
					tracedata.endpos = tracedata.start - 200*LiftSystem_SER[ply].PartTable[1]:GetUp()
				end
				tracedata.filter = { LiftSystem_SER[ply] , LiftSystem_SER[ply].PartTable[1] }
			local trace = util.TraceHull(tracedata)
			if !trace.Hit then LiftSystem_SER[ply].CanDown = true end
		end
		net.Start("SBEPDisableButtons_cl")
		net.WriteInt( n, 16 )
		net.WriteInt( C, 16 )
		if LiftSystem_SER[ply].CanDown then 
			net.WriteBit( 1 )
		else net.WriteBit( 0 )
		end
		net.WriteString( LiftSystem_SER[ply].PartTable[1]:GetPartType())
		if C > 1 then net.WriteString( LiftSystem_SER[ply].PartTable[2]:GetPartType()) end
		if C > 2 then net.WriteString( LiftSystem_SER[ply].PartTable[C-1]:GetPartType() ) end
		net.Send(ply)
	end
	concommand.Add( "SBEP_LiftGetCamHeight_ser" , SBEP_LiftGetCamHeight )	
	
	function SBEP_LiftConstructPart( ply , cmd , args )
		local type = ply:GetInfo( "sbep_lift_designer_type" )
		local n = tonumber( args[1] )
		local D = args[2]
		--[[if n == 1 and D == "DOWN" then
			local NP = LiftSystem_SER[ply]:CreatePart()
		end--]]
		
		LiftSystem_SER[ply]:SetNWInt("ActivePart", n )

		local NP = LiftSystem_SER[ply]:CreatePart()
		LiftSystem_SER[ply]:AddPartToTable( NP , n )
		NP:SetPartType( type )

		LiftSystem_SER[ply]:RefreshParts( n )
		
		ply:ConCommand( "SBEP_LiftGetCamHeight_ser" )
	end
	concommand.Add( "SBEP_LiftConstructPart_ser" , SBEP_LiftConstructPart )
	
	function SBEP_LiftFinishSystem( ply , cmd , args )
		net.Start("SBEP_CloseLiftDesignMenu_cl")
		net.Send(ply)
		if LiftSystem_SER[ply]:GetPartCount() > 1 then
		LiftSystem_SER[ply]:FinishSystem()
		else
		LiftSystem_SER[ply]:Remove()
		end
		ply:ConCommand( "sbep_lift_designer_editing 0" )
	end
	concommand.Add( "SBEP_LiftFinishSystem_ser" , SBEP_LiftFinishSystem )
	
	function SBEP_LiftDeletePart( ply , cmd , args )
		local n = LiftSystem_SER[ply]:GetNWInt("ActivePart")
		if n == 1 and BEM[LiftSystem_SER[ply].PartTable[2]:GetPartType()] then return end

		LiftSystem_SER[ply]:RemovePartFromTable( n )
		LiftSystem_SER[ply]:RefreshParts( 1 )
		
		local C = LiftSystem_SER[ply]:GetPartCount()
		if n > C then
			LiftSystem_SER[ply]:SetNWInt("ActivePart", C )
		end
		ply:ConCommand( "SBEP_LiftGetCamHeight_ser" )
	end
	concommand.Add( "SBEP_LiftDeletePart_ser" , SBEP_LiftDeletePart )

	function MakeLift( Player, Data )

		local ent = ents.Create( Data.Class )
		duplicator.DoGeneric( ent, Data )
		ent:Spawn()

		duplicator.DoGenericPhysics( ent, Player, Data )

		return ent

	end
	duplicator.RegisterEntityClass( "sbep_elev_housing", MakeLift, "Data" )
	duplicator.RegisterEntityClass( "sbep_elev_system", MakeLift, "Data" )
	
	-- cleanup
	hook.Add("PlayerDisconnected", "SBEPPlayerDisconnected", function(ply)
		LiftSystem_SER[ply] = nil
	end)
	
	/*reset convars to defaults on load
	for k,v in pairs( ConVars ) do
	ply:ConCommand( "sbep_lift_designer_"..k , v )
	end*/

end

function TOOL:LeftClick( trace )

	if CLIENT then return end
	
	local ply = self:GetOwner()
	local Editing = ply:GetInfoNum( "sbep_lift_designer_editing", 0 )
	
	if Editing == 0 then
	
		local startpos = trace.HitPos
			LiftSystem_SER[ply] = ents.Create( "sbep_elev_system" )
			LiftSystem_SER[ply]:SetPos( startpos + Vector(0,0,4.65))
			LiftSystem_SER[ply]:SetAngles( Angle(0,-90,0) )
			LiftSystem_SER[ply]:SetModel( "models/smallbridge/elevators_small/sbselevp3.mdl" )
			LiftSystem_SER[ply].Skin = ply:GetInfoNum( "sbep_lift_designer_skin", 0 )
			LiftSystem_SER[ply]:SetNWBool( "Sendable" , true )
			LiftSystem_SER[ply].PLY		= ply
			LiftSystem_SER[ply]:SetOwner(ply)
			
		LiftSystem_SER[ply].Usable = ply:GetInfoNum( "sbep_lift_designer_enableuse", 0 ) == 1
		
		LiftSystem_SER[ply]:Spawn()
		
		LiftSystem_SER[ply]:SetSystemSize( ply:GetInfoNum( "sbep_lift_designer_size", 1 ) )
		
		local hatchconvar = ply:GetInfoNum( "sbep_lift_designer_doors", 0 )
		LiftSystem_SER[ply].SystemTable.UseHatches = hatchconvar == 2
		LiftSystem_SER[ply].SystemTable.UseDoors   = hatchconvar == 3
		LiftSystem_SER[ply]:SetNWInt("ActivePart", 1 )
			
		local NP = LiftSystem_SER[ply]:CreatePart()
			LiftSystem_SER[ply]:AddPartToTable( NP , 1 )
			NP:SetPartType( "M" )
		LiftSystem_SER[ply]:RefreshParts( 1 )
		
		LiftSystem_SER[ply].PartTable[ 1 ]:SetRenderMode( RENDERMODE_TRANSCOLOR )
		LiftSystem_SER[ply].PartTable[ 1 ]:SetColor( Color( 255 , 255 , 255 , 180 ))
		
		ply:ConCommand( "sbep_lift_designer_editing 1" )

		return true
	end
end

function TOOL:RightClick( trace )

end

function TOOL:Reload( trace )

end

function TOOL.BuildCPanel(panel)
	
	panel:SetSpacing( 10 )
	panel:SetName( "SBEP Lift System Designer" )
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local SkinTable = {
			"Scrappers"  ,
			"Advanced"   ,
			"SlyBridge"  ,
			"MedBridge2" ,
			"Jaanus"
				}
	
	local SLV = vgui.Create("DListView")
		SLV:SetSize(100, 101)
		SLV:SetMultiSelect(false)
		SLV:AddColumn("Skin")
		SLV.OnClickLine = function(parent, line, isselected)
												parent:ClearSelection()
												line:SetSelected( true )
												RunConsoleCommand( "sbep_lift_designer_skin", line:GetID() - 1 )
										end
		 
		for k,v in ipairs( SkinTable ) do
			SLV:AddLine(v)
		end
		SLV:GetLine( 1 ):SetSelected( true )
		RunConsoleCommand( "sbep_lift_designer_skin", 0 )
	panel:AddItem( SLV )
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local DoorTable = {
			"None"  			,
			"Shaft Hatches"   	,
			"Floor Doors"  		
				}

	local DLV = vgui.Create("DListView")
		DLV:SetSize(100, 67)
		DLV:SetMultiSelect(false)
		DLV:AddColumn("Doors and Hatches")
		DLV.OnClickLine = function(parent, line, isselected)
												parent:ClearSelection()
												line:SetSelected( true )
												RunConsoleCommand( "sbep_lift_designer_doors", line:GetID() )
										end
		 
		for k,v in ipairs( DoorTable ) do
			DLV:AddLine(v)
		end
		DLV:GetLine( 1 ):SetSelected( true )
		RunConsoleCommand( "sbep_lift_designer_doors", 1 )
	panel:AddItem( DLV )
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local SizeTable = {
				"Small"  	,
				"Large"   		
				}

	local SiLV = vgui.Create("DListView")
		SiLV:SetSize(100, 50)
		SiLV:SetMultiSelect(false)
		SiLV:AddColumn("Size")
		SiLV.OnClickLine = function(parent, line, isselected)
												parent:ClearSelection()
												line:SetSelected( true )
												RunConsoleCommand( "sbep_lift_designer_size", line:GetID() )
										end
		 
		for k,v in ipairs( SizeTable ) do
			SiLV:AddLine(v)
		end
		SiLV:GetLine( 1 ):SetSelected( true )
		RunConsoleCommand( "sbep_lift_designer_size", 1 )
	panel:AddItem( SiLV )
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local UseCheckBox = vgui.Create( "DCheckBoxLabel" )
		UseCheckBox:SetText( "Enable Use Key on Housings" )
		UseCheckBox:SetTextColor(Color(0,0,0,255))
		UseCheckBox:SetConVar( "sbep_lift_designer_enableuse" )
		UseCheckBox:SetValue( 0 )
		UseCheckBox:SizeToContents()
	panel:AddItem( UseCheckBox )
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local ResetLabel= vgui.Create("DLabel")
		ResetLabel:SetText("This tool is still a prototype. If the tool bugs,\nyou may need to reset it with this button.")
		ResetLabel:SetTextColor(Color(0,0,0,255))
		ResetLabel:SizeToContents()
	panel:AddItem( ResetLabel )
		
	local ResetButton = vgui.Create( "DButton")
		ResetButton:SetSize( 100, 20 )
		ResetButton:SetText( "Reset" )
		ResetButton.DoClick = function()
							RunConsoleCommand( "sbep_lift_designer_editing" , 0 )
						end
	panel:AddItem( ResetButton )
	
	if SBEPDoc then
		local HelpB = vgui.Create( "DButton" )
			HelpB.DoClick = function()
				SBEPDoc.OpenPage( "Construction" , "Lift Systems.txt" )
			end
			HelpB:SetText( "Lift Designer Help Page" )
		panel:AddItem( HelpB )
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
end
