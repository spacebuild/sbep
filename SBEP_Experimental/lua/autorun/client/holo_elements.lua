holo = {}

holo.Register = function( sName , heObject , sParent )
					holo.Classes = holo.Classes or {}
					if sParent then
						local P = holo.Classes[sParent]
						if P then
							table.Inherit( heObject, P )
						end
					end
					heObject.Class = sName
					heObject.IsHElement = function(self) return true end
					holo.Classes[sName] = heObject
					return true
				end

holo.Create = function( sName , heParent )
					if !holo.Classes or !holo.Classes[sName] then ErrorNoHalt"Holo Class does not exist." return end
					
					local Obj = table.Copy( holo.Classes[sName] )
						Obj:Initialize()
						if heParent then
							Obj:SetParent( heParent )
						end
					return Obj
				end

holo.Render = function( heObject ) --or eHoloPanel
					heObject:Draw()
					if heObject.Children then
						for n,HE in ipairs( heObject.Children ) do
							holo.Render( HE )
						end
					end
				end

local FORCE_TABLE, FORCE_COLOR, FORCE_ENTITY, FORCE_HELEMENT	= 4, 5, 6, 7

local AccessorFunc = function ( tOBJ , sVar , sMethod , enFT )
						if type( tOBJ ) ~= "table" then return end
						
						tOBJ[ "Get"..sMethod ] = function( self ) return self[ sVar ] end

						if enFT == FORCE_BOOL then
							tOBJ[ "Set"..sMethod ] = function( self, B ) self[ sVar ] = tobool( B ) end
						return end
						if enFT == FORCE_NUMBER then
							tOBJ[ "Set"..sMethod ] = function( self, N ) self[ sVar ] = tonumber( N ) or self[ sVar ] end
						return end
						if enFT == FORCE_STRING then
							tOBJ[ "Set"..sMethod ] = function( self, S ) self[ sVar ] = tostring( S ) or self[ sVar ] end
						return end
						if enFT == FORCE_TABLE then
							tOBJ[ "Set"..sMethod ] = function( self, T ) if type( T ) == "table" then self[ sVar ] = T end end
						return end
						if enFT == FORCE_COLOR then
							tOBJ[ "Set"..sMethod ] = function( self, C )
														if type( C ) == "table" and C.r and C.g and C.b and C.a then self[ sVar ] = C end end
						return end
						if enFT == FORCE_ENTITY then
							tOBJ[ "Set"..sMethod ] = function( self, E )
														if E and E:IsValid() then self[ sVar ] = E end end
						return end
						if enFT == FORCE_HELEMENT then
							tOBJ[ "Set"..sMethod ] = function( self, HE )
														if HE and HE:IsHElement() then self[ sVar ] = HE end end
						return end
					   
						tOBJ[ "Set"..sMethod ] = function( self, var ) self[ sVar ] = var end
					end

local function ClampColor( cC )
	local r,g,b,a = math.Clamp( cC.r,0,255 ) , math.Clamp( cC.g,0,255 ) , math.Clamp( cC.b,0,255 ) , math.Clamp( cC.a,0,255 )
	return Color( r,g,b,a )
end

---------------------------------------------------------------------------------------------------
--	HRect										--
---------------------------------------------------------------------------------------------------
local OBJ = {}

AccessorFunc(  OBJ,  "bHL"		,  "HL"				,  FORCE_BOOL 		)
AccessorFunc(  OBJ,  "bCHL"		,  "CheckHL"		,  FORCE_BOOL 		)
AccessorFunc(  OBJ,  "bAFP"		,  "AlphaFromParent",  FORCE_BOOL 		)
AccessorFunc(  OBJ,  "bAFE"		,  "AlphaFromElement", FORCE_BOOL 		)
AccessorFunc(  OBJ,  "bHLFC"	,  "HLFromColor"	,  FORCE_BOOL 		)
AccessorFunc(  OBJ,  "nWide"	,  "Wide"			,  FORCE_NUMBER 	)
AccessorFunc(  OBJ,  "nTall"	,  "Tall"			,  FORCE_NUMBER 	)
AccessorFunc(  OBJ,  "nRad"		,  "Radius"			,  FORCE_NUMBER 	)
AccessorFunc(  OBJ,  "nVal"		,  "Value"			,  FORCE_NUMBER 	)
AccessorFunc(  OBJ,  "sOutput"	,  "Output"			,  FORCE_STRING 	)
AccessorFunc(  OBJ,  "tPos"		,  "Pos"	 		,  FORCE_TABLE	 	)
AccessorFunc(  OBJ,  "cCol"		,  "Color"	 		,  FORCE_COLOR	 	)
AccessorFunc(  OBJ,  "cHLCol"	,  "HLColor"		,  FORCE_COLOR	 	)
AccessorFunc(  OBJ,  "heParent"	,  "Parent"			,  FORCE_HELEMENT 	)
AccessorFunc(  OBJ,  "heElement",  "Element"		,  FORCE_HELEMENT 	)
AccessorFunc(  OBJ,  "ePanel"	,  "Panel"			,  FORCE_ENTITY 	)

