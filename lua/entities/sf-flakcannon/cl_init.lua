include('shared.lua')

function ENT:Initialize()

end

function ENT:Draw()
	
	self.Entity:DrawModel()

end

function ENT:Think()
	local C1 = self.Entity:GetNetworkedInt("CDown1")
	local C2 = self.Entity:GetNetworkedInt("CDown2")
	C1PC = ((5-( C1-CurTime())) / 5)*100
	C2PC = ((5-( C2-CurTime())) / 5)*100
	C1S = (C1PC>100) and "Loaded" or math.Round(C1PC).."%"
	C2S = (C2PC>100) and "Loaded" or math.Round(C2PC).."%"
	self.WInfo = "Flak Cannon - Round 1: "..C1S.." Round 2: "..C2S
end
