
-- Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Shoot stuff."

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "SBEPWeaponBase"			
SWEP.Slot				= 3
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true

SWEP.Base				= "weapon_base"
SWEP.HoldType			= "rpg"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/props_junk/PopCan01a.mdl"
SWEP.WorldModel			= "models/props_junk/PopCan01a.mdl"

SWEP.Primary.ClipSize		= 0
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "smg1"

SWEP.CSlot					= 0
SWEP.DTime					= 0
SWEP.DeployLength			= 0.75
SWEP.PRTime					= 0
SWEP.SRTime					= 0
SWEP.PReloadLength			= 2
SWEP.SReloadLength			= 2
SWEP.NBurst					= 0
SWEP.SFRecoilT				= 0
SWEP.PFRecoilT				= 0
SWEP.SFRecoilL				= 0.2
SWEP.PFRecoilL				= 0.2
SWEP.WSTog					= false
SWEP.Sensitivity			= 1
SWEP.CRRTime				= 0
SWEP.RecoilFade				= .8
SWEP.RecWalkA				= 0
SWEP.RecWalkT				= 0

SWEP.ISAccMod				= 0.5

SWEP.CRecoil				= 0.1 --Convince me that it's possible to have one gun recoiling like mad while still firing perfectly straight with your other gun, and I'll add separate recoil for primary/secondary.
SWEP.RecoilTime				= 0

if CLIENT then 
surface.CreateFont ("arial narrow", { 
font = "SBEPAmmo",
size = 50,
weight = 100,
antialias = true,
shadow = false,
} )
end

local SWEPData = list.Get( "SBEP_SWeaponry" )

/*---------------------------------------------------------
							Reload
---------------------------------------------------------*/
function SWEP:Reload()
	print("Reloading")
	if !self.PReloading and !self.SReloading and (self:Ammo1() > 0 or self:Ammo2() > 0) and (self:Clip1() < self.Primary.ClipSize or self:Clip2() < self.Secondary.ClipSize) then
		print("Can Reload")
		if self.Primary.ClipSize > 0 then
			if self.Secondary.ClipSize > 0 then
				local CPA = self:Clip1() / self.Primary.ClipSize
				local CSA = self:Clip2() / self.Secondary.ClipSize
				--print(CPA, CSA)
				if CPA <= CSA then
					self:PReload()
				else
					self:SReload()
				end
			else
				self:PReload()
			end
		else
			if self.Secondary.ClipSize > 0 then
				self:SReload()
			end
		end
	end
end

function SWEP:PReload()
	if !self.PReloading and !self.SReloading then
		self:SetNetworkedFloat( "PRTime", CurTime(), true )
		self.PReloading = true
		self.PRTime = CurTime()
		--print("PRel")
	end
end

function SWEP:SReload()
	if !self.PReloading and !self.SReloading then
		self:SetNetworkedFloat( "SRTime", CurTime(), true )
		self.SReloading = true
		self.SRTime = CurTime()
		--print("SRel")
	end
end

