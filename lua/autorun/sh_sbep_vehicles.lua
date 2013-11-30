local Category = "SpaceBuild Enhancement Project"

local function VehAnim( vehicle, player )
	return player:SelectWeightedSequence( ACT_DRIVE_AIRBOAT ) 
end

local function SitAnim( vehicle, player )
	return player:SelectWeightedSequence( ACT_HL2MP_SIT ) 
end



local VT = {
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
	{	name = "Captain Chair"					,
		info = "Captain Chair"					, 
		model = "models/spacebuild/chair.mdl"		,
		HA = SitAnim, ID = "sbep_chair"				} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Fighter Chair"						,
		info = "Chair for Fighter Planes"			, 
		model = "models/spacebuild/chair2.mdl"		, 
		HA = SitAnim, ID = "sbep_chair2"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Corvette Chair"						,
		info = "Chair from a Light Combat Corvette"	, 
		model = "models/spacebuild/corvette_chair.mdl", 
		HA = SitAnim, ID = "sbep_corvette_chair"	} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Prometheus Chair"					,
		info = "A chair. From the Prometheus."		, 
		model = "models/smallbridge/vehicles/sbvpchair.mdl", 
		HA = SitAnim, ID = "sb_P_chair"				} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Console Seat"						,
		info = "Sit in it."							, 
		model = "models/slyfo/consolechair.mdl"		, 
		HA = VehAnim, ID = "sbep_console_seat"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "GCockpit Seat"						,
		info = "For all your sitting needs."		, 
		model = "models/slyfo/gcockpitseat.mdl"		, 
		HA = VehAnim, ID = "sbep_gcockpitseat"		} ,
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 1"					,
		info = "Military CockPit Style 1"			, 
		model = "models/spacebuild/milcock.mdl"		,
		HA = VehAnim, ID = "sbep_milcock"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 2 Redux"			,
		info = "Military Cockpit 2 Redux"			, 
		model = "models/spacebuild/milcock2_redux.mdl", 
		HA = VehAnim, ID = "sbep_milcock2redux"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 3 Redux"			,
		info = "Military Cockpit 3 Redux"			, 
		model = "models/spacebuild/milcock3_redux.mdl", 
		HA = VehAnim, ID = "sbep_milcock3redux"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 4"					,
		info = "Military CockPit Style 4"			, 
		model = "models/spacebuild/milcock4a.mdl"	,
		HA = VehAnim, ID = "sbep_mcockfourb"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 5"					,
		info = "Military CockPit Style 5"			, 
		model = "models/spacebuild/milcock5a.mdl"	,
		HA = VehAnim, ID = "sbep_mcockfive"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 6 Redux"			,
		info = "Military Cockpit 6 Redux"			, 
		model = "models/spacebuild/milcock6_redux.mdl", 
		HA = VehAnim, ID = "sbep_milcock6redux"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 7"					,
		info = "Military Cockpit 7"					, 
		model = "models/spacebuild/mil_cock_7.mdl"	, 
		HA = VehAnim, ID = "sbep_milcock7"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 8"					,
		info = "Military Cockpit 8"					, 
		model = "models/spacebuild/milcock8.mdl"	, 
		HA = VehAnim, ID = "sbep_milcock8"			} ,
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
	{	name = "Drop Pod"							,
		info = "Drop Pod"							, 
		model = "models/spacebuild/nova/drop_pod.mdl", 
		HA = nil	, ID = "sbep_droppod"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "SmallBridge Drop Pod"				,
		info = "SmallBridge Drop Pod"				, 
		model = "models/smallbridge/vehicles/sbvdroppod1.mdl", 
		HA = SitAnim, ID = "sbep_SB_pod"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "SmallBridge Assault Pod"			,
		info = "SmallBridge Assault Pod"			, 
		model = "models/smallbridge/vehicles/sbvassaultpod.mdl", 
		HA = nil	, ID = "sbep_SB_Apod"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Ball Pod"							,
		info = "Ball Shaped Pod"					, 
		model = "models/spacebuild/strange.mdl"		,
		HA = SitAnim, ID = "sbep_stpod"				} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Assault Pod"						,
		info = "They'll never know what hit them."	, 
		model = "models/slyfo/assault_pod.mdl"		, 
		HA = VehAnim, ID = "sbep_assault_pod"		} ,
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
	{	name = "Light Combat Corvette"				,
		info = "Light Combat Corvette"				, 
		model = "models/spacebuild/light_combat_corvette.mdl", 
		HA = SitAnim, ID = "sbep_lcomcorv"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Wheelcycle"							,
		info = "Uniwheel Cyclepod"					, 
		model = "models/slyfo/wheelcycle.mdl"		, 
		HA = VehAnim, ID = "sbep_wheelcycle"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "SWORD"								,
		info = "Orbital Reconstruction/Demolition"	, 
		model = "models/slyfo/sword.mdl"			, 
		HA = VehAnim, ID = "sbep_sword"				} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "TorpedoShip1"						,
		info = "Torpedo Hauler"						, 
		model = "models/slyfo/torpedoship1.mdl"		, 
		HA = VehAnim, ID = "sbep_torpedoship1"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Forklift"							,
		info = "Forklift"							, 
		model = "models/slyfo/forklift.mdl"			, 
		HA = VehAnim, ID = "sbep_forklift"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Forkbase"							,
		info = "Forkbase"							, 
		model = "models/slyfo/forkbase.mdl"			, 
		HA = VehAnim, ID = "sbep_Forkbase"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "TorpedoShip2"						,
		info = "Flatbed Hauler"						, 
		model = "models/slyfo/torpedoship2.mdl"		, 
		HA = VehAnim, ID = "sbep_torpedoship2"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Transport, Large"					,
		info = "Move things with it."				, 
		model = "models/slyfo/transportlarge.mdl"	, 
		HA = VehAnim, ID = "sbep_transportlarge"	} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Transport, Small"					,
		info = "Move things with it."				, 
		model = "models/slyfo/transportsmall.mdl"	, 
		HA = VehAnim, ID = "sbep_transportsmall"	} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Clunker"							,
		info = "Good for moving the pilot. And not much else..", 
		model = "models/slyfo/clunker.mdl"			, 
		HA = VehAnim, ID = "sbep_clunker"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Rover"								,
		info = ""									, 
		model = "models/slyfo/rover1_chassis.mdl"	, 
		HA = VehAnim, ID = "sbep_rover1_chassis"	} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Arwing"								,
		info = "Do a Barrel Roll!"					, 
		model = "models/slyfo/arwing_body.mdl"		, 
		HA = VehAnim, ID = "sbep_arwing_body"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "CrateMover"							,
		info = "Slightly more useless than the Clunker", 
		model = "models/slyfo/cratemover.mdl"		, 
		HA = VehAnim, ID = "sbep_CrateMover"		} ,
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
	{	name = "StingRay"							,
		info = "Stingray Light Fighter"				, 
		model = "models/cerus/fighters/stingray.mdl", 
		HA = SitAnim, ID = "sbep_StingRay"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Wraith"								,
		info = "Wraith Assault Bomber"				, 
		model = "models/cerus/fighters/wraith.mdl"	, 
		HA = SitAnim, ID = "sbep_WraithBomber"		},
