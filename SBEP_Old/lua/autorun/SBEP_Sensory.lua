SBEP_S = SBEP_S or {}
SBEP_S.Contacts = SBEP_S.Contacts or {}
SBEP_S.Locks = SBEP_S.Locks or {}

SBEP_Sensor_Package = true

local S = SBEP_S

function SBEP_S.TrackInSphere( Pos, Sensor, Filter )
	if !(Sensor and Sensor:IsValid()) then return {} end
	--local Results = {}
	for k,e in pairs(ents.FindByClass("SensorContact")) do
		if e and e:IsValid() then
			--print(k,e)
			--PrintTable(e)
			local Prelocked = false
			for k2,e2 in pairs(ents.FindByClass("SensorLock")) do
				--print(e2.Cnt.Pos, e.Pos, e2.Sns, Sensor)
				if e2.Cnt == e and e2.Sns == Sensor then
					Prelocked = true
				end
			end
			--print(Prelocked)
			if !Prelocked then
				local TPos = e:GetPos()
				local Str = Sensor.SensorStrength or 0
				local Dist = S.CheapDist(Pos, TPos)
				local Total = (e.Energy + Str) - Dist
				--print(Dist,Total)
				if Total > 0 then
					local LPos = S.AddLock( Sensor, e, Total )
					--print("Adding lock, strength:",Total)
					--table.insert(Sensor.SensorLocks, S.Locks[LPos])
				end
			end
		end
	end
	--return Results
end

function SBEP_S.TrackInCone( Pos, Sensor, Filter, Angle )
	if !(Sensor and Sensor:IsValid()) then return {} end
	--local Results = {}
	for k,e in pairs(ents.FindByClass("SensorContact")) do
		if e and e:IsValid() then
			--print(k,e)
			--PrintTable(e)
			local Prelocked = false
			for k2,e2 in pairs(ents.FindByClass("SensorLock")) do
				--print(e2.Cnt.Pos, e.Pos, e2.Sns, Sensor)
				if e2.Cnt == e and e2.Sns == Sensor then
					Prelocked = true
				end
			end
			--print(Prelocked)
			if !Prelocked then
				local TPos = e:GetPos()
				local Str = Sensor.SensorStrength or 0
				local Dist = S.CheapDist(Pos, TPos)
				local Total = (e.Energy + Str) - Dist
				--print(Dist,Total)
				if Total > 0 then
					local LPos = S.AddLock( Sensor, e, Total )
					--print("Adding lock, strength:",Total)
					--table.insert(Sensor.SensorLocks, S.Locks[LPos])
				end
			end
		end
	end
	--return Results
end

function SBEP_S.CurrentLocks(Sensor)
	local T = {}
	for k,e in pairs(ents.FindByClass("SensorLock")) do
		if e.Sns == Sensor then
			table.insert(T,e)
		end
	end
	return T
end

function SBEP_S.CheckConcealment( Con1, Con2 )
	
end

function SBEP_S.CheapDist( Pos1, Pos2 )
	local x = math.abs(Pos1.x - Pos2.x)
	local y = math.abs(Pos1.y - Pos2.y)
	local z = math.abs(Pos1.z - Pos2.z)
	return (x + y + z) * 0.8
end

function SBEP_S.SqrDist( Pos1, Pos2 )
	local x = (Pos1.x - Pos2.x) ^ 2
	local y = (Pos1.y - Pos2.y) ^ 2
	local z = (Pos1.z - Pos2.z) ^ 2
	return (x + y + z)
end

function SBEP_S.AddContact( Pos, Str, Type )
	local e = ents.Create( "SensorContact" )
	if type(Pos) == "Vector" then
		e:SetPos( Pos )
	elseif type(Pos) == "Entity" then
		e:SetPos( Pos:GetPos() )
	end
	e.Energy = Str
	e:Spawn()
	e:Activate()
	if type(Pos) == "Entity" then
		if Pos and Pos:IsValid() then
			e:SetParent( Pos )
		end
	end
	
	return e
	
end

function SBEP_S.AddLock( Sensor, Contact, Strength )
	local e = ents.Create( "SensorLock" )
	e.Sns = Sensor
	e.Cnt = Contact
	e.Str = Strength
	e:Spawn()
	e:Activate()
	if Sensor and Sensor:IsValid() then
		e:SetPos( Sensor:GetPos() )
		e:SetParent( Sensor )
	end
		
	return e
end

function SBEP_S.VectorApproach( Vector1, Vector2 )
	local Speed = 0.01
	local RVec = Vector(0,0,0)
	RVec.x = math.Approach(Vector1.x, Vector2.x, Speed)
	RVec.y = math.Approach(Vector1.y, Vector2.y, Speed)
	RVec.z = math.Approach(Vector1.z, Vector2.z, Speed)
	
	return RVec
end

function SBEP_S.Think()
	/*
	for k,e in pairs(ents.FindByClass("SensorLock")) do
		e.PlC = math.Approach(e.PlC, e.PlT, e.PlS)
		if e.PlC == e.PlT then
			e.PlT = math.Rand(0,100)
			e.PlS = math.Rand(0.1,2)
		end
		
		e.V1C = S.VectorApproach( e.V1C, e.V1T )
		--print(e.V1C, e.V1T)
		if e.V1C == e.V1T then e.V1T = Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)) end
		e.V2C = S.VectorApproach( e.V2C, e.V2T )
		if e.V2C == e.V2T then e.V2T = Vector(math.Rand(-3,3),math.Rand(-3,3),math.Rand(-3,3)) end
		e.V3C = S.VectorApproach( e.V3C, e.V3T )
		if e.V3C == e.V3T then e.V3T = Vector(math.Rand(-9,9),math.Rand(-9,9),math.Rand(-9,9)) end
		
		local TPos = Vector(0,0,0)
		if e.Cnt and e.Cnt:IsValid() then
			TPos = e.Cnt:GetPos()
		else
			print("The contact's no longer valid. Removing the lock.")
			table.remove(S.Locks, k)
			return
		end		
		
		local SPos = Vector(0,0,0)
		local Str = 0
		if e.Sns and e.Sns:IsValid() then
			SPos = e.Sns:GetPos()
			Str = e.Sns.SensorStrength or 0
			--print(Str)
		else
			print("The sensor's missing. Removing the lock.")
			table.remove(S.Locks, k)
			return
		end
		
		local Dist = S.CheapDist(SPos, TPos)
		local Total = (e.Cnt.Energy + Str) - Dist
		local CStr = Total + e.PlC
		e.Str = CStr
		
		if CStr <= 0 then
			print(CStr, "The signal's too weak to maintain the lock. Removing it.")
			table.remove(S.Locks, k)
			return
		else
			local M1T = 3000
			local M2T = 1000
			local M3T = 500
			local Mul3 = math.Clamp((M3T - CStr),0,M3T) / M3T -- 0 to 10,000 signal strength
			local Mul2 = math.Clamp((M2T - CStr),0,M2T) / M2T -- 0 to 5000
			local Mul1 = math.Clamp((M1T - CStr),0,M1T) / M1T -- 0 to 2000
			
			--print(Mul1,Mul2,Mul3)
			
			e.TVc = (( (e.V1C * Mul1) + (e.V2C * Mul2) + (e.V3C * Mul3) ) * (Dist * 0.05 )) + TPos
		end
	end
	*/
end

hook.Add("Think", "SBEP_SensoryThink", SBEP_S.Think)