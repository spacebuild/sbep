
local matRefraction	= Material( "refract_ring" )
matRefraction:SetInt("$nocull",1)

local tMats = {}

tMats.Glow1 = CreateMaterial("glow1", "UnlitGeneric", {["$basetexture"] = "sprites/light_glow02", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
tMats.Glow2 = CreateMaterial("glow2", "UnlitGeneric", {["$basetexture"] = "sprites/yellowflare", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
tMats.Glow3 = CreateMaterial("glow3", "UnlitGeneric", {["$basetexture"] = "sprites/redglow2", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})

--[[for _,mat in pairs(tMats) do
	mat:SetInt("$spriterendermode",9)
	mat:SetInt("$ignorez",1)
	mat:SetInt("$illumfactor",8)
	mat:SetInt("$additive",1)
	mat:SetInt("$vertexcolor",1)
	mat:SetInt("$vertexalpha",1)
end]]--


function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()
	self.Position.z = self.Position.z + 5
	self.Yield = data:GetMagnitude()
	self.YieldFast = self.Yield^1.3
	self.YieldSlow = self.Yield^0.7
	self.YieldSlowest = self.Yield^0.5
	self.YieldInverse = self.Yield^-0.8
	self.TimeLeft = CurTime() + 27
	self.GAlpha = 255
	self.GSize = 100*self.Yield
	self.FAlpha = 254
	self.CloudHeight = data:GetScale()
	if self.CloudHeight < 100 then self.CloudHeight = 100 end
	
	self.Refract = 0.5
	self.DeltaRefract = 0.06
	self.Size = 0
	self.MaxSize = 4e5
	if render.GetDXLevel() <= 81 then
		matRefraction = Material( "effects/strider_pinch_dudv" )
		self.Refract = 0.3
		self.DeltaRefract = 0.03
		self.MaxSize = 2e5
	end
	
	self.smokeparticles = {}
	
	local Pos = self.Position
	local emitter = ParticleEmitter(Pos)
	if emitter then
	
	--big firecloud
		for i=1, 150 do
			
			local vecang = Vector(math.Rand(-32,32),math.Rand(-32,32),math.Rand(-18,18)):GetNormalized()
			local particle = emitter:Add( "particles/flamelet"..math.random(1,5), Pos + self.Yield*(vecang*(math.Rand(200,600)) + Vector(0,0,self.CloudHeight)))
			vecang.z = vecang.z + self.YieldSlowest*3.5
			particle:SetVelocity(math.Rand(30,33)*vecang)
			particle:SetDieTime( math.Rand( 23, 32 ) )
			particle:SetStartAlpha( math.Rand(230, 250) )
			particle:SetStartSize( self.YieldSlow*math.Rand(200, 300 ) )
			particle:SetEndSize( self.YieldSlow*math.Rand(350, 450 ) )
			particle:SetRoll( math.Rand( 150, 170 ) )
			particle:SetRollDelta( self.YieldInverse*math.random( -1, 1 ) )
			particle:SetColor(Color(math.random(150,255), math.random(100,150), 100))
			--particle:VelocityDecay( true )
	
		end
		
	--small firecloud
		for i=1, 84 do
			
			local vecang = Vector(math.Rand(-32,32),math.Rand(-32,32),math.Rand(-16,24)):GetNormalized()
			local particle = emitter:Add( "particles/flamelet"..math.random(1,5), Pos + self.Yield*(vecang*(math.Rand(2,340)) + Vector(0,0,math.random(-30,60))))
			vecang.z = 0.2*vecang.z
			particle:SetVelocity(math.Rand(24,32)*vecang)
			particle:SetDieTime( math.Rand( 20, 23 ) )
			particle:SetStartAlpha( math.Rand(230, 250) )
			particle:SetStartSize( self.YieldSlow*math.Rand(200, 300 ) )
			particle:SetEndSize( self.YieldSlow*math.Rand(350, 450 ) )
			particle:SetRoll( math.Rand( 150, 170 ) )
			particle:SetRollDelta( self.YieldInverse*math.Rand( -1, 1 ) )
			particle:SetColor(Color(math.random(150,255), math.random(100,150), 100))
			--particle:VelocityDecay( true )
	
		end
		
	--column of fire	
	for i=1, 72 do
			
			local spawnpos = self.YieldSlow*Vector(math.random(-72,72),math.random(-72,72),math.random(0,self.CloudHeight))
			local particle = emitter:Add( "particles/flamelet"..math.random(1,5), Pos + spawnpos)
			particle:SetVelocity(self.YieldSlowest*Vector(0,0,math.Rand(2,96)) + self.YieldSlowest*6*VectorRand())
			particle:SetDieTime( math.Rand( 24, 27 ) )
			particle:SetStartAlpha( math.Rand(230, 250) )
			particle:SetStartSize( self.YieldSlow*math.Rand(130, 150 ) )
			particle:SetEndSize( self.YieldSlow*math.Rand(190, 210 ) )
			particle:SetRoll( math.Rand( 150, 170 ) )
			particle:SetRollDelta( self.YieldInverse*math.Rand( -1, 1 ) )
			particle:SetColor(Color(math.random(150,255), math.random(100,150), 100))
			--particle:VelocityDecay( false )
			
		end
		
	-- big smoke cloud
		for i=1, 160 do
			
			local vecang = Vector(math.Rand(-32,32),math.Rand(-32,32),math.Rand(-18,18)):GetNormalized()
			local particle = emitter:Add( "particles/smokey", Pos + self.Yield*(vecang*(math.Rand(4,685)) + Vector(0,0,self.CloudHeight)))
			local startalpha = math.Rand( 0, 5 )
			vecang.z = vecang.z + self.YieldSlowest*4.2
			particle:SetVelocity(math.Rand(24,26)*vecang)
			particle:SetLifeTime( math.Rand( -23, -14 ) )
			particle:SetDieTime( 62 )
			particle:SetStartAlpha( startalpha )
			particle:SetEndAlpha( 250 + startalpha )
			particle:SetStartSize( self.YieldSlow*math.Rand(300, 380 ) )
			particle:SetEndSize( self.YieldSlow*math.Rand(450, 550 ) )
			particle:SetRoll( math.Rand( 150, 170 ) )
			particle:SetRollDelta( self.YieldInverse*math.random( -2, 2 ) )
			particle:SetColor(Color(60,58,54))
			--particle:VelocityDecay( true )
			table.insert(self.smokeparticles,particle)
	
		end
		
		
	-- small smoke cloud
		for i=1, 100 do
			
			local vecang = Vector(math.Rand(-32,32),math.Rand(-32,32),math.Rand(-2,4)):GetNormalized()
			local particle = emitter:Add( "particles/smokey", Pos + self.Yield*(vecang*(math.Rand(2,650))))
			local startalpha = math.Rand( 0, 5 )
			particle:SetVelocity(math.Rand(8,32)*vecang)
			particle:SetLifeTime( math.Rand( -21, -12 ) )
			particle:SetDieTime( 62 )
			particle:SetStartAlpha( startalpha )
			particle:SetEndAlpha( 250 + startalpha )
			particle:SetStartSize( self.YieldSlow*math.Rand(300, 380 ) )
			particle:SetEndSize( self.YieldSlow*math.Rand(400, 500 ) )
			particle:SetRoll( math.Rand( 150, 170 ) )
			particle:SetRollDelta( self.YieldInverse*math.Rand( -1, 1 ) )
			particle:SetColor(Color(60,58,54))
			--particle:VelocityDecay( false )
			table.insert(self.smokeparticles,particle)
	
		end
		

	--column of smoke
		for i=1, 115 do
			
			local spawnpos = self.YieldSlow*Vector(math.random(-68,68),math.random(-68,68),math.Rand(0,self.CloudHeight))
			local particle = emitter:Add( "particles/smokey", Pos + spawnpos)
			local startalpha = math.Rand( 0, 5 )
			particle:SetVelocity(self.YieldSlowest*Vector(0,0,math.Rand(0,96)) + self.YieldSlowest*math.Rand(4,9)*VectorRand())
			particle:SetLifeTime( math.Rand( -22, -13 ) )
			particle:SetDieTime( 62 )
			particle:SetStartAlpha( startalpha )
			particle:SetEndAlpha( 250 + startalpha )
			particle:SetStartSize( self.YieldSlow*math.Rand(240, 260 ) )
			particle:SetEndSize( self.YieldSlow*math.Rand(270, 300 ) )
			particle:SetRoll( math.Rand( 150, 170 ) )
			particle:SetRollDelta( self.YieldInverse*math.Rand( -1, 1 ) )
			particle:SetColor(Color(60,58,54))
			--particle:VelocityDecay( false )
			table.insert(self.smokeparticles,particle)
			
		end
		
	emitter:Finish()
	end
end


--THINK
-- Returning false makes the entity die
function EFFECT:Think( )
	local timeleft = self.TimeLeft - CurTime()
	if timeleft > 0 then 
		local ftime = FrameTime()
		
		if self.FAlpha > 0 then
			self.FAlpha = self.FAlpha - 100*ftime
		end
		
		self.GAlpha = self.GAlpha - 9.48*ftime
		self.GSize = self.GSize - 0.1*timeleft*ftime*self.Yield
		self.CloudHeight = self.CloudHeight + 120*ftime*self.YieldSlowest
		
		self.Refract = self.Refract - self.DeltaRefract*ftime
		self.Size = self.Size + 2e4*ftime

		return true
	else
		for __,particle in pairs(self.smokeparticles) do
		particle:SetStartAlpha( 70 )
		particle:SetEndAlpha( 0 )
		end
	return false	
	end
end


-- Draw the effect
function EFFECT:Render()
local startpos = self.Position

--Base glow
render.SetMaterial(tMats.Glow1)
render.DrawSprite(startpos + Vector(0,0,128),450*self.GSize,60*self.GSize,Color(255,240,220,self.GAlpha))
render.DrawSprite(startpos + Vector(0,0,self.CloudHeight),140*self.GSize,90*self.GSize,Color(255,240,220,0.7*self.GAlpha))

--blinding flash
if self.FAlpha > 0 then
	render.DrawSprite(startpos + Vector(0,0,256),80*(self.GSize^2),55*(self.GSize^2),Color(255,247,238,self.FAlpha))
end

--outer glow
render.SetMaterial(tMats.Glow2)
render.DrawSprite(startpos + Vector(0,0,800),600*self.GSize,500*self.GSize,Color(255,50,10,0.7*self.GAlpha))

--glare
render.SetMaterial(tMats.Glow3)
render.DrawSprite(startpos + Vector(0,0,self.CloudHeight),40*self.GSize,500*self.GSize,Color(130,120,240,0.23*self.GAlpha))
render.DrawSprite(startpos + Vector(0,0,self.CloudHeight),700*self.GSize,60*self.GSize,Color(80,73,255,self.GAlpha))


--shockwave
	if self.Size < self.MaxSize then
		
		matRefraction:SetFloat( "$refractamount", math.sin(self.Refract*math.pi) * 0.2 )
		render.SetMaterial( matRefraction )
		render.UpdateRefractTexture()
		
		render.DrawQuadEasy( startpos,
		Vector(0,0,1),
		self.Size, self.Size)
		
	end

end



