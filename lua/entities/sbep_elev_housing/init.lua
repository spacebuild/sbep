AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" ) 

local LMT = {}
LMT.S = {
		[ "B" 	 ] = { model = "models/smallbridge/elevators_small/sbselevb.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,0} } ,
		[ "BE" 	 ] = { model = "models/smallbridge/elevators_small/sbselevbe.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,1} } ,
		[ "BEdh" ] = { model = "models/smallbridge/elevators_small/sbselevbedh.mdl" , ZUD = 195.3 	, ZDD =  65.1 	, AT = {0,1,0,1} , SD = { IsDH = true } },
		[ "BEdw" ] = { model = "models/smallbridge/elevators_small/sbselevbedw.mdl" , ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,1} } ,
		[ "BR" 	 ] = { model = "models/smallbridge/elevators_small/sbselevbr.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,0,0} } ,
		[ "BT" 	 ] = { model = "models/smallbridge/elevators_small/sbselevbt.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,0} } ,
		[ "BX" 	 ] = { model = "models/smallbridge/elevators_small/sbselevbx.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,1} } ,

		[ "M" 	 ] = { model = "models/smallbridge/elevators_small/sbselevm.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,0} } ,
		[ "ME" 	 ] = { model = "models/smallbridge/elevators_small/sbselevme.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,1} } ,
		[ "MEdh" ] = { model = "models/smallbridge/elevators_small/sbselevmedh.mdl" , ZUD = 195.3 	, ZDD =  65.1 	, AT = {0,1,0,1} , SD = { IsDH = true } },
		[ "MEdw" ] = { model = "models/smallbridge/elevators_small/sbselevmedw.mdl" , ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,1} } ,
		[ "MR" 	 ] = { model = "models/smallbridge/elevators_small/sbselevmr.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,0,0} } ,
		[ "MT" 	 ] = { model = "models/smallbridge/elevators_small/sbselevmt.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,0} } ,
		[ "MX" 	 ] = { model = "models/smallbridge/elevators_small/sbselevmx.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,1} } ,

		[ "T" 	 ] = { model = "models/smallbridge/elevators_small/sbselevt.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,0} } ,
		[ "TE" 	 ] = { model = "models/smallbridge/elevators_small/sbselevte.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,1} } ,
		[ "TEdh" ] = { model = "models/smallbridge/elevators_small/sbselevtedh.mdl" , ZUD = 195.3 	, ZDD =  65.1 	, AT = {0,1,0,1} , SD = { IsDH = true } },
		[ "TEdw" ] = { model = "models/smallbridge/elevators_small/sbselevtedw.mdl" , ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,1} } ,
		[ "TR" 	 ] = { model = "models/smallbridge/elevators_small/sbselevtr.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,0,0} } ,
		[ "TT" 	 ] = { model = "models/smallbridge/elevators_small/sbselevtt.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,0} } ,
		[ "TX" 	 ] = { model = "models/smallbridge/elevators_small/sbselevtx.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,1} } ,

		[ "S" 	 ] = { model = "models/smallbridge/elevators_small/sbselevs.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,0,0,0} , SD = { IsShaft = true } },
		[ "S2" 	 ] = { model = "models/smallbridge/elevators_small/sbselevs2.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,0,0,0} , SD = { IsShaft = true } },

		[ "BV" 	 ] = { model = "models/smallbridge/station parts/sbbridgevisorb.mdl", ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,0,0,0} , SD = { IsVisor = true , IsSpecial = true } },
		[ "MV" 	 ] = { model = "models/smallbridge/station parts/sbbridgevisorm.mdl", ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,0,0,0} , SD = { IsVisor = true , IsSpecial = true } },
		[ "TV" 	 ] = { model = "models/smallbridge/station parts/sbbridgevisort.mdl", ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,0,0,0} , SD = { IsVisor = true , IsSpecial = true } },

		[ "H" 	 ] = { model = "models/smallbridge/station parts/sbhuble.mdl" 		, ZUD = 195.3 	, ZDD = 195.3 	, AT = {0,0,0,0} , SD = { IsHub = true , IsSpecial = true , MultiFloorTable = { 0 , 130.2 , 260.4 } } }
			}

LMT.L = {
		[ "B" 	 ] = { model = "models/smallbridge/elevators_large/sblelevb.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,0,0,1} } ,
		[ "BE" 	 ] = { model = "models/smallbridge/elevators_large/sblelevbe.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,1} } ,
		[ "BEdh" ] = { model = "models/smallbridge/elevators_large/sblelevbedh.mdl" , ZUD = 195.3 	, ZDD =  65.1 	, AT = {0,1,0,1} , SD = { IsDH = true } },
		[ "BR" 	 ] = { model = "models/smallbridge/elevators_large/sblelevbr.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,0,0} } ,
		[ "BT" 	 ] = { model = "models/smallbridge/elevators_large/sblelevbt.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,0} } ,
		[ "BX" 	 ] = { model = "models/smallbridge/elevators_large/sblelevbx.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,1} } ,

		[ "M" 	 ] = { model = "models/smallbridge/elevators_large/sblelevm.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,0,0,1} } ,
		[ "ME" 	 ] = { model = "models/smallbridge/elevators_large/sblelevme.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,1} } ,
		[ "MEdh" ] = { model = "models/smallbridge/elevators_large/sblelevmedh.mdl" , ZUD = 195.3 	, ZDD =  65.1 	, AT = {0,1,0,1} , SD = { IsDH = true } },
		[ "MR" 	 ] = { model = "models/smallbridge/elevators_large/sblelevmr.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,0,0} } ,
		[ "MT" 	 ] = { model = "models/smallbridge/elevators_large/sblelevmt.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,0} } ,
		[ "MX" 	 ] = { model = "models/smallbridge/elevators_large/sblelevmx.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,1} } ,

		[ "T" 	 ] = { model = "models/smallbridge/elevators_large/sblelevt.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,0,0,1} } ,
		[ "TE" 	 ] = { model = "models/smallbridge/elevators_large/sblelevte.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,1,0,1} } ,
		[ "TEdh" ] = { model = "models/smallbridge/elevators_large/sblelevtedh.mdl" , ZUD = 195.3 	, ZDD =  65.1 	, AT = {0,1,0,1} , SD = { IsDH = true } },
		[ "TR" 	 ] = { model = "models/smallbridge/elevators_large/sblelevtr.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,0,0} } ,
		[ "TT" 	 ] = { model = "models/smallbridge/elevators_large/sblelevtt.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,0} } ,
		[ "TX" 	 ] = { model = "models/smallbridge/elevators_large/sblelevtx.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {1,1,1,1} } ,

		[ "S" 	 ] = { model = "models/smallbridge/elevators_large/sblelevs.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,0,0,0} , SD = { IsShaft = true } },
		[ "S2" 	 ] = { model = "models/smallbridge/elevators_large/sblelevs2.mdl" 	, ZUD =  65.1 	, ZDD =  65.1 	, AT = {0,0,0,0} , SD = { IsShaft = true } }
			}

ENT.WireDebugName = "SBEP Elevator Housing"

for s,M in pairs( LMT ) do
	for t,D in pairs( M ) do
		list.Set( "SBEP_LiftHousingModels" , string.lower( D.model ) , { t , s } )
	end
end

function ENT:Initialize()

	self:SetUseType( SIMPLE_USE )
	
	self.PartData 		= {}
	self.PartData.HO		= 0
	self.PartData.Pitch	= 0
	self.PartData.Yaw		= 0
	self.PartData.Roll	= 0

	self.Entity:PhysicsInitialize()

end

function ENT:PhysicsInitialize()

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
		
	local phys = self.Entity:GetPhysicsObject()  	
	if IsValid(phys) then
		phys:EnableMotion( false )
		phys:Wake() 
	end

end

function ENT:MakeWire( bAdjust )
	
	if(not WireAddon) then return end

	if self.PartData.SD.MultiFloorTable then
		self.PartData.WI = {} --Wire Inputs
		for k,v in ipairs( self.PartData.SD.MultiFloorTable ) do
			self.PartData.WI[k] = "Call "..tostring( k )
		end
	elseif !self.PartData.SD.IsShaft then
		self.PartData.WI = { "Call" }
	end

	if bAdjust then
		self.Inputs = Wire_AdjustInputs(self.Entity, self.PartData.WI )
		--Wire_AdjustInputs(self.Entity, self.PartData.WI )
	else
		self.Inputs = Wire_CreateInputs(self.Entity, self.PartData.WI )
		--Wire_CreateInputs(self.Entity, self.PartData.WI )
	end
end

function ENT:TriggerInput(k,v)
	if table.getn( self.PartData.WI ) > 1 then
		for m,n in ipairs( self.PartData.WI ) do
			if k == n and v == 1 then
				if !self.PartData.SD.MultiFloorTable and self.Cont and self.Cont:IsValid() then
					self.Entity:CallLift( m )
				end
			end
		end
	elseif k == "Call" and v == 1 then
		if !self.PartData.SD.MultiFloorTable and self.Cont and self.Cont:IsValid() then
			self.Entity:CallLift()
		end
	end
end

function ENT:SetPartType( type )
	if self.PartData.T == type then return end

	local data = LMT[ self.Cont.Size[1] ][ type ]
	if !data then return end
	self.PartData.SD 	= {}
	self.PartData 	= table.Merge( self.PartData , data )
	self.PartData.T 	= type
	self.PartData.TC 	= string.Left( type , 1)
	self.PartData.TF 	= string.sub( type , 2)
	self.PartData.AT 	= table.Copy( self.PartData.AT )
	self.PartData.Usable  = self.Cont.Usable and !self.PartData.SD.IsShaft and !self.PartData.SD.MultiFloorTable
	self.Entity:SetModel( self.PartData.model )
	self.Entity:CheckSkin( self.Cont.Skin )
end

function ENT:GetPartType()
	return self.PartData.T
end

function ENT:SetPartClass( class )
	local t = class..string.sub( self.Entity:GetPartType() , 2 )
	if LMT[ self.Cont.Size[1] ][ t ] then
		self.Entity:SetPartType( t )
	end
end

function ENT:GetPartClass()
	return self.PartData.TC
end

function ENT:SetPartForm( form )
	local t = string.Left( self:GetPartType() , 1 )..form
	if LMT[ self.Cont.Size[1] ][ t ] then
		self.Entity:SetPartType( t )
	end
end

function ENT:GetPartForm()
	return self.PartData.TF
end

function ENT:UpdateHeightOffsets()
	if self.PartData.PN > 1 then
		local P1 = self.Cont.PartTable[self.PartData.PN - 1].PartData
			local C1 = math.Clamp( P1.Roll , 0 , 1 )
			local C2 = math.abs( C1 - 1 )
		local P2 = self.PartData
			local C3 = math.Clamp( P2.Roll , 0 , 1 )
			local C4 = math.abs( C3 - 1 )
		P2.HO = P1.HO + (C1*P1.ZDD + C2*P1.ZUD) + (C3*P2.ZUD + C4*P2.ZDD)
	else
		local P2 = self.PartData
			local C3 = math.Clamp( P2.Roll , 0 , 1 )
			local C4 = math.abs( C3 - 1 )
		P2.HO = C3*( P2.ZUD - P2.ZDD )
	end
	self.Entity:RefreshPos()	
end

function ENT:RefreshPos()
	self.Entity:SetPos( self.Cont:LocalToWorld( Vector(0,0, self.PartData.HO + 60.45 ) ) )
end

function ENT:RefreshAng()
	self.Entity:SetAngles( Angle( self.PartData.Pitch , self.PartData.Yaw , self.PartData.Roll ) )
end

function ENT:RotatePartPitch( pitch )
	self.PartData.Pitch = (self.PartData.Pitch + pitch) % 360
	self.Entity:RefreshAng()
end

function ENT:RotatePartYaw( yaw )
	self.PartData.Yaw = (self.PartData.Yaw + yaw) % 360
	self.Entity:RefreshAng()
end

function ENT:RotatePartRoll( roll )
	self.PartData.Roll = (self.PartData.Roll + roll) % 360
	self.Entity:RefreshAng()
end

function ENT:Invert()
	self.PartData.Roll = (self.PartData.Roll + 180) % 360
	self.PartData.Inv = !self.PartData.Inv
	self.Entity:RefreshAng()
end

function ENT:CheckSkin( skin )
	if self.Entity:SkinCount() > 5 then
		self.Entity:SetSkin( skin * 2 )
	else
		self.Entity:SetSkin( skin )
	end
end

function ENT:CallLift( m )
	if m then
		self.Cont:AddCallFloorNum( self.PartData.FN[m] )
	else
		self.Cont:AddCallFloorNum( self.PartData.FN    )
	end
end

function ENT:Use()
	if !self.PartData.Usable or self.PartData.SD.MultiFloorTable or !self.Cont or !self.Cont:IsValid() then return end
	self.Entity:CallLift()
end

function ENT:PreEntityCopy()
	local DI = {}
		DI.PartData	= self.PartData
		DI.Cont	= self.Cont:EntIndex()
		if self.PartData.FloorDoorTable then
			DI.FloorDoorTable = {}
			for n,D in ipairs( self.PartData.FloorDoorTable ) do
				DI.FloorDoorTable[n] = D:EntIndex()
			end
		end
	if WireAddon then
		DI.WireData = WireLib.BuildDupeInfo( self.Entity )
	end
	duplicator.StoreEntityModifier(self, "SBEPLP", DI)
end
duplicator.RegisterEntityModifier( "SBEPLP" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	local DI = Ent.EntityMods.SBEPLP
	self.PartData		= DI.PartData
	self.Cont	= CreatedEntities[DI.Cont]
	if DI.FloorDoorTable then
		for n,K in ipairs( DI.FloorDoorTable ) do
			self.PartData.FloorDoorTable[n] = CreatedEntities[K]
		end
	end
	self:MakeWire()
	if(Ent.EntityMods and DI.WireData and WireAddon) then
		WireLib.ApplyDupeInfo( pl, Ent, DI.WireData, function(id) return CreatedEntities[id] end)
	end
end