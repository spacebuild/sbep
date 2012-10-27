--save a reference to the original function
local calcVehView

--the new function
local function SBMP_OverrideOrigin( Vehicle, ply, origin, angles, fov )
	--call the original function
	view = calcVehView(Vehicle,ply,origin,angles,fov)
	local ViewEnt = ply:GetNetworkedEntity("ViewEnt")
	local OffsetOut = ply:GetNetworkedInt("OffsetOut") or 1000
	local OffsetUp = ply:GetNetworkedInt("OffsetUp") or 0
	if (ViewEnt and ViewEnt:IsValid()) then
		local pos = ViewEnt:GetPos()
		local offset = (view.angles:Forward() * OffsetOut) + (view.angles:Up() * -OffsetUp)
		view.origin = pos - offset
	end
	--return the changed view
	return view 
end

local function replaceHook()
	calcVehView = GAMEMODE.CalcVehicleThirdPersonView
	--print("Old Function = "..tostring(calcVehView))
	--print("New Function = "..tostring(SBMP_OverrideOrigin))
	--replace the original function
	GAMEMODE.CalcVehicleThirdPersonView = SBMP_OverrideOrigin
	--print("Current Function = "..tostring(GAMEMODE.CalcVehicleThirdPersonView))
end

local function IncrementZoom(player,command,args)
	--[[print("Increment Args")
	PrintTable(args)]]
	local zoomMod = 10
	if (#args ~= 0) then
		zoomMod = args[1]
	end
	if not (player and player:IsValid()) then return end
	local veh = player:GetVehicle()
	if not (veh and veh:IsValid()) then return end
	local cont = veh:GetNetworkedEntity("Controller")
	if veh:GetNetworkedInt("OffsetOut") then
		veh:SetNetworkedInt("OffsetOut",veh:GetNetworkedInt("OffsetOut") - zoomMod)
	end
end
local function DecrementZoom(player,command,args)
	--[[print("Decrement Args")
	PrintTable(args)]]
	local zoomMod = 10
	if (#args ~= 0) then
		zoomMod = args[1]
	end
	if not (player and player:IsValid()) then return end
	local veh = player:GetVehicle()
	if not (veh and veh:IsValid()) then return end
	if veh:GetNetworkedInt("OffsetOut") then
		veh:SetNetworkedInt("OffsetOut",veh:GetNetworkedInt("OffsetOut") + zoomMod)
	end
end
concommand.Add("sbep_zoom_in",IncrementZoom)
concommand.Add("sbep_zoom_out",DecrementZoom)
hook.Add( "Initialize", "replaceHook", replaceHook )