function OBJ:Initialize()

	self:SetPos(0,0) 
	self:SetRadius( 6 )
	self:SetSize( 10, 10 )
	self:SetValue( 0 )
	self:SetOutput( "" )
	self:SetHLFromColor( true )
	self:SetColor( Color(255,255,255,255) )
	
end

function OBJ:Draw()
	self:Think()

	local w,t = self:GetSize()
	local x, y = self:GetWorldPos()
	local C
	if self:GetAlphaFromElement() or self:GetAlphaFromParent() then
		C = self:ModColorAlpha()
	else
		C = self:GetHL() and self:GetHLColor() or self:GetColor()
	end
	
	draw.RoundedBox( self:GetRadius() , x - 0.5*w , y - 0.5*t , w, t, C )
end

function OBJ:Think()
	if self:GetCheckHL() then
		self:SetHL( self:MouseCheck( self:MPos() ) )
	end
end

function OBJ:SetPos( x , y )
	local X, Y = tonumber(x) or 0, tonumber(y) or 0
	
	self.nXPos = X
	self.nYPos = Y

	self:SetWorldPos()
	
	if self.Components then
		for n,E in ipairs( self.Components ) do
			E:SetPos( E:GetPos() )
		end
	end
end

function OBJ:GetPos()
	return self.nXPos, self.nYPos
end

function OBJ:SetWorldPos()
	local X, Y = self:GetPos()
	
	local HE = self:GetElement() or self:GetParent()
	local PX, PY = 0, 0
	if HE then
		PX, PY = HE:GetWorldPos()
	end
	self.nWXPos, self.nWYPos = X + PX , Y + PY
end
	
function OBJ:GetWorldPos()
	return self.nWXPos, self.nWYPos
end

function OBJ:SetSize( x , y )
	if type(x) == "number" and x > 0 then
		self:SetWide( x )
	end
	if type(y) == "number" and y > 0 then
		self:SetTall( y )
	end
end

function OBJ:GetSize()
	return self:GetWide(), self:GetTall()
end

function OBJ:SetRadius( nR )
	nR = math.Round( nR )
	nR = nR - math.fmod( nR, 2 )
	self.nRad = nR
end

function OBJ:SetColor( cC )
	self.cCol = ClampColor( cC )

	if self:GetHLFromColor() then
		self:SetHLColor( cC )
		self:SetHLColorBright( math.fmod( self:GetHLColorBright() + 0.15, 255 ) )
	end
end

function OBJ:SetHLColor( cC )
	self.cHLCol = ClampColor( cC )
end

function OBJ:SetColorBright( iV )
	iV = math.Clamp( iV, 0, 1 )
	local C = self:GetColor()
	local h,s,v = ColorToHSV( C )
	local C2 = HSVToColor( h,s, iV )
	C2.a = C.a
	self:SetColor( C2 )
end

function OBJ:GetColorBright()
	local h,s, V = ColorToHSV( self:GetColor() )
	return V
end

function OBJ:SetHLColorBright( iV )
	iV = math.Clamp( iV, 0, 1 )
	local C = self:GetHLColor()
	local h,s,v = ColorToHSV( C )
	local C2 = HSVToColor( h,s, iV )
	C2.a = C.a	
	self:SetHLColor( C2 )
end

function OBJ:GetHLColorBright()
	local h,s, V = ColorToHSV( self:GetHLColor() )
	return V
end

function OBJ:CheckPAlpha()
	local P = self:GetPanel()
		if P then
			return P:GetAlpha() or 1
		end
	return 1
end

function OBJ:ModColorAlpha()
	local A, C = self:CheckPAlpha(), self:GetColor()
		if self:GetHL() then
			C = self:GetHLColor()
		end
	return Color(C.r, C.g, C.b, C.a * A)
