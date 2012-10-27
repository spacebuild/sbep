SBEPFjcon = {}
local SBEPJoystickControl = function()
	SBEPFjcon.pitch = jcon.register{
		uid = "sbepftr_pitch",
		type = "analog",
		description = "Pitch",
		category = "Fighters",
	}
	SBEPFjcon.yaw = jcon.register{
		uid = "sbepftr_yaw",
		type = "analog",
		description = "Yaw",
		category = "Fighters",
	}
	SBEPFjcon.roll = jcon.register{
		uid = "sbepftr_roll",
		type = "analog",
		description = "Roll",
		category = "Fighters",
	}
	SBEPFjcon.thrust = jcon.register{
		uid = "sbepftr_thrust",
		type = "analog",
		description = "Thrust",
		category = "Fighters",
	}
	SBEPFjcon.accelerate = jcon.register{
		uid = "sbepftr_accelerate",
		type = "analog",
		description = "Accelerate/Decelerate",
		category = "Fighters",
	}
	SBEPFjcon.up = jcon.register{
		uid = "sbepftr_strafe_up",
		type = "digital",
		description = "Strafe Up",
		category = "Fighters",
	}
	SBEPFjcon.down = jcon.register{
		uid = "sbepftr_strafe_down",
		type = "digital",
		description = "Strafe Down",
		category = "Fighters",
	}
	SBEPFjcon.right = jcon.register{
		uid = "sbepftr_strafe_right",
		type = "digital",
		description = "Strafe Right",
		category = "Fighters",
	}
	SBEPFjcon.left = jcon.register{
		uid = "sbepftr_strafe_left",
		type = "digital",
		description = "Strafe Left",
		category = "Fighters",
	}
	SBEPFjcon.launch = jcon.register{
		uid = "sbepftr_launch",
		type = "digital",
		description = "Launch",
		category = "Fighters",
	}
	SBEPFjcon.switch = jcon.register{
		uid = "sbepftr_switch",
		type = "digital",
		description = "Yaw/Roll Switch",
		category = "Fighters",
	}
	SBEPFjcon.fire1 = jcon.register{
		uid = "sbepftr_fire1",
		type = "digital",
		description = "Fire 1",
		category = "Fighters",
	}
	SBEPFjcon.fire2 = jcon.register{
		uid = "sbepftr_fire2",
		type = "digital",
		description = "Fire 2",
		category = "Fighters",
	}
end
hook.Add("JoystickInitialize","SBEPJoystickControl",SBEPJoystickControl)