/*---------------------------------------------------------
							Think
---------------------------------------------------------*/
function SWEP:Think()
		
	if SERVER then
		if !self.Init then
			--self:SetNetworkedInt( "SGun", 1 )
			--self:SetNetworkedInt( "PGun", 1 )
			--self.PGun = 1
			--self.SGun = 1
			self.Init = true
			self.Owner.CSlot = 0
			self.Owner.Slots = self.Owner.Slots or {}
			self.Owner.Slots.Primary = {}
			self.Owner.Slots.Secondary = {}
			for i = 0,10 do
				self.Owner.Slots.Primary[i] = -1
				self.Owner.Slots.Secondary[i] = -1
			end
			self.Owner.Inventory = self.Owner.Inventory or {}
			
			self.Owner.IronSightTime = 0
			self.Owner.IronSightMode = false
		end
		
		if self.Owner:KeyDown( IN_USE ) and self.Owner:KeyDown( IN_WALK ) then
			self.Owner:SelectWeapon( "weapon_crowbar" )
		end
		
		--PrintTable(self.Owner.Inventory)
		--print(self.Owner.Inventory[ self.Owner.Slots.Primary[self.Owner.CSlot] ].Type)
		if self.Owner.Inventory[ self.Owner.Slots.Primary[self.Owner.CSlot] ] then
			self.PData = SWEPData[ self.Owner.Inventory[ self.Owner.Slots.Primary[self.Owner.CSlot] ].Type ]
			if !self.PData then
				self.PData = SWEPData[ "Empty" ]
			end
		end
		if self.Owner.Inventory[ self.Owner.Slots.Secondary[self.Owner.CSlot] ] then
			self.SData = SWEPData[ self.Owner.Inventory[ self.Owner.Slots.Secondary[self.Owner.CSlot] ].Type ]
			if !self.SData then
				self.SData = SWEPData[ "Empty" ]
			end
		end
		if !self.PData or !self.SData then return end
		--PrintTable(self.PData)
		self.Primary.ClipSize		= self.PData.ClipSize
		self.Primary.Automatic		= self.PData.Auto
		self.Primary.Ammo			= self.PData.AmmoType
		self.PReloadLength			= self.PData.ReloadLength
		
		self.Secondary.ClipSize		= self.SData.ClipSize
		self.Secondary.Automatic	= self.SData.Auto
		self.Secondary.Ammo			= self.SData.AmmoType
		self.SReloadLength			= self.SData.ReloadLength
			
		
		if self.PReloading and self.Owner.Slots.Primary[self.Owner.CSlot] > 0 then
			local CAmmo = self:Clip1()
			local RAmmo = self.Primary.ClipSize - CAmmo
			if CurTime() > self.PRTime + self.PReloadLength then
				if self:Ammo1() > RAmmo then
					self.Owner:RemoveAmmo( RAmmo, self.Weapon:GetPrimaryAmmoType() )
					self:SetClip1(self.Primary.ClipSize)
					self.PReloading = false
				else
					self:SetClip1(self:Ammo1() + CAmmo)
					self.Owner:RemoveAmmo( self:Ammo1(), self.Weapon:GetPrimaryAmmoType() )
					self.PReloading = false
				end
				self.Owner.Inventory[ self.Owner.Slots.Primary[self.Owner.CSlot] ].Ammo = self:Clip1()
			end
		end
		
		if self.SReloading and self.Owner.Slots.Secondary[self.Owner.CSlot] > 0 then
			local CAmmo = self:Clip2()
			local RAmmo = self.Secondary.ClipSize - CAmmo
			if CurTime() > self.SRTime + self.SReloadLength then
				if self:Ammo2() > RAmmo then
					self.Owner:RemoveAmmo( RAmmo, self.Weapon:GetSecondaryAmmoType() )
					self:SetClip2(self.Secondary.ClipSize)
					self.SReloading = false
				else
					self:SetClip2(self:Ammo2() + CAmmo)
					self.Owner:RemoveAmmo( self:Ammo2(), self.Weapon:GetSecondaryAmmoType() )
					self.SReloading = false
				end
				self.Owner.Inventory[ self.Owner.Slots.Secondary[self.Owner.CSlot] ].Ammo = self:Clip2()
			end
		end
		
		if CurTime() > self.CRRTime then
			self.CRecoil = self.CRecoil * self.RecoilFade
			self.CRRTime = CurTime() + 0.1
		end
		if self.CRecoil < 0.01 then
			self.CRecoil = 0
		end
		
		local ISMod = 0.5
		if self.Owner.IronSightMode then
			ISMod = 1.5
		end
		
		self.RecWalkA = self.RecWalkA + (math.AngleDifference(self.RecWalkA,self.RecWalkT) * self.CRecoil * -0.1)
		if math.AngleDifference(self.RecWalkA,self.RecWalkT) < 1 and math.AngleDifference(self.RecWalkA,self.RecWalkT) > -1 then
			self.RecWalkT = math.random(0,360)
		end
		local PAng = self.Owner:EyeAngles()
		PAng.pitch = PAng.pitch + (math.sin(math.rad( self.RecWalkA )) * self.CRecoil * 0.1 * ISMod )
		PAng.yaw = PAng.yaw + (math.cos(math.rad( self.RecWalkA )) * self.CRecoil * 0.1 * ISMod )
		if self.CRecoil > 0 then
			self.Owner:SetEyeAngles( PAng )
		end
		
		if self.Owner.CSlot > 0 then
			if self.Owner.Slots.Primary[self.Owner.CSlot] > 0 then
				if type(self.PData.CustomThink) == "function" then
					self.PData.CustomThink(self,self.Owner,true,self.PData)
				end
			end
			if self.Owner.Slots.Secondary[self.Owner.CSlot] > 0 then
				if type(self.SData.CustomThink) == "function" then
					self.SData.CustomThink(self,self.Owner,false,self.SData)
				end
			end
		end
		
	end
	
	if CLIENT then
	
		if !self.Init then
			--self:SetNetworkedInt( "SGun", 1 )
			--self:SetNetworkedInt( "PGun", 1 )
			--self.PGun = 1
			--self.SGun = 1
			self.Init = true
			self.Owner.Slots = {}
			self.Owner.Slots.Primary = {}
			self.Owner.Slots.Secondary = {}
			for i = 0,10 do
				self.Owner.Slots.Primary[i] = {}
				self.Owner.Slots.Primary[i].Pos = {(i * 122) - 95, 60, 65, 65}
				self.Owner.Slots.Primary[i].Inv = -1
				self.Owner.Slots.Primary[i].Icon = nil
				self.Owner.Slots.Secondary[i] = {}
				self.Owner.Slots.Secondary[i].Pos = {(i * 122) - 95, 155, 65, 65}
				self.Owner.Slots.Secondary[i].Inv = -1
				self.Owner.Slots.Secondary[i].Icon = nil
			end
			self.Owner.Inventory = self.Owner.Inventory or {}
			self.Owner.CSlot = 0
			
			self.Owner.IronSightTime = 0
			self.Owner.IronSightMode = false
		end
		
		self.Owner.CRecoil = self.Owner.CRecoil or 0
		self.Owner.CRRTime = self.Owner.CRRTime or 0
		if CurTime() > self.Owner.CRRTime then
			self.Owner.CRecoil = self.Owner.CRecoil * self.RecoilFade
			self.Owner.CRRTime = CurTime() + 0.1
		end
		if self.Owner.CRecoil < 0.01 then
			self.Owner.CRecoil = 0
		end
		if self.Owner.CRecoil > 0 then
			--print("Client", self.Owner.CRecoil)
		end
		
		/*
		if( input.IsKeyDown(KEY_I)) then
			if !self.NTog then
				if self.Owner.InventoryDisplay then
					self.Owner.InventoryDisplay:Remove()
					self.Owner.InventoryDisplay = nil
					self.Owner.InfoDisplay:Remove()
					self.Owner.InfoDisplay = nil
					self.Owner.WeaponSlot:Remove()
					self.Owner.WeaponSlot = nil
					gui.EnableScreenClicker(false)
					print("Removing")
				else
					self:CreateInventory()
					gui.EnableScreenClicker(true)
					print("Creating")
				end
				self.NTog = true
			end
		else
			self.NTog = false
		end
		*/
		
		if( input.IsKeyDown(KEY_I)) then
			if !self.NTog then
				if !self.Owner.InventoryDisplay then
					self:CreateInventory()
					gui.EnableScreenClicker(true)
					print("Creating")
				end
				self.NTog = true
			end
		else
			if self.NTog then
				if self.Owner.InventoryDisplay then
					self.Owner.InventoryDisplay:Remove()
					self.Owner.InventoryDisplay = nil
					self.Owner.InfoDisplay:Remove()
					self.Owner.InfoDisplay = nil
					self.Owner.WeaponSlot:Remove()
					self.Owner.WeaponSlot = nil
					gui.EnableScreenClicker(false)
					print("Removing")
				end
				self.NTog = false
			end
		end
		
		
		local NSlot = 0
		for i = 2, 10 do
			if input.IsKeyDown(i) then
				--print("i")
				NSlot = i -1
			end
		end
		if NSlot > 0 then
			if !self.WSTog and NSlot ~= self.Owner.CSlot and ( self.Owner.Slots.Primary[NSlot].Inv > 0 or self.Owner.Slots.Secondary[NSlot].Inv > 0  ) then
				self.Owner:ConCommand("SBEPChangeSlot "..NSlot)
				self.WSTog = true
			end
		else
			self.WSTog = false
		end
		
		if self.Owner.CSlot > 0 then
			if self.Owner.Slots.Primary[self.Owner.CSlot].Inv > 0 then
				if type(self.PData.CustomThink) == "function" then
					self.PData.CustomThink(self,self.Owner,true)
				end
			end
			if self.Owner.Slots.Secondary[self.Owner.CSlot].Inv > 0 then
				if type(self.SData.CustomThink) == "function" then
					self.SData.CustomThink(self,self.Owner,false)
				end
			end
		end
	end
	
	self:NextThink( CurTime() + 0.001 )
	return true
	
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if CLIENT then return end
	local ply = self.Owner
	--print(self.Owner.CSlot)
	if self.Owner.CSlot > 0 then
		if self.Owner.Slots.Primary[self.Owner.CSlot] > 0 then
			if type(self.PData.CustomPrimary) == "function" then
				self.PData.CustomPrimary(self,self.Owner,true,self.PData)
			else
				if self:Clip1() ~= 0 and !self.PReloading then
					
					self:EmitSound(self.PData.Sound)
						
					if self.PData.Bullets > 0 then
						self:StandardMuzzleFlash(true)
						self:SetNetworkedFloat( "PFTime", CurTime(), true )
						
						local CrouchMod = 1
						if self.Owner:Crouching() then
							CrouchMod = 0.5
						end
						local AkimboPenalty = 1
						if self.Owner.Slots.Secondary[self.Owner.CSlot] > 0 then
							AkimboPenalty = self.PData.AkimboPenalty * 1
						end
						local ISMod = 1
						if self.Owner.IronSightMode then
							ISMod = self.ISAccMod
						end
						self:ShootBullet( self.PData.Damage, self.PData.Bullets, math.Clamp((self.PData.Cone * CrouchMod * AkimboPenalty * ISMod) * ((self.CRecoil * self.PData.RecoilVulnerability) + 1),0,0.3) )
						--print(self.PData.Cone * CrouchMod * AkimboPenalty)
								
						self:TakePrimaryAmmo( 1 )
						self.Owner.Inventory[ self.Owner.Slots.Primary[self.Owner.CSlot] ].Ammo = self:Clip1()
					end
					
					if self.PData.Recoil > 0 then
						self.Owner:ViewPunch( Angle( math.Rand(-0.05,-0.05) * 10 * self.PData.Recoil, math.Rand(-0.05,0.05) * 10 * self.PData.Recoil, 0 ) )
						local CrouchMod = 1
						if self.Owner:Crouching() then
							CrouchMod = 0.5
						end
						local AkimboPenalty = 1
						if self.Owner.Slots.Secondary[self.Owner.CSlot] > 0 then
							AkimboPenalty = self.PData.AkimboPenalty or 1
						end
						self:Recoil(self.PData.Recoil * CrouchMod * AkimboPenalty)
					end
				else
					self:EmitSound( "Weapon_Pistol.Empty" )
					self:Reload()
				end
				
				self:SetNextPrimaryFire( CurTime() + self.PData.Refire )
			end
		else
			if type(self.SData.CustomSecondary) == "function" then
				self.SData.CustomSecondary(self,self.Owner,false,self.SData)
			end
		end
	end
	
	return true
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if CLIENT then return end
	local ply = self.Owner
	
	if self.Owner.CSlot > 0 then
		if self.Owner.Slots.Secondary[self.Owner.CSlot] > 0 then
			if type(self.SData.CustomPrimary) == "function" then
				self.SData.CustomPrimary(self,self.Owner,false,self.SData)
			else
				if self:Clip2() > 0 and !self.SReloading then
					self:EmitSound(self.SData.Sound)
												
					if self.SData.Bullets > 0 then
						self:StandardMuzzleFlash(false)
						self:SetNetworkedFloat( "SFTime", CurTime(), true )
						
						local CrouchMod = 1
						if self.Owner:Crouching() then
							CrouchMod = 0.5
						end
						local AkimboPenalty = 1
						if self.Owner.Slots.Primary[self.Owner.CSlot] > 0 then
							AkimboPenalty = self.SData.AkimboPenalty or 1
						end
						local ISMod = 1
						if self.Owner.IronSightMode then
							ISMod = self.ISAccMod
						end
						self:ShootBullet( self.SData.Damage, self.SData.Bullets, math.Clamp((self.PData.Cone * CrouchMod * AkimboPenalty * ISMod) * ((self.CRecoil * self.PData.RecoilVulnerability) + 1),0,0.3) )
						--print(self.PData.Cone * CrouchMod * AkimboPenalty)
								
						self:TakeSecondaryAmmo( 1 )
						self.Owner.Inventory[ self.Owner.Slots.Secondary[self.Owner.CSlot] ].Ammo = self:Clip2()
					end
					
					if self.SData.Recoil > 0 then
						self.Owner:ViewPunch( Angle( math.Rand(-0.05,-0.05) * 10 *self.SData.Recoil, math.Rand(-0.05,0.05) * 10 * self.SData.Recoil, 0 ) )
						local CrouchMod = 1
						if self.Owner:Crouching() then
							CrouchMod = 0.5
						end
						local AkimboPenalty = 1
						if self.Owner.Slots.Primary[self.Owner.CSlot] > 0 then
							AkimboPenalty = self.SData.AkimboPenalty
						end
						self:Recoil(self.SData.Recoil * CrouchMod * AkimboPenalty)
					end
				else
					self:EmitSound( "Weapon_Pistol.Empty" )
					self:Reload()
				end
				
				self:SetNextSecondaryFire( CurTime() + self.SData.Refire )
			end
		else
			if type(self.PData.CustomSecondary) == "function" then
				self.PData.CustomSecondary(self,self.Owner,true,self.PData)
			end
		end
	end
	
	return true
