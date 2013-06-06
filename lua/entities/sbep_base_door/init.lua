AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" ) 

ENT.WireDebugName = "SBEP Door"

local DTT = {}

--[[DTT[ "Door Type Name (Class)"	]	= { { model = "models/examplemodelpath.mdl" 	,	UD = Length of sequence (s) , OD = time before door can be walked though   , CD = time before door becomes solid  ,
		Opening Sounds => { [time 1(s)] = "Sound 1 Name" , [time 2(s)] = "Sound 2 Name" , etc } ,
		Closing Soungs   => { [time 1(s)] = "Sound 1 Name" , [time 2(s)] = "Sound 2 Name" , etc } }]]

DTT[ "Door_AnimS1"	]	= { { model = "models/SmallBridge/SEnts/SBADoorS1a.mdl" ,	UD = 3 , OD = 2   , CD = 1 	,
		OS = { [0] = "Doors.Move14" , [1.45] = "Doors.FullOpen8" , [2.75] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.45] = "Doors.FullOpen8" , [2.75] = "Doors.FullOpen9" } } ,
							{ model = "models/SmallBridge/SEnts/SBADoorS1.mdl" 	,	UD = 3 , OD = 2   , CD = 1 	,
		OS = { [0] = "Doors.Move14" , [1.45] = "Doors.FullOpen8" , [2.75] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.45] = "Doors.FullOpen8" , [2.75] = "Doors.FullOpen9" } } ,
			{ model = "models/SmallBridge/SEnts/forcedoor.mdl" 	,	UD = 1.4 , OD = 0.52 , CD = 0.88 	,
		OS = { [0] = "TriggerSuperArmor.DoneCharging" , [0.40] = "Doors.FullOpen8" , [0.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [0.40] = "Doors.FullOpen8" , [0.95] = "TriggerSuperArmor.DoneCharging" } } }

DTT[ "Door_AnimS2"	]	= { { model = "models/SmallBridge/SEnts/SBADoorS2a.mdl" 	,	UD = 2 , OD = 1   , CD = 1 	,
		OS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } } ,
							{ model = "models/SmallBridge/SEnts/SBADoorS2.mdl" 	,	UD = 2 , OD = 1   , CD = 1 	,
		OS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } } ,
					{ model = "models/SmallBridge/SEnts/SBADoorS3.mdl" 	,	UD = 2 , OD = 1.5   , CD = 0.5 	,
		OS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } } ,
			{ model = "models/SmallBridge/SEnts/forcesquare.mdl" 	,	UD = 1.4 , OD = 0.52 , CD = 0.88 	,
		OS = { [0] = "TriggerSuperArmor.DoneCharging" , [0.40] = "Doors.FullOpen8" , [0.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [0.40] = "Doors.FullOpen8" , [0.95] = "TriggerSuperArmor.DoneCharging" } } }

DTT[ "Door_AnimT"	]	= { { model = "models/SmallBridge/SEnts/SBADoorT.mdl" 	,	UD = 2 , OD = 1   , CD = 1 	,
		OS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } } ,
				{ model = "models/SmallBridge/SEnts/SBADoorT2.mdl" 	,	UD = 2 , OD = 1.5   , CD = 0.5 	,
		OS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } } ,
			{ model = "models/SmallBridge/SEnts/forcetall.mdl" 	,	UD = 1.4 , OD = 0.52 , CD = 0.88 	,
		OS = { [0] = "TriggerSuperArmor.DoneCharging" , [0.40] = "Doors.FullOpen8" , [0.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [0.40] = "Doors.FullOpen8" , [0.95] = "TriggerSuperArmor.DoneCharging" } } }