end

function OBJ:MouseCheck( MX, MY )
	local w, t = self:GetSize()
	if w and t then
		if MX >= -0.5*w and MX <= 0.5*w and MY >= -0.5*t and MY <= 0.5*t then
			return true
		end
	end
	return false
end
 
function OBJ:MPos()
	local panel = self:GetPanel()
	if panel then
		local mx, my = panel:MouseInfo()
		local x, y = self:GetWorldPos()		
		return x - mx, y - my
	end
	return 0,0
end

function OBJ:Input( nInput )
	if type(nInput) == "number" then
		self:SetValue( nInput )
	elseif type(nInput) == "Vector" then
		self.vVect = nInput
	end
end

function OBJ:Output(Output)
	local P = self:GetPanel()
	if !P then return end
	
	local OPType, sO = type(Output), self:GetOutput()
	--Check that the output is different to whatever was outputted last, so we don't keep sending the same value.
	if Output ~= self.LOutput and sO and sO ~= "" then
		if OPType == "number" then
			RunConsoleCommand( "HoloEleOut" , P:EntIndex() , sO, OPType , tostring(Output) )
		elseif OPType == "Vector" then
			RunConsoleCommand( "HoloEleOut" , P:EntIndex() , sO, OPType , Output.x, Output.y, Output.z )
		end
		self.LOutput = Output
	end
end

function OBJ:SetPanel( ePanel )
	if ePanel and ePanel:IsValid() then
		self.ePanel = ePanel
		if self.Components then
			for n,E in ipairs( self.Components ) do
				E:SetPanel( ePanel )
			end
		end
	end
end

function OBJ:GetPanel()
	local P = self.ePanel
	if P and P:IsValid() then
		return P
	else
		E = self:GetElement()
		if E then
			return E:GetPanel()
		end
		P = self:GetParent()
		if P then
			return P:GetPanel()
		end
	end
end

function OBJ:SetParent( heParent )
	self.heParent = heParent
	
	heParent.Children = heParent.Children or {}
		table.insert( heParent.Children, self )
end

function OBJ:SetElement( heElement )
	if !heElement or !heElement:IsHElement() then return end
	
	self.heElement = heElement
		heElement:AddComponent( self )
end

function OBJ:AddComponent( heComp )
	if !heComp or !heComp:IsHElement() then return end
	if !self.Components then self.Components = {} end
	
	table.insert( self.Components, heComp)
end

/*function OBJ:OnPressed()
end

function OBJ:OnReleased()
end*/

holo.Register( "HRect" , OBJ )

---------------------------------------------------------------------------------------------------
--	HCircle										--
---------------------------------------------------------------------------------------------------
local OBJ = {}

function OBJ:Initialize()

	self:SetPos(0,0) 
	self:SetRadius( 10 )
	self:SetValue( 0 )
	self:SetOutput( "" )
	self:SetHLFromColor( true )
	self:SetColor( Color(255,255,255,255) )
	
end

function OBJ:Draw()
	self:Think()

	local R = self:GetRadius()
	local x, y = self:GetWorldPos()
	local C
	if self:GetAlphaFromElement() or self:GetAlphaFromParent() then
		C = self:ModColorAlpha()
	else
		C = self:GetHL() and self:GetHLColor() or self:GetColor()
	end
	
	draw.RoundedBox( R , x - R , y - R , 2*R, 2*R, C )
end

function OBJ:SetSize( x , y )
	self:SetRadius( x )
end

function OBJ:GetSize()
	self:GetRadius()
end

function OBJ:MouseCheck( MX, MY )
	local R = self:GetRadius()
	if R then
		if MX >= -R and MX <= R and MY >= -R and MY <= R then
			return true
		end
	end
	return false
end

holo.Register( "HCircle" , OBJ , "HRect" )

---------------------------------------------------------------------------------------------------
--	HLabel										--
---------------------------------------------------------------------------------------------------
local OBJ = {}

AccessorFunc(  OBJ,  "sText"	,  "Text"		, FORCE_STRING	)
AccessorFunc(  OBJ,  "sFont"	,  "Font"		, FORCE_STRING	)
AccessorFunc(  OBJ,  "enAlign"	,  "Align"		)
AccessorFunc(  OBJ,  "nFSize"	,  "FontSize"	, FORCE_NUMBER	)
AccessorFunc(  OBJ,  "nFWeight"	,  "FontWeight"	, FORCE_NUMBER	)