end
--The next chunk of functions are just defined here because I can't be arsed to keep defining them in the SWep list.
function SWEP:StandardMuzzleFlash(Prime)
	local ply = self.Owner
	local Data = nil
	local SideMul = 1
	if Prime then
		Data = self.PData
	else
		Data = self.SData
		SideMul = -1
	end
	--PrintTable(Data)
	local WPos = Data.RVec
	if self.Owner.IronSightMode then
		if Data.IronSPos then
			WPos = Data.IronSPos
		end
	end
	local MVec = Data.MuzzlePos + WPos
	local effectdata = EffectData()
	effectdata:SetOrigin(ply:EyePos() + (ply:GetAimVector() * MVec.y) + (ply:EyeAngles():Right() * MVec.x * SideMul) + (ply:EyeAngles():Up() * MVec.z) )
	effectdata:SetAngle(ply:EyeAngles())
	effectdata:SetScale( 2 )
	util.Effect( "MuzzleEffect", effectdata )
end

function SWEP:FireCheck(Prime)
	if !((self.PReloading or self:Clip1() == 0) and Prime) and !((self.SReloading or self:Clip2() == 0) and !Prime) then
		return true
	else
		return false
	end
end

function SWEP:ConsumeAmmo(Prime, Ammo)
	if Prime then
		self:TakePrimaryAmmo( Ammo )
	else
		self:TakeSecondaryAmmo( Ammo )
	end
end

function SWEP:ReloadCheck(Prime)
	if Prime then
		self:PReload()
	else
		self:SReload()
	end
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:GetViewModelPosition( pos, ang )

	--pos = pos + (ang:Forward() * -40) 
	
	--This bit is utterly monsterous. Do not atempt to analyse while sober.
	if self.Owner.Inventory[ self.Owner.Slots.Primary[self.Owner.CSlot].Inv ] then
		self.PData = SWEPData[ self.Owner.Inventory[ self.Owner.Slots.Primary[self.Owner.CSlot].Inv ].Type ]
		if !self.PData then
			self.PData = SWEPData[ "Empty" ]
		end
	else
		self.PData = SWEPData[ "Empty" ]
	end
	if self.Owner.Inventory[ self.Owner.Slots.Secondary[self.Owner.CSlot].Inv ] then
		self.SData = SWEPData[ self.Owner.Inventory[ self.Owner.Slots.Secondary[self.Owner.CSlot].Inv ].Type ]
		if !self.SData then
			self.SData = SWEPData[ "Empty" ]
		end
	else
		self.SData = SWEPData[ "Empty" ]
	end
	
	if !self.PData or !self.SData then return end
	
	if self.OPModel ~= self.PData.Model then
		--print("New Primary")
		if self.PModel then 
			self.PModel:Remove()
			self.PModel = nil
			self.Owner.PModel = nil
		end
		self:SetNetworkedFloat( "PRTime", CurTime() - (self.PData.ReloadLength * .5), true )
	end
	if self.OSModel ~= self.SData.Model then
		--print("New Secondary")
		if self.SModel then 
			self.SModel:Remove()
			self.SModel = nil
			self.Owner.SModel = nil
		end
		self:SetNetworkedFloat( "SRTime", CurTime() - (self.SData.ReloadLength * .5), true )
	end
	
	/*
	if type(self.PData.CustomDraw) == "function" then
		self.PData.CustomDraw(self,self.Owner,true,self.PData)
		--print("Calling Primary")
	end
	
	if type(self.SData.CustomDraw) == "function" then
		self.SData.CustomDraw(self,self.Owner,false,self.SData)
		--print("Calling Secondary")
	end
	*/
	
	if !self.PModel then
		self.PModel = ClientsideModel(self.PData.Model, RENDERGROUP_OPAQUE)
		self.Owner.PModel = self.PModel
	end
	local PFAng = 0
	local PFTime = self:GetNetworkedFloat( "PFTime" ) or 0
	if PFTime + self.PFRecoilL > CurTime() then
		local Prg = (( PFTime + self.PFRecoilL ) - CurTime()) / self.PFRecoilL
		PFAng = math.sin(math.rad(Prg * 180))
		--print(PFAng)
	end
	local PRTime = self:GetNetworkedFloat( "PRTime" ) or 0
	local PRAng = 0
	if PRTime + self.PData.ReloadLength > CurTime() then
		local Prg = (( PRTime + self.PData.ReloadLength ) - CurTime()) / self.PData.ReloadLength
		PRAng = math.sin(math.rad(Prg * 180))
		--print(PRAng)
	end
	local PrimaryVector = Vector(0,0,0)
	local PrimaryAngle = Angle(0,0,0)
	--print(self.PData.IronSPos)
	--print(self.Owner.IronSightMode)
	if self.PData.IronSPos then
		if self.Owner.IronSightMode then
			local IST = self.Owner.IronSightTime or 0
			local Time = math.Clamp(math.TimeFraction( IST, IST + .5, CurTime() ),0,1)
			PrimaryVector = LerpVector(  Time,  self.PData.RVec,  self.PData.IronSPos )
			PrimaryAngle = LerpAngle(  Time,  self.PData.RAng,  self.PData.IronSAng )
		else
			local IST = self.Owner.IronSightTime or 0
			local Time = math.Clamp(math.TimeFraction( IST, IST + .5, CurTime() ),0,1)
			PrimaryVector = LerpVector(  Time,  self.PData.IronSPos,  self.PData.RVec )
			PrimaryAngle = LerpAngle(  Time,  self.PData.IronSAng,  self.PData.RAng )
		end
	else
		PrimaryVector = self.PData.RVec
		PrimaryAngle = self.PData.RAng
	end
	
	local AutoRAng = PRAng
	local AutoFAng = PFAng
	if self.PData.RecPos then
		PrimaryVector = PrimaryVector + (self.PData.RecPos * PFAng)
		AutoFAng = 0
	end
	if self.PData.RecAng then
		PrimaryAngle = PrimaryAngle + (self.PData.RecAng * PFAng)
		AutoFAng = 0
	end
	if self.PData.RelPos then
		PrimaryVector = PrimaryVector + (self.PData.RelPos * PRAng)
		AutoRAng = 0
	end
	if self.PData.RelAng then
		PrimaryAngle = PrimaryAngle + (self.PData.RelAng * PRAng)
		AutoRAng = 0
	end
	--print(AutoFAng)
	
	self.PModel:SetPos( pos + (ang:Right() * PrimaryVector.x) + (ang:Forward() * (PrimaryVector.y + (AutoFAng * -5))) + (ang:Up() * (PrimaryVector.z + (AutoRAng * -15))) )
	--print(self.PData.RVec)
	local PlAng = Angle(ang.Pitch,ang.Yaw,ang.Roll)
	PlAng:RotateAroundAxis( ang:Right(), (AutoFAng * 5) + (AutoRAng * -45) )
	PlAng:RotateAroundAxis( ang:Right(), PrimaryAngle.Pitch )
	PlAng:RotateAroundAxis( ang:Up(), PrimaryAngle.Yaw )
	PlAng:RotateAroundAxis( ang:Forward(), PrimaryAngle.Roll )
	self.PModel:SetAngles( PlAng )
	
	if self.PData.ModelScale then
		self.PModel:SetModelScale(self.PData.ModelScale)
	end
	
	
	if !self.SModel then
		self.SModel = ClientsideModel(self.SData.Model, RENDERGROUP_OPAQUE)
		self.Owner.SModel = self.SModel
	end
	local SFAng = 0
	local SFTime = self:GetNetworkedFloat( "SFTime" ) or 0
	if SFTime + self.SFRecoilL > CurTime() then
		local Prg = (( SFTime + self.SFRecoilL ) - CurTime()) / self.SFRecoilL
		SFAng = math.sin(math.rad(Prg * 180))
		--print(SFAng)
	end
	local SRTime = self:GetNetworkedFloat( "SRTime" ) or 0
	local SRAng = 0
	if SRTime + self.SData.ReloadLength > CurTime() then
		local Prg = (( SRTime + self.SData.ReloadLength ) - CurTime()) / self.SData.ReloadLength
		SRAng = math.sin(math.rad(Prg * 180))
		--print(SRAng)
	end
	self.SModel:SetPos( pos + (ang:Right() * -self.SData.RVec.x) + (ang:Forward() * (self.SData.RVec.y + (SFAng * -5))) + (ang:Up() * (self.SData.RVec.z + (SRAng * -15))) )
	local PlAng = Angle(ang.Pitch,ang.Yaw,ang.Roll)
	PlAng:RotateAroundAxis( ang:Right(), (SFAng * 5) + (SRAng * -45) )
	self.SModel:SetAngles( PlAng )
	--self.SModel:SetModelScale( Vector(1,-1,1) )
	self.OPModel = self.PData.Model
	self.OSModel = self.SData.Model
		 
	return pos - ang:Forward() * 100, ang

