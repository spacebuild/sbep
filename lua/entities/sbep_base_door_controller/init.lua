AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" ) 

local MST = list.Get( "SBEP_DoorControllerModels" )

ENT.WireDebugName = "SBEP Door Controller"

function ENT:Initialize()	
	self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		local phys = self:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:Wake() 
			phys:EnableMotion( false )
		end
	self.SpawnTime = CurTime()
end

function ENT:MakeWire( bWire , bAdjust )

	self.EnableWire = bWire
	if !self.DT then return end

	self.SBEPWireInputs = {}
	self.SBEPWireOutputs = {}
	
	for k,v in ipairs( self.DT ) do
		table.insert(self.SBEPWireInputs , "Open_"..tostring( k ) )
		table.insert(self.SBEPWireInputs , "Lock_"..tostring( k ) )
		
		table.insert(self.SBEPWireOutputs , "Open_"..tostring( k ) )
		table.insert(self.SBEPWireOutputs , "Locked_"..tostring( k ) )
	end

	if self.EnableUse then
		table.insert(self.SBEPWireInputs , "Disable Use" )
	end

	if bAdjust then
		Wire_AdjustInputs(self, self.SBEPWireInputs )
		Wire_AdjustOutputs(self, self.SBEPWireOutputs)
	else
		self.Inputs = Wire_CreateInputs(self, self.SBEPWireInputs )
		self.Outputs = Wire_CreateOutputs(self, self.SBEPWireOutputs)
	end
end

function ENT:SetUsable( bUsable )
	self.EnableUse = bUsable
end

function ENT:AddDoors()
	local doors = MST[ string.lower(self:GetModel()) ]
	if !doors then return false end
	self.DT = {}
	for n,Data in ipairs( doors ) do
		local D = ents.Create( "sbep_base_door" )
			D:Spawn()
			D:Initialize()
			D:SetDoorType( Data.type )
			D:Attach( self , Data.V , Data.A )
			D:SetController( self , n )
		table.insert( self.DT , D )
	end
end
function ENT:Trigger()
	if !self.EnableUse or self.DisableUse then return end

	for k,v in pairs( self.DT ) do
		if !v.Locked then
			v.OpenTrigger = !v.OpenTrigger
		end
	end
end
function ENT:Use( activator, caller )
	self:Trigger()
end

function ENT:Think()
	local skin = self:GetSkin()
	if self:SkinCount() > 5 then
		self.Skin = math.floor( skin / 2 )
	else
		self.Skin = skin
	end

	self:NextThink( CurTime() + 1 )
	return true
end

function ENT:TriggerInput(k,v)
	
	if k == "Disable Use" then
		if v > 0 then
			self.DisableUse = true
		else
			self.DisableUse = false
		end
	end
	
	for m,n in ipairs(self.DT) do
		if (k == "Lock_"..tostring(m)) then
			if v > 0 then
				n.OpenTrigger = false
				n.Locked = true
				WireLib.TriggerOutput(self,"Locked_"..tostring(m),1)
			else		
				n.Locked = false
				WireLib.TriggerOutput(self,"Locked_"..tostring(m),0)
			end
		end
		
		if k == "Open_"..tostring(m) then
			if !n.Locked then
				if v > 0 then
					n.OpenTrigger = true
				else
					n.OpenTrigger = false
				end
			end
		end
	end
end

function ENT:PreEntityCopy()
	local DI = {}

	DI.EnableWire = self.EnableWire
	DI.EnableUse 	= self.EnableUse
	DI.DT = {}
	for m,n in ipairs(self.DT) do
		DI.DT[m] = n:EntIndex()
	end
	
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self )
	end
	
	duplicator.StoreEntityModifier(self, "SBEPDC", DI)
end
duplicator.RegisterEntityModifier( "SBEPDC" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPDC

	self.EnableWire = DI.EnableWire
	self.EnableUse 	= DI.EnableUse
	self.DT			= {}
	for n,I in ipairs( DI.DT ) do
		if I then
			self.DT[n] = CreatedEntities[I]
		end
	end
	self:MakeWire()
	
	if(Ent.EntityMods and Ent.EntityMods.SBEPDC.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPDC.WireData, function(id) return CreatedEntities[id] end)
	end

end