function OBJ:Initialize()
	
	self:SetText( "Label" )
	self:SetFont( "TargetID" )
	self:SetFontSize( 30 )
	self:SetFontWeight( 400 )
	self:SetAlign( TEXT_ALIGN_CENTER )

end

function OBJ:Draw()
	self:Think()
	
	local x, y = self:GetPos()
	draw.DrawText( self:GetText() , self:GetFont(), x, y-13, self:GetColor() , self:GetAlign() )
end

function OBJ:SetAlign( enA )
	local en = {
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_TOP,
		TEXT_ALIGN_BOTTOM
				}
	
	for n, EN in ipairs( en ) do
		if enA == n - 1 or enA == EN then
			self.enAlign = EN
		end
	end
end

holo.Register( "HLabel" , OBJ , "HRect" )

---------------------------------------------------------------------------------------------------
--	HButton										--
---------------------------------------------------------------------------------------------------

local OBJ = {}

AccessorFunc( OBJ , "bOn"		, "Pressed"		, FORCE_BOOL	)
AccessorFunc( OBJ , "bToggle"	, "Toggle"		, FORCE_BOOL	)
AccessorFunc( OBJ , "nMax"		, "OnValue"		, FORCE_NUMBER	)
AccessorFunc( OBJ , "nMin"		, "OffValue"	, FORCE_NUMBER	)

function OBJ:Initialize()
	
	self.BaseClass.Initialize( self )
	
	self:SetOnValue(1)
	self:SetOffValue(0)

	H = holo.Create( "HRect" )
		H:SetElement( self )
		H:SetSize( self:GetWide() + 1 , self:GetTall() + 1 )
		H:SetAlphaFromElement( true )
	self.Shadow = H
	
	local H = holo.Create( "HRect" )
		H:SetElement( self )
		H:SetCheckHL( true )
		H:SetAlphaFromElement( true )
	self.Rect = H
	
	self:SetPressed( false )
	self:SetColor( self:GetColor() )

end

function OBJ:Think()	
	if self:GetToggle() then
		if (LocalPlayer():KeyPressed( IN_USE ) or (input.IsMouseDown(MOUSE_FIRST) and !self.MTog)) and self:MouseCheck( self:MPos() ) then
			self:Toggle()
			self.MTog = true
		elseif !input.IsMouseDown(MOUSE_FIRST) then
			self.MTog = false
		end
	elseif (LocalPlayer():KeyDown( IN_USE ) or (input.IsMouseDown(MOUSE_FIRST))) and  self:MouseCheck( self:MPos() ) then
		self:SetPressed( true )
	elseif self:GetPressed() then
		self:SetPressed( false )
	end
end

function OBJ:SetColor( cC )
	self.BaseClass.SetColor( self, cC )
	
	local R = self.Rect
	if R then
		R:SetColor( cC )
	end
	local S = self.Shadow
	if S then
		S:SetColor( cC )
		S:SetColorBright( math.fmod( self:GetColorBright() - 0.7 , 1 ) )
	end
end

function OBJ:SetSize( x , y )
	self:SetWide( x )
	self:SetTall( y )
	
	local R, S = self.Rect, self.Shadow
	if R then
		R:SetSize( x, y )
	end
	if S then
		S:SetSize( x+1, y+1 )
	end
end

function OBJ:SetPressed( bPress )
	if type(bPress) ~= "boolean" then return end
	if !self.bOn then self.bOn = !bPress end
	if self.bOn ~= bPress then
		self.bOn = bPress
		self:Output( bPress and self:GetOnValue() or self:GetOffValue() )
		local o = bPress and 0 or -1
		
		self.Rect:SetPos( o , o )
		self.Shadow:SetPos( 0 , 0 )

	end
end

function OBJ:Toggle()
	self:SetPressed( !self:GetPressed() )
end

function OBJ:Draw()
	self:Think()
	
	self.Shadow:Draw()
	self.Rect:Draw()
end

holo.Register( "HButton" , OBJ , "HRect" )

---------------------------------------------------------------------------------------------------
--	HSBar										--
---------------------------------------------------------------------------------------------------
local OBJ = {}

AccessorFunc( OBJ, "bVert"	, "Vertical"	, FORCE_BOOL )
AccessorFunc( OBJ, "bDrag"	, "Dragging"	, FORCE_BOOL )
AccessorFunc( OBJ, "bJump"	, "AllowJump"	, FORCE_BOOL )
AccessorFunc( OBJ, "nVal"	, "Value"		, FORCE_NUMBER )
AccessorFunc( OBJ, "nMax"	, "Max"			, FORCE_NUMBER )
AccessorFunc( OBJ, "nMin"	, "Min"			, FORCE_NUMBER )

