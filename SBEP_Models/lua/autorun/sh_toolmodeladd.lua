list.Set( "ButtonModels", "models/SmallBridge/Other/SBconsolelow.mdl", {} )
list.Set( "ButtonModels", "models/SmallBridge/Other/SBconsole.mdl", {} )
list.Set( "ButtonModels", "models/Slyfo/powercrystal.mdl", {} )

-- Wire Screen models
list.Set( "WireScreenModels" , "models/slyfo/consolescreenbig.mdl", {} )
list.Set( "WireScreenModels" , "models/slyfo/consolescreenmed.mdl", {} )
list.Set( "WireScreenModels" , "models/slyfo/consolescreensmall.mdl", {} )
list.Set( "WireScreenModels" , "models/smallbridge/other parts/sbscreen1.mdl", {} )
if CLIENT then
	local function defineWireScreens(tries)
		if	WireGPU_AddMonitor then
			WireGPU_AddMonitor("Slyfo Large Console Screen", "models/slyfo/consolescreenbig.mdl", 0.25, 0, 0, 0.055, 18, -18, 13, -13)
			WireGPU_AddMonitor("Slyfo Medium Console Screen", "models/slyfo/consolescreenmed.mdl", 0.25, 0, 0, 0.040, 18, -18, 13, -13)
			WireGPU_AddMonitor("Slyfo Small Console Screen", "models/slyfo/consolescreensmall.mdl", 0.25, 0, 0, 0.03, 18, -18, 13, -13)
			WireGPU_AddMonitor("SMB Square Screen", "models/smallbridge/other parts/sbscreen1.mdl", 1.25, 0, 0, 0.08, 20, -20, 20, -20)
		else
			if tries <= 10 then
				timer.Simple(1, defineWireScreens, tries+1)
			else
				ErrorNoHalt"SBEP: Failed to define Wire Screens\n"
			end
		end
	end
	defineWireScreens(1)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--SMALLBRIDGE TEXTURES
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Skin 1
list.Add( "OverrideMaterials", "spacebuild/Body" )
list.Add( "OverrideMaterials", "spacebuild/BodySkin" )
list.Add( "OverrideMaterials", "spacebuild/Hazard" )
list.Add( "OverrideMaterials", "spacebuild/Floor" )
list.Add( "OverrideMaterials", "spacebuild/SBLight" )
list.Add( "OverrideMaterials", "spacebuild/SBLight_D" )
list.Add( "OverrideMaterials", "spacebuild/Fusion" )
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Skin 2
list.Add( "OverrideMaterials", "spacebuild/Body2" )
list.Add( "OverrideMaterials", "spacebuild/Body2Skin" )
list.Add( "OverrideMaterials", "spacebuild/Hazard2" )
list.Add( "OverrideMaterials", "spacebuild/Floor2" )
list.Add( "OverrideMaterials", "spacebuild/SBLight2" )
list.Add( "OverrideMaterials", "spacebuild/SBLight2_D" )
list.Add( "OverrideMaterials", "spacebuild/Fusion2" )
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Skin 3
list.Add( "OverrideMaterials", "spacebuild/Body3" )
list.Add( "OverrideMaterials", "spacebuild/Body3Skin" )
list.Add( "OverrideMaterials", "spacebuild/Hazard3" )
list.Add( "OverrideMaterials", "spacebuild/Floor3" )
list.Add( "OverrideMaterials", "spacebuild/SBLight3" )
list.Add( "OverrideMaterials", "spacebuild/SBLight3_D" )
list.Add( "OverrideMaterials", "spacebuild/Fusion3" )
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Skin 4
list.Add( "OverrideMaterials", "spacebuild/Body4" )
list.Add( "OverrideMaterials", "spacebuild/Body4Skin" )
list.Add( "OverrideMaterials", "spacebuild/Hazard4" )
list.Add( "OverrideMaterials", "spacebuild/Floor4" )
list.Add( "OverrideMaterials", "spacebuild/SBLight4" )
list.Add( "OverrideMaterials", "spacebuild/SBLight4_D" )
list.Add( "OverrideMaterials", "spacebuild/Fusion4" )
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Skin 5
list.Add( "OverrideMaterials", "spacebuild/Body5" )
list.Add( "OverrideMaterials", "spacebuild/Body5Skin" )
list.Add( "OverrideMaterials", "spacebuild/Hazard5" )
list.Add( "OverrideMaterials", "spacebuild/Floor5" )
list.Add( "OverrideMaterials", "spacebuild/SBLight5" )
list.Add( "OverrideMaterials", "spacebuild/SBLight5_D" )
list.Add( "OverrideMaterials", "spacebuild/Fusion5" )
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Cerus' Textures
list.Add( "OverrideMaterials", "Cmats/Base_Grey" )
list.Add( "OverrideMaterials", "Cmats/Base_Metal_Floor" )
list.Add( "OverrideMaterials", "Cmats/Base_Metal_Rust" )
list.Add( "OverrideMaterials", "Cmats/Base_Tile" )
list.Add( "OverrideMaterials", "Cmats/Base_Metal_Yellow" )
list.Add( "OverrideMaterials", "Cmats/Base_Metal_Light" )
list.Add( "OverrideMaterials", "Cmats/Station_Metal_B" )
list.Add( "OverrideMaterials", "Cmats/Station_Metal_B_S" )
list.Add( "OverrideMaterials", "Cmats/genfield" )
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--STARGATE

list.Set( "StaffWeaponModels", "models/Slyfo/artycannon.mdl", {} )
list.Set( "StaffWeaponModels", "models/Slyfo/finfunnel.mdl", {} )
list.Set( "StaffWeaponModels", "models/Slyfo/powercrystal.mdl", {} )

list.Set( "DroneLauncherModels", "models/Slyfo/artycannon.mdl", {} )
list.Set( "DroneLauncherModels", "models/Slyfo/finfunnel.mdl", {} )
list.Set( "DroneLauncherModels", "models/Slyfo/powercrystal.mdl", {} )

list.Set( "StargateCloakModels", "models/Slyfo/finfunnel.mdl", {} )
list.Set( "StargateCloakModels", "models/Slyfo/powercrystal.mdl", {} )

list.Set( "StargateShieldModels", "models/Slyfo/finfunnel.mdl", {} )
list.Set( "StargateShieldModels", "models/Slyfo/powercrystal.mdl", {} )

list.Set( "WraithHarvesterModels", "models/Slyfo/finfunnel.mdl", {} )
list.Set( "WraithHarvesterModels", "models/Slyfo/powercrystal.mdl", {} )

list.Set( "MobileDHDModels", "models/SmallBridge/Other/SBconsolelow.mdl", {} )
list.Set( "MobileDHDModels", "models/SmallBridge/Other/SBconsole.mdl", {} )
list.Set( "MobileDHDModels", "models/Slyfo/powercrystal.mdl", {} )
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------