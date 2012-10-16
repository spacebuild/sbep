include('shared.lua')
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Initialize()
	self.CMat = Material( "cable/blue_elec" )
	self.SMat = Material( "sprites/light_glow02_add" )
	self.STime = CurTime()
	self.EfPoints = {}
end

function ENT:Draw()
	
	self.Entity:DrawModel()
	
	if self.STime > CurTime() + 5 then return end
	if self.EfPoints and table.getn(self.EfPoints) > 0 then
		--print("We have points...")
		local DMode = self.Entity:GetNWInt("DMode")
	
		if DMode == 2 or DMode == 3 then
			for x = 1,table.getn(self.EfPoints),1 do
				render.SetMaterial( self.SMat )	
				local color = Color( 100, 100, 150, 100 )
				render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * self.EfPoints[x].x + self.Entity:GetForward() * self.EfPoints[x].y + self.Entity:GetUp() * self.EfPoints[x].z, 20, 20, color )
				
				local NP = 0
				if x < table.getn(self.EfPoints) then
					NP = x + 1
				else
					NP = 1
				end
				local Sz = 10
				if DMode == 3 then Sz = 5 end
				
				render.SetMaterial( self.CMat )
				local Scroll = 0
				if DMode == 2 then
					Scroll = math.fmod(CurTime()*5,128)
				else
					Scroll = math.fmod(CurTime()*64,128)
				end
				--print(Scroll)
				render.DrawBeam( self.Entity:GetPos() + self.Entity:GetRight() * self.EfPoints[x].x + self.Entity:GetForward() * self.EfPoints[x].y + self.Entity:GetUp() * self.EfPoints[x].z, self.Entity:GetPos() + self.Entity:GetRight() * self.EfPoints[NP].x + self.Entity:GetForward() * self.EfPoints[NP].y + self.Entity:GetUp() * self.EfPoints[NP].z, Sz, Scroll + 10, Scroll, Color( 255, 255, 255, 255 ) ) 
			end
		end
		if DMode == 3 then
			local LinkLock = self.Entity:GetNetworkedEntity( "LinkLock" )
			if LinkLock and LinkLock:IsValid() then
				for x = 1,table.getn(self.EfPoints),1 do
					render.SetMaterial( self.SMat )	
					local color = Color( 100, 100, 150, 100 )
					render.DrawSprite( self.Entity:GetPos() + self.Entity:GetRight() * self.EfPoints[x].x + self.Entity:GetForward() * self.EfPoints[x].y + self.Entity:GetUp() * self.EfPoints[x].z, 20, 20, color )
					
					local NP = self.EfPoints[x].sp
					if NP ~= 0 then
						render.SetMaterial( self.CMat )
						local Scroll = math.fmod(CurTime()*10,128)
						render.DrawBeam( self.Entity:GetPos() + self.Entity:GetRight() * self.EfPoints[x].x + self.Entity:GetForward() * self.EfPoints[x].y + self.Entity:GetUp() * self.EfPoints[x].z, LinkLock:GetPos() + LinkLock:GetRight() * LinkLock.EfPoints[NP].x + LinkLock:GetForward() * LinkLock.EfPoints[NP].y + LinkLock:GetUp() * LinkLock.EfPoints[NP].z, 10, Scroll + 10, Scroll, Color( 255, 255, 255, 255 ) ) 
					end
				end
			end
		end
	else
		if !self.EfError then
			print("No effect data")
			self.EfError = true
		end
	end
		
end

function ENT:Think()
	for i = 1,10 do
		local Vec = self.Entity:GetNetworkedVector("EfVec"..i)
		if Vec and Vec ~= Vector(0,0,0) then
			self.EfPoints[i] = {}
			self.EfPoints[i].x = Vec.x
			self.EfPoints[i].y = Vec.y
			self.EfPoints[i].z = Vec.z
			self.EfPoints[i].sp = self.Entity:GetNetworkedInt("EfSp"..i) or 0
		end
	end
	
	--self.Entity:SetNextThink( CurTime() + 1 )
	--return true
end