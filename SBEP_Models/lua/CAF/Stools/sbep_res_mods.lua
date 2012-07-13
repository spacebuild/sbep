if not CAF or not CAF.GetAddon("Resource Distribution") then return end

TOOL.Category			= "SBEP"
TOOL.Name				= "#Resource Modules"

TOOL.DeviceName			= "Resource Module"
TOOL.DeviceNamePlural	= "Resource Modules"
TOOL.ClassName			= "sbep_res_mods"

TOOL.DevSelect			= true
TOOL.CCVar_type			= "base_default_res_module"
TOOL.CCVar_sub_type		= "test1"
TOOL.CCVar_model		= "models/Spacebuild/s1t1.mdl"

TOOL.Limited			= true
TOOL.LimitName			= "sbep_res_mods"
TOOL.Limit				= 30

CAFToolSetup.SetLang("SBEP Resource Modules","Create Resource Modules attached to any surface.","Left-Click: Spawn a Device.  Reload: Repair Device.")


TOOL.ExtraCCVars = {

}

function TOOL.ExtraCCVarsCP( tool, panel )
end

function TOOL:GetExtraCCVars()
	local Extra_Data = {}
	return Extra_Data
end

local function spawn_res_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras) 
	
	local mass = 1000
	local vol_mul = 1
	local base_volume = 10000
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() and phys.GetVolume then
		local vol = phys:GetVolume()
		vol_mul = vol/10000
		mass = phys:GetMass()
	end
	CAF.GetAddon("Resource Distribution").AddResource(ent, "energy", vol_mul * 4000)
	CAF.GetAddon("Resource Distribution").AddResource(ent, "water", vol_mul * 4000)
	CAF.GetAddon("Resource Distribution").AddResource(ent, "oxygen", vol_mul * 4000)
	local maxhealth = mass * 10
	return mass, maxhealth 
end

TOOL.Devices = {
	base_default_res_module = {
		Name	= "Resource Modules",
		type	= "base_default_res_module",
		class	= "base_default_res_module",
		func 	= spawn_res_func,
		legacy = false,
		devices = {
		},
	},
}


	
	
	
