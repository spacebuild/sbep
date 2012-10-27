local LS = {}

local status = false


/**
	The Constructor for this Custom Addon Class
*/
function LS.__Construct()
	if status then return false , "This Addon is already Active!" end
	status = true
	return true
end

/**
	The Destructor for this Custom Addon Class
*/
function LS.__Destruct()
	if not status then return false, "This addon wasn't on in the first place" end
	status = false
	return true
end

/**
	Get the required Addons for this Addon Class
*/
function LS.GetRequiredAddons()
	return {"Resource Distribution", "Life Support"}
end

/**
	Get the Boolean Status from this Addon Class
*/
function LS.GetStatus()
	return status
end

/**
	Get the Version of this Custom Addon Class
*/
function LS.GetVersion()
	return 0.4, "Beta"
end

/**
	Get any custom options this Custom Addon Class might have
*/
function LS.GetExtraOptions()
	return {}
end

/**
	Get the Custom String Status from this Addon Class
*/
function LS.GetCustomStatus()
	return "Not Implemented Yet"
end

function LS.AddResourcesToSend()

end

CAF.RegisterAddon("Spacebuild Enhancement Pack", LS, "2")
