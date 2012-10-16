ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Small Missile Pod"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP - Weapons"
ENT.Instructions	= "The guidance system for the missiles can be configured by wired inputs. 0 = Unguided, 1 = Non-Tracking, 2 = Tracking, 3 = Homing, 4 = Seeking, 5 = Optical. For more information, visit the thread." 

ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Owner			= nil
ENT.SPL				= nil
ENT.MCDown			= 0
ENT.CDown1			= true
ENT.CDown1			= 0
ENT.CDown2			= true
ENT.CDown2			= 0
ENT.HPType			= "Small"
ENT.APPos			= Vector(-10,0,17)

function ENT:SetShots( val )
	local CVal = self.Entity:GetNetworkedInt( "Shots" )
	if CVal ~= val then
		self.Entity:SetNetworkedInt( "Shots", val )
	end
end

scripted_ents.Register({
	Type 			= "anim",
	Spawnable		= true,
	AdminSpawnable	= true,
	PrintName 		= "4X Missile Pod",
	Author			= "Paradukes + SlyFo",
	Category		= "SBEP - Weapons",
	Instructions	= "The guidance system for the missiles can be configured by wired inputs. 0 = Unguided, 1 = Non-Tracking, 2 = Tracking, 3 = Homing, 4 = Seeking, 5 = Optical. For more information, visit the thread.",

	SpawnFunction = function( ent, ply, tr )
		if ( !tr.Hit ) then return end
	
		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		
		local ent = ents.Create( "SBEP_Base_Launcher" )
		ent.LType = "4X Launcher"
		ent:Initialize()
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
		ent.SPL = ply
		
		return ent
	end
	
}, "SF-SmallMissilePod", false)

scripted_ents.Register({
	Type 			= "anim",
	Spawnable		= true,
	AdminSpawnable	= true,
	PrintName 		= "8X Missile Pod",
	Author			= "Paradukes + SlyFo",
	Category		= "SBEP - Weapons",
	Instructions	= "The guidance system for the missiles can be configured by wired inputs. 0 = Unguided, 1 = Non-Tracking, 2 = Tracking, 3 = Homing, 4 = Seeking, 5 = Optical. For more information, visit the thread.",

	SpawnFunction = function( ent, ply, tr )
		if ( !tr.Hit ) then return end
	
		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		
		local ent = ents.Create( "SBEP_Base_Launcher" )
		ent.LType = "8X Launcher"
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
		ent.SPL = ply
		
		return ent
	end
	
}, "SF-8XMissilePod", false)

scripted_ents.Register({
	Type 			= "anim",
	Spawnable		= true,
	AdminSpawnable	= true,
	PrintName 		= "10X Missile Pod",
	Author			= "Paradukes + SlyFo",
	Category		= "SBEP - Weapons",
	Instructions	= "The guidance system for the missiles can be configured by wired inputs. 0 = Unguided, 1 = Non-Tracking, 2 = Tracking, 3 = Homing, 4 = Seeking, 5 = Optical. For more information, visit the thread.",

	SpawnFunction = function( ent, ply, tr )
		if ( !tr.Hit ) then return end
	
		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		
		local ent = ents.Create( "SBEP_Base_Launcher" )
		ent.LType = "10X Launcher"
		ent:Initialize()
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
		ent.SPL = ply
		
		return ent
	end
	
}, "SF-10XMissilePod", false)