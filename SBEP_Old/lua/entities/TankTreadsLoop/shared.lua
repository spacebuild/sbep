ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Tank Tread Loop"
ENT.Author			= "Paradukes + SlyFo + Hysteria"
ENT.Category		= "SBEP - Other"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false


function ENT:SetLength( val )
	self:SetNetworkedInt( "TLength", val )
end
function ENT:GetLength()
	return self:GetNetworkedInt( "TLength" )
end

function ENT:SetSegSize( val )
	self:SetNetworkedVector( "SLength", val )
end
function ENT:GetSegSize()
	return self:GetNetworkedVector( "SLength" )
end

/*
function ENT:SetCurved( val )
	self:SetNetworkedBool( "Curvy", val )
end
function ENT:GetCurved()
	return self:GetNetworkedBool( "Curvy" )
end
*/

function ENT:SetRadius( val )
	self:SetNetworkedInt( "Radius", val )
end
function ENT:GetRadius()
	return self:GetNetworkedInt( "Radius" )
end

function ENT:SetCSModel( val )
	self:SetNetworkedInt( "CSModel", val )
end
function ENT:GetCSModel()
	return self:GetNetworkedInt( "CSModel" )
end

function ENT:SetCont( val )
	self.Entity:SetNetworkedEntity("ClCont",val,true)
end

function ENT:GetCont()
	return self.Entity:GetNetworkedEntity("ClCont")
end