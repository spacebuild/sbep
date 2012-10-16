local Category = "SpaceBuild Enhancement Pack"

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
		model = "models/Spacebuild/chair.mdl"		,
		HA = SitAnim, ID = "sbep_chair"				} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Fighter Chair"						,
		info = "Chair for Fighter Planes"			, 
		model = "models/Spacebuild/chair2.mdl"		, 
		HA = SitAnim, ID = "sbep_chair2"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Corvette Chair"						,
		info = "Chair from a Light Combat Corvette"	, 
		model = "models/Spacebuild/Corvette_Chair.mdl", 
		HA = SitAnim, ID = "sbep_corvette_chair"	} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Prometheus Chair"					,
		info = "A chair. From the Prometheus."		, 
		model = "models/SmallBridge/Vehicles/SBVPchair.mdl", 
		HA = SitAnim, ID = "sb_P_chair"				} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Console Seat"						,
		info = "Sit in it."							, 
		model = "models/Slyfo/consolechair.mdl"		, 
		HA = VehAnim, ID = "sbep_console_seat"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "GCockpit Seat"						,
		info = "For all your sitting needs."		, 
		model = "models/Slyfo/Gcockpitseat.mdl"		, 
		HA = VehAnim, ID = "sbep_gcockpitseat"		} ,
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 1"					,
		info = "Military CockPit Style 1"			, 
		model = "models/Spacebuild/milcock.mdl"		,
		HA = VehAnim, ID = "sbep_milcock"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 2 Redux"			,
		info = "Military Cockpit 2 Redux"			, 
		model = "models/Spacebuild/MilCock2_Redux.mdl", 
		HA = VehAnim, ID = "sbep_milcock2redux"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 3 Redux"			,
		info = "Military Cockpit 3 Redux"			, 
		model = "models/Spacebuild/MilCock3_Redux.mdl", 
		HA = VehAnim, ID = "sbep_milcock3redux"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 4"					,
		info = "Military CockPit Style 4"			, 
		model = "models/Spacebuild/milcock4a.mdl"	,
		HA = VehAnim, ID = "sbep_mcockfourb"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 5"					,
		info = "Military CockPit Style 5"			, 
		model = "models/Spacebuild/milcock5a.mdl"	,
		HA = VehAnim, ID = "sbep_mcockfive"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 6 Redux"			,
		info = "Military Cockpit 6 Redux"			, 
		model = "models/Spacebuild/MilCock6_Redux.mdl", 
		HA = VehAnim, ID = "sbep_milcock6redux"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 7"					,
		info = "Military Cockpit 7"					, 
		model = "models/Spacebuild/Mil_Cock_7.mdl"	, 
		HA = VehAnim, ID = "sbep_milcock7"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Military Cockpit 8"					,
		info = "Military Cockpit 8"					, 
		model = "models/Spacebuild/MilCock8.mdl"	, 
		HA = VehAnim, ID = "sbep_milcock8"			} ,
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
	{	name = "Drop Pod"							,
		info = "Drop Pod"							, 
		model = "models/Spacebuild/Nova/drop_pod.mdl", 
		HA = nil	, ID = "sbep_droppod"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "SmallBridge Drop Pod"				,
		info = "SmallBridge Drop Pod"				, 
		model = "models/SmallBridge/Vehicles/SBVdroppod1.mdl", 
		HA = SitAnim, ID = "sbep_SB_pod"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "SmallBridge Assault Pod"			,
		info = "SmallBridge Assault Pod"			, 
		model = "models/SmallBridge/Vehicles/SBVassaultpod.mdl", 
		HA = nil	, ID = "sbep_SB_Apod"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Ball Pod"							,
		info = "Ball Shaped Pod"					, 
		model = "models/Spacebuild/strange.mdl"		,
		HA = SitAnim, ID = "sbep_stpod"				} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Assault Pod"						,
		info = "They'll never know what hit them."	, 
		model = "models/Slyfo/assault_pod.mdl"		, 
		HA = VehAnim, ID = "sbep_assault_pod"		} ,
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
	{	name = "Light Combat Corvette"				,
		info = "Light Combat Corvette"				, 
		model = "models/Spacebuild/Light_Combat_Corvette.mdl", 
		HA = SitAnim, ID = "sbep_lcomcorv"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Wheelcycle"							,
		info = "Uniwheel Cyclepod"					, 
		model = "models/Slyfo/wheelcycle.mdl"		, 
		HA = VehAnim, ID = "sbep_wheelcycle"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "SWORD"								,
		info = "Orbital Reconstruction/Demolition"	, 
		model = "models/Slyfo/SWORD.mdl"			, 
		HA = VehAnim, ID = "sbep_sword"				} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "TorpedoShip1"						,
		info = "Torpedo Hauler"						, 
		model = "models/Slyfo/TORPEDOSHIP1.mdl"		, 
		HA = VehAnim, ID = "sbep_torpedoship1"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Forklift"							,
		info = "Forklift"							, 
		model = "models/Slyfo/forklift.mdl"			, 
		HA = VehAnim, ID = "sbep_forklift"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Forkbase"							,
		info = "Forkbase"							, 
		model = "models/Slyfo/Forkbase.mdl"			, 
		HA = VehAnim, ID = "sbep_Forkbase"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "TorpedoShip2"						,
		info = "Flatbed Hauler"						, 
		model = "models/Slyfo/torpedoship2.mdl"		, 
		HA = VehAnim, ID = "sbep_torpedoship2"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Transport, Large"					,
		info = "Move things with it."				, 
		model = "models/Slyfo/transportlarge.mdl"	, 
		HA = VehAnim, ID = "sbep_transportlarge"	} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Transport, Small"					,
		info = "Move things with it."				, 
		model = "models/Slyfo/transportsmall.mdl"	, 
		HA = VehAnim, ID = "sbep_transportsmall"	} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Clunker"							,
		info = "Good for moving the pilot. And not much else..", 
		model = "models/Slyfo/clunker.mdl"			, 
		HA = VehAnim, ID = "sbep_clunker"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Rover"								,
		info = ""									, 
		model = "models/Slyfo/rover1_chassis.mdl"	, 
		HA = VehAnim, ID = "sbep_rover1_chassis"	} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Arwing"								,
		info = "Do a Barrel Roll!"					, 
		model = "models/Slyfo/arwing_body.mdl"		, 
		HA = VehAnim, ID = "sbep_arwing_body"		} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "CrateMover"							,
		info = "Slightly more useless than the Clunker", 
		model = "models/Slyfo/cratemover.mdl"		, 
		HA = VehAnim, ID = "sbep_CrateMover"		} ,
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
	{	name = "StingRay"							,
		info = "Stingray Light Fighter"				, 
		model = "models/Cerus/Fighters/Stingray.mdl", 
		HA = SitAnim, ID = "sbep_StingRay"			} ,
---------------------------------------------------------------------------------------------------------------------
	{	name = "Wraith"								,
		info = "Wraith Assault Bomber"				, 
		model = "models/Cerus/Fighters/Wraith.mdl"	, 
		HA = SitAnim, ID = "sbep_WraithBomber"		},
---------------------------------------------------------------------------------------------------------------------
	{	name = "VF-1a Fighter"							,
		info = "VF-1a Valkyrie, Fighter Mode"			, 
		model = "models/SBEP_community/errject_vf1afighter.mdl"	, 
		HA = SitAnim, ID = "sbep_vf1aFighter"		},
---------------------------------------------------------------------------------------------------------------------
	{	name = "VF-1a Super Fighter"							,
		info = "VF-1a Valkyrie, Fighter Mode with Super Pack"			, 
		model = "models/SBEP_community/errject_vf1asuperfighter.mdl"	, 
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
				Author = "SpaceBuild Enhancement Pack",
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
				Author = "SpaceBuild Enhancement Pack",
				Model = E.model,
			KeyValues = {
				vehiclescript	=	"scripts/vehicles/prisoner_pod.txt",
				limitview		=	"0"
						}
			}
	end
	list.Set( "Vehicles", E.ID, V )
end