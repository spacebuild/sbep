--SpacebuildEnhancementProject function table
SBEP = SBEP or {}

-- This function basically deals with stuff that happens when a player hops out of a vehicle
function SetExPoint(player, vehicle)
	if vehicle.ExitPoint and vehicle.ExitPoint:IsValid() then
		local EPP = vehicle.ExitPoint:GetPos()
		local VP = vehicle:GetPos()
		local Dist = EPP:Distance(VP)
		if Dist <= 500 then
			player:SetPos(vehicle.ExitPoint:GetPos() + vehicle.ExitPoint:GetUp() * 10)
			vehicle.ExitPoint.CDown = CurTime() + 0.5
		end
	end
	
	if player.CamCon then
		player.CamCon = false
		player:SetViewEntity()
	end
end

hook.Add("PlayerLeaveVehicle", "PlayerRepositioning", SetExPoint)
SBEP.SetExPoint = SetExPoint

function SBEP.ExitFighter(player,vehicle)
	if not vehicle.Cont then return end
	if vehicle.Cont.ExitFighter then
		vehicle.Cont:ExitFighter(player,vehicle)
	end
end
hook.Add("PlayerLeaveVehicle", "SBEP.ExitFighter", SBEP.ExitFighter)

--For controling certain entities
function SBEPCCC(ply, data)
	local cmd = ply:GetCurrentCommand()
	ply.SBEPYaw = cmd:GetMouseX()
	ply.SBEPPitch = cmd:GetMouseY()
	
end  
 
hook.Add("SetupMove", "SBEPControls", SBEPCCC)
SBEP.CCC = SBEPCCC

--This is all the hardpointing stuff
function HPLink( cont, pod, weap )
	if weap.Mounted then return false end
	if not cont.HPC then return false end
	for i = 1, cont.HPC do
		if not cont.HP[i]["Ent"] or not cont.HP[i]["Ent"]:IsValid() then
			local TypeMatch = false
			if type(cont.HP[i]["Type"]) == "string" then
				if type(weap.HPType) == "string" then
					--print("Double String")
					if cont.HP[i]["Type"] == weap.HPType then
						TypeMatch = true
					end
				elseif type(weap.HPType) == "table" then
					--print("String - Table")
					if table.HasValue( weap.HPType, cont.HP[i]["Type"] ) then
						TypeMatch = true
					end
				end
			elseif type(cont.HP[i]["Type"]) == "table" then
				if type(weap.HPType) == "string" then
					--print("Table - String")
					if table.HasValue( cont.HP[i]["Type"], weap.HPType ) then
						TypeMatch = true
					end
				elseif type(weap.HPType) == "table" then
					--print("Double Table")
					for _,v in pairs(cont.HP[i]["Type"]) do
						if table.HasValue( weap.HPType, v ) then
							TypeMatch = true
						end
					end
				end
			end			
			
			if TypeMatch then
				------Fishface60's new code-------
				local APAng = weap.APAng or Angle(0,0,0)
				local HPAng = cont.HP[i]["Angle"] or Angle(0,0,0)
				weap:SetAngles(pod:LocalToWorldAngles(HPAng))
				weap:SetAngles(weap:LocalToWorldAngles(APAng))
				
				local APPos = weap.APPos or Vector(0,0,0)
				local HPPos = cont.HP[i]["Pos"] or Vector(0,0,0)
				--copy the vector in case we change it
				HPPos = Vector(HPPos.x,HPPos.y,HPPos.z)
				if cont.Skewed then
					if (type(cont.Skewed) == "boolean" and cont.Skewed == true) then
						HPPos:Rotate(Angle(0,-90,0))
					elseif type(cont.Skewed) == "angle" then
						HPPos:Rotate(cont.Skewed)
					end
				end
				weap:SetPos(pod:LocalToWorld(HPPos))
				weap:SetPos(weap:LocalToWorld(APPos))
				
				weap:GetPhysicsObject():EnableCollisions(false)
				weap.HPNoc = constraint.NoCollide(pod, weap, 0, 0, 0, true)
				weap.HPWeld = constraint.Weld(pod, weap, 0, 0, 0, true)
				weap:SetParent( pod )
				pod:SetNetworkedEntity( "HPW_"..i, weap )
				if pod.Pod and pod.Pod:IsValid() then
					pod.Pod:SetNetworkedEntity( "HPW_"..i, weap )
				end
				cont.HP[i]["Ent"] = weap
				weap.Pod = pod
				weap.HPN = i
				weap.Mounted = true
				weap:GetPhysicsObject():EnableGravity(false)
				if cont.OnHPLink then cont:OnHPLink(weap) end
				return true
			end
		end
	end
	return false
end
SBEP.HPLink = HPLink

--This is basically a customized version of the standard GCombat explosion. Thanks to Q42 for making the system so maleable :)
--The only reason this is necessary is to stop certain projectiles from blowing each other up.
function SBGCSplash( position, radius, damage, pierce, filter )
	local targets = ents.FindInSphere( position, radius )
	local tooclose = ents.FindInSphere( position, 5 )
	
	for _,i in pairs(targets) do
		--print(filter)
		--print(i:GetClass())
		if not table.HasValue( filter, i:GetClass() ) then
			--print("Not Matching")
			local tracedata = {}
			tracedata.start = position
			tracedata.endpos = i:LocalToWorld( i:OBBCenter( ) )
			tracedata.filter = tooclose
			tracedata.mask = MASK_SOLID
			local trace = util.TraceLine(tracedata) 
					
			if trace.Entity == i then
				local hitat = trace.HitPos
				cbt_dealhcghit( i, damage, pierce, hitat, hitat)
			end
		end
	end
end

function SetPlayerSPEBWeaponColor(ply,cmd,args)
	args[1],args[2],args[3] = tonumber(args[1]),tonumber(args[2]),tonumber(args[3])
	if (not args[1]) or (not args[2]) or (not args[3]) then
		ply:PrintMessage(HUD_PRINTTALK,"Arguments for color invalid, proper format is \"SBEP_Weapon_Color r g b\"")
		return
	end
	ply.SBEPWeaponColor = Color(math.Clamp(args[1],0,255),math.Clamp(args[2],0,255),math.Clamp(args[3],0,255),255)
	ply:SetPData("SBEP_Weapon_Color_Red",ply.SBEPWeaponColor.r)
	ply:SetPData("SBEP_Weapon_Color_Green",ply.SBEPWeaponColor.g)
	ply:SetPData("SBEP_Weapon_Color_Blue",ply.SBEPWeaponColor.b)
	umsg.Start("IdLikeToRecieveMyOwnColorNow",ply)
	 umsg.Short(ply.SBEPWeaponColor.r)
	 umsg.Short(ply.SBEPWeaponColor.g)
	 umsg.Short(ply.SBEPWeaponColor.b)
	umsg.End()
end 
concommand.Add("SBEP_Weapon_Color",SetPlayerSPEBWeaponColor)
