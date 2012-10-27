
MasterPressureTable = MasterPressureTable or {}

function SBEPPrsCheck()
	if !SBEPPressure then return end
	local PAD = list.Get( "SBEP_PartAssemblyData" )
	--PrintTable(MasterPressureTable)
	for i,e in pairs(MasterPressureTable) do
		--print("Check 1")
		if e and e:IsValid() then
			--print("Check 2")
			local model = string.lower( e:GetModel() )
			local data = PAD[ model ]
			if data then
				--print("Data Exists")
				e.CPressure = e.CPressure or 0
				e.NextBreachCheck = e.NextBreachCheck or 0
				e.OpenBreach = e.OpenBreach or {}
				e.BreachConnections = e.BreachConnections or {}
				if CurTime() > e.NextBreachCheck then
					--print("Check 3")
					e.OpenBreach = {}
					e.BreachConnections = {}
					for k,v in pairs(data) do
						local ClosedConnection = false
						--print(k)
						local trace = {}
						trace.start = e:LocalToWorld( data[k].pos ) + e:LocalToWorldAngles( data[k].dir ):Up() * 60 --Gotta change this to work with DH as well
						trace.endpos = e:LocalToWorld( data[k].pos ) + (e:LocalToWorldAngles( data[k].dir ):Up() * 60) + (e:LocalToWorldAngles( data[k].dir ):Forward() * 10)
						trace.filter = e
						local tr = util.TraceLine( trace )
						if tr.Entity and tr.Entity:IsValid() then
							--print("Check 4")
							local TEnt = tr.Entity
							local TDat = PAD[ string.lower( TEnt:GetModel() ) ]
							if TDat then
								for n,y in pairs(TDat) do
									local trace = {}
									--print(TDat[n], n)
									trace.start = TEnt:LocalToWorld( TDat[n].pos ) + TEnt:LocalToWorldAngles( TDat[n].dir ):Up() * 60 --Gotta change this to work with DH as well
									trace.endpos = TEnt:LocalToWorld( TDat[n].pos ) + (TEnt:LocalToWorldAngles( TDat[n].dir ):Up() * 60) + (TEnt:LocalToWorldAngles( TDat[n].dir ):Forward() * 10)
									trace.filter = TEnt
									local tr = util.TraceLine( trace )
									if tr.Entity == e then
										TEnt.CPressure = TEnt.CPressure or 0
										local PDif = (TEnt.CPressure - e.CPressure) / 2
										TEnt.CPressure = math.Approach(TEnt.CPressure, TEnt.CPressure - PDif, 100)
										e.CPressure = math.Approach(e.CPressure, e.CPressure + PDif, 100)
										
										table.insert(e.BreachConnections, { TEnt, k } )
										ClosedConnection = true
									end
								end
							end
						end
						--print(ClosedConnection)
						if !ClosedConnection then
						--	print("Connection Open")
							table.insert(e.OpenBreach, k)
						end
						e.NextBreachCheck = CurTime() + math.Rand(0.5,1.5)
					end
				end
				local Breached = true
				--if e.IsDoorController then
					--print("Doorcheck1")
					if e.Door and e.Door[1] and e.Door[1]:GetClass() == "sbep_base_door" then
						if !e.Door[1].OpenStatus then
							--print("Doorcheck3")
							Breached = false
						end
					end					
					if e.Doors and e.Doors[1] and e.Doors[1]:GetClass() == "sbep_base_door" then
						--print("Doorcheck2")
						if !e.Doors[1].OpenStatus then
							--print("Doorcheck3")
							Breached = false
						end
					end
				--end
				if Breached then
					for k,v in pairs(e.OpenBreach) do					
						e.CPressure = math.Approach(e.CPressure, 0, 100)
						if e.CPressure > 100 then
							local effectdata = EffectData()
							effectdata:SetOrigin(e:LocalToWorld( data[v].pos ))
							effectdata:SetAngle(e:LocalToWorldAngles( data[v].dir ))
							effectdata:SetMagnitude(e.CPressure)
							util.Effect( "WindJet", effectdata )
							
							local mn, mx = e:WorldSpaceAABB()
							mn = mn + Vector(2, 2, 2)
							mx = mx - Vector(2, 2, 2)
							local T = ents.FindInBox(mn, mx)
							for _,i in pairs( T ) do
								if( i.Entity and i.Entity:IsValid() and i.Entity ~= e ) then
									local phys = i:GetPhysicsObject()
									if phys and phys:IsValid() then
										phys:ApplyForceCenter(e:LocalToWorldAngles( data[v].dir ):Forward() * 1000)
									end
								end
							end
						end
					end
					for k,v in pairs(e.BreachConnections) do
						local TEnt = v[1]
						if TEnt and TEnt:IsValid() then
							TEnt.CPressure = TEnt.CPressure or 0
							local PDif = (TEnt.CPressure - e.CPressure) / 2
							if e.CPressure <= 0 and math.abs(PDif) < 15 then
								e.CPressure = TEnt.CPressure
								TEnt.CPressure = 0
							elseif TEnt.CPressure <= 0 and math.abs(PDif) < 15 then
								TEnt.CPressure = e.CPressure
								e.CPressure = 0
							else
								TEnt.CPressure = math.Approach(TEnt.CPressure, TEnt.CPressure - PDif, 100)
								e.CPressure = math.Approach(e.CPressure, e.CPressure + PDif, 100)
								if PDif < -50 then
									local effectdata = EffectData()
									effectdata:SetOrigin(e:LocalToWorld( data[v[2]].pos ))
									effectdata:SetAngle(e:LocalToWorldAngles( data[v[2]].dir ))
									effectdata:SetMagnitude(math.Clamp(math.abs(PDif) * 10,0,10000))
									util.Effect( "WindJet", effectdata )
									
									local mn, mx = e:WorldSpaceAABB()
									mn = mn + Vector(2, 2, 2)
									mx = mx - Vector(2, 2, 2)
									local T = ents.FindInBox(mn, mx)
									for _,i in pairs( T ) do
										if( i.Entity and i.Entity:IsValid() and i.Entity ~= e ) then
											local phys = i:GetPhysicsObject()
											if phys and phys:IsValid() then
												phys:ApplyForceCenter(e:LocalToWorldAngles( data[v[2]].dir ) * math.Clamp(PDif * 10,-1000,1000))
											end
										end
									end
								end
							end
						else
							table.remove( e.BreachConnections, k )
						end
					end
				end
			else
				table.remove( MasterPressureTable, i )
			end
		else
			table.remove( MasterPressureTable, i )
		end
	end
	
end
hook.Add("Think", "SBEPPressurization", SBEPPrsCheck)