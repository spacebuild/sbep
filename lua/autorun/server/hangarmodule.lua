SBEP = SBEP or {}
SBEP.Hangar = {}
local Fighters = list.Get("sbepfighters")

local function InFighterTable(hangar,fighter)
	local name = string.lower(fighter.Cont:GetName())
	if Fighters[name] then
		local docklist = Fighters[name]["Docklist"]
		return (Fighters[name] && table.HasValue(docklist, string.lower(hangar:GetName())))
	else
		return false
	end
end

function SBEP.Hangar.Touch(self,ent)
	if (ent.docked) then return end
	--if the entity is a valid vehicle on the fighter table and isn't launched
	if ( ent.Cont and ent.Cont.IsFighter and ent.Cont:IsFighter()
		and InFighterTable(self.Entity,ent) and not ent.Cont.Launchy) then
		local fighter = string.lower(ent.Cont:GetName())
		local index,dock = SBEP.Hangar.NearestDock(self.Entity,ent)
		if (!dock) then return end
		if ( !dock.ship ) then
			--no-collide and nograv each part of ship
			dock.nocol = {}
			for _,prop in pairs(constraint.GetAllConstrainedEntities(ent)) do
				table.insert(dock.nocol,constraint.NoCollide(self.Entity,prop,0,0))
				prop:GetPhysicsObject():EnableGravity(false)
			end
			local vecOff = Fighters[fighter]["VecOff"]
			local dockAng = SBEP.NearestAng(self,ent:GetAngles(),dock.canface)
			ent:SetPos( self.Entity:LocalToWorld(dock.pos) )
			ent:SetPos( ent:LocalToWorld(vecOff*-1) )
			ent:SetAngles( self.Entity:LocalToWorldAngles(dockAng) )
			dock.ship = ent
			dock.weld = constraint.Weld(self.Entity, ent, 0, 0, 0, true)
			if (dock.EP && !ent.ExitPoint) then
				ent.ExitPoint = dock.EP
				dock.EP.Vec = ent
			end
			local pilot = ent.Pod:GetPassenger()
			if (pilot:IsPlayer()) then
				if (dock.pexit && !ent.ExitPoint) then
					pilot:ExitVehicle()
					pilot:SetPos( self.Entity:LocalToWorld(dock.pexit) )
				elseif ent.ExitPoint then
					pilot:ExitVehicle()
				end
			end
			ent.docked = true
			Wire_TriggerOutput(self.Entity, "Ship "..tostring(index), ent.Cont:GetName())
		end
	end
end

function SBEP.Hangar.Think(self)
	--For each bay on the hangar
	for k, v in pairs(self.Bay) do
		--if can't find weld, look for it and if it exists re-reference
		--necessary for dupe as constraints get added after entities
		if not ( v.weld and v.weld:IsValid() ) then
			--for all the welds of the hangar
			for l,w in pairs(constraint.FindConstraints( self.Entity, "Weld" )) do
				--if the weld is also constrained to the ship
				if (w.Ent1 == v.ship || w.Ent2 == v.ship) then
					--re-reference the weld
					v.weld = w.Constraint
				end
			end
			if not (v.weld and v.weld:IsValid()) then v.ship = nil end
		end
		--Launch procedure
		--If the ship is activated
		if ( v.ship && v.ship.Cont && v.ship.Cont.Launchy ) then
			--unweld and launch
			if (v.weld and v.weld:IsValid()) then
				v.weld:Remove()
			end
			for _,nocol in pairs(v.nocol) do
				nocol:Remove()
			end
			
			v.weld = nil
			if (v.EP == v.ship.ExitPoint) then
				v.ship.ExitPoint = nil
			end
			v.ship.Cont.Speed = self.LaunchSpeed
			v.ship.docked = false
			v.ship = nil
			Wire_TriggerOutput(self.Entity, "Ship "..tostring(k), "")
		end
	end
end

function SBEP.Hangar.MakeWire(self)
	local InputTable = {}
	table.insert(InputTable,"Launchspeed")
	for k,v in pairs(self.Bay) do
		table.insert(InputTable,"Disable "..tostring(k))
	end
	for k,v in pairs(self.Bay) do
		table.insert(InputTable,"Eject "..tostring(k))
	end
	--[[self.Inputs = self.Inputs or {}
	table.Add(self.Inputs,Wire_CreateInputs(self.Entity,InputTable))]]
	self.Inputs = Wire_CreateInputs(self.Entity,InputTable)
	local OutputTable = {Name = {}, Type = {}, Desc = {}}
	for k,v in pairs(self.Bay) do
		table.insert(OutputTable.Name,"Ship "..tostring(k))
		table.insert(OutputTable.Type,"STRING")
	end
	--[[self.Outputs = self.Outputs or {}
	table.Add(self.Outputs,WireLib.CreateSpecialOutputs(self.Entity,OutputTable.Name,OutputTable.Type,OutputTable.Desc))]]
	self.Outputs = WireLib.CreateSpecialOutputs(self.Entity,OutputTable.Name,OutputTable.Type,OutputTable.Desc)
end

function SBEP.Hangar.TriggerInput(self,iname,value)
	if (iname == "Launchspeed") then
		self.Entity:SetLaunchSpeed(value)
	end
	local input = string.Explode(" ",iname)
	for k,v in pairs(self.Bay) do
		if (iname == "Disable "..tostring(k)) then
			self.Entity:SetDisabled(v,value)
		end
		if (iname == "Eject "..tostring(k)) then
			self.Entity:Eject(v,value)
		end
	end
end

--find an arbitrary difference value between two angles
function SBEP.AngleDifference(ang1,ang2)
	local pdif = math.AngleDifference(ang1.p,ang2.p)
	local ydif = math.AngleDifference(ang1.y,ang2.y)
	local rdif = math.AngleDifference(ang1.r,ang2.r)
	--that's right, this is like the Hypotenuse formula
	return math.sqrt(pdif*pdif + ydif*ydif + rdif*rdif)
end

function SBEP.NearestAng(self,ang,angTable)
	if not (type(ang) == "Angle") then
		print("Angle Expected, got "..type(ang))
		return false
	end
	if not (type(angTable) == "table") then
		print("Angle Table Expected, got "..type(angTable))
		return false
	end
	local angle,adif
	for _,dang in pairs(angTable) do
		if not (type(dang) == "Angle") then
			print("Angle Table Expected, got other table")
			return false
		end
		local tadif = SBEP.AngleDifference(ang,self.Entity:LocalToWorldAngles(dang))
		if (!adif || tadif < adif) then
			--record the difference and the angle
			adif = tadif
			--angle = tangle
			angle = dang
		end
	end
	return angle
end

function SBEP.Hangar.NearestDock(dock,fighter)
	if not (dock.IsHangar and dock:IsHangar()) then
		print("Not a Hangar Entity")
		return false
	end
	if not (fighter.Cont and fighter.Cont.IsFighter and fighter.Cont:IsFighter()) then
		print("Not a Fighter Entity")
		return false
	end
	local closest,dis
	local pos = fighter:GetPos()
	for id, bay in pairs(dock.Bay) do
		if (bay.ship == nil) and not bay.disabled then
			local tdis = pos:Distance(dock:LocalToWorld(bay.pos))
			if (!dis || tdis < dis) then
				dis = tdis
				closest = id
			end
		end
	end
	return closest,dock.Bay[closest]
end