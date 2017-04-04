AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
util.PrecacheSound( "SB/Gattling2.wav" )

function ENT:Initialize()

	self.Entity:SetModel( "models/slyfo/rover1_glass.mdl" ) 
	self.Entity:SetName("SmallMachineGun")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	--self.val1 = 0
	--RD_AddResource(self.Entity, "Munitions", 0)

	self.HPC			= 1
	self.HP				= {}
	self.HP[1]			= {}
	self.HP[1]["Ent"]	= nil
	self.HP[1]["Type"]	= "Tiny"
	self.HP[1]["Pos"]	= Vector(6,6,-2)
	
	self.Cont = self.Entity
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "SF-RoverWindshield" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		

end

function ENT:PhysicsUpdate()

end

function ENT:Think()

end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

end

function ENT:Touch( ent )
	if ent.HasWindshield then
		if ent.Cont and ent.Cont:IsValid() then WinLink( ent.Cont, self.Entity ) end
	end
end

function ENT:WinLink( Cont, Pod )
			local Offset = {0, 0, 10}
			local AOffset = 0
			local ZVecAngle = Angle(0, 90, 0)
			local PodVec = (Pod:GetForward())
			PodVec:Rotate(ZVecAngle)
			if Cont.Wh[i]["Side"] == "Left" then
				AOffset = 90
				local Ang = (PodVec:Angle())
				Ang:RotateAroundAxis( PodVec, AOffset )
				self.Entity:SetAngles( Ang )
			else
				AOffset = -90
				local Ang = ((PodVec*-1):Angle())
				Ang:RotateAroundAxis( PodVec, AOffset )
				self.Entity:SetAngles( Ang )
			end
			self.Entity:SetPos(Pod:GetPos() + Pod:GetForward() * (Cont.Wh[i]["Pos"].x + Offset[1]) + Pod:GetRight() * (Cont.Wh[i]["Pos"].y + Offset[2]) + Pod:GetUp() * (Cont.Wh[i]["Pos"].z + Offset[3]))
			local LPos = nil
			local Cons = nil
			LPos = Vector(0,0,0)
			Cons = constraint.Weld( Pod, self.Entity )
			LPos = self.Entity:WorldToLocal(self.Entity:GetPos() + self.Entity:GetUp() * 10)
			Cons = constraint.Weld( Pod, self.Entity)
			self.Pod = Pod
			self.Cont = Cont
			self.Mounted = true
			return
end