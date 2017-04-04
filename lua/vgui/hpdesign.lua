/*------------------------------------------------------------------------------------------------------------------

	Control: HPDTablet

------------------------------------------------------------------------------------------------------------------*/
local PANEL = {}

AccessorFunc( PANEL, "hpdIO" , "IOForm" )
AccessorFunc( PANEL, "hpdIC" , "ItemContextList" )

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self.Elements = {}

end

/*---------------------------------------------------------
   Name: AddItem
---------------------------------------------------------*/
function PANEL:AddItem()
	local F = vgui.Create( "HPDItem" , self )
		F:SetPos( 20, 50 )
		local N = #self.Elements
		F.TIndex = N + 1
		F.Tablet = self
	self.Elements[ N + 1 ] = F
	return F
end

/*---------------------------------------------------------
   Name: SetSelected
---------------------------------------------------------*/
function PANEL:SetSelected( nS )
	nS = tonumber( nS ) or 1
	self.nSel = nS
	
	if !self.Elements then self.Elements = {} return end

	for n,HE in ipairs( self.Elements ) do
		if n == nS then
			HE:SetSelected( true )
		else
			HE:SetSelected( false )
		end
	end
end

/*---------------------------------------------------------
   Name: GetSelected
---------------------------------------------------------*/
function PANEL:GetSelected()
	local E = self.Elements
	if E then
		return E[ self.nSel ]
	end
end

derma.DefineControl( "HPDTablet", "A design tablet for the HoloPanel design menu.", PANEL, "DPanel" )

/*------------------------------------------------------------------------------------------------------------------

	Control: HPDItem

------------------------------------------------------------------------------------------------------------------*/
local PANEL = {}

AccessorFunc( PANEL, "bSel" , "Selected" 	, FORCE_BOOL )
AccessorFunc( PANEL, "sType", "ElementType" , FORCE_STRING )
  
/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetVisible( true )
	self:ShowCloseButton( false )
	self:SetTitle( "" )
	self:SetSize( 60, 80 )

	self.Inputs = {}
	self.Outputs = {}
	
	local HC = holo.Classes
	self.ElementTypes = {}
	local ET = self.ElementTypes
	for Type, HE in pairs( HC ) do
		table.insert( ET, Type )
	end
	PrintTable( ET )
end

/*---------------------------------------------------------
   Name: PaintOver
---------------------------------------------------------*/
function PANEL:PaintOver()
	if self:GetSelected() then
		surface.SetDrawColor( 255, 255, 255, 255 )
		self:DrawOutlinedRect()
	end
end

/*---------------------------------------------------------
   Name: SetElementType
---------------------------------------------------------*/
function PANEL:SetElementType( sT )
	local ET = self.ElementTypes
	if ET then
		if table.HasValue( ET, sT ) then
			self.sType = sT
			self:SetTitle( sT )
		end
	end
end

/*---------------------------------------------------------
   Name: CreateTypeChoice
---------------------------------------------------------*/
function PANEL:CreateTypeChoice()
	if self.TC then
		return self.TC
	else
		local ET = self.ElementTypes
		if ET then
			local MC = vgui.Create( "DMultiChoice" )
				for n, T in ipairs( ET ) do
					MC:AddChoice( T )
				end
				MC.OnSelect = function( self, index, value, data )
								self.Item:SetElementType( value )
							end
			MC.Item = self
			self.TC = MC
			return MC
		end
	end
end

/*---------------------------------------------------------
   Name: OnMouseReleased
---------------------------------------------------------*/
function PANEL:OnMouseReleased()
	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture( false )
	
	local P = self:GetParent()
	if P then
		P:SetSelected( self.TIndex )
		
		local F = P:GetIOForm()
		if F then
			F:SetItem( self )
		end
		
		local C = P:GetItemContextList()
		if C then
			C:SetItem(self)
		end
	end
end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function PANEL:Think()
	if self.Dragging then
	
		local x = gui.MouseX() - self.Dragging[1]
		local y = gui.MouseY() - self.Dragging[2]
		
		if self:GetScreenLock() then
			local pw, pt = self:GetParent():GetSize()
			x = math.Clamp( x, 0, pw - self:GetWide() )
			y = math.Clamp( y, 0, pt - self:GetTall() )
		end
	   
		self:SetPos( x, y )
	end
	
	if ( self.Sizing ) then

		local x = gui.MouseX() - self.Sizing[1]
		local y = gui.MouseY() - self.Sizing[2]

		self:SetSize( x, y )
		self:SetCursor( "sizenwse" )
		return

	end
   
	if ( self.Hovered  and
		self.m_bSizable  and
			gui.MouseX() > (self.x + self:GetWide() - 20)  and
			gui.MouseY() > (self.y + self:GetTall() - 20) ) then      

		self:SetCursor( "sizenwse" )
		return
	end
   
	if ( self.Hovered and self:GetDraggable() ) then
			self:SetCursor( "sizeall" )
	end