function OBJ:Initialize()

	self.BaseClass.Initialize( self )

	self:SetMin( 0 )
	self:SetMax( 1 )
	self:SetCheckHL( false )
	self:SetRadius( 2 )
	self:SetVertical( true )
	self:SetAllowJump( false )
	
	local H = holo.Create( "HRect" )
		H:SetElement( self )
		H:SetRadius( 2 )
		H:SetAlphaFromElement( true )
	self.Bar = H
	
	H = holo.Create( "HRect" )
		H:SetElement( self )
		H:SetRadius( 2 )
		H:SetAlphaFromElement( true )
		H:SetCheckHL( true )
	self.Slider = H
	
	self:SetSize( 14, 50 )
	self:SetValue( 0.5 )
	self:SetColor( Color(255,255,255,255) )
end

function OBJ:Draw()
	self:Think()
	
	self.Bar:Draw()
	self.Slider:Draw()
end

function OBJ:Think()
	local D = false
	if LocalPlayer():KeyDown( IN_USE ) or input.IsMouseDown(MOUSE_FIRST) then
		local M = false
		local x, y = self:MPos()
		if self:GetAllowJump() then
			M = self:MouseCheck( x,y )
		else
			M = self.Slider:MouseCheck( self.Slider:MPos() )
		end

		if M or self:GetDragging() then
			D = true
			
			local V, l = self:GetVertical(), self:GetLength()
			local m = V and y or x
			
			self:SetValue( Lerp( math.Clamp( 0.5 + m/l ,0,1 ) , self:GetMin(), self:GetMax() ) )
		end
	end
	self:SetDragging( D )
end

function OBJ:GetLength()
	return (self:GetVertical() and self:GetTall() or self:GetWide())
end

function OBJ:SetSize( x, y )
	local V = self:GetVertical()
	
	self:SetWide( x )
	self:SetTall( y )
	
	local B, S = self.Bar, self.Slider
	if V then
		if B then B:SetSize( x-4 , y  ) end
		if S then S:SetSize( x , y/15 ) end
	else
		if B then B:SetSize(  x , y-4 ) end
		if S then S:SetSize( x/15 , y ) end
	end
end

function OBJ:SetVertical( bV )
	local B = tobool(bV)
	self.bVert = B
	
	self:SetSize( self:GetSize() )
end

function OBJ:SetColor( cC )
	local H = self:GetHL()
	
	self.cCol = cC
	local B, S = self.Bar, self.Slider
	if B then 
		B:SetColor( cC )
		B:SetColorBright( math.fmod( B:GetColorBright() - 0.75 , 0 , 1 ) )
	end
	if S then S:SetColor( cC ) end
end

function OBJ:SetValue( nVal )
	if type( nVal ) ~= "number" then return end
	self.nVal = nVal
	if self.Slider then
		local V, d = self:GetVertical(), self:GetLength()
		local f = ( nVal - self:GetMin() ) / ( self:GetMax() - self:GetMin() )

		if V then
			self.Slider:SetPos( 0 , math.Clamp( d*(0.5 - f) , -0.5*d+1 , 0.5*d-1 )  )
		else
			self.Slider:SetPos( math.Clamp( d*(0.5 - f) , -0.5*d+1 , 0.5*d-1 ) , 0  )
		end
	end
	self:Output( nVal )
end

holo.Register( "HSBar" , OBJ , "HRect" )

---------------------------------------------------------------------------------------------------
--	HDSBar										--
---------------------------------------------------------------------------------------------------
local OBJ = {}

AccessorFunc( OBJ, "bDrag"	, "Dragging"	, FORCE_BOOL )
AccessorFunc( OBJ, "bJump"	, "AllowJump"	, FORCE_BOOL )
AccessorFunc( OBJ, "nXVal"	, "XValue"		, FORCE_NUMBER )
AccessorFunc( OBJ, "nYVal"	, "YValue"		, FORCE_NUMBER )
AccessorFunc( OBJ, "nXMax"	, "XMax"		, FORCE_NUMBER )
AccessorFunc( OBJ, "nXMin"	, "XMin"		, FORCE_NUMBER )
AccessorFunc( OBJ, "nYMax"	, "YMax"		, FORCE_NUMBER )
AccessorFunc( OBJ, "nYMin"	, "YMin"		, FORCE_NUMBER )

