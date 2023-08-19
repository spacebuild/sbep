--gyropod_advanced coders: Paradukes, DataSchmuck
--wireless_gyropod coder: LoRAWN
TOOL.Category		= "SBEP"
TOOL.Tab 			= "Spacebuild"
TOOL.Name			= "#Wireless Gyropod"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.ent = {}
TOOL.ClientConVar[ "model" ] = "models/spacebuild/nova/drone2.mdl"

local ClassName = "wireless_gyropod"
local RegisterName = "wireless_gyropods"
local UndoName = "wirelessgyropod"
local DisplayName = "Wireless Gyropod"

if ( CLIENT ) then
	language.Add( "Tool.wireless_gyropod.name", "LoRAWN's " .. DisplayName )
	language.Add( "Tool.wireless_gyropod.desc", "Read the instructions!" )
	language.Add( "Tool.wireless_gyropod.0", "To Spawn: Left-Click. To Link: Right-Click the gyropod, then the vehicle." )
	language.Add( "Tool.wireless_gyropod.1", "Right-Click the vehicle that will control the gyropod. Reload to cancel." )	
	language.Add( "Tool_turret_type", "Type of weapon" )
	language.Add( "Undone_" .. UndoName, "Undo " .. DisplayName)
end

if ( SERVER ) then
	CreateConVar( "sbox_max" .. RegisterName, 20 )
end	
cleanup.Register( RegisterName )

if ( SERVER ) then

	--stuff needed for setting up ghost and model selection
	function ConstructGyropod( owner, model, pos, ang )
		if ( !owner:CheckLimit( RegisterName ) ) then return false end
		local gyropod = ents.Create( ClassName )
		if not(IsValid(gyropod)) then return nil end
		gyropod:SetAngles(ang)
		gyropod:SetPos(pos)
		gyropod:SetModel(model)
		gyropod:Spawn()
		gyropod:SetPlayer( owner )
		local ttable = {
			owner = owner
		}
		table.Add(gyropod:GetTable(), ttable )
		owner:AddCount( RegisterName, gyropod )
		return gyropod
	end
	duplicator.RegisterEntityClass(ClassName, ConstructGyropod, "Model", "Pos", "Angle")
	
end

--spawn a gyropod
function TOOL:LeftClick( trace )
	local owner = self:GetOwner()
	if ( !trace.HitPos )							  then return false end
	if ( trace.Entity:IsPlayer() )					  then return false end
	if ( CLIENT )									  then return true  end
	if ( !self:GetSWEP():CheckLimit( RegisterName ) ) then return false end
	if ( trace.Entity:IsValid() and trace.Entity:GetClass() == ClassName and trace.Entity:GetTable().pl == owner ) then	return true	end
	local angle = trace.HitNormal:Angle()
	angle.pitch = angle.pitch + 90
	local model = self:GetClientInfo( "model" )
	local gyropod = ConstructGyropod( owner, model, trace.HitPos, angle )
	gyropod:SetPos( trace.HitPos - trace.HitNormal * gyropod:OBBMins().z )
	gyropod:GetPhysicsObject():EnableMotion(false)
	undo.Create( UndoName )
		undo.AddEntity( gyropod )
		undo.SetPlayer( owner )
	undo.Finish()
	owner:AddCleanup( RegisterName, gyropod )
	return true
end

--link a vehicle to a gyropod
function TOOL:RightClick( trace )
	local owner = self:GetOwner()
	if ( self:GetStage() == 0 ) then
		if( trace.Entity:GetClass() == ClassName ) then
			self.gyro = trace.Entity
			self:SetStage( 1 )
			return true
		end
		owner:PrintMessage( HUD_PRINTTALK, "Entity is not a gyropod!" )
		return false
	end
	if( trace.Entity:IsVehicle() ) then
		if ( self.gyro:Link( trace.Entity ) ) then
			owner:PrintMessage( HUD_PRINTTALK, "Link successful!" )
		else
			owner:PrintMessage( HUD_PRINTTALK, "Link failed!" )
		end
		self.gyro = nil
		self:SetStage( 0 )
		return true
	end
	owner:PrintMessage( HUD_PRINTTALK, "Entity is not a vehicle!" )
	return false
end

--Set the gyropods model, also clear the selected ent
function TOOL:Reload( trace )
	if ( self:GetStage()== 0 ) and trace.Entity:GetClass() == ClassName then self.gyro = nil end	
	if ( self:GetStage()== 0 ) then
		if CLIENT and trace.Entity:IsValid() then return true  end
		if not trace.Entity:IsValid() 		 then return false end
		local model = trace.Entity:GetModel()
		self:GetOwner():ConCommand(ClassName .. "_model " .. model);
		self.Model = model
	end
	self:SetStage(0)
	return true
end

--The detailed instructions
function TOOL.BuildCPanel( panel )
	panel:SetSpacing( 10 )
	panel:SetName( DisplayName )
	local BindLabel0 = {}
	local BindLabel1 = {}
	local BindLabel2 = {}
	BindLabel0.Text =
[[BASIC INSTRUCTIONS

1:  Press Left-Click to create a gyropod.
2:  Place the gyropod near center of ship.
3:  Orient the gyropod so it aligns with ship.
4:  Weld the gyropod to the ship.
5:  Link the gyropod to the ship:
    5.1: Right-Click the gyropod.
    5.2: Right-Click the vehicle.
6:  Get in the vehicle.
7:  Press Reload to turn on the engine.

]]
	BindLabel1.Text =
[[CONTROLS

Reload   = Engine on/off
Walk     = Freeze on/off
Sprint   = Level
RMB      = RollLock
Forward  = Accelerate Forward
Backward = Accelerate Backward
Left     = Roll Left (Accel. Left in RollLock mode)
Right    = Roll Right (Accel. Right in RollLock mode)
Jump     = Accelerate Upward
Duck     = Accelerate Downward

]]
	BindLabel2.Text =
[[TIPS

 *  Press Reload on any prop to set the model of the gyropod to that prop.
 *  If you need to cancel a link, press Reload on the gyropod. 

 Credit goes to:
 *  Paradukes and the SBEP Team for creating the original Gyropod.
 *  DataSchmuck for improving the code.
 *  LoRAWN for improving the code even more.
 
 ]]	
	BindLabel0.Description = "Basic Instructions1"
	panel:AddControl("Label", BindLabel0 )
	BindLabel1.Description = "Basic Instructions2"
	panel:AddControl("Label", BindLabel1 )
	BindLabel2.Description = "Basic Instructions3"
	panel:AddControl("Label", BindLabel2 )
	

end
