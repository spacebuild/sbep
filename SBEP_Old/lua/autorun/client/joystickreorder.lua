local a = joystick
if not a or type(a) ~= "table" then
	return
end
b = tonumber(a.binaryversion)
if not b then
	return
end
if b > 1.1 then
	return
end

SBEP = SBEP or {}

function SBEP.JoystickReorder(category,order)
	local oldCatTab = jcon.reg.cat[category]
	local newCatTab = {}
	if #oldCatTab ~= #order then
		ErrorNoHalt("New order hasn't got the same number of entries as old order")
		return
	end
	for order,description in ipairs(order) do
		for _,data in ipairs(oldCatTab) do
			if data.description == description then
				newCatTab[order] = data
			end
		end
	end
	jcon.reg.cat[category] = newCatTab
end

local function JoyReorder()
	SBEP.JoystickReorder("Fighters",{"Pitch","Yaw","Roll","Thrust","Accelerate/Decelerate",
					"Strafe Up","Strafe Down","Strafe Right","Strafe Left","Fire 1","Fire 2",
					"Launch","Yaw/Roll Switch"})
	SBEP.JoystickReorder("Gyro-Pod",{"Pitch","Yaw","Roll","Thrust","Accelerate/Decelerate",
					"Strafe Up","Strafe Down","Strafe Right","Strafe Left","Launch",
					"Yaw/Roll Switch"})
	SBEP.JoystickReorder("Rover",{"Turning","Accelerate/Decelerate","Strafe","Strafe Left",
					"Strafe Right","Jump","Fire 1","Fire 2"})
	SBEP.JoystickReorder("Boarding Pod",{"Pitch","Yaw","Roll","Yaw/Roll Switch","Launch"})
end

local function JoyReorderHook()
	timer.Simple(5,JoyReorder)
end

if CLIENT then
	hook.Add("JoystickInitialize","JoystickReorder",JoyReorderHook)
end
concommand.Add("SBEP_ReorderJoystick",JoyReorder)