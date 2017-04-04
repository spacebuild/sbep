LocalPlayer().SBEP_FOV = CreateClientConVar("SBEP_FOV", 0, true, true)
LocalPlayer().SBEP_FOV_MUL = CreateClientConVar("SBEP_FOV_MUL", 1, true, true)

function FOV()
	--print(LocalPlayer().SBEP_FOV:GetInt())
	if LocalPlayer().SBEP_FOV and LocalPlayer().SBEP_FOV:GetInt() == 1 then
		--print("Running...")
		local Vec = LocalPlayer():GetVehicle()
		if Vec and Vec:IsValid() then
			local Vel = Vec:GetVelocity() + LocalPlayer():GetPos()
			local FDist = Vel:Distance( LocalPlayer():GetPos() + LocalPlayer():GetAimVector() * 2000 )
			local BDist = Vel:Distance( LocalPlayer():GetPos() + LocalPlayer():GetAimVector() * -2000 )
			--print(BDist - FDist)
			--local SP = math.Clamp((BDist - FDist) * 0.01, -40, 40)
			local Mul = LocalPlayer().SBEP_FOV_MUL:GetFloat() * -3.5
			local SP = math.Clamp((((BDist - FDist) / 300)^2)/Mul, -40, 40)
			if BDist - FDist > 0 then
				SP = SP * -1
			end
			--SP = SP * LocalPlayer().SBEP_FOV_MUL:GetFloat()
			--print(SP)
			local AFOV = 90 + SP
			LocalPlayer():SetFOV(AFOV)
		end
	end
end
hook.Add("Think", "FOVERY", FOV)