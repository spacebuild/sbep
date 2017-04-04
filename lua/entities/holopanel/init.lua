AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Slyfo/util_tracker.mdl" )
		self:SetName("HoloPanel")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
	
	local V,N,A = "VECTOR","NORMAL","ANGLE"
	
	local inNames = {"TestValue1","TestValue2","TestValue3"}
	local inTypes = {N,N,V}
	self.Inputs = WireLib.CreateSpecialInputs( self.Entity,inNames,inTypes)
	
	local outNames = {"TestValue1","TestValue2","TestValue3","TestValue4"}
	local outTypes = {N,N,V,N}
	local outDescs = {}
	self.Outputs = WireLib.CreateSpecialOutputs( self.Entity,outNames,outTypes,outDescs)
	--PrintTable(self.Outputs)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
end

function ENT:TriggerInput(iname, value)
	local rp = RecipientFilter()
	rp:AddAllPlayers()
	umsg.Start("HoloEleIn", rp )
	umsg.Entity( self )
	umsg.String( iname )
	local T = type(value)
	if T == "number" then
		umsg.Short( 1 )
		umsg.Short( value )
	elseif T == "Vector" then
		umsg.Short( 2 )
		umsg.Vector( value )
	end
	umsg.End()
	
	--print("Input triggered...")
end

function ENT:Think()

end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	local ent = ents.Create( "HoloPanel" )
		ent:Spawn()
		ent:Initialize()
		ent:Activate()
	ent:SetPos( tr.HitPos + tr.HitNormal * -1 * ent:OBBMins().z )
	
	return ent
end

function ENT:Use( activator, caller )
	return false
	--if !self:GetActive() then
	--	self:SetActive( true )
	--end
end

local function HoloEleOut(player,commandName,args)
	local index, name, type, x,y,z = unpack( args )
	local Panel = ents.GetByIndex(tonumber(index))
	if Panel and Panel:IsValid() then
		if type == "number" then
			--print(tonumber(args[4]))
			Wire_TriggerOutput( Panel, name, tonumber(x) )
		elseif type == "Vector" then
			local Vec = Vector(tonumber(x),tonumber(y),tonumber(z))
			--print(Vec)
			Wire_TriggerOutput( Panel, name, Vec )
		end
	end
	--print(args[1],args[2],args[3],args[4],args[5],args[6])
end 
concommand.Add("HoloEleOut",HoloEleOut) 
