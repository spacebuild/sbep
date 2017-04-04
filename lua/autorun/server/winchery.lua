function GravyPunt( ply, ent )
	
	if ent.Puntable then
		return ent:Punt( ply )
	end
	return true
end
 
hook.Add( "GravGunPunt", "GravyPunt", GravyPunt )

local function GravyGrab( ply, ent )
	if ent.GravyGrab then
		return ent:GravyGrab( ply )
	end	
	return true
end

hook.Add("GravGunPickupAllowed", "GravyGrab", GravyGrab)

local function GravyDrop( ply, ent )
	if ent.GravyDrop then
		return ent:GravyGrab( ply )
	end	
	return true
end

hook.Add("GravGunOnDropped", "GravyDrop", GravyDrop)