DTT[ "Door_SIris"	]	= { { model = "models/SmallBridge/SEnts/SBADoorSIrisa.mdl",	UD = 3 , OD = 2   , CD = 1 	,
		OS = { [0] = "Doors.Move14" , [0.90] = "Doors.FullOpen8" , [2.65] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen8" , [2.75] = "Doors.FullOpen9" } } ,
							{ model = "models/SmallBridge/SEnts/SBADoorSIris.mdl",	UD = 3 , OD = 2   , CD = 1 	,
		OS = { [0] = "Doors.Move14" , [0.90] = "Doors.FullOpen8" , [2.65] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen8" , [2.75] = "Doors.FullOpen9" } } }

DTT[ "Door_AnimW"	]	= { { model = "models/SmallBridge/SEnts/SBADoorWb.mdl" ,	UD = 3 , OD = 1.5 , CD = 1.5 	,
		OS = { [0] = "Doors.Move14" , [0.95] = "Doors.FullOpen8" , [1.95] = "Doors.FullOpen8" , [2.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [0.95] = "Doors.FullOpen8" , [1.95] = "Doors.FullOpen8" , [2.95] = "Doors.FullOpen9" } } ,
							{ model = "models/SmallBridge/SEnts/SBADoorWa.mdl" ,	UD = 3 , OD = 1.5 , CD = 1.5 	,
		OS = { [0] = "Doors.Move14" , [0.95] = "Doors.FullOpen8" , [1.95] = "Doors.FullOpen8" , [2.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [0.95] = "Doors.FullOpen8" , [1.95] = "Doors.FullOpen8" , [2.95] = "Doors.FullOpen9" } } ,
			{ model = "models/SmallBridge/SEnts/forcewide.mdl" 	,	UD = 1.4 , OD = 0.52 , CD = 0.88 	,
		OS = { [0] = "TriggerSuperArmor.DoneCharging" , [0.40] = "Doors.FullOpen8" , [0.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [0.40] = "Doors.FullOpen8" , [0.95] = "TriggerSuperArmor.DoneCharging" } } }

DTT[ "Door_AnimL"	]	= { { model = "models/SmallBridge/SEnts/SBADoorLa.mdl" ,	UD = 3 , OD = 1.5 , CD = 1.5 	,
		OS = { [0] = "Doors.Move14" , [0.80] = "Doors.FullOpen8" , [1.60] = "Doors.FullOpen8" , [2.40] = "Doors.FullOpen8" , [2.90] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.35] = "Doors.FullOpen8" , [2.15] = "Doors.FullOpen8" , [2.90] = "Doors.FullOpen9" } } ,
							{ model = "models/SmallBridge/SEnts/SBADoorL.mdl" ,	UD = 3 , OD = 1.5 , CD = 1.5 	,
		OS = { [0] = "Doors.Move14" , [0.80] = "Doors.FullOpen8" , [1.60] = "Doors.FullOpen8" , [2.40] = "Doors.FullOpen8" , [2.90] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.35] = "Doors.FullOpen8" , [2.15] = "Doors.FullOpen8" , [2.90] = "Doors.FullOpen9" } } }

DTT[ "Door_Insert"	]	= { { model = "models/SmallBridge/SEnts/insertdoor.mdl" ,	UD = 2 , OD = 1   , CD = 1 	,
		OS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } } }

DTT[ "Door_Sly1"	]	= { { model = "models/Slyfo/SLYAdoor1.mdl" ,	UD = 2 , OD = 0.5 , CD = 1.5 	,
		OS = { [0] = "Doors.Move14" , [1.80] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.80] = "Doors.FullOpen9" } } }

DTT[ "Door_SlyDHatch"	]	= { { model = "models/Slyfo/DoublehatchDoor.mdl" 	,	UD = 2 , OD = 1   , CD = 1 	, 
		OS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } } ,
				{ model = "models/Slyfo/DoublehatchDoor2.mdl" 	,	UD = 2 , OD = 1   , CD = 1 	, 
		OS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } } ,
				{ model = "models/Slyfo/DoublehatchDoor3.mdl" 	,	UD = 2 , OD = 2   , CD = 1 	, 
		OS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.95] = "Doors.FullOpen9" } } }

DTT[ "Door_d12MBSFrame"	]	= { { model = "models/Slyfo/d12MBDoorN.mdl" ,	UD = 5 , OD = 2 , CD = 3 	,
		OS = { [0] = "Doors.Move14" , [1.80] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.80] = "Doors.FullOpen9" } } }
		
DTT[ "Door_DBS"		]	= { { model = "models/SmallBridge/SEnts/SBADoorDBs.mdl" ,	UD = 5 , OD = 4   , CD = 1.5	,
		OS = { [0] = "Doors.Move14" , [1.30] = "Doors.FullOpen8" , [2.60] = "Doors.FullOpen8" , [3.90] = "Doors.FullOpen9" , [4.90] = "Doors.FullOpen8" } ,
		CS = { [0] = "Doors.Move14" , [2.60] = "Doors.FullOpen8" , [3.95] = "Doors.FullOpen8" , [4.90] = "Doors.FullOpen9" } } }

