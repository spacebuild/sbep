
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:IsHangar()
	return true
end

function ENT:Initialize()

	self.Entity:SetName( self.HangarName )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	//self.Entity:InitDock()
    self.Entity:SetKeyValue("rendercolor", "255 255 255")
	if WireAddon then
		SBEP.Hangar.MakeWire(self)
	end
end

function ENT:TriggerInput(iname, value)
	SBEP.Hangar.TriggerInput(self,iname,value)
end

function ENT:SetLaunchSpeed(value)
	self.LaunchSpeed = value
end

function ENT:SetDisabled(bay,value)
	if (value != 0) then
		bay.disabled = true
	else
		bay.disabled = false
	end
end

function ENT:Eject(bay,value)
	if (value != 0) then
		if bay.ship then
			bay.ship.Cont.Launchy = true
		end
	end
end

function ENT:Think()
	SBEP.Hangar.Think(self)
end

function ENT:Touch( ent )
	SBEP.Hangar.Touch(self,ent)
end

function ENT:BuildDupeInfo()
	return WireLib.BuildDupeInfo(self.Entity)
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID )
end

function ENT:PreEntityCopy()
	//build the DupeInfo table and save it as an entity mod
	if WireAddon then
		local DupeInfo = self:BuildDupeInfo()
		if(DupeInfo) then
			duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",DupeInfo)
		end
	end
	local DupeInfo = {}
	DupeInfo["ships"] = {}
	DupeInfo["EPs"] = {}
	for k, v in pairs(self.Bay) do
		if (v.ship) and (v.ship:IsValid()) then
			DupeInfo["ships"][k] = v.ship:EntIndex()
		end
		if (v.EP) and (v.EP:IsValid()) then
			DupeInfo["EPs"][k] = v.EP:EntIndex()
		end
	end
	duplicator.StoreEntityModifier(self.Entity,"HangarDupeInfo",DupeInfo)
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
	//apply the DupeInfo
	if(Ent.EntityMods) then
		if (Ent.EntityMods.WireDupeInfo) then
			Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
		end
		if (Ent.EntityMods.HangarDupeInfo) then
			--PrintTable(Ent.EntityMods.HangarDupeInfo)
			for k, v in pairs(Ent.EntityMods.HangarDupeInfo.ships) do
				self.Bay[k]["ship"] = CreatedEntities[v]
				if (!self.Bay[k]["ship"]) then
					self.Bay[k]["ship"] = ents.GetByIndex(v)
				end
				--PrintTable(self.Bay)
			end
			for k, v in pairs(Ent.EntityMods.HangarDupeInfo.EPs) do
				self.Bay[k]["EP"] = CreatedEntities[v]
				if (!self.Bay[k]["EP"]) then
					self.Bay[k]["EP"] = ents.GetByIndex(v)
				end
			end
		end
	end
end