---------------------------------------------------------------------------------------------------------------------
	{	name = "VF-1a Fighter"							,
		info = "VF-1a Valkyrie, Fighter Mode"			, 
		model = "models/sbep_community/errject_vf1afighter.mdl"	, 
		HA = SitAnim, ID = "sbep_vf1aFighter"		},
---------------------------------------------------------------------------------------------------------------------
	{	name = "VF-1a Super Fighter"							,
		info = "VF-1a Valkyrie, Fighter Mode with Super Project"			, 
		model = "models/sbep_community/errject_vf1asuperfighter.mdl"	, 
		HA = SitAnim, ID = "sbep_vf1aSuperFighter"		}
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
			}

for n,E in ipairs( VT ) do
	local V
	if E.HA then
		V = { 	
			Name = E.name, 
				Class = "prop_vehicle_prisoner_pod",
				Category = Category,
				Information = E.info,
				Author = "SpaceBuild Enhancement Project",
				Model = E.model,
			KeyValues = {
				vehiclescript	=	"scripts/vehicles/prisoner_pod.txt",
				limitview		=	"0"
						},
				Members = { HandleAnimation = E.HA, }
			}
	else
		V = { 	
			Name = E.name, 
				Class = "prop_vehicle_prisoner_pod",
				Category = Category,
				Information = E.info,
				Author = "SpaceBuild Enhancement Project",
				Model = E.model,
			KeyValues = {
				vehiclescript	=	"scripts/vehicles/prisoner_pod.txt",
				limitview		=	"0"
						}
			}
	end
	list.Set( "Vehicles", E.ID, V )
end
-- End of old code That I do not need to change as it seems to work. The next piece of code should stop in the ground models! (Yay)


function NotInTheGroundPlz( ply, vehicle ) -- Awesome function name hey? pretty descriptive to.
	local model = vehicle:GetModel()
	DebugMessage("SBEP Vehicle Ground Preventation")
	DebugMessage("The Vehicle Model is: "..model.."")
	DebugMessage("Player:"..tostring(ply).."")
	if (model == "models/spacebuild/strange.mdl") then
		local oldPos = vehicle:GetPos()
		local mini = vehicle:OBBMins()
		local height = vehicle:OBBMaxs().z - vehicle:OBBMins().z
		vehicle:SetPos( Vector(oldPos.x, oldPos.y, oldPos.z + height/2 ))
	end
	
	for k,v in pairs(VT) do
		DebugMessage("V = "..v.model.."")
		if (v.model == model) then -- We have found the corresponding element in the table. Now using OBBMins.
			local oldPos = vehicle:GetPos()
			local mini = vehicle:OBBMins()
			local height = vehicle:OBBMaxs().z - vehicle:OBBMins().z
			DebugMessage("Old Pos: "..tostring(oldPos).."")
			DebugMessage("Height: "..tostring( vehicle:OBBMaxs().z - vehicle:OBBMins().z).."")
			
			DebugMessage("New Pos: "..tostring( Vector(oldPos.x, oldPos.y, oldPos.z + height/2)).."")
		
			
			vehicle:SetPos( Vector(oldPos.x, oldPos.y, oldPos.z + height/2 ))
			break -- Get out of the loop for performance (smalL but meh) 
			
		end
	end
end

hook.Add("PlayerSpawnedVehicle","Stop SBEP Vehicles spawning in the ground", NotInTheGroundPlz)

--ISSUES:
-- Duping (ASAP). NotInGround bugs when a vehicle is duped  add an if-then-else to check if the vehicle has been spawned in by a player or duped in. Only occurs with Ad1 and IGN Dupe