DTT[ "Door_Hull"	]	= { { model = "models/SmallBridge/SEnts/SBAhullDsE.mdl" ,	UD = 3 , OD = 1.5 , CD = 1.5 ,
		OS = { [0] = "Doors.Move14" , [0.95] = "Doors.FullOpen8" , [1.95] = "Doors.FullOpen8" , [2.85] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [0.95] = "Doors.FullOpen8" , [1.95] = "Doors.FullOpen8" , [2.90] = "Doors.FullOpen9" } } }

DTT[ "Door_ElevHatch_S"]	= { { model = "models/SmallBridge/SEnts/sbahatchelevs.mdl" 	,	UD = 1 , OD = 0.6 , CD = 0.4 	,
		OS = { [0] = "Doors.Move14" , [0.40] = "Doors.FullOpen8" , [0.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [0.40] = "Doors.FullOpen8" , [0.95] = "Doors.FullOpen9" } } }

DTT[ "Door_ElevHatch_L"]	= { { model = "models/SmallBridge/SEnts/sbahatchelevl.mdl" 	,	UD = 2 , OD = 0.6 , CD = 1 	,
		OS = { [0] = "Doors.Move14" , [1.00] = "Doors.FullOpen8" , [1.90] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.00] = "Doors.FullOpen8" , [1.90] = "Doors.FullOpen9" } } }
		
