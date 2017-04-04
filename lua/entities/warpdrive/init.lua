
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.WireDebugName = "Warp Drive"

function ENT:SpawnFunction( ply, tr )
	local ent = ents.Create("WarpDrive") 		-- Create the entity
	ent:SetPos(tr.HitPos + Vector(0, 0, 20)) 	-- Set it to spawn 20 units over the spot you aim at when spawning it
	ent:Spawn() 								-- Spawn it
	return ent 									-- You need to return the entity to make it work
end 

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	util.PrecacheModel( "models/props_c17/consolebox03a.mdl" )
	util.PrecacheSound( "warpdrive/warp.wav" )
	util.PrecacheSound( "warpdrive/error2.wav" )
	
	--self.Entity:SetModel( "models/props_c17/consolebox03a.mdl" )
	self.Entity:SetModel( "models/Slyfo/ftl_drive.mdl" )
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:DrawShadow(false)
	
	local phys = self.Entity:GetPhysicsObject()
	
	self.NTime = 0
	
	if ( phys:IsValid() ) then 
		phys:SetMass( 100 )
		phys:EnableGravity( true )
		phys:Wake() 
	end
	self.JumpCoords = {}
	self.JumpCoords.Dest = Vector(0,0,0)
	self.SearchRadius = 512
	self.Constrained = 1
	self.Inputs = WireLib.CreateSpecialInputs( self.Entity, { "Warp", "Radius", "UnConstrained", "Destination", "Destination X", "Destination Y", "Destination Z" }, { [4] = "VECTOR"} );
end

function ENT:TriggerInput(iname, value)
	if(iname == "Radius") then
		self.SearchRadius = value
		if self.SearchRadius > 1000 then self.SearchRadius = 1000 end
	elseif(iname == "UnConstrained") then
		self.Constrained = value
	elseif(iname == "Destination X") then
		self.JumpCoords.x = value
		self.UseWhich = 1
	elseif(iname == "Destination Y") then
		self.JumpCoords.y = value
		self.UseWhich = 1
	elseif(iname == "Destination Z") then
		self.JumpCoords.z = value
		self.UseWhich = 1
	elseif(iname == "Destination") then
		self.JumpCoords.Vec = value
		self.UseWhich = 2
	elseif(iname == "Warp" and value > 0) then
		if(self.UseWhich == 1) then
			self.JumpCoords.Dest = Vector(self.JumpCoords.x, self.JumpCoords.y, self.JumpCoords.z)
		else
			self.JumpCoords.Dest = self.JumpCoords.Vec
		end
	--[[	print( timer.IsTimer( "warpdrivewaittime" ) ) ]]
		if (CurTime()-self.NTime)>7 and !timer.Exists( "warpdrivewaittime" ) and self.JumpCoords.Dest~=self.Entity:GetPos() and util.IsInWorld(self.JumpCoords.Dest) then
			self.NTime=CurTime()
			self.Entity:EmitSound("WarpDrive/warp.wav", 450, 70)
			timer.Create( "warpdrivewaittime", 1, 1, function() self.Entity:Go() timer.Destroy("warpdrivewaittime") end, self )
		else
			self.Entity:EmitSound("WarpDrive/error2.wav", 450, 70)
		end
	--[[	print( self.NTime )
		print( timer.IsTimer( "warpdrivewaittime" ) )
		print( self.JumpCoords.Dest ~= self.Entity:GetPos() )
		print( util.IsInWorld( self.JumpCoords.Dest ) ) ]]
	end
end

function ENT:Go()
	local WarpDrivePos = self.Entity:GetPos()
	
	local effectdata = EffectData()
		effectdata:SetEntity( self )
		local Dir = (self.JumpCoords.Dest - self:GetPos())
		Dir:Normalize()
		effectdata:SetOrigin( self:GetPos() + Dir * math.Clamp( self:BoundingRadius() * 5, 180, 4092 ) )
		util.Effect( "jump_out", effectdata, true, true )

		DoPropSpawnedEffect( self )

		for _, ent in pairs( ents ) do
			-- Effect out
			local effectdata = EffectData()
			effectdata:SetEntity( ent )
			effectdata:SetOrigin( self:GetPos() + Dir * math.Clamp( self:BoundingRadius() * 5, 180, 4092 ) )
			util.Effect( "jump_out", effectdata, true, true )
		end
	
	if(self.Constrained == 1) then
		self.DoneList = {}
		self.ConstrainedEnts = ents.FindInSphere( self.Entity:GetPos() , self.SearchRadius)
		for _, v in pairs(self.ConstrainedEnts) do
			if v:IsValid() and !self.DoneList[v] then
				self.ToTele = constraint.GetAllConstrainedEntities(v)
				for ent,_ in pairs(self.ToTele)do
				//PrintTable(self.ToTele)
					if not (ent.BaseClass and ent.BaseClass.ClassName=="stargate_base" and ent:OnGround()) then
						if ent:IsValid() and ( ent:GetMoveType()==6 or ent:IsPlayer() or ent:IsNPC() ) then
							self.DoneList[ent]=ent
							self:SharedJump(ent)
						end
					end
				end
			end
		end
	else
		self.ConstrainedEnts = constraint.GetAllConstrainedEntities(self.Entity)
		local Peeps = player.GetAll()
		for _, k in pairs(Peeps) do
			if(k:GetPos():Distance(self.Entity:GetPos()) <= self.SearchRadius ) then
				self:SharedJump(k)
			end
		end
		for _, ent in pairs(self.ConstrainedEnts) do
			self:SharedJump(ent)
		end
	end
--[[	print("----------------------------------------")
	PrintTable(self.ConstrainedEnts) ]]
end

function ENT:SharedJump(ent)
local WarpDrivePos = self.Entity:GetPos()
	local phys = ent:GetPhysicsObject()
	if !(ent:IsPlayer() or ent:IsNPC()) then DoPropSpawnedEffect( ent ) ent=phys end
	ent:SetPos(self.JumpCoords.Dest + (ent:GetPos() - WarpDrivePos) + Vector(0,0,10))
	if(!phys:IsMoveable())then
		phys:EnableMotion(true)
		phys:EnableMotion(false)
	end 
	phys:Wake()
end

function ENT:PreEntityCopy()
	if WireAddon then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",WireLib.BuildDupeInfo(self.Entity))
	end
end

function ENT:PostEntityPaste(ply, ent, createdEnts)
	if WireAddon then
		local emods = ent.EntityMods
		if not emods then return end
		WireLib.ApplyDupeInfo(ply, ent, emods.WireDupeInfo, function(id) return createdEnts[id] end)
	end
end