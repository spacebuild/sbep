function SBEP_AddDockCLEffectsTable( um )
	
	local CLDockEnt = um:ReadEntity()
	local NumPoints = um:ReadShort()
	--print(CLDockEnt:GetClass())
	--print(CLDockEnt:AddEfPointsTable())
	local EfPoints = {}
	for i = 1, NumPoints do
		EfPoints[i] = {}
		local Vec = um:ReadVector()
		local sp  = um:ReadShort()
		--print( tostring( Vec ) )
		EfPoints[i]["x" ] = Vec.x
		EfPoints[i]["y" ] = Vec.y
		EfPoints[i]["z" ] = Vec.z
		EfPoints[i]["sp"] = sp
		--print( tostring( sp ) )
	end
	CLDockEnt:AddEfPointsTable( EfPoints )
end
usermessage.Hook("SBEP_AddDockCLEffectsTable_cl", SBEP_AddDockCLEffectsTable)