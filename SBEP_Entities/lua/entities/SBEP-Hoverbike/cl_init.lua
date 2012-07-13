include('shared.lua')

function ENT:Initialize()
	local P1 = self.Entity:GetNetworkedEntity( "Pod1" )
	local Passengers = self.Entity:GetNetworkedInt( "Passengers" ) or 0
	P1.WInfo = "Hoverbike - Passengers: "..Passengers
end

function ENT:Draw()
	
	self.Entity:DrawModel()

end
