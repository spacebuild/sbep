	
local PANEL = {}
  
/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetSize( 100,400 )
		self:EnableHorizontal( false )
		self:EnableVerticalScrollbar()
		self:SetSpacing( 5 )
		self:SetPadding( 5 )

	self.Controls   = {}
	self.Categories = {}
	
	timer.Simple( 0.1 , function()
								self:SizeToContents()
							end)

end
 
/*---------------------------------------------------------
   Name: AddMCategory
---------------------------------------------------------*/
function PANEL:AddMCategory( strName , tbModels )

	local DCC = vgui.Create("DCollapsibleCategory" ) --, self)
			DCC:SetSize( 100, 50 )
			DCC:SetLabel( strName )
			DCC:SetExpanded( false )
			DCC.MC = self
			local i = table.getn( self.Categories ) + 1
			DCC.Header.OnMousePressed = function( self )
											--self:GetParent().MC:SetCategory( self:GetParent().SN )
											self:GetParent().MC:SetCategory( i )
										end
	
	local PS = vgui.Create( "NCPropSelect" , DCC )
		PS:SetSize( 100,300 )
		for n,model in pairs( tbModels ) do
			PS:AddModel( model )
		end
	DCC:SetContents( PS )
		
	self:AddItem( DCC )
	table.insert( self.Categories , DCC )
	
	self:SizeToContents()
end

/*---------------------------------------------------------
   Name: SizeToContents
---------------------------------------------------------*/
function PANEL:SizeToContents()

	local H = self:GetTall()
	local N = table.getn( self.Categories )
	
	local NewH = H - 31 * N
	
	for n,CC in ipairs( self.Categories ) do
		CC.Contents:SetSize( CC.Contents:GetWide() , NewH )
	end
	
	self:PerformLayout()
end

/*---------------------------------------------------------
   Name: SetCategory
---------------------------------------------------------*/
function PANEL:SetCategory( nCat )
	
	for n,CC in ipairs( self.Categories ) do
		if n == nCat then
			if !CC:GetExpanded() then
				CC:Toggle()
			end
		else
			if CC:GetExpanded() then
				CC:Toggle()
			end
		end
	end
	
end

/*---------------------------------------------------------
   Name: SetConVar
---------------------------------------------------------*/
function PANEL:SetConVar( strConVar )
	
	self.ConVar = strConVar
	
end

derma.DefineControl( "MCPropSelect", "A Multi-Category Prop Select.", PANEL, "DPanelList" )