local PANEL = {}

/*---------------------------------------------------------
   Name: This function is used as the paint function for
                   selected buttons.
---------------------------------------------------------
local function HighlightedButtonPaint( self )
 
        surface.SetDrawColor( 255, 200, 0, 255 )
       
        for i=2, 3 do
                surface.DrawOutlinedRect( i, i, self:GetWide()-i*2, self:GetTall()-i*2 )
        end
 
end
 
/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self:EnableHorizontal( true )
	self:EnableVerticalScrollbar()
	self:SetSpacing( 1 )
	self:SetPadding( 3 )
	
	self.ActiveModel = ""
	self.Controls   = {}
	self.Height     = 2
	self:SetSize( self:GetWide() , 64 * self.Height + 6 )

end

/*---------------------------------------------------------
   Name: SetSize
---------------------------------------------------------
function PANEL:SetSize( x , y )

	DPanel.SetSize( self, x, y )
	self:PerformLayout()

end


/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------
function PANEL:PerformLayout()
 
        --local y = self.BaseClass.PerformLayout( self )
       
        local Height = 64 * self.Height + 6
       
        --self:SetPos( 0, y )
        self:SetSize( 100, Height )
       
        --y = y + Height
       -- y = y + 5
       
        --self:SetTall( y )
 
end

/*---------------------------------------------------------
   Name: SelectButton
---------------------------------------------------------
function PANEL:FindAndSelectButton( Value )
 
        self.CurrentValue = Value
 
        for k, Icon in pairs( self.Controls ) do
       
                if ( Icon.Model == Value ) then
               
                        -- Remove the old overlay
                        if ( self.SelectedIcon ) then
                                self.SelectedIcon.PaintOver = nil
                        end
                       
                        -- Add the overlay to this button
                        Icon.PaintOver = HighlightedButtonPaint;
                        self.SelectedIcon = Icon
 
                end
       
        end
 
end
 
/*---------------------------------------------------------
   Name: TestForChanges
---------------------------------------------------------
function PANEL:TestForChanges()
 
        local Value = self.ActiveModel
       
        if ( Value == self.CurrentValue ) then return end
       
        self:FindAndSelectButton( Value )
 
end

/*---------------------------------------------------------
   Name: AddModel
---------------------------------------------------------*/
function PANEL:AddModel( model )

	local Icon = vgui.Create( "SpawnIcon", self )
		Icon:SetModel( model )
		Icon:SetToolTip( model )
		Icon.Model = model
		local ent = self
		Icon.DoClick =  function ( self )
							ent:SetActiveModel( self.Model )
							local convar = ent:GetParent().MC.ConVar
							if convar then
								RunConsoleCommand( convar , self.Model )
							end
						end

		self:AddItem( Icon )
	table.insert( self.Controls, Icon )
end

/*---------------------------------------------------------
   Name: SetActiveModel
---------------------------------------------------------*/
function PANEL:SetActiveModel( model )

	self.ActiveModel = model
	
end

/*---------------------------------------------------------
   Name: GetActiveModel
---------------------------------------------------------*/
function PANEL:GetActiveModel()

	return self.ActiveModel
	
end

derma.DefineControl( "NCPropSelect", "A Prop Select without convars.", PANEL, "DPanelList" )