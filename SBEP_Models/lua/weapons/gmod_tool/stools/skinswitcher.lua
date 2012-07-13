TOOL.Category   = "Render"
TOOL.Name       = "#Skin Switcher"
TOOL.Command    = nil
TOOL.ConfigName = ""

TOOL.ClientConVar[ "skin" ] 		= 0

if ( SERVER ) then

local manualcontrol = true
local oldslider = 0
local newslider = 0

end

if ( CLIENT ) then 

local SkinswitcherPreviousEntity = nil

language.Add("Tool_skinswitcher_name", "Skin Switcher Tool")
language.Add("Tool_skinswitcher_desc", "Directly select the model skin if it has more than one defined.")
language.Add("Tool_skinswitcher_0", "Left click to cycle model skins. \nRight click to select a model for manipulation.\nReload to pick a random skin.")

function TOOL.BuildCPanel( CPanel, SwitchEntity )
  -- HEADER
  CPanel:AddControl( "Header", { Text = "#Tool_skinswitcher_name", 
                                 Description	= "#Tool_skinswitcher_desc" 
                               }  )
                               
  if ValidEntity(SwitchEntity) then
    local maxskins = SwitchEntity:SkinCount()
    if maxskins > 1 then
      CPanel:AddControl("Slider", { Label = "Select skin", 
                                    Description = "Number of skins the model has.", 
                                    Type = "Integer", 
                                    Min = 0, 
                                    Max = maxskins-1, 
                                    Command = "skinswitcher_skin" 
                                  } )
    else
      CPanel:AddControl("Label", { Text = "This model only has one skin." } )
    end
  else
    CPanel:AddControl("Label", { Text = "No model selected." } )
  end
end

function TOOL:RebuildControlPanel()
  local CPanel = GetControlPanel( "skinswitcher" )
  if ( !CPanel ) then return end
  CPanel:ClearControls()
  self.BuildCPanel(CPanel, self:GetSkinSwitcherEntity())
end


function TOOL:DrawHUD()

  local selected = self:GetSkinSwitcherEntity()
		
  if ( !ValidEntity( selected ) ) then return end
	
		local scrpos = selected:GetPos():ToScreen()
		if (!scrpos.visible) then return end
		
		local player_eyes = LocalPlayer():EyeAngles()
		local side = (selected:GetPos() + player_eyes:Right() * 50):ToScreen()
		local size = math.abs( side.x - scrpos.x )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture(surface.GetTextureID( "gui/faceposer_indicator"))
		surface.DrawTexturedRect( scrpos.x-size, scrpos.y-size, size*2, size*2 )

end


end -- if CLIENT

function TOOL:GetSkinSwitcherEntity()
	return self:GetWeapon():GetNetworkedEntity( 1 )
end

function TOOL:SetSkinSwitcherEntity( ent )
	return self:GetWeapon():SetNetworkedEntity( 1, ent )
end



function TOOL:LeftClick(Trace)

  if not Trace.Entity:IsValid() then
    return false
  end

  if ( CLIENT ) then return true end

  local skins = Trace.Entity:SkinCount()

  if skins <= 1 then
    return false
  else 
    local currentskin = Trace.Entity:GetSkin()
    local newskin = 0
    if (currentskin + 1) >= skins then
      newskin = currentskin + 1 - skins
    else
      newskin = currentskin+1
    end  
    Trace.Entity:SetSkin(newskin)
  end

  return true

end

function TOOL:Reload(Trace)

  if not Trace.Entity:IsValid() then
    return false
  end

  if ( CLIENT ) then return true end

  local skins = Trace.Entity:SkinCount()
	
  if skins == 1 then
    return false
  else 
    local currentskin = Trace.Entity:GetSkin()
    local newskin = currentskin
    while newskin == currentskin do
      newskin = math.random(skins)
    end
    Trace.Entity:SetSkin(newskin)
  end

  return true
    
end

function TOOL:RightClick(Trace)
  if Trace.Entity:IsValid() then
    if ( CLIENT ) then return true end 
    -- In fact, I don't think CLIENT is EVER true in this function.
    -- Otherwise this whole mess of getter/setter functions
    -- wouldn't be necessary. It certainly doesn't seem to actually run
    -- any code in single player or listen server,
    -- making the line itself pointless.
    self.SelectedEntity = Trace.Entity
    self:SetSkinSwitcherEntity(self.SelectedEntity)
  else
    self.SelectedEntity = nil
    return false
  end
end

function TOOL:Think()
  if ( CLIENT ) then
    if not (SkinswitcherPreviousEntity == self:GetSkinSwitcherEntity()) then
      self:RebuildControlPanel()
      SkinswitcherPreviousEntity = self:GetSkinSwitcherEntity()
    end
    return
  end

  newslider = self:GetClientNumber("skin")
  if newslider ~= oldslider then
    oldslider = newslider
    manualcontrol = false
  else
    manualcontrol = true
  end

  if self.SelectedEntity then 
    if self.SelectedEntity:IsValid() then
      if self.SelectedEntity:SkinCount() > 1 then
        -- I can't say it's good code, but I'm fed up with it.
        if not manualcontrol then
          self.SelectedEntity:SetSkin(newslider)
        end
      end
    end
  end 
end
