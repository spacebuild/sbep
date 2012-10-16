RTSSelectionMaterial = Material( "sprites/light_glow02_add" )

function RTSViewTrace()

	local AVec = gui.ScreenToVector( gui.MousePos() )
	AVec:Rotate( LocalPlayer():EyeAngles() * -1 )
	AVec:Rotate( Angle(0,90,0) )
	local trace = {}
	trace.start = LocalPlayer():GetShootPos() + LocalPlayer().BComp.CVVec
	trace.endpos = (LocalPlayer():GetShootPos() + LocalPlayer().BComp.CVVec) + (AVec * 65535)
	--trace.filter = self.FTab
	local tr = util.TraceLine( trace )

	return tr.HitPos
end

function SBEPRTS() --It stands for Spacebuild Enhancement Project - Real Time Strategy, in case you couldn't guess
	local ply = LocalPlayer()
	local PLVec = ply:GetVehicle()
	if PLVec and PLVec:IsValid() then
		local BComp = PLVec:GetNetworkedEntity( "BattleComputer" ) or nil
		local BCR = BComp:GetNetworkedBool( "BattleComputerActive" ) or false
		if BComp and BComp:IsValid() and BComp:GetNetworkedEntity( "BattleComputerPod" ) == PLVec then
			if BCR then
			
				--print(ply:EyeAngles())
				------------------------------------Preperation------------------------------------
				if !BComp.Prepped then
					BComp.CVVec = Vector(0,0,1000)
					BComp.Prepped = true
					ply.BComp = BComp
				end
				ply.BCMode = true
				
				
				------------------------------------HUD Initialization------------------------------------
				if !ply.BCOrderBox then
					local OBWidth = 400
					local OBHeight = 100
					ply.BCOrderBox = vgui.Create( "DFrame" )
				    ply.BCOrderBox:SetSize( OBWidth, OBHeight )
				    ply.BCOrderBox:SetPos( (ScrW() / 2) - (OBWidth / 2), ScrH() - OBHeight )
				    ply.BCOrderBox:SetVisible( true )
				    ply.BCOrderBox:ShowCloseButton( false )
				    ply.BCOrderBox:SetDraggable( false )
				    ply.BCOrderBox:SetTitle( "Set Stance:" )
				   	
				    ply.BCOrderBox.Offence = vgui.Create( "Button", ply.BCOrderBox ) --Create a button that is attached to Frame 
				    ply.BCOrderBox.Offence:SetText( "Offence" ) --Set the button's text to "Click me!" 
				    ply.BCOrderBox.Offence:SetPos( 20, 35 ) --Set the button's position relative to it's parent(Frame) 
				    ply.BCOrderBox.Offence:SetWide( 80 ) --Sets the width of the button you're making 
					function ply.BCOrderBox.Offence:DoClick( ) --This is called when the button is clicked 
				    	--self:SetText( "Clicked" ) --Set the text to "Clicked"
				    	--SBEPRTS_SetStance( 3, BComp )
				    	SBEPRTS_SetStance( 3, LocalPlayer():GetVehicle():GetNetworkedEntity( "BattleComputer" ) )
					end
					local Button2 = vgui.Create( "Button", ply.BCOrderBox ) --Create a button that is attached to Frame 
				    Button2:SetText( "Defence" ) --Set the button's text to "Click me!" 
				    Button2:SetPos( 110, 35 ) --Set the button's position relative to it's parent(Frame) 
				    Button2:SetWide( 80 ) --Sets the width of the button you're making 
					function Button2:DoClick( ) --This is called when the button is clicked 
				    	SBEPRTS_SetStance( 2, BComp )
					end
					local Button3 = vgui.Create( "Button", ply.BCOrderBox ) --Create a button that is attached to Frame 
				    Button3:SetText( "Hold Fire" ) --Set the button's text to "Click me!" 
				    Button3:SetPos( 200, 35 ) --Set the button's position relative to it's parent(Frame) 
				    Button3:SetWide( 80 ) --Sets the width of the button you're making 
					function Button3:DoClick( ) --This is called when the button is clicked 
				    	SBEPRTS_SetStance( 1, BComp )
					end
					local Button4 = vgui.Create( "Button", ply.BCOrderBox ) --Create a button that is attached to Frame 
				    Button4:SetText( "Deactivate" ) --Set the button's text to "Click me!" 
				    Button4:SetPos( 290, 35 ) --Set the button's position relative to it's parent(Frame) 
				    Button4:SetWide( 80 ) --Sets the width of the button you're making 
					function Button4:DoClick( ) --This is called when the button is clicked 
				    	SBEPRTS_SetStance( 0, BComp )
					end
				end
				
				
				------------------------------------Display the HUD------------------------------------
				if ply.BCOrderBox then
					ply.BCOrderBox:SetVisible( true )
					gui.EnableScreenClicker( true )
				end
				
				
				------------------------------------Selection------------------------------------
				if input.IsMouseDown(MOUSE_FIRST) and !BComp.COrder then
					if !BComp.RTS_Selecting then
						--print("Mouse Start")
						if (gui.MouseY() < (ScrH() - 100)) then -- Note to self: Create a constant for the height/width of the various panels.

							BComp.RTS_Selecting = true
							BComp.RTS_SelStartP = RTSViewTrace() + Vector(0,0,20)
							
							--print(tr.HitPos)
						end
					else
						BComp.RTS_SelCurP = RTSViewTrace() + Vector(0,0,20)
						
						local effectdata = EffectData() 
						effectdata:SetOrigin( BComp.RTS_SelStartP ) 
						effectdata:SetStart( Vector(BComp.RTS_SelStartP.x,BComp.RTS_SelCurP.y,BComp.RTS_SelStartP.z) ) 
						util.Effect( "RTSSelection", effectdata )
						
						local effectdata = EffectData() 
						effectdata:SetOrigin( Vector(BComp.RTS_SelCurP.x,BComp.RTS_SelCurP.y,BComp.RTS_SelStartP.z) ) 
						effectdata:SetStart( Vector(BComp.RTS_SelStartP.x,BComp.RTS_SelCurP.y,BComp.RTS_SelStartP.z) ) 
						util.Effect( "RTSSelection", effectdata )
						
						local effectdata = EffectData() 
						effectdata:SetOrigin( Vector(BComp.RTS_SelCurP.x,BComp.RTS_SelCurP.y,BComp.RTS_SelStartP.z) ) 
						effectdata:SetStart( Vector(BComp.RTS_SelCurP.x,BComp.RTS_SelStartP.y,BComp.RTS_SelStartP.z) ) 
						util.Effect( "RTSSelection", effectdata )
						
						local effectdata = EffectData() 
						effectdata:SetOrigin( Vector(BComp.RTS_SelCurP.x,BComp.RTS_SelStartP.y,BComp.RTS_SelStartP.z) ) 
						effectdata:SetStart( BComp.RTS_SelStartP ) 
						util.Effect( "RTSSelection", effectdata )
						
						--This stuff is only here for debugging purposes
						/*
						if BComp.Sec1 then BComp.Sec1:Remove() end
						BComp.Sec1 = ClientsideModel("models/props_junk/PopCan01a.mdl", RENDERGROUP_OPAQUE)
						BComp.Sec1:SetPos(BComp.RTS_SelStartP)
						BComp.Sec1:SetMaterial("models/alyx/emptool_glow")
						BComp.Sec1:SetModelScale(Vector(10,10,10))
						
						if BComp.Sec2 then BComp.Sec2:Remove() end
						BComp.Sec2 = ClientsideModel("models/props_junk/PopCan01a.mdl", RENDERGROUP_OPAQUE)
						BComp.Sec2:SetPos(Vector(BComp.RTS_SelCurP.x,BComp.RTS_SelCurP.y,BComp.RTS_SelStartP.z))
						BComp.Sec2:SetMaterial("models/alyx/emptool_glow")
						BComp.Sec2:SetModelScale(Vector(10,10,10))
						
						if BComp.Sec3 then BComp.Sec3:Remove() end
						BComp.Sec3 = ClientsideModel("models/props_junk/PopCan01a.mdl", RENDERGROUP_OPAQUE)
						BComp.Sec3:SetPos(Vector(BComp.RTS_SelStartP.x,BComp.RTS_SelCurP.y,BComp.RTS_SelStartP.z))
						BComp.Sec3:SetMaterial("models/alyx/emptool_glow")
						BComp.Sec3:SetModelScale(Vector(10,10,10))
						
						if BComp.Sec4 then BComp.Sec4:Remove() end
						BComp.Sec4 = ClientsideModel("models/props_junk/PopCan01a.mdl", RENDERGROUP_OPAQUE)
						BComp.Sec4:SetPos(Vector(BComp.RTS_SelCurP.x,BComp.RTS_SelStartP.y,BComp.RTS_SelStartP.z))
						BComp.Sec4:SetMaterial("models/alyx/emptool_glow")
						BComp.Sec4:SetModelScale(Vector(10,10,10))
						*/
						
					end
				else
					
					if BComp.RTS_Selecting then
						BComp.UnitsSelected = {}
						local FEnts = ents.FindInBox( BComp.RTS_SelStartP - Vector(0,0,10000), BComp.RTS_SelCurP + Vector(0,0,10000) ) 
						for _,i in ipairs(FEnts) do
							--print(i:GetClass())
							local Com = i.BCCommandable
							--print(Com)
							if Com then
								table.insert( BComp.UnitsSelected, i )
							end
							--LocalPlayer():ConCommand("RTSSelection "..BComp.RTS_SelStartP.x.." "..BComp.RTS_SelStartP.y.." "..BComp.RTS_SelStartP.z.." "..BComp.RTS_SelCurP.x.." "..BComp.RTS_SelCurP.y.." "..BComp.RTS_SelCurP.z)
							--PrintTable(BComp.UnitsSelected)
						end
						 
					end
					
					BComp.RTS_Selecting = false
					
				end
				
				for k,i in ipairs(BComp.UnitsSelected) do
					if !i or !i:IsValid() then
						table.remove(BComp.UnitsSelected, k)
					end
					--PrintTable(BComp.UnitsSelected)
				end
				
				if input.IsMouseDown(MOUSE_FIRST) and BComp.COrder then
					
				end
				
				
				------------------------------------Orders------------------------------------
				
				local Y,X = gui.MousePos()
				if input.IsMouseDown(MOUSE_RIGHT) then
					if !BComp.AltC then
						BComp.OYOff = X
						BComp.OrderBaseVec = RTSViewTrace()
						BComp.AltC = true
					else
						local AVec = BComp.OrderBaseVec + Vector(0,0,(X - BComp.OYOff) * -10)
						local effectdata = EffectData() 
						effectdata:SetOrigin( BComp.OrderBaseVec ) 
						effectdata:SetStart( AVec ) 
						util.Effect( "RTSSelection", effectdata )
					end
				else
					if BComp.AltC then
						local AVec = BComp.OrderBaseVec + Vector(0,0,(X - BComp.OYOff) * -10) + Vector(0,0,BComp.MSize * 3)
						--local trace = RTSViewTrace()
						--LocalPlayer():ConCommand("IssueRTSOrder "..trace.x.." "..trace.y.." "..trace.z)
						SBEPRTS_IssueOrder( AVec, BComp, 1 )
						local effectdata = EffectData() 
						effectdata:SetOrigin( AVec - Vector(0,0,BComp.MSize * 3) )
						util.Effect( "RTSOrder", effectdata )
						BComp.AltC = false
					end
				end
				
				------------------------------------Scrolling------------------------------------
				local Y,X = gui.MousePos()
				if X < 50 then
					BComp.CVVec.x = BComp.CVVec.x + ( ( ( 50 - X ) * 0.5 ) * 5 )
					if BComp.CVVec.x > 10000 then
						BComp.CVVec.x = 10000
					end
				elseif X > ( ScrH() - 50 ) then
					BComp.CVVec.x = BComp.CVVec.x - ( ( ( X - ( ScrH() - 50 ) ) * 0.5 ) * 5 )
					if BComp.CVVec.x < -10000 then
						BComp.CVVec.x = -10000
					end
				end
				if Y < 50 then
					BComp.CVVec.y = BComp.CVVec.y + ( ( ( 50 - Y ) * 0.5 ) * 5 )
					if BComp.CVVec.y > 10000 then
						BComp.CVVec.y = 10000
					end
				elseif Y > ( ScrW() - 50 ) then
					BComp.CVVec.y = BComp.CVVec.y - ( ( ( Y - ( ScrW() - 50 ) ) * 0.5 ) * 5 )
					if BComp.CVVec.y < -10000 then
						BComp.CVVec.y = -10000
					end
				end
							
				BComp.BCZScroll = BComp.BCZScroll or 0
				
				if input.IsKeyDown( KEY_PAGEDOWN ) then
					BComp.BCZScroll = math.Clamp(BComp.BCZScroll - 15,-700,700)
				elseif input.IsKeyDown( KEY_PAGEUP ) then
					BComp.BCZScroll = math.Clamp(BComp.BCZScroll + 15,-700,700)
				else
					BComp.BCZScroll = 0
				end
				
				--print(BComp.BCZScroll)
				
				BComp.CVVec.z = math.Clamp(BComp.CVVec.z + BComp.BCZScroll,-10000,10000)
				
				------------------------------------Selection Display------------------------------------
				BComp.UnitsSelected = BComp.UnitsSelected or {}
				local MSize = 0
				for _,i in ipairs(BComp.UnitsSelected) do
					if i and i:IsValid() then
						local Mag = i:GetNetworkedInt( "Size" )
						if Mag <= 0 then Mag = 500 end
						if Mag > MSize then MSize = Mag end
						local effectdata = EffectData() 
						effectdata:SetOrigin( i:GetPos() )
						effectdata:SetStart( i:GetPos() ) 
						effectdata:SetMagnitude( Mag )
						util.Effect( "RTSSelected", effectdata )
					end
				end
				BComp.MSize = MSize
				
			else
				if ply.BCOrderBox then
					ply.BCOrderBox:SetVisible( false )
					gui.EnableScreenClicker( false )
				end
				ply.BCMode = false
				BComp.Prepped = false
			end
		else
			if ply.BCOrderBox then
				ply.BCOrderBox:SetVisible( false )
				gui.EnableScreenClicker( false )
			end
			ply.BCMode = false
		end
	else
		if ply.BCOrderBox then
			ply.BCOrderBox:SetVisible( false )
			gui.EnableScreenClicker( false )
		end
		ply.BCMode = false
	end