end

derma.DefineControl( "HPDItem", "An item for the HoloPanel design menu.", PANEL, "DFrame" )

/*------------------------------------------------------------------------------------------------------------------

	Control: HPDInOut

------------------------------------------------------------------------------------------------------------------*/
local PANEL = {}

AccessorFunc( PANEL, "hpdItem" , "Item" )
AccessorFunc( PANEL, "hpdTablet" , "Tablet" )

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetLabel( "Inputs and Outputs" )
	self:SetExpanded( true )

	local IOP = vgui.Create( "DPanel" )
		IOP:SetSize( 215, 160 )
		self.Form = IOP
	self:SetContents( IOP )
	
	local DI = vgui.Create( "DPanelList" , IOP )
		DI:SetPos( 5 , 5 )
		DI:SetSize( 110 , 150 )
		DI:GetCanvas():SetSize( 105 , 150 )
		DI:SetSpacing( 5 )
	self.In = DI
		--DI:EnableVerticalScrollbar( true )

	local AIB = vgui.Create( "DButton" )
		AIB:SetSize( 110, 20 )
		AIB:SetText( "Add Input Node" )
		AIB.DoClick = function( self )
							local I = self.Form:GetItem()
							if I then
								if !I.Inputs then I.Inputs = {} end
								if #I.Inputs < 5 then
									local In = vgui.Create( "DMultiChoice" )
										self.List:AddItem( In )
									table.insert( I.Inputs, In )
								end
							end
						end
	DI.Add = AIB
	AIB.Form = self
	AIB.List = DI
	DI:AddItem( AIB )
	
	local DO = vgui.Create( "DPanelList" , IOP )
		DO:SetPos( 115 , 5 )
		DO:SetSize( 110 , 150 )
		DO:GetCanvas():SetSize( 105 , 155 )
		DO:SetSpacing( 5 )
	self.Out = DO
		--DO:EnableVerticalScrollbar( true )
	
	local AOB = vgui.Create( "DButton" )
		AOB:SetSize( 110, 20 )
		AOB:SetText( "Add Output Node" )
		AOB.DoClick = function( self )
							local I = self.Form:GetItem()
							if I then
								if !I.Outputs then I.Outputs = {} end
								if #I.Outputs < 5 then
									local Out = vgui.Create( "DMultiChoice" )
										self.List:AddItem( Out )
									table.insert( I.Outputs, Out )
								end
							end
						end
	DO.Add = AOB
	AOB.Form = self
	AOB.List = DO
	DO:AddItem( AOB )
	
	/*self.Toggle = function( self )
					self.BaseClass.Toggle( self )
					self.In:GetCanvas():SetSize( 105 , 155 )
					self.Out:GetCanvas():SetSize( 105 , 155 )
				end*/
end

/*---------------------------------------------------------
   Name: Clear
---------------------------------------------------------*/
function PANEL:Clear()
	if self.In then
		self.In:Clear()
		self.In:AddItem( self.In.Add )
	end
	if self.Out then
		self.Out:Clear()
		self.Out:AddItem( self.Out.Add )
	end
end

/*---------------------------------------------------------
   Name: SetItem
---------------------------------------------------------*/
function PANEL:SetItem( hpdItem )
	if hpdItem == self.hpdItem then return end
	self.hpdItem = hpdItem
	
	self:Clear()
	
	for n,I in ipairs( hpdItem.Inputs ) do
		self.In:AddItem( I )
	end
	for n,O in ipairs( hpdItem.Outputs ) do
		self.Out:AddItem( O )
	end
end

derma.DefineControl( "HPDInOut", "An input-output interface for the HoloPanel design menu.", PANEL, "DCollapsibleCategory" )

/*------------------------------------------------------------------------------------------------------------------

	Control: HPDItemContext

------------------------------------------------------------------------------------------------------------------*/

local PANEL = {}

AccessorFunc( PANEL, "hpdI" , "Item" )
AccessorFunc( PANEL, "hpdT" , "Tablet" )

/*---------------------------------------------------------
   Name: SetItem
---------------------------------------------------------*/
function PANEL:SetItem( hpdI )
	if hpdI == self.hpdI then return end
	self.hpdI = hpdI
	
	self:Clear()
	
	if hpdI.TC then
		self:AddItem( hpdI.TC )
	else
		local TC = hpdI:CreateTypeChoice()
		self:AddItem( TC )
	end
end

derma.DefineControl( "HPDItemContext", "A item context list for the HoloPanel design menu.", PANEL, "DPanelList" )