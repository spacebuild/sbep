ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Assault Boarding Pod"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP - Other"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Owner			= nil
--ENT.CPL				= nil

ENT.EPrs			= false
ENT.TSpeed			= 75
ENT.LTog			= false
ENT.MTog			= false
ENT.MCC				= false
ENT.MChange			= false
ENT.Speed			= 0
ENT.Active			= false
ENT.Launchy			= false
ENT.Pitch			= 0
ENT.Yaw				= 0
ENT.Roll			= 0
ENT.HPType			= "Vehicle"
ENT.APPos			= Vector(0,0,-46)
ENT.APAng			= Angle(0,0,180)

function ENT:SetActive( val )
	self.Entity:SetNetworkedBool("Active",val,true)
end

function ENT:GetActive()
	return self.Entity:GetNetworkedBool("Active")
end

function ENT:SetPod( val )
	self.Entity:SetNetworkedEntity("ClPod",val,true)
end

function ENT:GetPod()
	return self.Entity:GetNetworkedEntity("ClPod")
end