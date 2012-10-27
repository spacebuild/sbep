include('shared.lua')

function ENT:Initialize()
	local P1 = self:GetNetworkedEntity( "Pod1" )
	local Passengers = self:GetNetworkedInt( "Passengers" ) or 0
	P1.WInfo = "Hoverbike - Passengers: "..Passengers
end

function ENT:Draw()
	
	self:DrawModel()

end