end

function SWEP:ViewModelDrawn()
	if self.PData then
		if type(self.PData.CustomDraw) == "function" then
			self.PData.CustomDraw(self,self.Owner,true,self.PData)
			--print("Calling Primary")
		end
	end
	if self.SData then
		if type(self.SData.CustomDraw) == "function" then
			self.SData.CustomDraw(self,self.Owner,false,self.SData)
			--print("Calling Secondary")
		end
	end
end

function SWEP:AdjustMouseSensitivity()
	return self.Owner.Sensitivity
end

function SWEP:DrawWorldModel()
     self.Weapon:DrawModel()
end

function SWEP:Deploy()
	--self.DTime = CurTime()
	--self:SetNetworkedFloat( "DTime", CurTime(), true )
    return true
end

function SWEP:Holster()
	
	if self.PModel then 
		self.PModel:Remove()
		self.PModel = nil
		self.Owner.PModel = nil
	end
	if self.SModel then 
		self.SModel:Remove()
		self.SModel = nil
		self.Owner.SModel = nil
	end
	--print("Holstered")
	--if self.Owner:KeyDown( IN_WALK ) then
	--	return true
	--end
	return true
end

function SWEP:OnDrop()
	if self.PModel then 
		self.PModel:Remove()
		self.PModel = nil
	end
	if self.SModel then 
		self.SModel:Remove()
		self.SModel = nil
	end
	--print("Dropped")
	return true
end

function SWEP:CustomAmmoDisplay()  
    self.AmmoDisplay                = self.AmmoDisplay or {}  
    self.AmmoDisplay.Draw           = false  
    self.AmmoDisplay.PrimaryClip    = -1 --self.Weapon:Clip2()  
    self.AmmoDisplay.PrimaryAmmo    = -1 --self.Weapon:Clip1()  
    self.AmmoDisplay.SecondaryAmmo  = -1 --self.Weapon:Ammo1()
    return self.AmmoDisplay  
end

function SWEP:GetTracerOrigin()
	local PFTime = self:GetNetworkedFloat( "PFTime" ) or 0
	local SFTime = self:GetNetworkedFloat( "SFTime" ) or 0
	local EVec = Vector(0,0,0)
	local ply = self.Owner
	local DVec = Vector(0,0,0)
	local Mdl = nil
	local Data = nil
	if PFTime >= SFTime then
		Mdl = self.PModel
		EVec = ply:EyePos() + (ply:GetAimVector() * 15) + (ply:EyeAngles():Right() * 12) + (ply:EyeAngles():Up() * -5.5)
		Data = self.PData
	else
		Mdl = self.SModel
		EVec = ply:EyePos() + (ply:GetAimVector() * 15) + (ply:EyeAngles():Right() * -12) + (ply:EyeAngles():Up() * -5.5)
		Data = self.SData
	end
	local MzPos = Data.MuzzlePos or Vector(0,0,0)
	if Mdl and Mdl:IsValid() then
		DVec = Mdl:GetPos() + (Mdl:GetRight() * MzPos.x) + (Mdl:GetForward() * MzPos.y) + (Mdl:GetUp() * MzPos.z)
	end
	if DVec ~= Vector(0,0,0) then
		return DVec
	end
    return EVec or self.Owner:EyePos()
end

function SWEP:Recoil(Recoil)
	self.CRecoil = self.CRecoil + (Recoil * math.Rand(0.5,1.5))
	umsg.Start("SBEPSetRecoil", self.Owner )
	umsg.Float( self.CRecoil )
	umsg.End()
end

function SWEP:StandardIronSight(Prime)
	if !self.Owner.IronSightMode then
		self.Owner:SetFOV( 35, .5 )
		umsg.Start("SBEPSetIronSights", self.Owner )
		umsg.Bool(true)
		umsg.Float( CurTime() )
		umsg.End()
		self.Owner.IronSightMode = true
	else
		self.Owner:SetFOV( 0, .5 )
		umsg.Start("SBEPSetIronSights", self.Owner )
		umsg.Bool(false)
		umsg.Float( CurTime() )
		umsg.End()
		self.Owner.IronSightMode = false
	end
	if Prime then
		self:SetNextSecondaryFire( CurTime() + .5 )
	else
		self:SetNextPrimaryFire( CurTime() + .5 )
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
---																		ConCommands																	   ---
----------------------------------------------------------------------------------------------------------------------------------------------------------


if SERVER then
	function SBEPItemDrop(player,commandName,args)
		local NWeap = ents.Create( "SBEPInventoryItem" )
		if ( !NWeap:IsValid() ) then return end
		local Vec = Vector(tonumber(args[2]),tonumber(args[3]),tonumber(args[4]))
		print(args[1], Vec, player.Inventory[tonumber(args[1])])
		NWeap.ItemType = player.Inventory[tonumber(args[1])].Type
		NWeap.Ammo = player.Inventory[tonumber(args[1])].Ammo or 0
		NWeap:SetPos( player:GetShootPos() + (Vec * 10) )
		NWeap:SetAngles( Vec:Angle() )
		NWeap:Spawn()
		NWeap:Activate()
		NWeap:Spawn()
		NWeap:Initialize()
		NWeap:Activate()
		NWeap:GetPhysicsObject():Wake()
		NWeap:GetPhysicsObject():SetVelocity((Vec * 100))
		
		umsg.Start("SBEPInventoryRemove", player )
		umsg.Float( tonumber(args[1]) )
		umsg.End()
		
		SBEPSlotReorder(player,"SBEPSlotReorder",{ 1 })
		table.remove(player.Inventory, tonumber(args[1]) )
	end 
	concommand.Add("SBEPItemDrop",SBEPItemDrop) 
	
	
	
	function SBEPSlotSetup(player,commandName,args)
		if tonumber(args[3]) == 1 then
			player.Slots.Primary[tonumber(args[1])] = tonumber(args[2])
			if tonumber(args[1]) == player.CSlot then
				local Wep = player:GetWeapon("SBEPWepBase")
				if Wep.PData then
					Wep:SetNetworkedFloat( "PRTime", CurTime() - (Wep.PData.ReloadLength * .5), true )
				end
			end
		elseif tonumber(args[3]) == 2 then
			player.Slots.Secondary[tonumber(args[1])] = tonumber(args[2])
			if tonumber(args[1]) == player.CSlot then
				local Wep = player:GetWeapon("SBEPWepBase")
				if Wep.PData then
					Wep:SetNetworkedFloat( "SRTime", CurTime() - (Wep.PData.ReloadLength * .5), true )
				end
			end
		end
	end 
	concommand.Add("SBEPSlotSetup",SBEPSlotSetup) 
	
	
	
	function SBEPChangeSlot(player,commandName,args)
		player.CSlot = tonumber(args[1])
		umsg.Start("SBEPGunChangeCL", player )
		umsg.Float( tonumber(args[1]) )
		umsg.End()
		
		
		local Wep = player:GetWeapon("SBEPWepBase")
		
		if player.Inventory[ player.Slots.Primary[player.CSlot] ] then
			Wep.PData = SWEPData[ player.Inventory[ player.Slots.Primary[player.CSlot] ].Type ]
			if !Wep.PData then
				Wep.PData = SWEPData[ "Empty" ]
			end
		else
			Wep.PData = SWEPData[ "Empty" ]
		end
		if player.Inventory[ player.Slots.Secondary[player.CSlot] ] then
			Wep.SData = SWEPData[ player.Inventory[ player.Slots.Secondary[player.CSlot] ].Type ]
			if !Wep.SData then
				Wep.SData = SWEPData[ "Empty" ]
			end
		else
			Wep.SData = SWEPData[ "Empty" ]
		end
		
		Wep.PReloading = false
		Wep.SReloading = false
		
		--print(Wep)
		if Wep.PData and Wep.PData.ClipSize > 0 then-- and  Wep.PData.Model ~= "models/props_junk/PopCan01a.mdl" then
			Wep:SetNetworkedFloat( "PRTime", CurTime() - (Wep.PData.ReloadLength * .5), true )
			Wep:SetClip1(player.Inventory[ player.Slots.Primary[player.CSlot] ].Ammo)
		end
		--PrintTable(Wep.SData)
		if Wep.SData and Wep.SData.ClipSize > 0 then--Wep.SData.Model ~= "models/props_junk/PopCan01a.mdl" then
			Wep:SetNetworkedFloat( "SRTime", CurTime() - (Wep.SData.ReloadLength * .5), true )
			Wep:SetClip2(player.Inventory[ player.Slots.Secondary[player.CSlot] ].Ammo)
		end
		
		player:SetFOV(0,.2)
		umsg.Start("SBEPSenseChange", player )
		umsg.Float( 1 )
		umsg.End()
	end 
	concommand.Add("SBEPChangeSlot",SBEPChangeSlot)
	
	
	
	function SBEPSlotReorder(player,commandName,args)
		
		local Dropped = tonumber(args[1])
		--print(Dropped)
		for i=0,10 do
			local CInv = player.Slots.Primary[i]
			if CInv == Dropped then
				player.Slots.Primary[i] = -1
			elseif CInv > Dropped then
				player.Slots.Primary[i] = CInv - 1
			end
			local CInv = player.Slots.Secondary[i]
			if CInv == Dropped then
				player.Slots.Secondary[i] = -1
			elseif CInv > Dropped then
				player.Slots.Secondary[i] = CInv - 1
			end
		end
		
		umsg.Start("SBEPSlotReorder", player )
		umsg.Float( tonumber(args[1]) )
		umsg.End()
		
	end 
	concommand.Add("SBEPSlotReorder",SBEPSlotReorder)
