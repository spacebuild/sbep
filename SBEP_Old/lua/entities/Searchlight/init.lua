AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local ZeroVector = Vector(0,0,0)

function ENT:Initialize()

	self:SetModel( "models/Slyfo/searchlight.mdl" )
	self:SetName("Mine")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetMaterial("models/props_combine/combinethumper002")
	self.Inputs = Wire_CreateInputs( self, { "On", "Searching" } )
	local outNames = {"TargetFound","Target","X","Y","Z","Vector"}
	local outTypes = {"NORMAL","ENTITY","NORMAL","NORMAL","NORMAL","VECTOR"}
	local outDescs = {}
	self.Outputs = WireLib.CreateSpecialOutputs( self,outNames,outTypes,outDescs)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end
	
    --self:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self:GetPhysicsObject()
	self.CAng = self:GetAngles()
	
	self.Searching = false
end
function ENT:TriggerInput(iname, value)		
	
	if (iname == "On") then
		if (value > 0) then
			self.Active = true
			self:SetActive( true )
		else
			self.Active = false
			self:SetActive( false )
		end
		
	elseif (iname == "Searching") then
		if (value > 0) then
			self.Searching = true
		else
			self.Searching = false
		end
		
	end	
end

function ENT:Think()
	-- THE FOLLOWING CODE WAS NICKED FROM THE LS3 LAMP. I TAKE NO CREDIT FOR IT! --
	if self.Active and !self.flashlight then
		--local angForward = self:GetAngles() + Angle( 90, 0, 0 )
		self.flashlight = ents.Create( "env_projectedtexture" )
		self.flashlight:SetParent( self )

		-- The local positions are the offsets from parent..
		self.flashlight:SetLocalPos( Vector(35,0,0) )
		self.flashlight:SetLocalAngles( Angle(0,0,0) )

		-- Looks like only one flashlight can have shadows enabled!
		self.flashlight:SetKeyValue( "enableshadows", 1 )
		self.flashlight:SetKeyValue( "farz", 2048 )
		self.flashlight:SetKeyValue( "nearz", 8 )

		--the size of the light
		self.flashlight:SetKeyValue( "lightfov", 70 )

		-- Color.. white is default
		self.flashlight:SetKeyValue( "lightcolor", "255 255 255" )
		self.flashlight:Spawn()
		self.flashlight:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )
	elseif !self.Active and self.flashlight then
		SafeRemoveEntity( self.flashlight )
		self.flashlight = nil
	end
	-- END OF CODE THEFT --
	
	if self.Active and self.Searching then
		if self.Target and self.Target:IsValid() then
			local trace = {}
			trace.start = self:GetPos() + self:GetForward() * 10
			trace.endpos = self:GetPos() + self:GetForward() * 5000
			if self.Pod and self.Pod:IsValid() then
				trace.filter = { self, self.Pod }
			else
				trace.filter = self
			end
			trace.mask = -1
			local tr = util.TraceLine( trace )
			local LWidth = self:GetPos():Distance(tr.HitPos) * math.tan(75) -- Once again, Hysteria comes to my rescue :)
			--print(LWidth)
			local targets = ents.FindInSphere( tr.HitPos, LWidth )
			--local targets = ents.FindInCone( self:GetPos(), self:GetForward(), 4000, 360)
			if table.HasValue( targets, self.Target ) then
				local trace = {}
				trace.start = self:GetPos() + self:GetForward() * 10
				trace.endpos = self.Target:GetPos()
				trace.filter = self
				trace.mask = -1
				local tr = util.TraceLine( trace )
				local Dist = tr.HitPos:Distance(self.Target:GetPos())
				if Dist < 50 then
					local Pos = self.Target:GetPos()
					Wire_TriggerOutput(self, "TargetFound", 1)
					Wire_TriggerOutput(self, "Target", self.Target)
					Wire_TriggerOutput(self, "X", Pos.x)
					Wire_TriggerOutput(self, "Y", Pos.y)
					Wire_TriggerOutput(self, "Z", Pos.z)
					Wire_TriggerOutput(self, "Vector",Pos)
				end
			else
				self.Target = nil
			end
		else
			Wire_TriggerOutput(self, "TargetFound", 0)
			Wire_TriggerOutput(self, "Target", WireLib.DT.ENTITY.Zero)
			Wire_TriggerOutput(self, "X", 0)
			Wire_TriggerOutput(self, "Y", 0)
			Wire_TriggerOutput(self, "Z", 0)
			Wire_TriggerOutput(self, "Vector",ZeroVector)
			
			--I really wish ents.FindInCone was working properly...
			local trace = {}
			trace.start = self:GetPos() + self:GetForward() * 10
			trace.endpos = self:GetPos() + self:GetForward() * 5000
			trace.filter = self
			trace.mask = -1
			local tr = util.TraceLine( trace )
			local LWidth = self:GetPos():Distance(tr.HitPos) * math.tan(70)
			--print(LWidth)
			local targets = ents.FindInSphere( tr.HitPos, LWidth )
			--local targets = ents.FindInCone( self:GetPos(), self:GetForward(), 4000, 360)
					
			for _,i in pairs(targets) do
				if i:IsPlayer() or i:IsNPC() then
					local trace = {}
					trace.start = self:GetPos() + self:GetForward() * 10
					trace.endpos = i:GetPos()
					trace.filter = self
					trace.mask = -1
					local tr = util.TraceLine( trace )
					local Dist = tr.HitPos:Distance(i:GetPos())
					if Dist < 50 then
						self.Target = i
						return
					end
				end
			end			
		end
	else
		Wire_TriggerOutput(self, "TargetFound", 0)
		Wire_TriggerOutput(self, "Target", WireLib.DT.ENTITY.Zero)
		Wire_TriggerOutput(self, "X", 0)
		Wire_TriggerOutput(self, "Y", 0)
		Wire_TriggerOutput(self, "Z", 0)
		Wire_TriggerOutput(self, "Vector",ZeroVector)
	end
	
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "Searchlight" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:Use( activator, caller )
	if CurTime() > self.TogC then
		self.TogC = CurTime() + 0.6
		if self:GetActive() then
			if (activator:KeyDown( IN_SPEED )) then
				self.Searching = false
			end
			self.Active = false
			self:SetActive( false )
		else
			if (activator:KeyDown( IN_SPEED )) then
				self.Searching = true
			end
			self.Active = true
			self:SetActive( true )
		end
	end
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then
			HPLink( ent.Cont, ent.Entity, self )
		end
	end
end

function ENT:HPFire()
	if self:GetActive() then
		self.Active = true
		self:SetActive( false )
	else
		self.Active = false
		self:SetActive( true )
	end
end