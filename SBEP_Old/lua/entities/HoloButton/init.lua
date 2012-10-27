AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/util_tracker.mdl" )
		self:SetName("HoloKeypad")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
	--self.Inputs = Wire_CreateInputs( self, { "Active" } )
	self.Outputs = Wire_CreateOutputs( self, { "Value", "CorrectCode", "IncorrectCode" })
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
	end
	
	self.RHoldLength = 1
	self.WHoldLength = 1
	self.InputTime = 0
end

function ENT:TriggerInput(iname, value)
	--if iname == "Active" then
	--	self:SetActive( value > 0 )
	--end	
end

function ENT:Think()
	if self.Code == self.StrValue and CurTime() - self.InputTime <= self.RHoldLength then
		Wire_TriggerOutput( self, "CorrectCode", 1 )
		Wire_TriggerOutput( self, "IncorrectCode", 0 )
	elseif self.Code ~= self.StrValue and CurTime() - self.InputTime <= self.WHoldLength then
		Wire_TriggerOutput( self, "IncorrectCode", 1 )
		Wire_TriggerOutput( self, "CorrectCode", 0 )
	else
		Wire_TriggerOutput( self, "CorrectCode", 0 )
		Wire_TriggerOutput( self, "IncorrectCode", 0 )
	end
end

function ENT:Use( activator, caller )
	return false
	--if !self:GetActive() then
	--	self:SetActive( true )
	--end
end

function HoloPadSetVar(player,commandName,args)
	local Pad = ents.GetByIndex(tonumber(args[1]))
	if Pad and Pad:IsValid() then
		Pad.KeyValue = tonumber(args[2])
		Pad.StrValue = args[2]
		Pad.InputTime = CurTime()
		Wire_TriggerOutput( Pad, "Value", Pad.KeyValue )
					
	end	 
end 
concommand.Add("HoloPadSetVar",HoloPadSetVar) 