end



/*
if self.Owner:KeyDown( IN_WALK ) then
	if self.Owner:KeyDown( IN_RELOAD ) then
		if !self.PTog then
			self.PGun = self.PGun + 1
			if self.PGun > 6 then
				self.PGun = 1
			end
			self.PData = SWEPData[ self.PGun ]
			
			self:SetNetworkedInt( "PGun", self.PGun )
			--self:PReload()
			self:SetNetworkedFloat( "PRTime", CurTime() - (self.PData.ReloadLength * .5), true )
			--self.PRTime = CurTime() - (self.PData.ReloadLength * .5)
			self.PReloading = false
			self.PTog = true
		end
	else
		self.PTog = false
	end
end
if self.Owner:KeyDown( IN_WALK ) then
	if self.Owner:KeyDown( IN_USE ) then
		if !self.STog then
			self.SGun = self.SGun + 1
			if self.SGun > 6 then
				self.SGun = 1
			end
			self.SData = SWEPData[ self.SGun ]
			
			self:SetNetworkedInt( "SGun", self.SGun )
			--self:SReload()
			self:SetNetworkedFloat( "SRTime", CurTime() - (self.SData.ReloadLength * .5), true )
			--self.SRTime = CurTime() - (self.SData.ReloadLength * .5)
			self.SReloading = false
			self.STog = true
		end
	else
		self.STog = false
	end
end
*/



----------------------------------------------------------------------------------------------------------------------------------------------------------
---																		Derma Inventory																   ---
----------------------------------------------------------------------------------------------------------------------------------------------------------


