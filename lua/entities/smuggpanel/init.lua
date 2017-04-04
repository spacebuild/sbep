
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
util.PrecacheSound( "SB/Gattling2.wav" )

function ENT:Initialize()

	self.Entity:SetModel( "models/Slyfo/smuggler_top.mdl" ) 
	self.Entity:SetName("SmugglerPanel")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetRenderMode(4)
	self.Inputs = Wire_CreateInputs( self.Entity, { "Open", "OpenMode", "X", "Y", "Z" } )
	
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
	
	self.Cont = self.Entity
	self.COp = false
	self.Mode = 0
	
	self.OTime = 0
	self.BTime = 0
	self.RTime = 0
	self.CHeight = 0
	self.CRotate = 0
	self.TogC = 0
	self.AutoCT = 0
	self.AutoC = false
	self.X = 0
	self.Y = 0
	self.Z = 0
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "SmugGPanel" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Open") then
		if (value > 0) then
			if !self.COp then
				self.Entity:Open(self.Mode)
			end
		else
			if self.COp then
				self.Entity:Close(self.Mode)
			end
		end
		
	elseif (iname == "OpenMode") then
		self.Mode = value
		
	elseif (iname == "X") then
		self.X = value
		
	elseif (iname == "Y") then
		self.Y = value
		
	elseif (iname == "Z") then
		self.Z = value
			
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	
	if self.AutoC and CurTime() > self.AutoCT then
		self.Entity:Close(self.Mode)
		self.AutoC = false
	end
	
	if self.Mode == 1 or self.Mode == 2 then
		local A = math.Clamp( self.OTime - CurTime(), 0, 1 )
		local F = 0
		local S = 0
		if self.COp then
			F = 0
			S = 255
		else
			F = 255
			S = 0
		end
		local Alph = Lerp(A,F,S)
		self.Entity:SetColor(Color(255,255,255,Alph))
		
		if self.Mode == 2 and self.BTime > CurTime() then
			if self.Panel and self.Panel:IsValid() then
				self.Panel:GetPhysicsObject():SetVelocity(self.Entity:GetRight() * self.X + self.Entity:GetForward() * self.Y + self.Entity:GetUp() * self.Z)
			end
		end
	end
	
	if self.Panel and self.Panel:IsValid() and !self.Panel.Blasted then
		self.Panel:GetPhysicsObject():SetVelocity(self.Entity:GetRight() * self.X + self.Entity:GetForward() * self.Y + self.Entity:GetUp() * self.Z)
		self.Panel.Blasted = true
	end

	self.Entity:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )
--	if CurTime() > self.TogC then
--		if self.COp then
--			self.Entity:Close(self.Mode)
--		else
--			self.Entity:Open(self.Mode)
--			self.AutoCT = CurTime() + 15
--			self.AutoC = true
--		end
--		self.TogC = CurTime() + 4
--	end
--
end

--Modes: 0 = fade, 1 = slow fade, 2 = blast, 3 = slide, 4 = rotate
function ENT:Open( mode )
	if mode == 0 then
		self.Entity:SetColor(Color(255,255,255,50))
		--self.Entity:SetParent(self.Pod)
		self.Entity:SetNotSolid( true )
		self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self.COp = true
	elseif mode == 1 then
		self.OTime = CurTime() + 1	
		--self.Entity:SetParent(self.Pod)
		self.Entity:SetNotSolid( true )
		self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self.COp = true
	elseif mode == 2 then
		self.Entity:SetColor(Color(255,255,255,0))
		self.Entity:SetNotSolid( true )
		self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self.COp = true
				
		if self.Panel and self.Panel:IsValid() then
			self.Panel:Remove()
		end
		
		local Panel = ents.Create( "prop_physics" )
		
		Panel:SetModel( self.Entity:GetModel() )
		Panel:SetPos( self.Entity:GetPos() + self.Entity:GetUp() * 10 ) 
		Panel:SetAngles( self.Entity:GetAngles() )
		Panel:Spawn()
		--self.CamC:Initialize()
		Panel:Activate()
		Panel:GetPhysicsObject():SetVelocity(self.Entity:GetUp() * 5000)
		Panel:GetPhysicsObject():EnableDrag(false)
		Panel:Fire("kill", "", 20)
		Panel.Blasted = false
		
		self.Panel = Panel
		
		self.BTime = CurTime() + 0.05
		
	end

end

function ENT:Close( mode )
	self.AutoC = false
	--self.Entity:SetParent(self.Pod)
	if mode == 0 then
		self.Entity:SetColor(Color(255,255,255,255))
		self.Entity:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		self.Entity:SetNotSolid( false )
		self.COp = false
	elseif mode == 1 then
		self.OTime = CurTime() + 1	
		self.Entity:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		self.Entity:SetNotSolid( false )
		self.COp = false
	elseif mode == 2 then
		self.OTime = CurTime() + 1
		self.Entity:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		self.Entity:SetNotSolid( false )
		self.COp = false
	end
end