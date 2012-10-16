include('shared.lua')

 function ENT:SpawnFunction( ply, tr )
   local ent = ents.Create("sbep_manual") 		
   ent:SetPos(tr.HitPos) 
   ent:Spawn() 									
   
   return ent 									
  end 

function ENT:Initialize()

self.Entity:SetModel( "models/Spacebuild/sbepmanual.mdl" )
self.Entity:PhysicsInit( SOLID_VPHYSICS )
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )							
self.Entity:SetSolid( SOLID_VPHYSICS )
self.Entity:SetUseType( SIMPLE_USE )
self.Entity:SetPos( self.Entity:GetPos() + Vector( 0, 0, self.Entity:OBBMins().z ) )

local phys = self.Entity:GetPhysicsObject()
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
