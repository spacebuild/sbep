TOOL.Category		= "SBEP"
TOOL.Name			= "#Weapon Mount"
TOOL.Command		= nil
TOOL.ConfigName 	= ""

local MST = list.Get( "SBEP_WeaponMountModels" )
local MTT = list.Get( "SBEP_WeaponMountToolModels" )

if CLIENT then
	language.Add( "Tool_sbep_weapon_mount_name"	, "SBEP Weapon Mount Tool" 							)
	language.Add( "Tool_sbep_weapon_mount_desc"	, "Create an SBEP weapon mount."					)
	language.Add( "Tool_sbep_weapon_mount_0"	, "Left click to spawn a hardpointed weapon mount." )
	language.Add( "undone_SBEP Weapon Mount"	, "Undone SBEP Weapon Mount"						)
end

TOOL.ClientConVar[ "model" ] = "models/Spacebuild/milcock4_wing1.mdl"

function TOOL:LeftClick( trace )

	if CLIENT then return end
	local model = self:GetClientInfo( "model" )
	local Data  = MST[ model ]
	local pos   = trace.HitPos
	
	local WeaponMountEnt = ents.Create( "sbep_base_weapon_mount" )
		WeaponMountEnt.MountName = Data.type
		WeaponMountEnt.MountData = {}
		WeaponMountEnt.MountData["model"] = model

		if Data.HP then
			WeaponMountEnt.HP = {}
			for n,P in ipairs( Data.HP ) do
				WeaponMountEnt.HP[n] = P
			end
		end
		
		WeaponMountEnt.HPType = Data.type
		WeaponMountEnt.APPos  = Data.V
		WeaponMountEnt.APAng  = Data.A
		
		WeaponMountEnt.SPL = self:GetOwner()
		
		WeaponMountEnt:SetPos( pos + Vector(0,0,50) )
		WeaponMountEnt:Spawn()
		WeaponMountEnt:Activate()
	
	undo.Create("SBEP Weapon Mount")
		undo.AddEntity( WeaponMountEnt )
		undo.SetPlayer( self:GetOwner() )
	undo.Finish()

	return true
end

function TOOL:RightClick( trace )

end

function TOOL:Reload( trace )

end

function TOOL.BuildCPanel( panel )

	panel:SetSpacing( 10 )
	panel:SetName( "SBEP Weapon Mount" )

	local MCPS = vgui.Create( "MCPropSelect" )
		MCPS:SetConVar( "sbep_weapon_mount_model" )
		for Cat,mt in pairs( MTT ) do
			MCPS:AddMCategory( Cat , mt )
		end
	MCPS:SetCategory( 1 )
	panel:AddItem( MCPS )

end