function OBJ:Initialize()

	self.BaseClass.Initialize( self )

	self:SetXMin( 0 )
	self:SetXMax( 1 )
	self:SetYMin( 0 )
	self:SetYMax( 1 )
	self:SetRadius( 2 )
	self:SetAllowJump( false )
	
	local H = holo.Create( "HRect" )
		H:SetElement( self )
		H:SetRadius( 4 )
		H:SetAlphaFromElement( true )
	self.Sheet = H
	
	H = holo.Create( "HRect" )
		H:SetElement( self )
		H:SetRadius( 2 )
		H:SetAlphaFromElement( true )
	self.XBar = H
	
	H = holo.Create( "HRect" )
		H:SetElement( self )
		H:SetRadius( 2 )
		H:SetAlphaFromElement( true )
	self.YBar = H
	
	H = holo.Create( "HRect" )
		H:SetElement( self )
		H:SetRadius( 2 )
		H:SetAlphaFromElement( true )
		H:SetCheckHL( true )
	self.Slider = H
	
	self:SetSize( 50 , 50 )
	self:SetValue( 0.5, 0.5 )
	self:SetColor( Color(255,255,255,255) )
end

function OBJ:Draw()
	self:Think()
	
	self.Sheet:Draw()
	self.XBar:Draw()
	self.YBar:Draw()
	self.Slider:Draw()
end

function OBJ:Think()
	local D = false
	if LocalPlayer():KeyDown( IN_USE ) or input.IsMouseDown(MOUSE_FIRST) then
		local M = false
		local x, y = self:MPos()
		if self:GetAllowJump() then
			M = self:MouseCheck( x,y )
		else
			M = self.Slider:MouseCheck( self.Slider:MPos() )
		end

		if M or self:GetDragging() then
			D = true
			
			local X = Lerp( math.Clamp( 0.5 + x/self:GetWide() ,0,1 ) , self:GetXMin(), self:GetXMax() )
			local Y = Lerp( math.Clamp( 0.5 + y/self:GetTall() ,0,1 ) , self:GetYMin(), self:GetYMax() )
			self:SetValue( X , Y )
		end
	end
	self:SetDragging( D )
end

function OBJ:SetSize( x, y )
	self:SetWide( x )
	self:SetTall( y )
	
	local Sh, XB, YB, Sl = self.Sheet, self.XBar, self.YBar, self.Slider
	if Sh then Sh:SetSize( x , y ) end
	if XB then XB:SetSize(  x , y/10 - 4 ) end
	if YB then YB:SetSize( x/10 - 4 , y  ) end
	if Sl then Sl:SetSize(  x/10 , y/10  ) end
end

function OBJ:SetColor( cC )
	cC = ClampColor( cC )
	
	self.cCol = cC
	local Sh, XB, YB, Sl = self.Sheet, self.XBar, self.YBar, self.Slider
	if Sh then 
		local C2 = cC
		if C2.a < 255 then
			C2.a = math.Clamp( C2.a - 40 , 100 , 255 )
		end
		Sh:SetColor( C2 )
		Sh:SetColorBright( math.fmod( Sh:GetColorBright() - 0.5 , 0 , 1 ) )
	end
	if XB then 
		XB:SetColor( cC )
		XB:SetColorBright( math.fmod( XB:GetColorBright() - 0.75 , 0 , 1 ) )
	end
	if YB then 
		YB:SetColor( cC )
		YB:SetColorBright( math.fmod( YB:GetColorBright() - 0.75 , 0 , 1 ) )
	end
	if Sl then Sl:SetColor( cC ) end
end

function OBJ:SetValue( nXVal , nYVal )
	if type( nXVal ) ~= "number" or type( nYVal ) ~= "number" then return end

	self.nXVal = nXVal
	self.nYVal = nYVal
	local fx = ( nXVal - self:GetXMin() ) / ( self:GetXMax() - self:GetXMin() )
	local fy = ( nYVal - self:GetYMin() ) / ( self:GetYMax() - self:GetYMin() )
	
	local w, t = self:GetWide(), self:GetTall()
	local x = math.Clamp( w*(0.5 - fx) , -0.5*w + 1 , 0.5*w - 1 )
	local y = math.Clamp( t*(0.5 - fy) , -0.5*t + 1 , 0.5*t - 1 )
	
	local Sl = self.Slider
		if Sl then
			Sl:SetPos( x , y  )
		end
	local XB = self.XBar
		if XB then
			XB:SetPos( 0 , y  )
		end
	local YB = self.YBar
		if YB then
			YB:SetPos( x , 0  )
		end
	self:Output( Vector( nXVal, nYVal, 0 ) )
