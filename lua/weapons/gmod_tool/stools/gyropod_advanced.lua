TOOL.Category		= "SBEP"
TOOL.Tab 			= "Spacebuild"
TOOL.Name			= "#Gyro-Pod"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.ent = {}
TOOL.ClientConVar[ "model" ] = "models/spacebuild/nova/drone2.mdl"

if ( CLIENT ) then
	language.Add( "Tool.gyropod_advanced.name", "DataSchmuck's Enhanced Gyro-Pod" )
	language.Add( "Tool.gyropod_advanced.desc", "Customize controls & sensitivity with inputs. READ THE INSTRUCTIONS!" )
	language.Add( "Tool.gyropod_advanced.0", "Left-Click to spawn.  Right click the Gyro-Pod to start linking a vehicle." )
	language.Add( "Tool.gyropod_advanced.1", "Now Right click the vehicle that will control the Gyro-Pod via mouselook.  Reload to cancel." )	
	language.Add( "Tool_turret_type", "Type of weapon" )	
end

if (SERVER) then
	CreateConVar('sbox_maxgyropod_advanceds', 20)
end	
cleanup.Register( "gyropod_advanceds" )	

--Link an entity to the gyropod
function TOOL:RightClick(trace)
	if (self:GetStage() == 0) and trace.Entity:GetClass() == "gyropod_advanced" then
		self.AdvGyro = trace.Entity
		self:SetStage(1)
		return true
	elseif self:GetStage() == 1 and trace.Entity.GetPassenger then
		local owner = self:GetOwner()
		if self.AdvGyro:Link(trace.Entity) then
			owner:PrintMessage(HUD_PRINTTALK,"Vehicle linked to Gyro-Pod!")
		else
			owner:PrintMessage(HUD_PRINTTALK,"Link failed!")
		end
		self:SetStage(0)
		self.AdvGyro = nil
		return true
	else
		self:GetOwner():PrintMessage(HUD_PRINTTALK,"Left click to spawn.  To link, right click the Gyro-Pod first, THEN the vehicle!")
		return false
	end
end

--Spawn the gyropod
function TOOL:LeftClick( trace )
	if (!trace.HitPos) then return false end
	if (trace.Entity:IsPlayer()) then return false end
	if ( CLIENT ) then return true end
	local ply = self:GetOwner()
	if ( trace.Entity:IsValid() and trace.Entity:GetClass() == "gyropod_advanced" and trace.Entity:GetTable().pl == ply ) then
		return true
	end
	if ( !self:GetSWEP():CheckLimit( "gyropod_advanceds" ) ) then return false end
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	local Model = self:GetClientInfo( "model" )
	local datagpod = MakeDataGPod( ply, Model, trace.HitPos, Ang )
	local min = datagpod:OBBMins()
	datagpod:SetPos( trace.HitPos - trace.HitNormal * min.z )	
	undo.Create("Gyro Pod Advanced")
		undo.AddEntity( datagpod )
		undo.SetPlayer( ply )
	undo.Finish()
	ply:AddCleanup( "gyropod_advanceds", datagpod )
	return true
end

--Set the gyropods model, also clear the selected ent
function TOOL:Reload( trace )
	if (self:GetStage()== 0) and trace.Entity:GetClass() == "gyropod_advanced" then
		self.AdvGyro = nil
	end	
	if (self:GetStage()== 0) then
		if CLIENT and trace.Entity:IsValid() then return true end
		if not trace.Entity:IsValid() then return end
		local model = trace.Entity:GetModel()
		self:GetOwner():ConCommand("gyropod_advanced_model "..model);
		self.Model = model
	end
	self:SetStage(0)
	return true
end

