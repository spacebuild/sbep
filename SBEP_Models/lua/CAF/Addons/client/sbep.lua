local RD = {}
local status = false

--The Class
/**
	The Constructor for this Custom Addon Class
*/
function RD.__Construct()
	status = true;
	return true
end

/**
	The Destructor for this Custom Addon Class
*/
function RD.__Destruct()
	status = false;
	return true;
end

/**
	Get the required Addons for this Addon Class
*/
function RD.GetRequiredAddons()
	return {}
end

/**
	Get the Boolean Status from this Addon Class
*/
function RD.GetStatus()
	return status
end

/**
	Get the Version of this Custom Addon Class
*/
function RD.GetVersion()
	return 0.4, "Beta"
end

/**
	Get any custom options this Custom Addon Class might have
*/
function RD.GetExtraOptions()
	return {}
end

/**
	Gets a menu from this Custom Addon Class
*/
function RD.GetMenu(menutype, menuname)--Name is nil for main menu, String for others
	local data = {}
	return data
end

/**
	Get the Custom String Status from this Addon Class
*/
function RD.GetCustomStatus()
	if status then
		return "Installed"
	end
	return "Not installed"
end

/**
	Can the Status of the addon be changed?
*/
function RD.CanChangeStatus()
	return false;
end

/**
	Returns a table containing the Description of this addon
*/
function RD.GetDescription()
	return {
				"Spacebuild Enhancement Pack",
				"",
				"stuff"
			}
end
CAF.RegisterAddon("Spacebuild Enhancement Pack", RD, "1")