end

function OBJ:GetValue()
	return self:GetXValue() , self:GetYValue()
end

function OBJ:SetXValue( nVal )
	if type( nVal ) ~= "number" then return end
		
	self.nXVal = nVal
	local f = ( nVal - self:GetXMin() ) / ( self:GetXMax() - self:GetXMin() )
	local w = self:GetWide()
	local x = math.Clamp( w*(0.5 - f) , -0.5*w + 1 , 0.5*w - 1 )
	
	local Sl = self.Slider
		if Sl then
			local n, y = Sl:GetPos()
			Sl:SetPos( x , y )
		end
	local YB = self.YBar
		if YB then
			YB:SetPos( x , 0  )
		end
	self:Output( Vector( nXVal, self:GetYValue(), 0 ) )
end

function OBJ:SetYValue( nVal )
	if type( nVal ) ~= "number" then return end
		
	self.nYVal = nVal
	local f = ( nVal - self:GetYMin() ) / ( self:GetYMax() - self:GetYMin() )
	local t = self:GetTall()
	local y = math.Clamp( t*(0.5 - f) , -0.5*t + 1 , 0.5*t - 1 )
	
	local Sl = self.Slider
		if Sl then
			local x, n = Sl:GetPos()
			Sl:SetPos( x , y  )
		end
	local XB = self.XBar
		if XB then
			XB:SetPos( 0 , y )
		end
	self:Output( Vector( self:GetXValue() , nYVal, 0 ) )
end

holo.Register( "HDSBar" , OBJ , "HRect" )

---------------------------------------------------------------------------------------------------
--	HRotator										--
---------------------------------------------------------------------------------------------------
local OBJ = {}

AccessorFunc( OBJ, "bDrag"	, "Dragging"	, FORCE_BOOL )
AccessorFunc( OBJ, "nVal"	, "Value"		, FORCE_NUMBER )
AccessorFunc( OBJ, "nMax"	, "Max"			, FORCE_NUMBER )
AccessorFunc( OBJ, "nMin"	, "Min"			, FORCE_NUMBER )
AccessorFunc( OBJ, "nIRad"	, "InnerRadius" , FORCE_NUMBER )

function OBJ:Initialize()

	self.BaseClass.Initialize( self )

	self:SetMin( 0 )
	self:SetMax( 1 )
	self:SetCheckHL( false )
	
	local H = holo.Create( "HCircle" )
		H:SetElement( self )
		H:SetAlphaFromElement( true )
	self.Disp = H
	
	H = holo.Create( "HCircle" )
		H:SetElement( self )
		H:SetAlphaFromElement( true )
		H:SetCheckHL( true )
	self.Rot = H
	
	self:SetRadius( 12 )
	self:SetValue( 0.5 )
	self:SetColor( Color(255,255,255,255) )
end

function OBJ:Draw()
	self:Think()
	
	self.Disp:Draw()
	self.Rot:Draw()
end

function OBJ:Think()
	local D = false
	if LocalPlayer():KeyDown( IN_USE ) or input.IsMouseDown(MOUSE_FIRST) then
		local M, Ro = false, self.Rot
		local x, y = self:MPos()
		if Ro then
			M = Ro:MouseCheck( x, y )
		end
		
		if M or self:GetDragging() then
			D = true
			
			local ang = math.atan2( y, x )
			if !self.oang then self.oang = ang end
			local d = self.oang + math.abs( ang )
			
			self:SetValue( Lerp( math.EaseInOut( math.Clamp( d/6.28 ,0,1 ), 0.5, 0.5 ) , self:GetMin(), self:GetMax() ) )
			self.oang = ang
		end
	end
	self:SetDragging( D )
end

function OBJ:SetRadius( nR )
	local R = tonumber( nR )
	self.nRad = R > 12 and R or 12
	self:SetInnerRadius()
end

function OBJ:SetInnerRadius()
	local IR = math.Clamp( math.Round( self:GetRadius()/2.5 ) , 6 , 18 )
	IR = IR - math.fmod( IR, 2 )
	self.nIRad = IR
	local R = self.Rot
	if R then
		R:SetRadius( IR )
	end
	self:SetValue( self:GetValue() )
