AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
util.PrecacheSound( "SB/Gattling2.wav" )

function ENT:Initialize()

	self:SetModel( "models/SmallBridge/Wings/SBwingC1L.mdl" ) 
	self:SetName("SmallMachineGun")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.Inputs = Wire_CreateInputs( self, { "Deploy" } )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
	self:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self:GetPhysicsObject()
	
	--self.val1 = 0
	--RD_AddResource(self, "Munitions", 0)

	self.HPC			= 5
	self.HP				= {}
	self.HP[1]			= {}
	self.HP[1]["Ent"]	= nil
	self.HP[1]["Type"]	= "Small"
	self.HP[1]["Pos"]	= Vector(-22,0,40)
	self.HP[1]["Angle"]	= Angle(90,0,180)
	self.HP[2]			= {}
	self.HP[2]["Ent"]	= nil
	self.HP[2]["Type"]	= "Small"
	self.HP[2]["Pos"]	= Vector(-22,0,-28)
	self.HP[2]["Angle"]	= Angle(90,0,180)
	self.HP[3]			= {}
	self.HP[3]["Ent"]	= nil
	self.HP[3]["Type"]	= { "Small", "Medium" }
	self.HP[3]["Pos"]	= Vector(-35,35,11)
	self.HP[3]["Angle"]	= Angle(180,0,180)
	self.HP[4]			= {}
	self.HP[4]["Ent"]	= nil
	self.HP[4]["Type"]	= { "Small", "Medium" }
	self.HP[4]["Pos"]	= Vector(-20,110,11)
	self.HP[4]["Angle"]	= Angle(180,0,180)
	self.HP[5]			= {}
	self.HP[5]["Ent"]	= nil
	self.HP[5]["Type"]	= "Small"
	self.HP[5]["Pos"]	= Vector(-22,223,10)
	self.HP[5]["Angle"]	= Angle(90,0,180)
	
	self.Cont = self
	self.Dpl = false
	self.WingAngle = 0

	self:SetFold( false )
	
	
	if fintool and type(fintool) == "table" and 1==0 then
		local fin = ents.Create( "fin_2" )
			--fin:SetPos(Entity:LocalToWorld(Data.pos))
			fin:SetPos(self:GetPos()) --its pos doesn't matter
			fin:SetAngles(fin:LocalToWorldAngles(self:WorldToLocalAngles(self:GetUp():Angle())))--(self:GetUp():Angle())--
			fin.ent			= self
			fin.efficiency	= 50
			fin.lift		= "lift_normal"
			fin.pln			= 1
			fin.wind		= 0
			fin.cline		= 0
		fin:Spawn()
		fin:Activate()
	
		fin:SetParent(Entity)
		self:DeleteOnRemove(fin)
		self.Fin2_Ent = fin
	end

end

function ENT:SpawnFunction( ply, tr )
	
	if !fintool or type(fintool) ~= "table" then
		ply:PrintMessage( HUD_PRINTCENTER, "You need the fin tool installed" )	
		return nil
	end
	
	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "SF-BigWingL" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.SPL = ply
	
	return ent
	
end

function ENT:TriggerInput(iname, value)		
	if (iname == "Fire") then
		if (value > 0) then
			self.Active = true
		else
			self.Active = false
		end
	
	elseif (iname == "Deploy") then
		if (value > 0) then
			self.Dpl = true
			self:SetFold( true )
		else
			self.Dpl = false
			self:SetFold( false )
		end
			
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()

	if self.Dpl then
		if self.WingAngle < 35 then 
			self.WingAngle = self.WingAngle + 1
			--self:SetFold( self.WingAngle )
		else
			self.WingAngle = 35
		end
	else
		if self.WingAngle > 0 then 
			self.WingAngle = self.WingAngle - 1
			--self:SetFold( self.WingAngle )
		else
			self.WingAngle = 0
		end
	end
	
	if self.HP[1]["Ent"] and self.HP[1]["Ent"]:IsValid() then
		local SwivPos = ( Vector(-28,223,18) )
		local NAng = self:GetAngles()
		NAng:RotateAroundAxis( self:GetForward(), -self.WingAngle + 90 )
		NAng:RotateAroundAxis( NAng:Up(), 180 )
		RAng = self:WorldToLocalAngles(NAng)
		self.HP[1]["Ent"]:SetLocalAngles( self:WorldToLocalAngles(NAng) )
		self.HP[1]["Ent"]:SetLocalPos( SwivPos + RAng:Up() * 223 + RAng:Right() * 18 + RAng:Forward() * 28 )--( self:GetRight() * CoSine ) + ( self:GetUp() * Sine ) )
	end
	
	if self.HP[2]["Ent"] and self.HP[2]["Ent"]:IsValid() then
		local SwivPos = ( Vector(-28,223,18) )
		local NAng = self:GetAngles()
		NAng:RotateAroundAxis( self:GetForward(), self.WingAngle + 90 )
		NAng:RotateAroundAxis( NAng:Up(), 180 )
		RAng = self:WorldToLocalAngles(NAng)
		self.HP[2]["Ent"]:SetLocalAngles( self:WorldToLocalAngles(NAng) )
		self.HP[2]["Ent"]:SetLocalPos( SwivPos + RAng:Up() * 223 + RAng:Right() * -18 + RAng:Forward() * 28 )--( self:GetRight() * CoSine ) + ( self:GetUp() * Sine ) )
	end
	
	if self.HP[5]["Ent"] and self.HP[5]["Ent"]:IsValid() then
		local NAng = self:GetAngles()
		NAng:RotateAroundAxis( self:GetForward(), self.WingAngle + 90 )
		NAng:RotateAroundAxis( NAng:Up(), 180 )
		self.HP[5]["Ent"]:SetLocalAngles( self:WorldToLocalAngles(NAng) )
	end
	

	self:NextThink( CurTime() + 0.01 ) 
	return true
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

end

function ENT:Touch( ent )
	if ent.HasHardpoints then
		if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self ) end
	end
end

function ENT:HPFire()
	--if self.HP[1]["Ent"] and self.HP[1]["Ent"]:IsValid() then
	--	self.HP[1]["Ent"]:HPFire()
	--end
end