DTT[ "Door_ModBridge_11a"]	= { { model = "models/Cerus/Modbridge/Misc/Doors/door11a_anim.mdl" 	,	UD = 3.8 , OD = 1.5 , CD = 2 	,
		OS = { [0] = "Doors.FullOpen8" , [0.50] = "Doors.Move14"    , [1.50] = "Doors.FullOpen8" , [3.40] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" 	  , [1.50] = "Doors.FullOpen8" , [2.30] = "Doors.FullOpen9" , [3.00] = "Doors.Move14" , [3.60] = "Doors.FullOpen8" } } }
		
DTT[ "Door_ModBridge_11b"]	= { { model = "models/Cerus/Modbridge/Misc/Doors/door11b_anim.mdl" 	,	UD = 1.4 , OD = 0.52 , CD = 0.88 	,
		OS = { [0] = "TriggerSuperArmor.DoneCharging" , [0.40] = "Doors.FullOpen8" , [0.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [0.40] = "Doors.FullOpen8" , [0.95] = "TriggerSuperArmor.DoneCharging" } } }
		
DTT[ "Door_ModBridge_12b"]	= { { model = "models/Cerus/Modbridge/Misc/Doors/door12b_anim.mdl" 	,	UD = 1.4 , OD = 0.52 , CD = 0.88 	,
		OS = { [0] = "TriggerSuperArmor.DoneCharging" , [0.40] = "Doors.FullOpen8" , [0.95] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [0.40] = "Doors.FullOpen8" , [0.95] = "TriggerSuperArmor.DoneCharging" } } }
		
DTT[ "Door_ModBridge_12a"]	= { { model = "models/Cerus/Modbridge/Misc/Doors/door12a_anim.mdl" 	,	UD = 3.0 , OD = 1.5 , CD = 1.5 	,
		OS = { [0] = "Doors.Move14" , [0.90] = "Doors.FullOpen8" , [1.90] = "Doors.FullOpen8" , [2.70] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [0.90] = "Doors.FullOpen8" , [1.90] = "Doors.FullOpen8" , [2.70] = "Doors.FullOpen9" } } }
		
DTT[ "Door_ModBridge_13a"]	= { { model = "models/Cerus/Modbridge/Misc/Doors/door13a_anim.mdl" 	,	UD = 4.8 , OD = 2 , CD = 3.5 	,
		OS = { [0] = "Doors.Move14" , [1.00] = "Doors.FullOpen8" , [1.90] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.00] = "Doors.FullOpen8" , [1.90] = "Doors.FullOpen9" } } }
		
DTT[ "Door_ModBridge_23a"]	= { { model = "models/Cerus/Modbridge/Misc/Doors/door23a_anim.mdl" 	,	UD = 5.2 , OD = 4 , CD = 1.5 	,
		OS = { [0] = "Doors.Move14" 	, [0.90] = "Doors.Move14"    , [2.80] = "Doors.FullOpen8" 	, [5.00] = "Doors.FullOpen9" } , 
		CS = { [0] = "Doors.Fullopen8" 	, [2.40] = "Doors.FullOpen8" , [3.40] = "Doors.Move14" 		, [4.40] = "Doors.FullOpen8" , [5.20] = "Doors.FullOpen9" } } }
		
DTT[ "Door_ModBridge_33a"]	= { { model = "models/Cerus/Modbridge/Misc/Doors/door33a_anim.mdl" 	,	UD = 2.8 , OD = 1.6 , CD = 1.2 	,
		OS = { [0] = "Doors.Move14" , [1.00] = "Doors.FullOpen8" , [1.90] = "Doors.FullOpen9" } ,
		CS = { [0] = "Doors.Move14" , [1.00] = "Doors.FullOpen8" , [1.90] = "Doors.FullOpen9" } } }
		

		

		
		
		
DTT[ "ACC_Furnace1"]	= { { model = "models/Cerus/Modbridge/Misc/Accessories/acc_furnace1_anim.mdl" 	,	UD = 1 , OD = 0.2 , CD = 0.8 	,
		OS = { [0] = "Doors.Move14" , [1.00] = "Doors.FullOpen9" } , 
		CS = { [0] = "Doors.Fullopen8" 	, [1.00] = "Doors.Move14" } } }

function ENT:Initialize()
	self.D					= {}
	self.OpenStatus      	= false
	self.OpenTrigger		= false
	self.Locked     		= false
	self.DisableUse 		= false
	self.Timers 			= {}
	self.Index				= self:EntIndex()
	
	self:SetUseType( SIMPLE_USE )
	self:PhysicsInitialize()
end

function ENT:PhysicsInitialize()
	self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		local phys = self:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:Wake()  
			phys:EnableGravity(false)
			--phys:EnableDrag(false)
			phys:EnableMotion( true )
		end
end

function ENT:SetDoorType( strType , nClass )
	if !strType or (strType == self.type and nClass == self.DClass) then
		print( "Invalid Door Type: "..tostring(strType) )
		return false 
	end
	self:SetDoorVars( strType , nClass )
	self:SetModel( self.D.model )
	self:GetSequenceData()
	self:PhysicsInitialize()	
	self:Close()
end

function ENT:SetDoorVars( strType , nClass )
	if !strType or ( nClass and !DTT[strType][nClass] ) then return end
	self.type  = strType
	self.DClass = nClass or 1
	self.D = DTT[ strType ][ self.DClass ]
end

function GetDoorType()
	return self.type
end

function ENT:SetDoorClass( nClass )
	nClass = math.fmod( nClass - 1 , #DTT[ self.type ] ) + 1
	if DTT[ self.type ][ nClass ] then
		self:SetDoorType( self.type, nClass )
	end
end

function ENT:GetDoorClass()
	return self.DClass
end

function ENT:Attach( ent , V , A )
	self.D = self.D || {}
	
	local Voff = Vector(0,0,0)
	if V then Voff = Vector( V.x , V.y , V.z ) end
	self:SetPos( ent:LocalToWorld( Voff ) )
		
	local Aoff = Angle(0,0,0)
	if A then Aoff = Angle( A.p , A.y , A.r ) end
	self:SetAngles( ent:GetAngles() + Aoff )
		
	self.ATWeld = constraint.Weld( ent , self , 0, 0, 0, true )
	
	self:SetSkin( ent:GetSkin() )
	--self.OpenTrigger = false
	
	self.ATEnt	= ent
	self.VecOff	= Voff
	self.AngOff	= Aoff
	
	self:GetPhysicsObject():EnableMotion( true )
	ent:DeleteOnRemove( self )
end

function ENT:SetController( cont , sysnum )
	if cont and IsValid(cont) then
		self.Cont = cont
	end
	if sysnum then
		self.SDN = sysnum
	end
end

function ENT:OpenDoorSounds()
	self:EmitSound( self.D.OS[0] )
	for k,v in pairs( self.D.OS ) do
		local var = "SBEP_"..tostring( self.Index ).."_OpenSounds_"..tostring( k )
		table.insert( self.Timers , var )

		timer.Create( var , k , 1 , function()
			if( not v ) then return end
			self:EmitSound( v )
		end )
	end
end

function ENT:CloseDoorSounds()
	self:EmitSound( self.D.CS[0] )
	for k,v in pairs( self.D.CS ) do
		local var = "SBEP_"..tostring( self.Index ).."_CloseSounds_"..tostring( k )
		table.insert( self.Timers , var )

		timer.Create( var , k , 1 , function()
			if( not v ) then return end
			self:EmitSound( v )
		end )
	end
end

function ENT:GetSequenceData()
	self.OSeq = self:LookupSequence( "open" )
	self.CSeq = self:LookupSequence( "close" )
end

function ENT:Open()
	self:ResetSequence( self.OSeq )
		self:OpenDoorSounds()
		local var = "SBEP_"..tostring( self.Index ).."_OpenSolid"
		table.insert( self.Timers , var )
		
		timer.Create( var , self.D.OD , 1 , function()
			self:SetNotSolid( true )
		end)
		local var = "SBEP_"..tostring( self.Index ).."_OpenStatus"
		table.insert( self.Timers , var )
		
		timer.Create( var , self.D.UD , 1 , function()
			self.OpenStatus = true
			if self.Cont then
				WireLib.TriggerOutput(self.Cont,"Open_"..tostring( self.SDN ),1)
			end
		end)
		
	if self.Cont then
		WireLib.TriggerOutput(self.Cont,"Open_"..tostring( self.SDN ),0.5)
	end
end

function ENT:Close()
	self:ResetSequence( self.CSeq )
		self:CloseDoorSounds()
		local var = "SBEP_"..tostring( self.Index ).."_CloseSolid"
		table.insert( self.Timers , var )
		timer.Create( var , self.D.CD , 1 , function()
							self:SetNotSolid( false )
						end)
		local var = "SBEP_"..tostring( self.Index ).."_CloseStatus"
		table.insert( self.Timers , var )
		timer.Create( var , self.D.UD , 1 , function()
							self.OpenStatus = false
							if self.Cont then
								WireLib.TriggerOutput(self.Cont,"Open_"..tostring( self.SDN ),0)
							end
						end)
	if self.Cont then
		WireLib.TriggerOutput(self.Cont,"Open_"..tostring( self.SDN ),0.5)
	end
end

function ENT:Think()
	if !(self.OpenTrigger == nil) then
		if self.OpenTrigger and !self:IsOpen() and !self.OpenStatus then
			self:Open()
		elseif !self.OpenTrigger and self:IsOpen() and self.OpenStatus then
			self:Close()
		end
	end
	if (self.ATEnt and self.ATEnt:IsValid() ) and (!self.ATWeld or !self.ATWeld:IsValid()) then
		local wt = constraint.FindConstraints( self , "Weld" )
		for n,C in ipairs( wt ) do
			if C.Ent2 == self.ATEnt or C.Ent1 == self.ATEnt then
				self.ATWeld = C.Constraint
			end
		end
		if !self.Duped and (!self.ATWeld or !self.ATWeld:IsValid()) then
 			self:Attach( self.ATEnt , self.VecOff , self.AngOff )
		else
			if self.ATWeld then self.Duped=nil end
		end
	end
	if self.Cont then
		if self:GetSkin() ~= self.Cont.Skin && self.Cont.Skin then
			self:SetSkin( self.Cont.Skin )
		end
	end
	self:NextThink( CurTime() + 0.05 )
	return true
end

function ENT:IsOpen()

	if self:GetSequence() == self.OSeq then -- and  self.OpenStatus then
		return true
	elseif self:GetSequence() == self.CSeq then -- and  !self.OpenStatus then
		return false
	end	

end

function ENT:Use( activator, caller )
	if IsValid(self.Cont) and self.Cont then
		self.Cont:Trigger()
	end
end

function ENT:OnRemove()
	for k,v in ipairs( self.Timers ) do
		if timer.Exists( v ) then
			timer.Remove( v )
		end
	end
	if self.Cont and IsValid( self.Cont ) then
		table.remove( self.Cont.DT , self.SDN )
		self.Cont:MakeWire( true )
	end
end

function ENT:PreEntityCopy()
	local DI = {}
	DI.type 	= self.type
	if self.Cont then
		DI.Cont 	= self.Cont:EntIndex()
	end
	DI.D 		= self.D
	DI.ATEnt	= self.ATEnt:EntIndex()
	DI.VecOff	= self.VecOff
	DI.AngOff	= self.AngOff
	duplicator.StoreEntityModifier(self, "SBEPD", DI)
end
duplicator.RegisterEntityModifier( "SBEPD" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPD

	self.type 	= DI.type
	self.D 		= DI.D
	self.ATEnt	= CreatedEntities[ DI.ATEnt ]
	self.VecOff	= DI.VecOff
	self.AngOff	= DI.AngOff
	self.Duped	= true
	if Ent.EntityMods.SBEPD.Cont then
		self:SetController( CreatedEntities[ DI.Cont ] )
	end
	self:PhysicsInitialize()
	self:GetSequenceData()
	self:Close()
end