end

function OBJ:SetColor( cC )
	local H = self:GetHL()
	
	self.cCol = cC
	local R, D = self.Rot, self.Disp
	if D then 
		D:SetColor( cC )
		D:SetColorBright( math.fmod( D:GetColorBright() - 0.25 , 0 , 1 ) )
	end
	if R then R:SetColor( cC ) end
end

function OBJ:SetValue( nVal )
	if type( nVal ) ~= "number" then return end
	self.nVal = nVal
	if self.Disp then
		local R, IR = self:GetRadius(), self:GetInnerRadius()
		local f = ( nVal - self:GetMin() ) / ( self:GetMax() - self:GetMin() )

		self.Disp:SetRadius( IR + f*(R - IR) )
	end
	self:Output( nVal )
end

holo.Register( "HRotator" , OBJ , "HCircle" )


---------------------------------------------------------------------------------------------------
--	HVecView										--
---------------------------------------------------------------------------------------------------
local OBJ = {}

AccessorFunc( OBJ, "vVect"	, "Vector"  )

function OBJ:Initialize()

	self.BaseClass.Initialize( self )
		
	self:SetSize( 50 , 50 )
	self:SetVector( Vector(0,0,0) )
	self:SetColor( Color(255,255,255,255) )
	
	self.VX = 0
	self.VY = 0
end

function OBJ:Draw()
	self:Think()
	
	local w,t = self:GetSize()
	local x,y = self:GetWorldPos()
	
	local u,d,l,r = y - t * 0.5, y + t * 0.5, x - w * 0.5, x + w * 0.5
	local XEd, YEd = 0,0
	
	surface.SetDrawColor(0, 0, 0, 180)
	
	surface.DrawLine( l, u, r, u )
	surface.DrawLine( r, u, r, d )
	surface.DrawLine( r, d, l, d )
	surface.DrawLine( l, d, l, u )
	
	surface.SetDrawColor(255, 0, 0, 180)
	
	if self:MouseCheck( self.VX, self.VY ) then --Rather conveniently, the mouse-check function also works for stuff other than the mouse :)
		--draw.RoundedBox( 1 , self.VX -5, self.VY -5 , 10, 10, self:GetColor() )
		surface.DrawLine( self.VX - 20, self.VY, self.VX + 20, self.VY )
		surface.DrawLine( self.VX, self.VY - 20, self.VX, self.VY + 20 )
	else
		if self.VY < u then
			YEd = -1
		elseif self.VY > d then
			YEd = 1
		end
		if self.VX < l then
			XEd = -1
		elseif self.VX > r then
			XEd = 1
		end
		
		--print(XEd,YEd)
		
		local RX,RY,AX,AY = XEd ~= 0 and x + (w * 0.5 * XEd) or self.VX,YEd ~= 0 and y + (t * 0.5 * YEd) or self.VY,-math.abs(XEd) + 1,-math.abs(YEd) + 1
		
		surface.DrawLine( RX + (-5 * XEd), RY + (-5 * YEd), RX + (-30 * XEd), RY + (-30 * YEd) )
		surface.DrawLine( RX + (-5 * XEd), RY + (-5 * YEd), RX + (-5 * XEd) + (-10 * AX) + (-10 * AY * XEd), RY + (-20 * YEd) + (-10 * AY) + (5 * AX * YEd) )
		surface.DrawLine( RX + (-5 * XEd), RY + (-5 * YEd), RX + (-20 * XEd) + (10 * AX) + (5 * AY * XEd), RY + (-5 * YEd) + (10 * AY) + (-10 * AX * YEd) )
	end
end

function OBJ:Think()
	local P = self:GetPanel()
	if P and P:IsValid() then
		local up = P:GetUp()
		local eyepos = LocalPlayer():GetShootPos()
			
		local W = eyepos - (P:GetPos() + up * P.Z)
		local N = up
		local AVec = self:GetVector() - LocalPlayer():GetShootPos()
		local U = AVec
		local Upper = N:DotProduct(W)
		local Lower = N:DotProduct(U)
		
		local RDist = -Upper / Lower
		
		local RPos = eyepos + U * RDist
		
		local R = P:WorldToLocal( RPos )
		self.VX, self.VY = R.x * 10, R.y * -10
	end
end

holo.Register( "HVecView" , OBJ , "HRect" )