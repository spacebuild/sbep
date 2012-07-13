ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Holo Input"
ENT.Author			= "Paradukes + Hysteria + SlyFo"
ENT.Category		= "SBEP - Other"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:SetupDataTables()

	self:DTVar( "Bool", 1, "bActive" )
	self:DTVar( "Int" , 0, "iHighL" )
	self:DTVar( "Int" , 0, "iValue" )
	self:DTVar( "Entity" , 0, "eowner" )
	
	-- self:DTVar( "Int", 0, "On" );
	-- self:DTVar( "Bool", 0, "On" );
	-- self:DTVar( "Vector", 0, "vecTrack" );
	-- self:DTVar( "Entity", 0, "entTrack" );

end

function ENT:SetActive( bVal )
	self.dt.bActive = bVal
end

function ENT:GetActive()
	return self.dt.bActive
end

function ENT:SetHighlighted( iVal )
	self.dt.iHighL = iVal
end

function ENT:GetHighlighted()
	return self.dt.iHighL
end

function ENT:AddHValue( iVal )
	if iVal >= 0 and iVal < 10 then
		self.dt.iValue = self.dt.iValue + iVal2
	end
end

function ENT:GetHValue()
	return self.dt.iValue
end

function ENT:SendValue()
	self:SetActive( false )
end

function ENT:ClearValue()
	self:SetActive( false )
	self.dt.iValue = 0
end