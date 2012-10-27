include('shared.lua')

 function ENT:SpawnFunction( ply, tr )
   local ent = ents.Create("sbep_manual") 		
   ent:SetPos(tr.HitPos) 
   ent:Spawn() 									
   
   return ent 									
  end 

function ENT:Initialize()

self:SetModel( "models/Spacebuild/sbepmanual.mdl" )
self:PhysicsInit( SOLID_VPHYSICS )
self:SetMoveType( MOVETYPE_VPHYSICS )							
self:SetSolid( SOLID_VPHYSICS )
self:SetUseType( SIMPLE_USE )
self:SetPos( self:GetPos() + Vector( 0, 0, self:OBBMins().z ) )

local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Think()
end 

function ENT:Use( activator, caller )
	umsg.Start("OpenSBEPManual", RecipientFilter():AddPlayer( activator ) )
	umsg.End()
end

function SBEPManualFirstSpawn( ply )
	if not file.Exists("manuals/spawned.txt") then 
		umsg.Start("OpenSBEPManual", ply)
		umsg.End()
	file.Write("manuals/spawned.txt" ,  "Asphid_Jackal iz mah supreem gawd and ah will folla him forevahz!") 
	end	
end
hook.Add( "PlayerInitialSpawn", "superuniquesbepusermanual", SBEPManualFirstSpawn );
