
-- Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Shoot stuff."

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Drone Blast Rifle"			
SWEP.Slot				= 3
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true

SWEP.Base				= "weapon_base"
SWEP.HoldType			= "rpg"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/Spacebuild/Nova/dronegun1.mdl"
SWEP.WorldModel			= "models/Spacebuild/Nova/dronegun1.mdl"

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.DTime					= 0
SWEP.DeployLength			= 0.75
SWEP.RTime					= 0
SWEP.ReloadLength			= 2
SWEP.NBurst					= 0

/*---------------------------------------------------------
							Reload
---------------------------------------------------------*/
function SWEP:Reload()
	if !self.Reloading and self:Ammo1() > 0 and self:Clip1() < self.Primary.ClipSize then
		self:SetNetworkedFloat( "RTime", CurTime(), true )
		--print(self:GetNetworkedFloat( "RTime" ))
		self.Reloading = true
		self.RTime = CurTime()
	end
end

function SWEP:Think()
	if self.Reloading then
		local CAmmo = self:Clip1()
		local RAmmo = self.Primary.ClipSize - CAmmo
		if CurTime() > self.RTime + self.ReloadLength then
			if self:Ammo1() > RAmmo then
				self.Owner:RemoveAmmo( RAmmo, self.Weapon:GetPrimaryAmmoType() )
				self:SetClip1(self.Primary.ClipSize)
				self.Reloading = false
			else
				self:SetClip1(self:Ammo1() + CAmmo)
				self.Owner:RemoveAmmo( self:Ammo1(), self.Weapon:GetPrimaryAmmoType() )
				self.Reloading = false
			end
		end
	end

	if self.Bursting then
		if self:Clip1() > 0 then
			if CurTime() > self.NBurst then
				local ply = self.Owner
				self:TakePrimaryAmmo( 1 )
				local bomb = ents.Create( "SF-MortarShell" )
				bomb:SetAngles( ply:EyeAngles() )
				bomb:SetPos( ply:EyePos() + ply:GetAimVector() * 5 + ply:EyeAngles():Right() * 10)
				bomb:SetOwner( ply )
				--bomb:SetAngles( ply:GetAimVector():Angle() + Angle(90, 0, 0))
				bomb:Spawn()
				bomb:Initialize()
				bomb:Activate()
				bomb.PreLaunch = true
				--bomb.RifleNade = true
				local physi = bomb:GetPhysicsObject()
				local Acc = 300
				--physi:EnableGravity(false)
				physi:EnableDrag(false)
				physi:SetVelocity((ply:GetAimVector() * 6000) + Vector(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc)))
				
				self:EmitSound("Weapon_XM1014.Single")
				
				self.Owner:ViewPunch( Angle( math.Rand(-0.01,-0.01) * 100, math.Rand(-0.01,0.01) *100, 0 ) )
				
				local effectdata = EffectData()
				effectdata:SetOrigin(ply:EyePos() + (ply:GetAimVector() * 10) + (ply:EyeAngles():Right() * 6))
				effectdata:SetAngle(ply:EyeAngles())
				effectdata:SetScale( 2 )
				util.Effect( "MuzzleEffect", effectdata )
				self.NBurst = CurTime() + 0.1
			end
		else
			self:EmitSound( "Weapon_Pistol.Empty" )
			self.Bursting = false
			self:Reload()
		end
	end
	
	self:NextThink( CurTime() + 0.1 )
end

/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if CLIENT or self.Bursting then return end
	
	if self:Clip1() > 0 and !self.Reloading then
		local ply = self.Owner
	
		self:TakePrimaryAmmo( 1 )
		
		local bomb = ents.Create( "SF-MortarShell" )
		bomb:SetAngles( ply:EyeAngles() )
		bomb:SetPos( ply:EyePos() + (ply:GetAimVector() * 2) + (ply:EyeAngles():Right() * 10))
		bomb:SetOwner( ply )
		--bomb:SetAngles( ply:GetAimVector():Angle() + Angle(90, 0, 0))
		bomb:Spawn()
		bomb:Initialize()
		bomb:Activate()
		bomb.PreLaunch = true
		--bomb.RifleNade = true
		local physi = bomb:GetPhysicsObject()
		local Acc = 50
		--physi:EnableGravity(false)
		physi:EnableDrag(false)
		physi:SetVelocity((ply:GetAimVector() * 6000) + Vector(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc)))
		
		self:EmitSound("Weapon_XM1014.Single")
		
		self.Owner:ViewPunch( Angle( math.Rand(-0.05,-0.05) * 100, math.Rand(-0.05,0.05) *100, 0 ) )
		
		local effectdata = EffectData()
		effectdata:SetOrigin(ply:EyePos() + (ply:GetAimVector() * 10) + (ply:EyeAngles():Right() * 6))
		effectdata:SetAngle(ply:EyeAngles())
		effectdata:SetScale( 2 )
		util.Effect( "MuzzleEffect", effectdata )
	else
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:Reload()
	end
		
	
	self:SetNextPrimaryFire( CurTime() + 0.4 )
	self:SetNextSecondaryFire( CurTime() + 0.4 )
	return true
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if CLIENT then return end
	--local ply = self.Owner
	if self:Clip1() > 0 and !self.Reloading then
		self.Bursting = !self.Bursting
	else
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:Reload()
	end
	
	self:SetNextPrimaryFire( CurTime() + .2 )
	self:SetNextSecondaryFire( CurTime() + .2 )
	return true
end

/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
	return false
end

if (CLIENT) then
	function SWEP:GetViewModelPosition( pos, ang )
		local NAng = 0
		local RTime = self:GetNetworkedFloat( "RTime" ) or 0
		local DTime = self:GetNetworkedFloat( "DTime" ) or 0
		--print(RTime)
		if RTime + self.ReloadLength > CurTime() then
			local Prg = (( RTime + self.ReloadLength ) - CurTime()) / self.ReloadLength
			NAng = math.sin(math.rad(Prg * 180))
			--print(NAng * 45)
			--print("Reloading")
		end
		if DTime + self.DeployLength > CurTime() then
			local Prg = (( DTime + self.DeployLength ) - CurTime()) / self.DeployLength
			NAng = math.sin(math.rad(Prg * 90))
			--print(NAng * 45)
			--print("Reloading")
		end
		--print(NAng)
		ang:RotateAroundAxis( ang:Right(), NAng * -30 )
 		pos = pos + (ang:Forward() * 40) + (ang:Right() * 10) + (ang:Up() * (-20 + (NAng * -5))) 
		--ang:RotateAroundAxis( ang:Forward(), 90 )
	 
		return pos, ang
 
	end
end

function SWEP:DrawWorldModel()
     self.Weapon:DrawModel()
end

function SWEP:Deploy()
	self.DTime = CurTime()
	self:SetNetworkedFloat( "DTime", CurTime(), true )
    return true
end