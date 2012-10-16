
include('shared.lua')
--killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))


function ENT:Initialize()

end

function ENT:Draw()
	
	self.Entity:DrawModel()

end

function ENT:Think()
	local Shots = self.Entity:GetNetworkedInt("Shots")
	self.WInfo = "Stinger Mortar - Shots: "..Shots
end