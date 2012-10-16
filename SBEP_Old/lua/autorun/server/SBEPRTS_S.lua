function RTSSendOrder(player,commandName,args)
		
	--Msg("Recieved a message from "..player:Name().."! It says "..table.concat(args," ").."") 
	--local Soldier = args[1]
	--print(table.concat(args," "))
--	player.RTSUnitsSelected = player.RTSUnitsSelected or {}
--	for _,i in ipairs(player.RTSUnitsSelected) do
--		if i:IsNPC() then
--		if i and i:IsValid() then
--			i:SetLastPosition( Vector(args[1], args[2], args[3]) ) 
--			i:SetSchedule( 71 ) -- run move
--			--print("Running")
	--	end
--		end
--	end
	local Unit = ents.GetByIndex(args[1])
	if Unit and Unit:IsValid() then
		if tonumber(args[5]) == 1 then
			Unit.MVec = Vector(args[2],args[3],args[4])
			if tonumber(args[9]) == 1 then
				Unit.Angling = true
				local Ang = Angle(0,0,0)
				Ang.r = args[6]
				Ang.p = args[7]
				Ang.y = args[8]
				Unit.MAngle = Ang
			else
				Unit.Angling = false
			end
		end
	end
end 
concommand.Add("IssueRTSOrder",RTSSendOrder) 

function RTSSetStance(player,commandName,args)
	local Unit = ents.GetByIndex(tonumber(args[1]))
	if Unit and Unit:IsValid() then
		Unit.Stance = tonumber(args[2])
	end
	 
end 
concommand.Add("RTSSetStance",RTSSetStance) 

function RTSSelection(player,commandName,args) 
	player.RTSUnitsSelected = {}
	local FEnts = ents.FindInBox( Vector(args[1],args[2],args[3]), Vector(args[4],args[5],args[6]) )
	for _,i in ipairs(FEnts) do
		--if i.BCCommandable then
			table.insert( player.RTSUnitsSelected, i )
		--end
	end
end 
concommand.Add("RTSSelection",RTSSelection) 


function SBEPRTS_S()
	--print("Running")
	local plys = player.GetAll()
	
	for _,i in ipairs(plys) do
		if i:KeyDown( IN_SPEED ) then
			if i.SBEPYaw == 0 and i.SBEPPitch == 0 then
				local L = LerpAngle( 0.1, i:EyeAngles(), Angle( 0, 0, 0 ) )
				--i:SetEyeAngles( L )
			end
		end
	end
end

hook.Add("Think", "SBEPRTS_S", SBEPRTS_S)