if (SERVER) then
	
	--stuff needed for setting up ghost and model selection
	function MakeDataGPod( pl, Model, Pos, Ang )
		if ( !pl:CheckLimit( "gyropod_advanceds" ) ) then return false end
		local datagpod = ents.Create( "gyropod_advanced" )
		if not(IsValid(datagpod)) then return nil end
		datagpod:SetAngles(Ang)
		datagpod:SetPos(Pos)
		datagpod:SetModel(Model)
		datagpod:Spawn()
		datagpod:SetPlayer( pl )
		local ttable = {
			pl = pl
		}
		table.Merge(datagpod:GetTable(), ttable )
		pl:AddCount( "gyropod_advanceds", datagpod )
		return datagpod
	end
	duplicator.RegisterEntityClass("gyropod_advanced", MakeDataGPod, "Model", "Pos", "Ang", "Vel", "aVel", "frozen")
end

--The detailed instructions
function TOOL.BuildCPanel(panel)

	panel:SetSpacing( 10 )
	panel:SetName( "SBEP Gyro-Pod (Advanced)" )

	local BindLabel0 = {}
	local BindLabel1 = {}
	local BindLabel2 = {}

	BindLabel0.Text =
[[BASIC INSTRUCTIONS

1:   Left Click to create a Gyro-Pod.
2:   Wire the 'Activate' input to a TOGGLED output.
3:   Wire movement controls to an Adv. Pod Controller.
4a:  To control Pitch/Yaw with mouse movement:
        Right Click the gyro-pod.
        Right Click the vehicle.
4b:  To control Pitch/yaw with inputs:
        DO NOT link the vehicle to the Gyro-pod.
        Wire the PitchUp, PitchDown, YawLeft, YawRight,
        inputs to an Adv. Pod Controller
5:   Place Gyro-Pod near center of ship.
6:  Orient the Gyro-Pod so it's aligned with ship.
7:  Weld the Gyro-pod to the ship.
8:  Press key you wired to the 'Activate' input to turn on/off.
9:  Use the keys you wired to the movement controls to move the ship through space.

ADVANCED CONTROLS (OPTIONAL)
]]

	BindLabel1.Text =
[[MULTIPLIERS
Controls axis sensitivity.
Values from 0.0 to 0.99 reduce sensitivity.
Values greater than 1 increase sensitivity.
Negative values reverse input.
Defaults for all are 1

SPEED LIMIT
Limits the speed in MPH.
Default is 112.  Max is 112

AIMING MODE
Points ship towards GPS coords.
Wire AIMMODE to a TOGGLED output.
Wire the AIM XYZ (or AIMVEC) inputs to WORLD XYZ cords.

FREEZE SHIP
All CONSTRAINED entities will be frozen
Wire the FREEZE Input to a TOGGLED output.
You CAN still use your physgun's reload function to unfreeze the ship.
]]

	BindLabel2.Text =
[[AUTOLEVEL
Keeps ship's roll and pitch at 0.
Wire LEVEL to a TOGGLED	output.

TIPS
 *  Press Reload on any prop to set the model of the Gyro-Pod to that prop.
 *  You do not need to gyro-link anything anymore.  Any props whos mass is over 20 will be automatically linked.  Wire components are never linked.
 *  If you need to cancel a link, press Reload on the Gyro-Pod.
 *  If you PARENT the Gyro-Pod, you will lose the ability to modify the wiring, so save parenting for last.
 *  Try wiring a 'Not' gate to the 'Active' Output of your pod controller, then wiring the 'Freeze' Input of the Gyro-Pod to the 'Not' gate.
 *  Joystick is supported, but not tested
 

 Credit goes to Paradukes and the SBEP Team for creating the original Gyro-Pod.  I (DataSchmuck) just modified the code a bit.]]
	
	BindLabel0.Description = "Basic Instructions1"
	panel:AddControl("Label", BindLabel0 )
	
	BindLabel1.Description = "Basic Instructions2"
	panel:AddControl("Label", BindLabel1 )
	
	BindLabel2.Description = "Basic Instructions3"
	panel:AddControl("Label", BindLabel2 )
	

end
