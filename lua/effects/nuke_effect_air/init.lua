
local matRefraction	= Material( "refract_ring" )

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
	self.Position.z = self.Position.z + 4
	self.Yield = data:GetMagnitude()
	self.YieldFast = self.Yield^1.4
	self.YieldSlow = self.Yield^0.75
	self.YieldSlowest = self.Yield^0.5
	self.YieldInverse = self.Yield^-1
	self.TimeLeft = CurTime() + 24
	self.FAlpha = 255
	self.GAlpha = 254
	self.GSize = 100*self.YieldSlow
	self.CloudHeight = data:GetScale()
	
	self.Refract = 0
	self.Size = 24
	if render.GetDXLevel() <= 81 then
		matRefraction = Material( "effects/strider_pinch_dudv" )
	end
	
	local Pos = self.Position
	
	self.smokeparticles = {}
	self.Emitter = ParticleEmitter( Pos )
	if not self.Emitter then return end
	
	--big firecloud
		for i=1, 280 do
			
			local vecang = Vector(math.Rand(-32,32),math.Rand(-32,32),math.Rand(-18,18)):GetNormalized()
			local particle = self.Emitter:Add( "particles/flamelet"..math.random(1,5), Pos + self.YieldSlow*(vecang*(math.Rand(250,690))))
			vecang.z = vecang.z + self.YieldSlowest*1.4
			particle:SetVelocity(math.Rand(30,33)*vecang)
			particle:SetDieTime( math.Rand( 23, 26 ) )
			particle:SetStartAlpha( math.Rand(230, 250) )
			particle:SetStartSize( self.YieldSlow*math.Rand( 280, 360 ) )
			particle:SetEndSize( self.YieldSlow*math.Rand( 540, 630 ) )
			particle:SetRoll( math.Rand( 480, 540 ) )
			particle:SetRollDelta( self.YieldInverse*math.random( -1, 1 ) )
			particle:SetColor(Color(math.random(150,255), math.random(100,150), 100))
			--particle:VelocityDecay( true )
	
		end
		
		--fire plumes
		for i=1, 27 do
			
			local vecang = VectorRand()*8
			local spawnpos = Pos + self.YieldSlowest*256*vecang
			
				for k=5,26 do
				local particle = self.Emitter:Add( "particles/flamelet"..math.random(1,5), spawnpos - vecang*9*k)
				particle:SetVelocity(vecang*math.Rand(2,3) + Vector(0,0,math.Rand(15,20)) )
				particle:SetDieTime( math.Rand( 22, 24 ) )
				particle:SetStartAlpha( math.Rand(230, 250) )
				particle:SetStartSize( self.YieldSlow*(k*math.Rand( 3, 4 ))^1.2 )
				particle:SetEndSize( self.YieldSlow*(k*math.Rand( 5, 6 ))^1.2 )
				particle:SetRoll( math.Rand( 20, 80 ) )
				particle:SetRollDelta( self.YieldInverse*math.random( -1, 1 ) )
				particle:SetColor(Color(math.random(150,255), math.random(100,150), 100))
				--particle:VelocityDecay( true )
				end
		
		end
		
	-- big smoke cloud
		for i=1, 320 do
			
			local vecang = Vector(math.Rand(-32,32),math.Rand(-32,32),math.Rand(-18,18)):GetNormalized()
			local particle = self.Emitter:Add( "particles/smokey", Pos + self.YieldSlow*(vecang*(math.Rand(2,665))))
			local startalpha = math.Rand( 0, 7 )
			vecang.z = vecang.z + self.YieldSlowest*1.5
			particle:SetVelocity(math.Rand(40,44)*vecang)
			particle:SetLifeTime( math.Rand( -16, -10 ) )
			particle:SetDieTime( 23 )
			particle:SetStartAlpha( startalpha )
			particle:SetEndAlpha( 20 + startalpha )
			particle:SetStartSize( self.YieldSlow*math.Rand( 300, 400 ) )
			particle:SetEndSize( self.YieldSlow*math.Rand( 600, 800 ) )
			particle:SetRoll( math.Rand( 480, 540 ) )
			particle:SetRollDelta( self.YieldInverse*math.random( -1, 1 ) )
			particle:SetColor(Color(230,230,230))
			--particle:VelocityDecay( true )
			table.insert(self.smokeparticles,particle)
	
		end

end

--THINK
-- Returning false makes the entity die
function EFFECT:Think( )
	local timeleft = self.TimeLeft - CurTime()
	if timeleft > 0 then 
	local ftime = FrameTime()
	
	if self.FAlpha > 0 then
		self.FAlpha = self.FAlpha - 150*ftime
	end
	
	self.GAlpha = self.GAlpha - 10.5*ftime
	self.GSize = self.GSize - 0.12*timeleft*ftime*self.YieldSlow
	
	self.Size = self.Size + 1200*ftime
	self.Refract = self.Refract + 1.3*ftime
		
	return true
	else
		if self.Emitter then self.Emitter:Finish() end
		for __,particle in pairs(self.smokeparticles) do
		particle:SetStartAlpha( 20 )
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
render.DrawSprite(startpos, 400*self.GSize,90*self.GSize,Color(255,240,220,self.GAlpha))
render.DrawSprite(startpos, 70*self.GSize,280*self.GSize,Color(255,240,220,0.7*self.GAlpha))

--blinding flash
if self.FAlpha > 0 then
	render.DrawSprite(startpos + Vector(0,0,256),50*(self.GSize^2),35*(self.GSize^2),Color(255,245,235,self.FAlpha))
end

--outer glow
render.SetMaterial(tMats.Glow2)
render.DrawSprite(startpos, 700*self.GSize,550*self.GSize,Color(255,50,10,self.GAlpha))

--glare
render.SetMaterial(tMats.Glow3)
render.DrawSprite(startpos, 56*self.GSize,600*self.GSize,Color(130,120,240,0.5*self.GAlpha))
render.DrawSprite(startpos, 700*self.GSize,70*self.GSize,Color(80,73,255,self.GAlpha))

--shockwave
	if self.Size < 32768 then

		local Distance = EyePos():Distance( self.Entity:GetPos() )
		local Pos = self.Entity:GetPos() + (EyePos() - self.Entity:GetPos()):GetNormal() * Distance * (self.Refract^(0.3)) * 0.8

		matRefraction:SetFloat( "$refractamount", math.sin( self.Refract * math.pi ) * 0.1 )
		render.SetMaterial( matRefraction )
		render.UpdateRefractTexture()
		render.DrawSprite( Pos, self.Size, self.Size )

	end

end