if CLIENT then

	local PANEL = {}
 
	function PANEL:LayoutEntity( Entity )
	 
		if ( self.bAnimated ) then
			self:RunAnimation()
		end
	 
	end
	 
	vgui.Register("DModelPanelNoRotate",PANEL,"DModelPanel")

	function SWEP:CreateInventory()
		--local SWEPData = list.Get( "SBEP_SWeaponry" )
		LocalPlayer().InventoryDisplay = {}
		LocalPlayer().Inventory = LocalPlayer().Inventory or {}
		
		local InfoPanel = vgui.Create( "DFrame" )
		InfoPanel:SetPos( 900,30 )
		InfoPanel:SetSize( 350, 500 )
		InfoPanel:SetTitle( "Info" )
		InfoPanel:SetVisible( true )
		InfoPanel:SetDraggable( true )
		InfoPanel:SetMouseInputEnabled( true )
		InfoPanel:ShowCloseButton( true )
		InfoPanel:SetDeleteOnClose( true )
		InfoPanel.Inv = 0
		
		InfoName = vgui.Create("Label", InfoPanel)
		InfoName:SetPos(10,30)
		InfoName:SetFont("DefaultBold")
		InfoName:SetText("Name: ")
		InfoName:SizeToContents()
		
		InfoMain = vgui.Create("DLabel", InfoPanel)
		InfoMain:SetPos(25,210)
		InfoMain:SetFont("Default")
		InfoMain:SetText("Damage:\nClip-Size\nRate of Fire:\nAccuracy:\nRecoil:\nAmmo-Type:\nTwo-Handed:\nDescription:")
		--InfoMain:SizeToContents()
		InfoMain:SetMultiline( true ) 
		InfoMain:SetSize( 100,145 )
		
		function InfoPanel:PaintOver()
			--surface.SetTextPos( 25, 210 )
			--surface.SetFont("Default")
			--surface.DrawText( "Testing" )
			surface.SetDrawColor( 30, 30, 30, 255 )
		
			surface.SetDrawColor( 30, 30, 30, 255 )
			surface.DrawOutlinedRect( 26, 56, 300, 145)
			
			surface.SetDrawColor( 150, 150, 150, 255 )
			surface.DrawOutlinedRect( 25, 55, 300, 145)
		end
		
		local ModelDisp = vgui.Create( "DModelPanelNoRotate", InfoPanel )
		ModelDisp:SetVisible( true )
		ModelDisp:SetPos( 25,45 )
		ModelDisp:SetSize( 300,300 )
		ModelDisp:SetModel( "" )
		ModelDisp:SetCamPos( Vector( 100, 100, 100 ) )
		ModelDisp:SetLookAt( Vector(0,1,0) )
		ModelDisp.Inv = 0
		function ModelDisp:Think()
			if ModelDisp.Inv <= 0 or !LocalPlayer().Inventory[ModelDisp.Inv] then return end
			local InfoData = SWEPData[ LocalPlayer().Inventory[ModelDisp.Inv].Type ]
			if InfoData then
				if ModelDisp.Entity and ModelDisp.Entity:IsValid() then
					local DVec = InfoData.IVec or Vector(0,20,0)
					local Ang = ModelDisp.Entity:GetAngles() or Angle(0,0,0)
					--print(Ang)
					Ang.Yaw = Ang.Yaw + 3
					--local X = (math.cos(math.rad( -Ang.Yaw )) * DVec.x) + (math.sin(math.rad( Ang.Yaw )) * DVec.y)
					--local Y = (math.sin(math.rad( -Ang.Yaw )) * DVec.x) + (math.cos(math.rad( Ang.Yaw )) * DVec.y)
					--local Y = (math.cos(math.rad( -Ang.Yaw )) * DVec.x) + (math.sin(math.rad( Ang.Yaw )) * DVec.y)
					--local X = (math.sin(math.rad( -Ang.Yaw )) * DVec.x) + (math.cos(math.rad( Ang.Yaw )) * DVec.y)
					local X = (math.sin(math.rad(Ang.Yaw)) * DVec.y) + (math.cos(math.rad(Ang.Yaw)) * DVec.x)
					local Y = (math.cos(math.rad(Ang.Yaw)) * -DVec.y) + (math.sin(math.rad(Ang.Yaw)) * DVec.x)
					--print(X,Y)
					ModelDisp.Entity:SetAngles(Ang)
					ModelDisp:SetCamPos( DVec + (ModelDisp.Entity:GetRight() * Y) + (ModelDisp.Entity:GetForward() * X)  )
					--ModelDisp.Entity:SetPos( Vector(X,Y,DVec.z) )
					--ModelDisp.Entity:SetPos( -DVec + (ModelDisp.Entity:GetRight() * Y) + (ModelDisp.Entity:GetForward() * X) )
					--ModelDisp:SetCamPos( DVec )
					ModelDisp:SetLookAt( DVec + Vector(0,-1,0) )
				end
			end
		end
		
		function InfoPanel:ChangeItemDisplay(Inv)
			local InfoData = SWEPData[ LocalPlayer().Inventory[Inv].Type ]
			if InfoData then
				ModelDisp.Inv = Inv
				ModelDisp:SetModel(InfoData.Model)
				--print(InfoData.Model)
				local DVec = InfoData.IVec or Vector(0,20,0)
				--print(DVec)
				ModelDisp:SetCamPos( DVec )
				ModelDisp:SetLookAt( DVec + Vector(0,-1,0) )
				ModelDisp.Entity:SetAngles(Angle(0,90,0))
				--print("Name: "..LocalPlayer().Inventory[Inv].Type)
				InfoName:SetText("Name: "..LocalPlayer().Inventory[Inv].Type)
				InfoName:SizeToContents()
				
				local Dmg = ""
				if InfoData.Damage and InfoData.Damage > 0 then
					if InfoData.Bullets and InfoData.Bullets > 1 then
						Dmg = "Damage: "..InfoData.Damage.." x "..InfoData.Bullets.."\n"
					else
						Dmg = "Damage: "..InfoData.Damage.."\n"
					end
				end
				
				local ClpSz = ""
				if InfoData.ClipSize and InfoData.ClipSize > 0 then
					ClpSz = "Clip-Size: "..InfoData.ClipSize.."\n"
				end
				
				local ROF = ""
				if InfoData.Refire and InfoData.Refire > 0 then
					local SPS = tostring(60 / InfoData.Refire)
					local SPSStr = string.Left(SPS, 4)
					ROF = "Rate-of-Fire: "..SPSStr.." Rounds/m\n"
				end
				
				local Auto = ""
				if InfoData.Auto then
					Auto = "Automatic\n"
				end
				
				local Acc = ""
				if InfoData.Cone and InfoData.Cone >= 0 then
					local Prc = math.Clamp((1 - (InfoData.Cone * 3)) * 100,0,100)
					Acc = "Accuracy: "..Prc.."%\n"
				end
				
				local Rec = ""
				if InfoData.Recoil and InfoData.Recoil >= 0 then
					Rec = "Recoil: "..InfoData.Recoil.."\n"
				end
				
				local AType = ""
				if InfoData.AmmoType then
					AType = "Ammo-Type: "..InfoData.AmmoType.."\n"
				end
				
				local TwoH = ""
				if InfoData.TwoHanded then
					TwoH = "Two-Handed\n"
				end
				
				local Desc = ""
				if InfoData.Description then
					Desc = "Description: "..InfoData.Description.."\n"
				end
				
				--InfoMain:SizeToContents()
				InfoMain:SetText(""..Dmg..ClpSz..ROF..Auto..Acc..Rec..AType..TwoH..Desc.."")
				--InfoMain:SizeToContents()
				InfoMain:SetSize( 300,500 )
				InfoMain:SetMultiline( true )
				InfoMain:SetWrap(true)
				InfoMain:SetAutoStretchVertical(true)
				--InfoMain:SetPos(25,210)
				
				--InfoMain:SizeToContents()
				
				
				
			end
		end
		
		
		local WSlot = vgui.Create( "DFrame" )
		local RWSH = ScrH() - 260
		WSlot:SetPos( 30,RWSH )
		WSlot:SetSize( 1220, 236 )
		WSlot:SetTitle( "Weapon Slots" )
		WSlot:SetVisible( true )
		WSlot:SetDraggable( true )
		WSlot:SetMouseInputEnabled( true )
		WSlot:ShowCloseButton( true )
		WSlot:SetDeleteOnClose( true )
		WSlot.RebuildTime = 0
		
		function WSlot:PaintOver()
			for i = 1,10 do
				surface.SetTextColor( 200, 200, 200, 255 )
				surface.SetTextPos( ((i-1) * 122) + 5, 25 )
				surface.SetFont("DefaultBold")
				surface.DrawText( "Slot "..i )
				
				surface.SetTextPos( ((i-1) * 122) + 40, 45 )
				surface.SetFont("Default")
				surface.DrawText( "Primary" )
				
				surface.SetTextPos( ((i-1) * 122) + 35, 140 )
				surface.SetFont("Default")
				surface.DrawText( "Secondary" )
			
				surface.SetDrawColor( 150, 150, 150, 255 )
				surface.DrawOutlinedRect( i * 122, 24, 1, 300)
				
				surface.SetDrawColor( 30, 30, 30, 255 )
				surface.DrawOutlinedRect( (i * 122) + 1, 24, 1, 300)
				
				
				
				surface.SetDrawColor( 30, 30, 30, 255 )
				surface.DrawOutlinedRect( (i * 122) - 94, 61, 64, 64)
				
				surface.SetDrawColor( 150, 150, 150, 255 )
				surface.DrawOutlinedRect( (i * 122) - 95, 60, 65, 65)
				
				
				
				surface.SetDrawColor( 30, 30, 30, 255 )
				surface.DrawOutlinedRect( (i * 122) - 94, 156, 64, 64)
				
				surface.SetDrawColor( 150, 150, 150, 255 )
				surface.DrawOutlinedRect( (i * 122) - 95, 155, 65, 65)
			end
		end
		
		function WSlot:Think()
			if WSlot.NeedsRebuilding then
				if CurTime() > WSlot.RebuildTime then
					WSlot:Rebuild()
				end
			end
		end		
		
		function WSlot:Rebuild()
			--print("Rebuilding")
			WSlot.NeedsRebuilding = false
			for i = 0,10 do
				if LocalPlayer().Slots.Primary[i].Icon then
					LocalPlayer().Slots.Primary[i].Icon:Remove()
					LocalPlayer().Slots.Primary[i].Icon = nil
				end
				if LocalPlayer().Slots.Secondary[i].Icon then
					LocalPlayer().Slots.Secondary[i].Icon:Remove()
					LocalPlayer().Slots.Secondary[i].Icon = nil
				end
				--print(WSlot.Slots.Primary[i].Inv)
				if LocalPlayer().Slots.Primary[i].Inv > 0 then
					local Data = nil
					if LocalPlayer().Inventory[LocalPlayer().Slots.Primary[i].Inv] then
						Data = SWEPData[ LocalPlayer().Inventory[LocalPlayer().Slots.Primary[i].Inv].Type ]
					end
					--print(SWEPData)
					--print(Data)
					if Data then
						local WSIcon = vgui.Create( "SpawnIcon", WSlot )
						WSIcon:SetPos( LocalPlayer().Slots.Primary[i].Pos[1], LocalPlayer().Slots.Primary[i].Pos[2] )
						WSIcon:SetModel( Data.Model )
						WSIcon:SetToolTip( LocalPlayer().Inventory[LocalPlayer().Slots.Primary[i].Inv].Type )
						function WSIcon:DoClick()
							LocalPlayer().Slots.Primary[i].Inv = -1
							local NInv = 0
							LocalPlayer():ConCommand("SBEPSlotSetup "..i.." "..NInv.." "..1)
							WSIcon:Remove()
						end
						LocalPlayer().Slots.Primary[i].Icon = WSIcon
					end
				end
				--print(WSlot.Slots.Secondary[i].Inv)
				if LocalPlayer().Slots.Secondary[i].Inv > 0 then
					local Data = nil
					if LocalPlayer().Inventory[LocalPlayer().Slots.Secondary[i].Inv] then
						Data = SWEPData[ LocalPlayer().Inventory[LocalPlayer().Slots.Secondary[i].Inv].Type ]
					end
					--print(SWEPData)
					--print(Data)
					--print(v.Type)
					if Data then
						local WSIcon = vgui.Create( "SpawnIcon", WSlot )
						WSIcon:SetPos( LocalPlayer().Slots.Secondary[i].Pos[1], LocalPlayer().Slots.Secondary[i].Pos[2] )
						WSIcon:SetModel( Data.Model )
						WSIcon:SetToolTip( LocalPlayer().Inventory[LocalPlayer().Slots.Secondary[i].Inv].Type )
						function WSIcon:DoClick()
							LocalPlayer().Slots.Secondary[i].Inv = -1
							local NInv = 0
							LocalPlayer():ConCommand("SBEPSlotSetup "..i.." "..NInv.." "..2)
							WSIcon:Remove()
						end
						LocalPlayer().Slots.Secondary[i].Icon = WSIcon
					end
				end
			end
		end
		WSlot:Rebuild()
		
				
		local Frame = vgui.Create( "DFrame" )
		
		Frame:SetPos( 30,30 )
		Frame:SetSize( 530, 500 )
		Frame:SetTitle( "Inventory" )
		Frame:SetVisible( true )
		Frame:SetDraggable( true )
		Frame:SetMouseInputEnabled( true )
		Frame:ShowCloseButton( true )
		Frame:SetDeleteOnClose( true )
		
		function Frame:PaintOver()
			local Row = 0
			local Column = 0
			local MaxRowLength = 8
			for i = 1, 24 do
				local CX = ((Column) * 65 ) + 5
				local CY = ((Row) * 65 ) + 25 
				--surface.SetDrawColor( 110, 110, 110, 255 )
				--surface.DrawRect(  CX,  CY,  65,  65 )
				
				surface.SetDrawColor( 30, 30, 30, 255 )
				surface.DrawOutlinedRect( CX + 1, CY + 1, 64, 64)
				
				surface.SetDrawColor( 150, 150, 150, 255 )
				surface.DrawOutlinedRect( CX, CY, 65, 65)
				
				Column = Column + 1
				if Column >= MaxRowLength then
					Column = 0
					Row = Row + 1
				end 
				/*
				surface.SetDrawColor( 110, 110, 110, 255 )
				surface.DrawRect(  5,  250,  65,  65 )
				
				surface.SetDrawColor( 30, 30, 30, 255 )
				surface.DrawOutlinedRect( 6, 251, 64, 64)
				
				surface.SetDrawColor( 150, 150, 150, 255 )
				surface.DrawOutlinedRect( 5, 250, 65, 65)
				*/
			end
		end
		
		
		Frame.Icon = {}
		
		function Frame:Rebuild()
			if Frame.Icon then
				for i,v in pairs( Frame.Icon ) do
					v:Remove()
				end
			end
			local Row = 0
			local Column = 0
			local MaxRowLength = 8
			for i,v in pairs( LocalPlayer().Inventory ) do
				local Data = SWEPData[ v.Type ]
				--print(SWEPData)
				--print(Data)
				--print(v.Type)
				if Data then
					--print("Data Approved")
					Icon = vgui.Create( "SpawnIcon", Frame )
					Icon:SetPos( ((Column) * 65 ) + 5, ((Row) * 65 ) + 25 )
					Icon:SetModel( Data.Model )
					Icon:SetToolTip( v.Type )
					--Icon:SetIconSize(80)
					--Icon.InvPos = i
					function Icon:OnCursorEntered()
						--InfoPanel.Inv = i
						--InfoMain:SetText("a")
						--InfoMain:SizeToContents()
						InfoPanel:ChangeItemDisplay(i)
						--InfoPanel:ChangeItemDisplay(i)
					end
					function Icon:OnMousePressed(num)
						if num == 107 then
							HIcon = vgui.Create( "SpawnIcon" )
							HIcon:SetPos( gui.MouseX() + 10, gui.MouseY() + 10 )
							HIcon:SetModel( Data.Model )
							HIcon:SetToolTip( nil )
							HIcon:MoveToFront()
							HIcon.InvPos = i
							function HIcon:Think()
								--if !MouseCC(Frame:GetBounds()) and !MouseCC(InfoPanel:GetBounds()) then
									--print("Hovering")
									--local Vec = gui.ScreenToVector( gui.MousePos() )
									--LocalPlayer():ConCommand("SBEPItemDrop "..i.." "..Vec.x.." "..Vec.y.." "..Vec.z)
								--end
								if input.IsMouseDown(MOUSE_LEFT) then
									local PX,PY = HIcon:GetParent():GetPos()
									HIcon:SetPos( (gui.MouseX() - 32) - PX, (gui.MouseY() - 32) - PY )
								else
									if !MouseCC(Frame:GetBounds()) and !MouseCC(InfoPanel:GetBounds()) and !MouseCC(WSlot:GetBounds()) then
										--print("Dropping, Stage 1")
										local Vec = gui.ScreenToVector( gui.MousePos() )
										LocalPlayer():ConCommand("SBEPItemDrop "..i.." "..Vec.x.." "..Vec.y.." "..Vec.z)
										--LocalPlayer():ConCommand("SBEPSlotReorder "..i)
										WSlot:Rebuild()
										WSlot.NeedsRebuilding = true
										WSlot.RebuildTime = CurTime() + 0.1
									else
										for n = 1,10 do
											local WSX,WSY = WSlot:GetPos()
											if MouseCC(LocalPlayer().Slots.Primary[n].Pos[1] + WSX,LocalPlayer().Slots.Primary[n].Pos[2] + WSY,LocalPlayer().Slots.Primary[n].Pos[3],LocalPlayer().Slots.Primary[n].Pos[4]) then
												print("Primary Match "..n)
												local NewData = SWEPData[ LocalPlayer().Inventory[i].Type ]
												local SecData = SWEPData[ LocalPlayer().Slots.Secondary[n].Inv ]
												if NewData then
													if (SecData and SecData.TwoHanded) or LocalPlayer().Slots.Secondary[n].Inv == i then
														print("Can't equip!")
													else
														LocalPlayer().Slots.Primary[n].Inv = i
														LocalPlayer():ConCommand("SBEPSlotSetup "..n.." "..i.." "..1)
														WSlot:Rebuild()
													end
												end
											end
											if MouseCC(LocalPlayer().Slots.Secondary[n].Pos[1] + WSX,LocalPlayer().Slots.Secondary[n].Pos[2] + WSY,LocalPlayer().Slots.Secondary[n].Pos[3],LocalPlayer().Slots.Secondary[n].Pos[4]) then
												print("Secondary Match "..n)
												local NewData = SWEPData[ LocalPlayer().Inventory[i].Type ]
												local PrmData = SWEPData[ LocalPlayer().Slots.Primary[n].Inv ]
												if NewData then
													if (PrmData and PrmData.TwoHanded) or LocalPlayer().Slots.Primary[n].Inv == i then
														print("Can't equip!")
													else
														LocalPlayer().Slots.Secondary[n].Inv = i
														LocalPlayer():ConCommand("SBEPSlotSetup "..n.." "..i.." "..2)
														WSlot:Rebuild()
													end
												end												
											end
										end
									end
									
									HIcon:Remove()
								end
							end						
						end
						--print(num)
					end
					
					Frame.Icon[i] = Icon
				end
				Column = Column + 1
				if Column >= MaxRowLength then
					Column = 0
					Row = Row + 1
				end
			end
		end
		
		Frame:Rebuild()
		
		
			
		LocalPlayer().InventoryDisplay = Frame
		LocalPlayer().InfoDisplay = InfoPanel
		LocalPlayer().WeaponSlot = WSlot
	end
	
	--Just a quick function to check if the mouse is in a given rect.
	function MouseCC(X,Y,W,H)
		if gui.MouseX() >= X and gui.MouseX() <= X + W then
			if gui.MouseY() >= Y and gui.MouseY() <= Y + H then
				return true
			end
		end
		return false
	end
	
