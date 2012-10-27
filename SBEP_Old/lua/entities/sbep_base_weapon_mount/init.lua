AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	if self.MountData then self:SetModel( self.MountData["model"] ) end
	if self.MountName then self:SetName( self.MountName ) end
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self.Inputs = Wire_CreateInputs( self, { "Fire" } )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self:GetPhysicsObject()

	if self.HP then
		self.HPC	= #self.HP
	else
		self.HPC	= 0
	end
	
	self:SetNetworkedInt( "HPC", self.HPC )
	
	self.Cont = self
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			self.Active = true
		else
			self.Active = false
		end
			
	end
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
	if self.PilotSeat then
		return activator:EnterVehicle( self.PilotSeat )
	end
end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		
		if ent.Cont and ent.Cont:IsValid() then
			HPLink( ent.Cont, ent.Entity, self )
		end
		self:GetPhysicsObject():EnableCollisions(true)
		self:SetParent()
		--constraint.NoCollide( ent, self, 0, 0 )
	end
end

function ENT:HPFire()
	for k,v in pairs(self.HP) do
		if v["Ent"] and v["Ent"]:IsValid() then
			v["Ent"]:HPFire()
		end
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if (self.Pod) and (self.Pod:IsValid()) then
	    dupeInfo.Pod = self.Pod:EntIndex()
	end
	dupeInfo.guns = {}
	for k,v in pairs(self.HP) do
		if (v["Ent"]) and (v["Ent"]:IsValid()) then
			dupeInfo.guns[k] = v["Ent"]:EntIndex()
		end
	end
	
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self )
	end
	
	duplicator.StoreEntityModifier(self, "SBEPWeaponMountDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "SBEPWeaponMountDupeInfo" , function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)

	if (Ent.EntityMods.SBEPWeaponMountDupeInfo.Pod) then
		self.Pod = GetEntByID(Ent.EntityMods.SBEPWeaponMountDupeInfo.Pod)
		if (!self.Pod) then
			self.Pod = ents.GetByIndex(Ent.EntityMods.SBEPWeaponMountDupeInfo.Pod)
		end
	end
	if (Ent.EntityMods.SBEPWeaponMountDupeInfo.guns) then
		for k,v in pairs(Ent.EntityMods.SBEPWeaponMountDupeInfo.guns) do
			local gun = GetEntByID(v)
			self.HP[k]["Ent"] = gun
			if (!self.HP[k]["Ent"]) then
				gun = ents.GetByIndex(v)
				self.HP[k]["Ent"] = gun
			end
		end
	end
	
	if(Ent.EntityMods and Ent.EntityMods.SBEPWeaponMountDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( pl, Ent, Ent.EntityMods.SBEPWeaponMountDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

end