end

hook.Add("Think", "SBEPRTS", SBEPRTS)

--function SBEPRTSHud() 
	--Turns out this wasn't needed after all. I'm leaving it commented out, in case it ever turns out to be useful.	
--end 
--hook.Add("HUDPaint", "SBHud", SBHud)

function RTSC()
	local ply = LocalPlayer()
	ply.BCOrderBox:SetVisible( false )
	ply.BCOrderBox:Remove()
	ply.BCOrderBox = nil
end

function SBEPRTS_SetStance( Stance, Computer )
	--print(table.Count(Computer.UnitsSelected))
	if !Computer then
		print("No Computer!")
		return 
	end
	
	if !Computer.UnitsSelected then 
		print("Critical Unit Failure!")
		return 
	end
	for _,i in ipairs(Computer.UnitsSelected) do
		if i and i:IsValid() then
			LocalPlayer():ConCommand("RTSSetStance "..i:EntIndex().." "..Stance)
		end
	end
end

function SBEPRTS_IssueOrder( Vec, Computer, OrderType )
	--print(Computer)
	local UCount = table.Count(Computer.UnitsSelected)
	local Dir = Vector(0,0,0)
	local Ang = Angle(0,0,0)
	local Distance = Computer.MSize * 3
	if UCount > 0 then
		local First = Computer.UnitsSelected[1]
		if First and First:IsValid() then
			Dir = (First:GetPos() - Vec):GetNormal()
			Ang = (Dir * -1):Angle()
			Ang.p = 0 --I'll figure out vertical formations later
		end
		if UCount > 1 then
			if Computer.Formation == 0 then
				for k,i in ipairs(Computer.UnitsSelected) do
					if i and i:IsValid() then
						local Ri = (k - (UCount/2)) * Distance
						local AV = Vec + (Ang:Right() * Ri)
						LocalPlayer():ConCommand("IssueRTSOrder "..i:EntIndex().." "..AV.x.." "..AV.y.." "..AV.z.." "..OrderType.." "..Ang.r.." "..Ang.p.." "..Ang.y.." "..1)
					end
				end
			elseif Computer.Formation == 1 then
				local RC = 0 --Y'know, sometimes I think I deliberately label variables as ambiguously as possible just to make things difficult for myself...
				local CR = 0
				local ColumnWidth = 3
				for k,i in ipairs(Computer.UnitsSelected) do
					if i and i:IsValid() then
						RC = RC + 1
						if RC >= ColumnWidth then
							RC = 0
							CR = CR + 1
						end
						local Ri = (RC - (ColumnWidth/2)) * Distance
						local Fr = (CR * -Distance)
						local AV = Vec + (Ang:Right() * Ri) + (Ang:Forward() * Fr) 
						LocalPlayer():ConCommand("IssueRTSOrder "..i:EntIndex().." "..AV.x.." "..AV.y.." "..AV.z.." "..OrderType.." "..Ang.r.." "..Ang.p.." "..Ang.y.." "..1)
					end
				end
			else
				for k,i in ipairs(Computer.UnitsSelected) do
					if i and i:IsValid() then
						local Ri = (k - (UCount/2)) * Distance
						local AV = Vec + (Ang:Right() * Ri)
						LocalPlayer():ConCommand("IssueRTSOrder "..i:EntIndex().." "..AV.x.." "..AV.y.." "..AV.z.." "..OrderType.." "..Ang.r.." "..Ang.p.." "..Ang.y.." "..1)
					end
				end
			end
		else
			for _,i in ipairs(Computer.UnitsSelected) do
				if i and i:IsValid() then
					LocalPlayer():ConCommand("IssueRTSOrder "..i:EntIndex().." "..Vec.x.." "..Vec.y.." "..Vec.z.." "..OrderType.." "..Ang.r.." "..Ang.p.." "..Ang.y.." "..0)
				end
			end
		end
	end
	--print(UCount)
end

function SBEPBMView( ply, origin, angles, fov ) 
	if ply.BCMode then
		if ply.BComp and ply.BComp:IsValid() then
			
		 	origin = origin + ply.BComp.CVVec
			angles = Angle(90,0,0) 
		end
		
		return GAMEMODE:CalcView(ply,origin,angles,fov)
	end
end 
hook.Add("CalcView", "SBEPBMView", SBEPBMView)  
--[[
function PlayerPress( ply, bind ) -- Thanks to Catdaemon and Creec for this bit :)
	if string.find(bind, "invnext") then
		ply.BCZScroll = math.Clamp(ply.BCZScroll - 10,-100,100) or 0
	end
	if string.find(bind, "invprev") then
		ply.BCZScroll = math.Clamp(ply.BCZScroll + 10,-100,100) or 0
	end
end
hook.Add( "PlayerBindPress", "PlayerPress", PlayerPress )
]]--
