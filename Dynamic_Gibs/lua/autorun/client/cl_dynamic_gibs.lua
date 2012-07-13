
local cvar = CreateClientConVar("cl_Dynamic_gibs",1,true, true)
local cvar2 = CreateClientConVar("cl_Dynamic_gibs_lifetime",2,true, false)

local gibcount = 0

local function Plane( normal, point )
	return normal, normal:Dot( point )
end  

local function DeleteGibs( ent,index )
	hook.Remove("Think",index.."GibThinkHook")
	timer.Simple(0.1,function() ent:Remove() end)
end 

local function CreateGibs( um )
	local shouldgib = cvar:GetBool()
	if shouldgib == true then
		local ang = um:ReadAngle()
		local pos = um:ReadVector()
		local inspace = um:ReadBool()
		local model = Model(um:ReadString())
		local skin = um:ReadShort()
		local lifetime = cvar2:GetFloat()
		
		local anglez = Vector(math.random(200,1000),math.random(200,1000),math.random(200,1000))
		
		local gib1 = ents.Create("prop_physics")
		gib1:SetModel(model)
		gib1:SetPos(pos)
		gib1:SetAngles(ang)
		gib1:SetSkin(skin)
		gib1:SetKeyValue("spawnflags","4")
		gib1:SetMoveType(MOVETYPE_VPHYSICS)
		gib1:PhysicsInit( SOLID_VPHYSICS )
		gib1:Spawn()
		local physobj1 = gib1:GetPhysicsObject()
		if physobj1 and physobj1:IsValid() then
			physobj1:SetMass(physobj1:GetMass()/2)
			physobj1:EnableGravity( not inspace )
			physobj1:ApplyForceCenter( (anglez*-1) *(physobj1:GetMass()/4))
		end
		gib1:SetRenderClipPlaneEnabled( true )
		local nrml,dist = Plane( ((anglez+gib1:GetAngles():Forward())):GetNormal()*-1,gib1:GetPos())
		gib1:SetRenderClipPlane( nrml, dist )
		
		hook.Add("Think",gibcount.."GibThinkHook1",function() 
			if gib1 and gib1:IsValid() then
				local nrml,dist = Plane( ((anglez+gib1:GetAngles():Forward())):GetNormal()*-1, gib1:GetPos() )
				gib1:SetRenderClipPlane( nrml, dist ) 
			end
		end)
		timer.Simple(lifetime,DeleteGibs,gib1,gibcount)
		
		gibcount = gibcount + 1
		
		local gib2 = ents.Create("prop_physics")
		gib2:SetModel(model)
		gib2:SetPos(pos)
		gib2:SetAngles(ang)
		gib2:SetSkin(skin)
		gib2:SetKeyValue("spawnflags","4")
		gib2:SetMoveType(MOVETYPE_VPHYSICS)
		gib2:PhysicsInit( SOLID_VPHYSICS )
		gib2:Spawn()
		local physobj2 = gib2:GetPhysicsObject()
		if physobj2 and physobj2:IsValid() then
			physobj2:SetMass(physobj2:GetMass()/2)
			physobj2:EnableCollisions(false)
			timer.Simple(0.5,function() physobj2:EnableCollisions(true) end)
			physobj2:EnableGravity( not inspace )
			physobj2:ApplyForceCenter(anglez*(physobj2:GetMass()/4))
		end
		gib2:SetRenderClipPlaneEnabled( true )
		local nrml,dist = Plane( (anglez+gib2:GetAngles():Forward()):GetNormal(), gib2:GetPos() )
		gib2:SetRenderClipPlane( nrml, dist )
		
		hook.Add("Think",gibcount.."GibThinkHook1",function() 
			if gib2 and gib2:IsValid() then
				local nrml,dist = Plane( (anglez+gib2:GetAngles():Forward()):GetNormal(), gib2:GetPos() )
				gib2:SetRenderClipPlane( nrml, dist ) 
			end
		end)
		
		timer.Simple(lifetime,DeleteGibs,gib2,gibcount)
		
		gibcount = gibcount + 1
		
	end
end
usermessage.Hook("gib_message", CreateGibs)


usermessage.Hook("ApplyClippingPlaneToGCObject",function(um) 
	local ent = ents.GetByIndex(um:ReadLong())
	local norm = um:ReadVector()
	local invert = um:ReadBool()
	if ent and ent:IsValid() then
		ent:SetRenderClipPlaneEnabled( true )
		hook.Add("PreDrawOpaqueRenderables",gibcount.."GCombatServersideWreckPlane",function() 
			if ent and ent:IsValid() then
				if not invert then
					local nrml,dist = Plane( (norm+ent:GetAngles():Forward()):GetNormal(), ent:GetPos() )
					ent:SetRenderClipPlane( nrml, dist ) 
				else
					local nrml,dist = Plane( (norm+ent:GetAngles():Forward()):GetNormal()*-1, ent:GetPos() )
					ent:SetRenderClipPlane( nrml, dist ) 

				end
			else
				hook.Remove("PreDrawOpaqueRenderables",gibcount.."GCombatServersideWreckPlane")
			end
		end)
		gibcount = gibcount + 1
	end
end)