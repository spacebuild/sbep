AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--util.PrecacheSound( "SB/SteamEngine.wav" )

function ENT:Initialize()
	
	self.Entity:SetModel( "models/Slyfo_2/acc_food_stridernugsml.mdl" ) 
	self.Entity:SetName( "SensorLock" )
	self.Entity:PhysicsInit( 6 )
	self.Entity:SetMoveType( 0 )
	self.Entity:SetSolid( 0 )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
		phys:SetMass(1)
	end
	self.Entity:StartMotionController()
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	self.hasdamagecase = true
	
	self.Sns = self.Sns or nil
	self.Cnt = self.Cnt or nil
	self.Str = self.Str or 0
	self.V1C = Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)) -- Sets three random vectors for the target. They reduce the accuracy of the target fix.
	self.V1T = Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))
	self.V2C = Vector(math.Rand(-3,3),math.Rand(-3,3),math.Rand(-3,3))
	self.V2T = Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))
	self.V3C = Vector(math.Rand(-9,9),math.Rand(-9,9),math.Rand(-9,9))
	self.V3T = Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))
	self.TVc = Vector(0,0,0)
	self.PlC = 0 -- The current strength pulse. Effectively, the pulse makes the signal fade in and out slightly.
	self.PlT = math.Rand(0,100) -- The current target of the pulse.
	self.PlS = math.Rand(0,10) -- The current speed of the pulse. It might be better to use a constant value. We'll see.
	
	self.LTT = CurTime()
end

function ENT:Think()
	local Delta = CurTime() - self.LTT
	
	local S = SBEP_S
	
	self.PlC = math.Approach(self.PlC, self.PlT, self.PlS)
	if self.PlC == self.PlT then
		self.PlT = math.Rand(0,100)
		self.PlS = math.Rand(0.1,2)
	end
	
	self.V1C = S.VectorApproach( self.V1C, self.V1T )
	--print(self.V1C, self.V1T)
	if self.V1C == self.V1T then self.V1T = Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)) end
	self.V2C = S.VectorApproach( self.V2C, self.V2T )
	if self.V2C == self.V2T then self.V2T = Vector(math.Rand(-3,3),math.Rand(-3,3),math.Rand(-3,3)) end
	self.V3C = S.VectorApproach( self.V3C, self.V3T )
	if self.V3C == self.V3T then self.V3T = Vector(math.Rand(-9,9),math.Rand(-9,9),math.Rand(-9,9)) end
	
	local TPos = Vector(0,0,0)
	if self.Cnt and self.Cnt:IsValid() then
		TPos = self.Cnt:GetPos()
	else
		print("The contact's no longer valid. Removing the lock.")
		self:Remove()
		return
	end		
	
	local SPos = Vector(0,0,0)
	local Str = 0
	if self.Sns and self.Sns:IsValid() then
		SPos = self.Sns:GetPos()
		Str = self.Sns.SensorStrength or 0
		--print(Str)
	else
		print("The sensor's missing. Removing the lock.")
		self:Remove()
		return
	end
	
	local Dist = S.CheapDist(SPos, TPos)
	local Total = (self.Cnt.Energy + Str) - Dist
	local CStr = Total + self.PlC
	self.Str = CStr
	
	if CStr <= 0 then
		print(CStr, "The signal's too weak to maintain the lock. Removing it.")
		self:Remove()
		return
	else
		local M1T = 3000
		local M2T = 1000
		local M3T = 500
		local Mul3 = math.Clamp((M3T - CStr),0,M3T) / M3T -- 0 to 10,000 signal strength
		local Mul2 = math.Clamp((M2T - CStr),0,M2T) / M2T -- 0 to 5000
		local Mul1 = math.Clamp((M1T - CStr),0,M1T) / M1T -- 0 to 2000
		
		--print(Mul1,Mul2,Mul3)
		
		self.TVc = (( (self.V1C * Mul1) + (self.V2C * Mul2) + (self.V3C * Mul3) ) * (Dist * 0.05 )) + TPos
	end
		
	self.LTT = CurTime()
	
	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:OnRemove()
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )
	
end

function ENT:gcbt_breakactions(damage, pierce)

end