local MW = CreateClientConVar("SBMWheel", 0, true, true)


function SBEPPlayerPress( ply, bind ) -- Thanks to Catdaemon and Creec for this bit :)
	local CMW = MW:GetFloat( "SBMWheel" )
	if string.find(bind, "invnext") then
		CMW = CMW + 1
		--ply.BCZScroll = math.Clamp(ply.BCZScroll - 10,-100,100) or 0
	end
	if string.find(bind, "invprev") then
		CMW = CMW - 1
		--ply.BCZScroll = math.Clamp(ply.BCZScroll + 10,-100,100) or 0
	end
	RunConsoleCommand("SBMWheel",CMW)
	--print(MW:GetFloat( "SBMWheel" ))
end
hook.Add( "PlayerBindPress", "SBEPPlayerPress", SBEPPlayerPress )

function SBEPWheelThink()
	local Ply = LocalPlayer()
	Ply.LSBMWT = Ply.LSBMWT or 0--Last SB Mouse Wheel Think
	local Delta = CurTime() - Ply.LSBMWT
	
	local CMW = MW:GetFloat( "SBMWheel" )
	CMW = math.Approach(CMW, 0, Delta * 50)
	RunConsoleCommand("SBMWheel",CMW)
	
	--print(MW:GetFloat( "SBMWheel" ))
	
	Ply.LSBMWT = CurTime()
end

hook.Add("Think", "SBEPWheelThink", SBEPWheelThink)