----------------------------------------------------------------------------------------------------------------------------------------------------------
---																		User Messages																   ---
----------------------------------------------------------------------------------------------------------------------------------------------------------

	
	function SBEPInventoryAdd( um )
		LocalPlayer().Inventory = LocalPlayer().Inventory or {}
		table.insert(LocalPlayer().Inventory, { Type = um:ReadString(), Ammo = um:ReadFloat() } )
		--print("LocalPlayer() Inventory:")
		--PrintTable(LocalPlayer().Inventory)
	end
	usermessage.Hook("SBEPInventoryAdd", SBEPInventoryAdd)
	
	
	
	function SBEPInventoryRemove( um )
		LocalPlayer().Inventory = LocalPlayer().Inventory or {}
		table.remove(LocalPlayer().Inventory, um:ReadFloat() )
		print("Dropping Clientside")
		--print("LocalPlayer() Inventory:")
		--PrintTable(LocalPlayer().Inventory)
		LocalPlayer().InventoryDisplay:Rebuild()
	end
	usermessage.Hook("SBEPInventoryRemove", SBEPInventoryRemove)
	
	
	
	function SBEPGunChangeCL( um )
		LocalPlayer().CSlot = um:ReadFloat()
	end
	usermessage.Hook("SBEPGunChangeCL", SBEPGunChangeCL)
	
	
	
	function SBEPSlotReorder( um )
		local Dropped = um:ReadFloat()
		--print(Dropped)		
		for i=0,10 do
			local CInv = LocalPlayer().Slots.Primary[i].Inv
			if CInv == Dropped then
				LocalPlayer().Slots.Primary[i].Inv = -1
			elseif CInv > Dropped then
				LocalPlayer().Slots.Primary[i].Inv = CInv - 1
			end
			local CInv = LocalPlayer().Slots.Secondary[i].Inv
			if CInv == Dropped then
				LocalPlayer().Slots.Secondary[i].Inv = -1
			elseif CInv > Dropped then
				LocalPlayer().Slots.Secondary[i].Inv = CInv - 1
			end
		end
	end
	usermessage.Hook("SBEPSlotReorder", SBEPSlotReorder)
	
	
	
	function SBEPSenseChange( um )
		LocalPlayer().Sensitivity = um:ReadFloat()
	end
	usermessage.Hook("SBEPSenseChange", SBEPSenseChange)
	
	
	
	function SBEPSetRecoil( um )
		LocalPlayer().CRecoil = um:ReadFloat()
	end
	usermessage.Hook("SBEPSetRecoil", SBEPSetRecoil)
	
	
	
	function SBEPSetIronSights( um )
		LocalPlayer().IronSightMode = um:ReadBool()
		LocalPlayer().IronSightTime = um:ReadFloat()
	end
	usermessage.Hook("SBEPSetIronSights", SBEPSetIronSights)
	
	
	
	function SBEPEmergencyWeaponScrap( um )
		if LocalPlayer().PModel then
			if LocalPlayer().PModel:IsValid() then
				LocalPlayer().PModel:Remove()
				LocalPlayer().PModel = nil
			end
		end
		if LocalPlayer().SModel then 
			if LocalPlayer().SModel:IsValid() then
				LocalPlayer().SModel:Remove()
				LocalPlayer().SModel = nil
			end
		end
	end
	usermessage.Hook("SBEPEmergencyWeaponScrap", SBEPEmergencyWeaponScrap)
	
	
	
	function SBEPInventoryOpen( um )
		if !LocalPlayer().InventoryDisplay then
			local Wep = player:GetWeapon("SBEPWepBase")
			Wep:CreateInventory()
			gui.EnableScreenClicker(true)
			print("Creating")
		end
	end
	usermessage.Hook("SBEPInventoryOpen", SBEPInventoryOpen)
	
	
	
	function SBEPInventoryClose( um )
		if LocalPlayer().InventoryDisplay then
			LocalPlayer().InventoryDisplay:Remove()
			LocalPlayer().InventoryDisplay = nil
			LocalPlayer().InfoDisplay:Remove()
			LocalPlayer().InfoDisplay = nil
			LocalPlayer().WeaponSlot:Remove()
			LocalPlayer().WeaponSlot = nil
			gui.EnableScreenClicker(false)
			print("Removing")
		end
	end
	usermessage.Hook("SBEPInventoryClose", SBEPInventoryClose)
	
	
	
	function SWEP:DrawHUD()
		if !self.Owner.Slots or !self.PData then return end --This just gets rid of that rather annoying error when first spawned
		--print("Drawing")
		
		if !self.Owner.IronSightMode then
			local CrouchMod = 1
			if self.Owner:Crouching() then
				CrouchMod = 0.5
			end
			local AkimboPenalty = 1
			if self.Owner.Slots.Primary[self.Owner.CSlot].Inv > 0 and self.Owner.Slots.Secondary[self.Owner.CSlot].Inv > 0 then
				AkimboPenalty = self.SData.AkimboPenalty * 1
			end
			--self:ShootBullet( self.SData.Damage, self.SData.Bullets, math.Clamp(self.SData.Cone * CrouchMod * AkimboPenalty,0,.5) )
			local Cone = 0
			if self.PData.Cone > self.SData.Cone then
				Cone = self.PData.Cone
			else
				Cone = self.SData.Cone
			end
			local RVun = 0
			if self.PData.RecoilVulnerability > self.SData.RecoilVulnerability then
				RVun = self.PData.RecoilVulnerability
			else
				RVun = self.SData.RecoilVulnerability
			end
			local ISMod = 1
			if self.Owner.IronSightMode then
				ISMod = 0.5
			end
			local Acc = math.Clamp((Cone * CrouchMod * AkimboPenalty * ISMod) * ((self.Owner.CRecoil * RVun) + 1),0,0.3)
			
			--gets the center of the screen
			local x = (ScrW() * 0.5) - 1
			local y = (ScrH() * 0.5) - 1
			
			--set the drawcolor
			surface.SetDrawColor( 0, 255, 0, 255 )
			
			local gap = Acc * 1000
			local length = gap + 5
			
			--draw the crosshair
			surface.DrawLine( x - length, y, x - gap, y )
			surface.DrawLine( x + length, y, x + gap, y )
			surface.DrawLine( x, y - length, x, y - gap )
			surface.DrawLine( x, y + length, x, y + gap )
		end
		
		if self.Owner.CSlot > 0 then
			local SecondaryOnly = 0
			local SameAmmo = 0
			if self.Owner.Slots.Primary[self.Owner.CSlot].Inv > 0 then
				if self.PData.AmmoType == self.SData.AmmoType then
					SameAmmo = 1
				end
			
				local LeftEdge = 1100
				
				draw.RoundedBox( 6, LeftEdge - (SameAmmo * 80), 921, 170 + (SameAmmo * 80), 76, Color( 0, 0, 0, 50 ) )
				
				local Spacer = 0
				if self:Clip1() >= 100 then
					Spacer = 20
				elseif self:Clip1() >= 10 then
					Spacer = 10
				end
				
				local Spacer2 = 0
				if self:Ammo1() >= 1000 then
					Spacer2 = 30
				elseif self:Ammo1() >= 100 then
					Spacer2 = 20
				elseif self:Ammo1() >= 10 then
					Spacer2 = 10
				end
				surface.SetFont("SBEPAmmo")
				surface.SetTextPos(LeftEdge + 30 - Spacer,933)
				surface.SetTextColor(255,230,0,200)
				surface.DrawText(self:Clip1())
				
				surface.SetFont("Trebuchet19")
				surface.SetTextPos(LeftEdge + 15,925)
				surface.SetTextColor(255,230,0,200)
				surface.DrawText("Primary")
				
				surface.SetFont("Trebuchet19")
				surface.SetTextPos(LeftEdge + 20,975)
				surface.SetTextColor(255,230,0,200)
				surface.DrawText("Clip 1")
				
				
				surface.SetFont("SBEPAmmo")
				surface.SetTextPos(LeftEdge + 110 - Spacer2,933)
				surface.SetTextColor(255,230,0,200)
				surface.DrawText(self:Ammo1())
				
				surface.SetFont("Trebuchet19")
				surface.SetTextPos(LeftEdge + 95,975)
				surface.SetTextColor(255,230,0,200)
				surface.DrawText("Reserve")
				
				surface.SetFont("Trebuchet19")
				surface.SetTextPos(LeftEdge + 107,925)
				surface.SetTextColor(255,230,0,200)
				surface.DrawText(self.PData.AmmoType)
				
				
			else
				SecondaryOnly = 180
			end
			if self.Owner.Slots.Secondary[self.Owner.CSlot].Inv > 0 then
				
				local LeftEdge = 920 + SecondaryOnly + (SameAmmo * 100)
				
				draw.RoundedBox( 6, LeftEdge, 921, 170 + (SameAmmo * 80), 76, Color( 0, 0, 0, 50 ) )
				
				local Spacer = 0
				if self:Clip2() >= 100 then
					Spacer = 20
				elseif self:Clip2() >= 10 then
					Spacer = 10
				end
				
				local Spacer2 = 0
				if self:Ammo2() >= 1000 then
					Spacer2 = 30
				elseif self:Ammo2() >= 100 then
					Spacer2 = 20
				elseif self:Ammo2() >= 10 then
					Spacer2 = 10
				end
				surface.SetFont("SBEPAmmo")
				surface.SetTextPos(LeftEdge + 30 - Spacer,933)
				surface.SetTextColor(255,230,0,200)
				surface.DrawText(self:Clip2())
				
				surface.SetFont("Trebuchet19")
				surface.SetTextPos(LeftEdge + 5,925)
				surface.SetTextColor(255,230,0,200)
				surface.DrawText("Secondary")
				
				surface.SetFont("Trebuchet19")
				surface.SetTextPos(LeftEdge + 20,975)
				surface.SetTextColor(255,230,0,200)
				surface.DrawText("Clip 2")
				
				if SameAmmo <= 0 then
					surface.SetFont("SBEPAmmo")
					surface.SetTextPos(LeftEdge + 110 - Spacer2,933)
					surface.SetTextColor(255,230,0,200)
					surface.DrawText(self:Ammo2())
					
					surface.SetFont("Trebuchet19")
					surface.SetTextPos(LeftEdge + 95,975)
					surface.SetTextColor(255,230,0,200)
					surface.DrawText("Reserve")
					
					surface.SetFont("Trebuchet19")
					surface.SetTextPos(LeftEdge + 107,925)
					surface.SetTextColor(255,230,0,200)
					surface.DrawText(self.SData.AmmoType)
				end
			end
		end
	end
	
	
	function SWEP:HUDShouldDraw( element )
		if (element == "CHudCrosshair") then
			if self.PData and self.SData then
				if self.PData.Crosshair or self.SData.Crosshair then
					return true
				end
			end
			return false
		end
		
		if (element == "CHudWeaponSelection") then
			return false
		end
		
		return true
	end
end

function InvPrint()
	if CLIENT then
		PrintTable(self.Owner.Inventory)
	end
	if SERVER then
		PrintTable(player.GetByID(1).Inventory)
	end
end

function SBEPClientWeaponModelRemoval(ply, attacker, dmginfo)
	umsg.Start("SBEPEmergencyWeaponScrap", ply )
	umsg.End()

end
hook.Add("DoPlayerDeath", "SBEPClientWeaponModelRemoval", SBEPClientWeaponModelRemoval)