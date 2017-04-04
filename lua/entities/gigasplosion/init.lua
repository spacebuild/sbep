
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/props_junk/watermelon01.mdl" )
	self.Entity:SetName("Gigafish")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetRenderMode(4)
	self.Entity:SetMoveType( 0 )
	self.Entity:SetSolid( 0 )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:EnableCollisions(true)
	end
	
	self:SetColor(Color(0,0,0,0))
	
    --self.Entity:SetKeyValue("rendercolor", "0 0 0")
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	self.Time = 12
 	self.PreSplode = 5
 	self.STime = CurTime()
 	self.LifeTime = CurTime() + self.Time
	
	local gigasplode = EffectData ( )
	gigasplode:SetOrigin(self.Entity:GetPos())
	gigasplode:SetNormal(self.Entity:GetForward())
	gigasplode:SetStart(self.Entity:GetPos())
	gigasplode:SetAngles(self.Entity:GetAngles())
	gigasplode:SetEntity( self.Entity )
	util.Effect( "Gigafish", gigasplode )
	
	self.hasdamagecase = true
	
	self.NFT = 0
end

function ENT:gcbt_breakactions(damage, pierce)
	
end

function ENT:Think()
	local T = CurTime() - self.STime
	local Time = ( (CurTime() - self.STime - self.PreSplode) / (self.Time - self.PreSplode) )
	local Alpha = math.Clamp((255 - (Time * 255)) - 50,0,255)
	local Sz = ((Time * 2) + (Alpha * 0.001) - 0.201) * 70000
	
	if T >= 4.5 and T <= 11.5 and CurTime() >= self.NFT then
		self.NFT = CurTime() + 0.1
		local Targets = ents.FindInSphere( self:GetPos(), Sz)
		
		for _,e in pairs(Targets) do
			if e and e:IsValid() and e:GetClass() ~= "wreckedstuff" then
				--print(e:GetClass())
				local ZD = math.abs(e:GetPos().z - self:GetPos().z)
				local Dmg = (15000 - ZD) * 3
				if Dmg > 0 then
					e:TakeDamage( Dmg, self, self )
					attack = cbt_dealdevhit(e, Dmg, 8)
					if (attack ~= nil) then
						if (attack == 2) then
							/*
							local wreck = ents.Create( "wreckedstuff" )
							wreck:SetModel( e:GetModel() )
							wreck:SetAngles( e:GetAngles() )
							wreck:SetPos( e:GetPos() )
							wreck:Spawn()
							wreck:Activate()
							*/
							e:Remove()
							
							local effectdata1 = EffectData()
							effectdata1:SetOrigin(e:GetPos())
							effectdata1:SetStart(e:GetPos())
							effectdata1:SetScale( 10 )
							effectdata1:SetRadius( 100 )
							util.Effect( "Explosion", effectdata1 )
						end
					end
				end
			end
		end
	end
	
	if CurTime() - self.STime >= self.Time + 0.1 then
		self:Remove()
	end
	
end