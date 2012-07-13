local SBEP_SWeps = {

	[ "Empty" ] = {
				Model = "models/props_junk/PopCan01a.mdl", 
				LVec = Vector(-60,-60,-60), 
				RVec = Vector(-60,-60,-60),
				IVec = Vector(0,0,0),
				MuzzlePos = Vector(0,0,0),
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 0,
				RecoilVulnerability = 0,
				Refire = 0, 
				Auto = false,
				Bullets = 0,
				Damage = 0,
				Sound = "",
				Cone = 0,
				AkimboPenalty = 1,
				ClipSize = 0,
				ReloadLength = 0,
				AmmoType = ""
				},
	[ "P33 Pereira"	] = {
				Model = "models/Dts Stuff/BF2142 weapons/eu_handgun_1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15),
				IVec = Vector(0,7,0),
				IronSPos = Vector(0,15,-7.1),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,7.2,6.1),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366), 
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 3,
				RecoilVulnerability = 2,
				Refire = 0.4, 
				Auto = false,
				Bullets = 1,
				Damage = 30,
				Sound = "Weapon_Revolver.Single",
				Cone = 0.01,
				AkimboPenalty = 1.1,
				ClipSize = 6,
				ReloadLength = .6,
				AmmoType = "357",
				Description = "The EU's primary sidearm, while accurate over short range, it should only be considered a last resort in today's confrontation.",
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "Turcotte SMG" ] = {
				Model = "models/Dts Stuff/BF2142 weapons/eu_smg_1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15),
				IVec = Vector(0,12.5,0),
				IronSPos = Vector(.34,15,-11.75),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,10,8.5), 
				--OBBMaxs = Vector(10.4496, 1.2435, 12.7074), 
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = .8,
				RecoilVulnerability = 1.5,
				Refire = 0.05, 
				Auto = true,
				Bullets = 1,
				Damage = 4,
				Sound = "Weapon_SMG1.Single",
				Cone = 0.05,
				AkimboPenalty = 1.1,
				ClipSize = 45,
				ReloadLength = .8,
				AmmoType = "SMG1",
				Description = "Originally used in law enforcement and adopted by military forces as a personal defense weapon the high-tech Turcotte Rapid SMG (Sub Machine Gun) combines the muzzle velocity of a standard assault rifle, the automatic capability of a machine gun and the portability of a pistol. Loaded with small caliber, armor-piercing rounds, the Turcotte Rapid, lacks accuracy, and stopping power at long range, but its high rate of fire makes it an effective close combat weapon.",
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end,
				CustomDraw = function(Wep,Ply,Prime,Data)
					if !Wep.RDMat then
						Wep.RDMat = Material( "sprites/light_glow02_add" )
					end
					if Ply.IronSightMode then
						
					end
				end
				},
	[ "Clark 15B" ] = {
				Model = "models/Dts Stuff/BF2142 weapons/unl_shotgun_1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15),
				IVec = Vector(0,18,0),
				IronSPos = Vector(0,15,-7.1),
				IronSAng = Angle(0,0,0),
				RDPos = Vector(-0.01,2,7.11),
				MuzzlePos = Vector(0,20,5.5),
				--OBBMaxs = Vector(20.0345, 1.5769, 7.6729),
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 4, 
				RecoilVulnerability = .5,
				Refire = 0.5, 
				Auto = false,
				Bullets = 10,
				Damage = 20,
				Sound = "Weapon_XM1014.Single",
				Cone = 0.03,
				AkimboPenalty = 2,
				ClipSize = 7,
				ReloadLength = 1,
				AmmoType = "Buckshot",
				Description = "Built with kylonite, an advanced thermoplastic shell material, and a polymer drum magazine, the gas-operated Clark 15B Combat Shotgun fires the latest fin-stabilized flechette Frag-15 rounds, which produce a circular damage pattern, most effective against close-range, light armored infantry.",
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end,
				CustomDraw = function(Wep,Ply,Prime,Data)
					if !Wep.RDMat then
						Wep.RDMat = Material( "sprites/light_glow02_add" )
					end
					if Ply.IronSightMode then
						local RDPos = Data.RDPos or Vector(0,0,0)
						local DVec = Vector(0,0,0)
						local Mdl = nil
						if Prime then
							Mdl = Wep.PModel
						else
							Mdl = Wep.SModel
						end
						if Mdl and Mdl:IsValid() then
							DVec = Mdl:GetPos() + (Mdl:GetRight() * RDPos.x) + (Mdl:GetForward() * RDPos.y) + (Mdl:GetUp() * RDPos.z)
							--print(Mdl:GetUp())
						end
						render.SetMaterial( Wep.RDMat )
						local color = Color( 255, 0, 0, 255 )
						render.DrawSprite( DVec, .3, .3, color )
						--print("Drawing")
					end
				end
				},
	[ "Krylov FA-37" ] = {
				Model = "models/Dts Stuff/BF2142 weapons/as_ar_2.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15),
				IVec = Vector(0,15,0),
				IronSPos = Vector(-.1,12,-8),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,14,6.3),
				--OBBMaxs = Vector(14.4928, 1.3651, 9.6631), 
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = .4, 
				RecoilVulnerability = 3,
				Refire = 0.11, 
				Auto = true,
				Bullets = 1,
				Damage = 12,
				Sound = "Weapon_AK47.Single",
				Cone = 0.009,
				AkimboPenalty = 3,
				ClipSize = 30,
				ReloadLength = 1.5,
				AmmoType = "AR2",
				Description = "An effective assault-rifle that sacrifices power and accuracy in favour of lighter-weight and good rate of fire. Excellent when wielded Akimbo.",
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "Scar 11"	] = {
				Model = "models/Dts Stuff/BF2142 weapons/eu_ar_1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15), 
				IVec = Vector(0,15,0),
				IronSPos = Vector(0,12,-12.35),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,16,8.8),
				--OBBMaxs = Vector(15.8443, 2.8450, 12.6117),
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = .3,
				RecoilVulnerability = 4,
				Refire = 0.15, 
				Auto = true,
				Bullets = 1,
				Damage = 15,
				Sound = "Weapon_MP5Navy.Single",
				Cone = 0.005,
				AkimboPenalty = 5,
				ClipSize = 20,
				ReloadLength = 1.8,
				AmmoType = "AR2",
				Description = "The combined effort of multiple US and European arms manufacturers, the SCAR 11 has become the standard issue Assault Rifle due to its robust firepower and ability to perform in cold weather conditions. The SCAR 11 maintains a high rate of fire even in arctic climates, using an integrated heat distributor to prevent apparatus freezing. Electronically-fired, each tungsten-core round boasts an impact velocity of over 800 m/s, penetrating even the latest body armor technologies.",
				TwoHanded = true,
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "Pilum H-AVR" ] = {
				Model = "models/Dts Stuff/BF2142 weapons/unl_av_rifle_1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15), 
				IVec = Vector(40,20,-5),
				MuzzlePos = Vector(0,42,8),
				--OBBMaxs = Vector(43.1149, 4.1845, 14.7338), 
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 5,
				RecoilVulnerability = 1,
				Refire = 1, 
				Auto = false,
				Bullets = 0,
				Damage = 0,
				Sound = "Weapon_IRifle.Single",
				Cone = 0,
				ClipSize = 4,
				ReloadLength = 2.5,
				AmmoType = "smg1",
				Description = "Unlike its siblings, the Mitchell AV-18 and Sudnik VP, the Pilum H-AVR (Heavy Anti Vehicle Rifle) lacks any guidance package, instead relying on the high speed of its projectile to eliminate targets. With an embedded, microprocessor-driven, anti-recoil system and steel alloy-composite structure, the Pilum H-AVR launches armor-piercing fin stabilized projectiles that have proven far more effective armored targets than traditional warheads, capable of punching clean through armor and detonating inside, causing massive damage to sensitive instruments and crew-members.",
				TwoHanded = true,
				CustomPrimary = function(Wep,Ply,Prime)
					local Side = 1
					if !Prime then
						Side = -1
					end
					local Shell = ents.Create( "SF-ArtShell" )
					Shell:SetAngles( Ply:EyeAngles() )
					Shell:SetPos( Ply:EyePos() + (Ply:GetAimVector() * 5) + (Ply:EyeAngles():Right() * 15 * Side) + (Ply:EyeAngles():Up() * -5.5) )
					Shell:SetOwner( Ply )
					Shell:Spawn()
					Shell:Initialize()
					Shell:Activate()
					local physi = Shell:GetPhysicsObject()
					local Acc = 50
					physi:SetVelocity((Ply:GetAimVector() * 6000) + Vector(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc)))
					
					if Prime then
						Wep:TakePrimaryAmmo( 1 )
					else
						Wep:TakeSecondaryAmmo( 1 )
					end
				end,
				CustomSecondary = function(Wep,Ply,Prime)
					--print("Secondary Fire")
				end
				},
	[ "Morretti SR4" ] = {
				Model = "models/Dts Stuff/BF2142 weapons/eu_sni_1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15),
				IVec = Vector(20,5,0),
				MuzzlePos = Vector(0,30,9.5),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366), 
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 5,
				RecoilVulnerability = 20,
				Refire = 0.3, 
				Auto = false,
				Bullets = 1,
				Damage = 70,
				Sound = "Weapon_Scout.Single",
				Cone = 0.001,
				AkimboPenalty = 2,
				ClipSize = 5,
				ReloadLength = 1.9,
				AmmoType = "357",
				Description = "The Morretti SR4 (Sniper Rifle 4) is a next generation sniping medium utilizing a semiautomatic configuration, high calibre round and telescopic sight to effectively assail medium and long-range targets. The rifle is fitted with a carbonized metal barrel to decrease thermal distortion, ensuring maximum accuracy, although the high calibre generates significant recoil, requiring a non-repetitive, one shot/one kill approach.",
				TwoHanded = true,
				CustomSecondary = function(Wep,Ply,Prime)
					if !Wep.ZLvl or Wep.ZLvl <= 0 then
						Ply:SetFOV( 35, .3 )
						umsg.Start("SBEPSenseChange", Ply )
						umsg.Float( .5 )
						umsg.End()
						
						Wep.ZLvl = 1
					elseif Wep.ZLvl == 1 then
						Ply:SetFOV( 15, .3 )
						umsg.Start("SBEPSenseChange", Ply )
						umsg.Float( .1 )
						umsg.End()
						Wep.ZLvl = 2
					elseif Wep.ZLvl >= 2 then
						Ply:SetFOV( 0, .3 )
						umsg.Start("SBEPSenseChange", Ply )
						umsg.Float( 1 )
						umsg.End()
						Wep.ZLvl = 0
					end
					if Prime then
						Wep:SetNextSecondaryFire( CurTime() + .5 )
					else
						Wep:SetNextPrimaryFire( CurTime() + .5 )
					end
				end
				},
	[ "Park 52" ] = {
				Model = "models/Dts Stuff/BF2142 weapons/as_sni_3.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15),
				IVec = Vector(80,20,0),
				MuzzlePos = Vector(0,40,10),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366), 
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 5,
				RecoilVulnerability = 5,
				Refire = 0.3, 
				Auto = false,
				Bullets = 1,
				Damage = 40,
				Sound = "Weapon_SG552.Single",
				Cone = 0.007,
				AkimboPenalty = 1.5,
				ClipSize = 15,
				ReloadLength = 1.7,
				AmmoType = "357",
				Description = "Firing a custom-designed, 14mm flechette round, the Park 52 Sniper Rifle provides an equivalent level of force and precision as the EU Morretti SR4 without the cumbersome design factors. Fabricated using the latest metallurgic technologies, the lightweight Park 52 counters accuracy-hampering movement through shock-resistant, plastic steel barrel bedding. A high-magnification scope allows the sniper a long-range visual field, which can be upgraded through the DysTek Hi-Scope X4.",
				TwoHanded = true,
				CustomSecondary = function(Wep,Ply,Prime)
					if !Wep.ZLvl or Wep.ZLvl <= 0 then
						Ply:SetFOV( 45, .3 )
						umsg.Start("SBEPSenseChange", Ply )
						umsg.Float( .5 )
						umsg.End()
						
						Wep.ZLvl = 1
					elseif Wep.ZLvl >= 1 then
						Ply:SetFOV( 0, .3 )
						umsg.Start("SBEPSenseChange", Ply )
						umsg.Float( 1 )
						umsg.End()
						Wep.ZLvl = 0
					end
					if Prime then
						Wep:SetNextSecondaryFire( CurTime() + .3 )
					else
						Wep:SetNextPrimaryFire( CurTime() + .3 )
					end
				end
				},
	[ "Bianchi FA-6" ] = {
				Model = "models/Dts Stuff/BF2142 weapons/eu_machinegun_3.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15), 
				IVec = Vector(0,15,0),
				IronSPos = Vector(0,20,-13),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,20,10.7),
				RDPos = Vector(0,-6,12.9999),
				--RDPos = Vector(0,-6,10.9999),
				--OBBMaxs = Vector(15.8443, 2.8450, 12.6117),
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = .5,
				RecoilVulnerability = .5,
				RecPos = Vector(0,-3,0),
				RelPos = Vector(0,0,-20),
				RelAng = Vector(-50,0,0),
				Refire = 0.1, 
				Auto = true,
				Bullets = 1,
				Damage = 10,
				Sound = "Weapon_ELITE.Single",
				Cone = 0.005,
				AkimboPenalty = 15,
				ClipSize = 70,
				ReloadLength = 2.3,
				AmmoType = "AR2",
				Description = "The Bianchi FA-6 Light Machine Gun is remarkably effective as a provider of suppressive fire given its all-condition resilience and lengthy firing duration. Unlike its 21st century precursors, with its heat-resistant metal alloy components and computer-driven thermal transfer system, the Bianchi FA-6 requires neither mid-battle barrel changes nor maintenance, allowing for rapid, uninterrupted fire. With a retractable bipod, the Bianchi FA-6 is most accurate when fired from the prone position.",
				TwoHanded = true,
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end,
				CustomDraw = function(Wep,Ply,Prime,Data)
					if !Wep.RDMat then
						Wep.RDMat = Material( "sprites/light_glow02_add" )
					end
					if Ply.IronSightMode then
						local RDPos = Data.RDPos or Vector(0,0,0)
						local DVec = Vector(0,0,0)
						local Mdl = nil
						if Prime then
							Mdl = Wep.PModel
						else
							Mdl = Wep.SModel
						end
						if Mdl and Mdl:IsValid() then
							DVec = Mdl:GetPos() + (Mdl:GetRight() * RDPos.x) + (Mdl:GetForward() * RDPos.y) + (Mdl:GetUp() * RDPos.z)
							--print(Mdl:GetUp())
						end
						render.SetMaterial( Wep.RDMat )
						local color = Color( 255, 0, 0, 255 )
						render.DrawSprite( DVec, .2, .2, color )
						--print("Drawing")
					end
				end
				},
	[ "Shuko K-80" ] = {
				Model = "models/Dts Stuff/BF2142 weapons/as_mg_3.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15), 
				IVec = Vector(0,15,0),
				IronSPos = Vector(0,12,-12.35),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,24,8),
				--OBBMaxs = Vector(15.8443, 2.8450, 12.6117),
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 2,
				RecoilVulnerability = 1,
				Refire = 0.08, 
				Auto = true,
				Bullets = 1,
				Damage = 8,
				Sound = "Weapon_Galil.Single",
				Cone = 0.005,
				AkimboPenalty = 20,
				ClipSize = 150,
				ReloadLength = 3.5,
				AmmoType = "AR2",
				Description = "Like its EU counterpart, the Bianchi FA-6, the PAC Shuko K-80 Light Machine Gun provides invaluable support to assault operations through unrelenting suppressive fire. Shooting smaller, nitrocellulose-molded, caseless ammunition, the Shuko K-80 boasts higher clip capacity, resulting in less frequent reloading, albeit at the expensive of per round stopping power. Like the Bianchi FA-6, the Shuko K-80 is more precise when stabilized on its protracted bipod.",
				TwoHanded = true,
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "Ganz HMG" ] = {
				Model = "models/Dts Stuff/BF2142 weapons/hmg_3.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,20,-15), 
				IVec = Vector(0,15,0),
				IronSPos = Vector(-.12,14,-13.2),
				IronSAng = Angle(1.8,-.55,0),
				MuzzlePos = Vector(0.1,28,9.3),
				--OBBMaxs = Vector(15.8443, 2.8450, 12.6117),
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = .3,
				RecoilVulnerability = .6,
				Refire = 0.06, 
				Auto = true,
				Bullets = 1,
				Damage = 15,
				Sound = "Weapon_AUG.Single",
				Cone = 0.005,
				AkimboPenalty = 25,
				ClipSize = 120,
				ReloadLength = 2.7,
				AmmoType = "AR2",
				Description = "Even more dependable than the Bianchi LMG and more relentless than the Shuko LMG, the Ganz HMG (Heavy Machinegun) is the crowning achievement in light machine gun design. Engineered from super light polymer matter, upgraded with an ultramodern onboard stabilization and heat reduction system, and fitted with an electronic double-magazine feeder, the Ganz HMG is unmatched in power, quality, and consistency of fire.",
				TwoHanded = true,
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "MW2 FAMAS"	] = {
				Model = "models/mw2/famas.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(5,12,-10),
				IVec = Vector(0,7,0),
				IronSPos = Vector(.01,7,-9.2),
				IronSAng = Angle(-2.1,.3,0),
				MuzzlePos = Vector(0,7.9,5.1),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366), 
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 1,
				RecoilVulnerability = 2,
				Refire = 0.55, 
				Auto = false,
				Bullets = 1,
				Damage = 30,
				Sound = "Weapon_FAMAS.Single",
				Cone = 0.01,
				AkimboPenalty = .6,
				ClipSize = 24,
				Crosshair = true,
				ReloadLength = 1.6,
				AmmoType = "AR2",
				RecPos = Vector(0,-3,0),
				Description = "The EU's primary sidearm, while accurate over short range, it should only be considered a last resort in today's confrontation.",
				CustomPrimary = function(Wep,Ply,Prime,Data)
					if Wep:FireCheck(Prime) then
						if Wep.Bursting <= 0 then
							Wep.Bursting = 3
						end
					else
						Wep:EmitSound( "Weapon_Pistol.Empty" )
						Wep:Reload()
					end
					Wep:SetNextPrimaryFire( CurTime() + Data.Refire )
				end,
				CustomThink = function(Wep,Ply,Prime,Data)
					if SERVER then
						Wep.Bursting = Wep.Bursting or 0
						if Wep.Bursting > 0 then
							if Wep:FireCheck(Prime) then
								Wep.NBurst = Wep.NBurst or 0
								if CurTime() > Wep.NBurst then
									local Side = 1
									if !Prime then
										Side = -1
									end
									
									local CrouchMod = 1
									if Ply:Crouching() then
										CrouchMod = 0.5
									end
									local AkimboPenalty = 1
									if (Prime and Ply.Slots.Secondary[Ply.CSlot] > 0) or (!Prime and Ply.Slots.Primary[Ply.CSlot] > 0) then
										AkimboPenalty = self.PData.AkimboPenalty * 1
									end
									local ISMod = 1
									if Ply.IronSightMode then
										ISMod = Wep.ISAccMod
									end
									Wep:ShootBullet( Data.Damage, Data.Bullets, math.Clamp((Data.Cone * CrouchMod * AkimboPenalty * ISMod) * ((Wep.CRecoil * Data.RecoilVulnerability) + 1),0,0.3) )
									
									Wep:EmitSound("Weapon_XM1014.Single")
									
									Wep:StandardMuzzleFlash(Prime)
									
									if Prime then Wep:SetNetworkedFloat( "PFTime", CurTime(), true ) else Wep:SetNetworkedFloat( "SFTime", CurTime(), true ) end
					
									Wep:Recoil(Data.Recoil * .5 * CrouchMod * AkimboPenalty)
									
									Wep:ConsumeAmmo(Prime, 1)
									Wep.NBurst = CurTime() + 0.08
									Wep.Bursting = Wep.Bursting - 1
								end
							else
								Wep:EmitSound( "Weapon_Pistol.Empty" )
								Wep.Bursting = false
								Wep:Reload()
							end
						end
					end
				end,
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "FRG-1 Grenade" ] = {
				Model = "models/Dts Stuff/BF2142 weapons/unl_grenade_frag_1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15), 
				IVec = Vector(0,15,0),
				IronSPos = Vector(0,12,-12.35),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,0,0),
				--OBBMaxs = Vector(15.8443, 2.8450, 12.6117),
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 0,
				RecoilVulnerability = 0,
				Refire = 0, 
				Auto = true,
				Bullets = 0,
				Damage = 150,
				Sound = "Weapon_MP5Navy.Single",
				Cone = 0.005,
				AkimboPenalty = 0,
				ClipSize = 1,
				ReloadLength = 0.5,
				AmmoType = "Grenade",
				Description = "Hand-thrown, the FRG-1 is a modernized Fragmentation Grenade which yields a small but highly lethal explosive radius. By substituting the traditional TNT filler with the RDX chemical compound, PNC (polyethyl nitrate cyclobutane) the grenade offers a lighter grenade with enhanced effectiveness.",
				TwoHanded = true,
				CustomPrimary = function(Wep,Ply,Prime)
					local Side = 1
					if !Prime then
						Side = -1
					end
					local Shell = ents.Create( "SF-FragNade" )
					Shell:SetAngles( Ply:GetAimVector() )
					Shell:SetPos( Ply:EyePos() + (Ply:GetAimVector() * 1) + (Ply:EyeAngles():Right() * 15 * Side) + (Ply:EyeAngles():Up() * -5.5) )
					Shell:SetOwner( Ply )
					Shell:Spawn()
					Shell:Initialize()
					Shell:Activate()
					local physi = Shell:GetPhysicsObject()
					local Acc = 50
					physi:SetVelocity((Ply:GetAimVector() * 600) + Vector(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc)))
					
					if Prime then
						Wep:TakePrimaryAmmo( 1 )
					else
						Wep:TakeSecondaryAmmo( 1 )
					end
				end
				},
	[ "RDX DemoPak"	] = {
				Model = "models/Dts Stuff/BF2142 weapons/unl_c4_1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,25,-15), 
				IVec = Vector(0,15,0),
				IronSPos = Vector(0,12,-12.35),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,0,0),
				--OBBMaxs = Vector(15.8443, 2.8450, 12.6117),
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = .3,
				RecoilVulnerability = 4,
				Refire = 0.15, 
				Auto = true,
				Bullets = 1,
				Damage = 15,
				Sound = "Weapon_MP5Navy.Single",
				Cone = 0.005,
				AkimboPenalty = 5,
				ClipSize = 20,
				ReloadLength = 1.8,
				AmmoType = "AR2",
				Description = "Similar to its predecessor, C4, RDX DemoPak is a remotely detonated, plastic-bonded, chemical explosive. The RDX is infused with the highly stable high explosive chemical compound, PNC (polyethyl nitrate cyclobutane), increasing its optimum effective explosive output.",
				TwoHanded = true,
				CustomSecondary = function(Wep,Ply,Prime)
					if !Ply.IronSightMode then
						Ply:SetFOV( 35, .5 )
						umsg.Start("SBEPSetIronSights", Ply )
						umsg.Bool(true)
						umsg.Float( CurTime() )
						umsg.End()
						
						Ply.IronSightMode = true
					else
						Ply:SetFOV( 0, .5 )
						umsg.Start("SBEPSetIronSights", Ply )
						umsg.Bool(false)
						umsg.Float( CurTime() )
						umsg.End()
						Ply.IronSightMode = false
					end
					if Prime then
						Wep:SetNextSecondaryFire( CurTime() + .5 )
					else
						Wep:SetNextPrimaryFire( CurTime() + .5 )
					end
				end
				},
	[ "TB-15 Plasma Accelerator" ] = {
				Model = "models/Cerus/Weapons/plas_cannon.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(11,-10,-10), 
				IVec = Vector(-30,35,0),
				IronSPos = Vector(0,12,-12.35),
				IronSAng = Angle(0,0,0),
				--OBBMaxs = Vector(15.8443, 2.8450, 12.6117),
				RAng = Angle(0,180,0), 
				LAng = Angle(0,0,0), 
				Recoil = 0,
				RecoilVulnerability = 0,
				Refire = 10, 
				Auto = false,
				Bullets = 1,
				Damage = 666,
				Sound = "Weapon_MP5Navy.Single",
				Cone = 0.01,
				AkimboPenalty = 0,
				ClipSize = 1,
				ReloadLength = 5,
				AmmoType = "AR2",
				Description = "The Claret Arms TB-15 Plasma Accelerator. Built in the late 22nd century, the plasma accelerator was intended to provide crucial anti-vehicular capabilities to land-based troops. The Accelerator first compresses and super-heats a bolt of plasma, before using a magnetic launching array to catapult the deadly projectile at high speeds. One drawback of this system is that the Accelerator needs to be charged before it fires. Soldiers can reduce the charge-time at the expense of payload damage, or overcharge it for a massive impact. The lack of a guidance system makes the weapon unwieldy against air targets, but its high speed and heavy impact ensure that whatever is on the wrong end of the Accelerator will not be having a good day.", --\n\nHealth and safety tips: \n- Aim away from face.\n- Always maintain a minimum safe distance from the target. For maximum safety, try standing on a different planet from your target.\n- Do not overcharge the Accelerator, unless you really like stuff blowing up in your face.\n- No really, don't.\n-Once the firing process has begun, it cannot be stopped.\n-Before firing the weapon, always ensure you have a safe direction in which to discharge it.\n-Holstering this weapon while charging is a VERY BAD IDEA.\n-No, you know what? For the health and safety of yourself and everyone around you, DO NOT FIRE THIS WEAPON!
				TwoHanded = true,
				CustomThink = function(Wep,Ply,Prime)
					if SERVER then
						Wep.PlasmaPower = Wep.PlasmaPower or 0
						if ((Prime and Ply:KeyDown(IN_ATTACK)) or (!Prime and Ply:KeyDown(IN_ATTACK2))) and Wep.PlasmaPower < 251 then
							if Wep.PoweringUp then
								Wep.PlasmaPower = math.Clamp(Wep.PlasmaPower + 1,0,255)
							else
								if !((Wep.PReloading or Wep:Clip1() == 0) and Prime) and !((Wep.SReloading or Wep:Clip2() == 0) and !Prime) then
									Wep.PoweringUp = true
									Wep.PlasmaPower = 0
								end
							end
						else
							if Wep.PoweringUp then
								if Wep.PlasmaPower >= 250 then
									local Shell = ents.Create( "SF-PlasmaBlast" )
									Shell:SetAngles( Ply:EyeAngles() )
									Shell:SetPos( Ply:EyePos() + (Ply:GetAimVector() * -11) + (Ply:EyeAngles():Right() * 15 * Side) + (Ply:EyeAngles():Up() * -5.5) )
									Shell:SetOwner( Ply )
									Shell:Spawn()
									Shell:Initialize()
									Shell.Power = Wep.PlasmaPower
									Shell:Activate()
									Shell:GoBang()
									Wep.PoweringUp = false
								else
									local Side = 1
									if !Prime then
										Side = -1
									end
									local Shell = ents.Create( "SF-PlasmaBlast" )
									Shell:SetAngles( Ply:EyeAngles() )
									Shell:SetPos( Ply:EyePos() + (Ply:GetAimVector() * 1) + (Ply:EyeAngles():Right() * 15 * Side) + (Ply:EyeAngles():Up() * -5.5) )
									Shell:SetOwner( Ply )
									Shell:Spawn()
									Shell:Initialize()
									Shell.Power = Wep.PlasmaPower
									Shell:Activate()
									local physi = Shell:GetPhysicsObject()
									local Acc = 50
									physi:SetVelocity((Ply:GetAimVector() * 600) + Vector(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc)))
									Wep.PoweringUp = false
								end
							end
							Wep.PlasmaPower = 0
						end
					end
					if CLIENT then
						--print("CLIENT IS THINKING!")
						if LocalPlayer() == Ply then
							if input.IsMouseDown(MOUSE_LEFT) then
								--print("Clicking")
								if !Wep.Anim then
									local sequence = Wep.PModel:LookupSequence("Charge")
									Wep.PModel:ResetSequence(sequence)
									Wep.PModel:SetCycle(0)
									Wep.Anim = true
								end
							else
								Wep.PModel.AutomaticFrameAdvance = true
								local sequence = Wep.PModel:LookupSequence("Idle")
								Wep.PModel:SetSequence(sequence)
								Wep.PModel:FrameAdvance()
								Wep.PModel:SetCycle(0)
								Wep.Anim = false
							end
							Wep.PModel:FrameAdvance()
						end
					end
				end,
				CustomPrimary = function(Wep,Ply,Prime)
					local Side = 1
					if !Prime then
						Side = -1
					end
				end
				},
	[ "Blast Rifle" ] = {
				Model = "models/Spacebuild/Nova/dronegun1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,20,-20), 
				IVec = Vector(20,10,10),
				MuzzlePos = Vector(0,20,17),
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 5,
				RecoilVulnerability = 5,
				Refire = .3, 
				Auto = false,
				Bullets = 0,
				Damage = 0,
				Sound = "Weapon_XM1014.Single",
				Cone = 0.01,
				AkimboPenalty = 2,
				ClipSize = 45,
				ReloadLength = 2,
				AmmoType = "AR2",
				Description = "Unlike its siblings, the Mitchell AV-18 and Sudnik VP, the Pilum H-AVR (Heavy Anti Vehicle Rifle) lacks any guidance package, instead relying on the high speed of its projectile to eliminate targets. With an embedded, microprocessor-driven, anti-recoil system and steel alloy-composite structure, the Pilum H-AVR launches armor-piercing fin stabilized projectiles that have proven far more effective armored targets than traditional warheads, capable of punching clean through armor and detonating inside, causing massive damage to sensitive instruments and crew-members.",
				CustomPrimary = function(Wep,Ply,Prime,Data)
					if Wep:FireCheck(Prime) then
						local Side = 1
						if !Prime then
							Side = -1
						end
						
						local CrouchMod = 1
						if Ply:Crouching() then
							CrouchMod = 0.5
						end
						local AkimboPenalty = 1
						if Ply.Slots.Secondary[Ply.CSlot] > 0 then
							AkimboPenalty = Data.AkimboPenalty
						end
						local Acc = math.Clamp((Data.Cone * CrouchMod * AkimboPenalty) * ((Wep.CRecoil * Data.RecoilVulnerability) + 1) * 10, 0, 10)
						--local AVec = (Ply:GetAimVector() * 1000) + Vector(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc))
						local AAng = (Ply:EyeAngles() + Angle(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc)))
						local Shell = ents.Create( "SF-MicroRocket" )
						Shell:SetAngles( AAng )
						Shell:SetPos( Ply:EyePos() + (Ply:GetAimVector() * 1) + (Ply:EyeAngles():Right() * 15 * Side) + (Ply:EyeAngles():Up() * -5.5) )
						Shell:SetOwner( Ply )
						Shell:Spawn()
						Shell.Drunk = math.Clamp(Acc * 5,5,20)
						Shell:Initialize()
						Shell:Activate()
						local physi = Shell:GetPhysicsObject()
						
						physi:SetVelocity(Shell:GetForward() * 1000)
						
						Wep:EmitSound("Weapon_XM1014.Single")
		
						Wep:Recoil(Data.Recoil * CrouchMod * AkimboPenalty)
						
						Wep:StandardMuzzleFlash(Prime)
						
						Wep:ConsumeAmmo(Prime, 1)
						
						Wep:SetNextPrimaryFire( CurTime() + Data.Refire )
					else
						Wep:ReloadCheck(Prime)
					end
				end,
				CustomSecondary = function(Wep,Ply,Prime)
					if Wep:FireCheck(Prime) then
						Wep.Bursting = !Wep.Bursting
					else
						Wep:EmitSound( "Weapon_Pistol.Empty" )
						Wep:Reload()
					end
					Wep:SetNextSecondaryFire( CurTime() + .2 )
				end,
				CustomThink = function(Wep,Ply,Prime,Data)
					if SERVER then
						if Wep.Bursting then
							if Wep:FireCheck(Prime) then
								Wep.NBurst = Wep.NBurst or 0
								if CurTime() > Wep.NBurst then
									local Side = 1
									if !Prime then
										Side = -1
									end
									
									local CrouchMod = 1
									if Ply:Crouching() then
										CrouchMod = 0.5
									end
									local AkimboPenalty = 1
									if Ply.Slots.Secondary[Ply.CSlot] > 0 then
										AkimboPenalty = Data.AkimboPenalty
									end
									local Acc = math.Clamp((Data.Cone * CrouchMod * AkimboPenalty) * ((Wep.CRecoil * Data.RecoilVulnerability) + 1) * 20, 0, 20)
									local AAng = (Ply:EyeAngles() + Angle(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc)))
									--local AVec = (Ply:GetAimVector() * 1000) + Vector(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc))
									local Shell = ents.Create( "SF-MicroRocket" )
									Shell:SetAngles( AAng )
									Shell:SetPos( Ply:EyePos() + (Ply:GetAimVector() * 1) + (Ply:EyeAngles():Right() * 15 * Side) + (Ply:EyeAngles():Up() * -5.5) )
									Shell:SetOwner( Ply )
									Shell:Spawn()
									Shell.Drunk = math.Clamp(Acc * 5,5,20)
									Shell:Initialize()
									Shell:Activate()
									local physi = Shell:GetPhysicsObject()
									physi:SetVelocity(Shell:GetForward() * 1000)
									
									Wep:EmitSound("Weapon_XM1014.Single")
									
									Wep:StandardMuzzleFlash(Prime)
					
									Wep:Recoil(Data.Recoil * .5 * CrouchMod * AkimboPenalty)
									
									Wep:ConsumeAmmo(Prime, 1)
									Wep.NBurst = CurTime() + 0.1
								end
							else
								Wep:EmitSound( "Weapon_Pistol.Empty" )
								Wep.Bursting = false
								Wep:Reload()
							end
						end
					end
				end
				},
	[ "Sudnik Flamer" ] = {
				Model = "models/Dts Stuff/BF2142 weapons/as_aa_3.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(10,20,-20), 
				IVec = Vector(20,10,10),
				MuzzlePos = Vector(0,20,17),
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 0.1,
				RecoilVulnerability = 0.1,
				Refire = .1, 
				Auto = true,
				Bullets = 0,
				Damage = 0,
				Sound = "",
				Cone = 0.5,
				AkimboPenalty = 2,
				ClipSize = 150,
				ReloadLength = 3,
				AmmoType = "AR2",
				Description = "Unlike its siblings, the Mitchell AV-18 and Sudnik VP, the Pilum H-AVR (Heavy Anti Vehicle Rifle) lacks any guidance package, instead relying on the high speed of its projectile to eliminate targets. With an embedded, microprocessor-driven, anti-recoil system and steel alloy-composite structure, the Pilum H-AVR launches armor-piercing fin stabilized projectiles that have proven far more effective armored targets than traditional warheads, capable of punching clean through armor and detonating inside, causing massive damage to sensitive instruments and crew-members.",
				CustomPrimary = function(Wep,Ply,Prime,Data)
					if Wep:FireCheck(Prime) then
						local Side = 1
						if !Prime then
							Side = -1
						end
							
						local CrouchMod = 1
						if Ply:Crouching() then
							CrouchMod = 0.5
						end
						local AkimboPenalty = 1
						if Ply.Slots.Secondary[Ply.CSlot] > 0 then
							AkimboPenalty = Data.AkimboPenalty
						end
						local Acc = math.Clamp((Data.Cone * CrouchMod * AkimboPenalty) * ((Wep.CRecoil * Data.RecoilVulnerability) + 1) * 20, 0, 20)
						local AAng = (Ply:EyeAngles() + Angle(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc)))
						--local AVec = (Ply:GetAimVector() * 1000) + Vector(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc))
						local Shell = ents.Create( "FlameGout" )
						Shell:SetAngles( AAng )
						Shell:SetPos( Ply:EyePos() + (Ply:GetAimVector() * 18) + (Ply:EyeAngles():Right() * 4 * Side) + (Ply:EyeAngles():Up() * -5.5) )
						Shell:SetOwner( Ply )
						Shell:Spawn()
						Shell:Activate()
						local physi = Shell:GetPhysicsObject()
						--print(physi)
						physi:SetVelocity(Ply:GetAimVector()*100)
							
						--Wep:StandardMuzzleFlash(Prime)
			
						--Wep:Recoil(Data.Recoil * .5 * CrouchMod * AkimboPenalty)
							
						Wep:ConsumeAmmo(Prime, 1)
						
						Wep:SetNextPrimaryFire( CurTime() + Data.Refire )
					else
						Wep:ReloadCheck(Prime)
					end
				end,
				CustomThink = function(Wep,Ply,Prime)
					if SERVER then
						Wep.PlasmaPower = Wep.PlasmaPower or 0
						if ((Prime and Ply:KeyDown(IN_ATTACK)) or (!Prime and Ply:KeyDown(IN_ATTACK2))) and Wep.PlasmaPower < 251 then
							if Wep.PoweringUp then
								Wep.PlasmaPower = math.Clamp(Wep.PlasmaPower + 1,0,255)
							else
								if !((Wep.PReloading or Wep:Clip1() == 0) and Prime) and !((Wep.SReloading or Wep:Clip2() == 0) and !Prime) then
									Wep.PoweringUp = true
									Wep.PlasmaPower = 0
								end
							end
						else
							if Wep.PoweringUp then
								if Wep.PlasmaPower >= 250 then
									local Shell = ents.Create( "SF-PlasmaBlast" )
									Shell:SetAngles( Ply:EyeAngles() )
									Shell:SetPos( Ply:EyePos() + (Ply:GetAimVector() * -11) + (Ply:EyeAngles():Right() * 15 * Side) + (Ply:EyeAngles():Up() * -5.5) )
									Shell:SetOwner( Ply )
									Shell:Spawn()
									Shell:Initialize()
									Shell.Power = Wep.PlasmaPower
									Shell:Activate()
									Shell:GoBang()
									Wep.PoweringUp = false
								else
									local Side = 1
									if !Prime then
										Side = -1
									end
									local Shell = ents.Create( "SF-PlasmaBlast" )
									Shell:SetAngles( Ply:EyeAngles() )
									Shell:SetPos( Ply:EyePos() + (Ply:GetAimVector() * 1) + (Ply:EyeAngles():Right() * 15 * Side) + (Ply:EyeAngles():Up() * -5.5) )
									Shell:SetOwner( Ply )
									Shell:Spawn()
									Shell:Initialize()
									Shell.Power = Wep.PlasmaPower
									Shell:Activate()
									local physi = Shell:GetPhysicsObject()
									local Acc = 50
									physi:SetVelocity((Ply:GetAimVector() * 600) + Vector(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc)))
									Wep.PoweringUp = false
								end
							end
							Wep.PlasmaPower = 0
						end
					end
					if CLIENT then
						--print("CLIENT IS THINKING!")
						if LocalPlayer() == Ply then
							if input.IsMouseDown(MOUSE_LEFT) then
								--print("Clicking")
								if !Wep.Anim then
									local sequence = Wep.PModel:LookupSequence("Charge")
									Wep.PModel:ResetSequence(sequence)
									Wep.PModel:SetCycle(0)
									Wep.Anim = true
								end
							else
								Wep.PModel.AutomaticFrameAdvance = true
								local sequence = Wep.PModel:LookupSequence("Idle")
								Wep.PModel:SetSequence(sequence)
								Wep.PModel:FrameAdvance()
								Wep.PModel:SetCycle(0)
								Wep.Anim = false
							end
							Wep.PModel:FrameAdvance()
						end
					end
				end
				},
	[ "SI-HTR Assault"	] = {
				Model = "models/Slyfo_2/swep_assault_rifle1base.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(5,12,-5),
				IVec = Vector(0,7,0),
				IronSPos = Vector(0,11,-1.61),
				IronSAng = Angle(.5,0,0),
				MuzzlePos = Vector(0,7.2,2.1),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366), 
				Crosshair = true,
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 1,
				RecoilVulnerability = 1,
				Refire = 0.1, 
				Auto = true,
				Bullets = 1,
				Damage = 30,
				Sound = "Weapon_Pistol.Single",
				Cone = 0.01,
				AkimboPenalty = 3,
				ClipSize = 25,
				ReloadLength = 1.6,
				AmmoType = "AR2",
				RecPos = Vector(0,-3,0),
				Description = "The EU's primary sidearm, while accurate over short range, it should only be considered a last resort in today's confrontation.",
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "SI-HTR Carbine"	] = {
				Model = "models/Slyfo_2/swep_assault_rifle2.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(5,12,-7.5),
				IVec = Vector(0,7,0),
				IronSPos = Vector(0,11,-4.5),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,5,2.1),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366),
				Crosshair = true,
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 1,
				RecoilVulnerability = 2,
				Refire = 0.075, 
				Auto = true,
				Bullets = 1,
				Damage = 25,
				Sound = "Weapon_MP5Navy.Single",
				Cone = 0.02,
				AkimboPenalty = 1,
				ClipSize = 25,
				ReloadLength = 1.2,
				AmmoType = "AR2",
				RecPos = Vector(0,-3,0),
				Description = "The EU's primary sidearm, while accurate over short range, it should only be considered a last resort in today's confrontation.",
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "SI-HTR Carbine Drum-Mag"	] = {
				Model = "models/Slyfo_2/swep_assault_rifle2drum.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(5,12,-7.5),
				IVec = Vector(0,7,0),
				IronSPos = Vector(0,11,-4.5),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,5,2.1),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366),
				Crosshair = true,
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = 1.2,
				RecoilVulnerability = 2,
				Refire = 0.075, 
				Auto = true,
				Bullets = 1,
				Damage = 25,
				Sound = "Weapon_MP5Navy.Single",
				Cone = 0.022,
				AkimboPenalty = 1.4,
				ClipSize = 80,
				ReloadLength = 1.7,
				AmmoType = "AR2",
				RecPos = Vector(0,-3,0),
				Description = "The EU's primary sidearm, while accurate over short range, it should only be considered a last resort in today's confrontation.",
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "SI-HTR MP1"	] = {
				Model = "models/Slyfo_2/swep_machinepistol1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(5,12,-7.5),
				IVec = Vector(0,7,0),
				IronSPos = Vector(0,11,-4.5),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,5,2.1),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366),
				Crosshair = true,
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = .4,
				RecoilVulnerability = .4,
				Refire = 0.15, 
				Auto = false,
				Bullets = 1,
				Damage = 15,
				Sound = "Weapon_Glock.Single",
				Cone = 0.02,
				AkimboPenalty = 1,
				ClipSize = 18,
				ReloadLength = 0.7,
				AmmoType = "SMG1",
				RecPos = Vector(0,-3,0),
				Description = "The EU's primary sidearm, while accurate over short range, it should only be considered a last resort in today's confrontation.",
				CustomPrimary = function(Wep,Ply,Prime,Data)
					if Wep:FireCheck(Prime) then
						if Wep.Bursting <= 0 then
							Wep.Bursting = 3
						end
					else
						Wep:EmitSound( "Weapon_Pistol.Empty" )
						Wep:Reload()
					end
					Wep:SetNextPrimaryFire( CurTime() + Data.Refire )
				end,
				CustomThink = function(Wep,Ply,Prime,Data)
					if SERVER then
						Wep.Bursting = Wep.Bursting or 0
						if Wep.Bursting > 0 then
							if Wep:FireCheck(Prime) then
								Wep.NBurst = Wep.NBurst or 0
								if CurTime() > Wep.NBurst then
									local Side = 1
									if !Prime then
										Side = -1
									end
									
									local CrouchMod = 1
									if Ply:Crouching() then
										CrouchMod = 0.5
									end
									local AkimboPenalty = 1
									if (Prime and Ply.Slots.Secondary[Ply.CSlot] > 0) or (!Prime and Ply.Slots.Primary[Ply.CSlot] > 0) then
										AkimboPenalty = Data.AkimboPenalty * 1
									end
									local ISMod = 1
									if Ply.IronSightMode then
										ISMod = Wep.ISAccMod
									end
									Wep:ShootBullet( Data.Damage, Data.Bullets, math.Clamp((Data.Cone * CrouchMod * AkimboPenalty * ISMod) * ((Wep.CRecoil * Data.RecoilVulnerability) + 1),0,0.3) )
									
									Wep:EmitSound("Weapon_XM1014.Single")
									
									Wep:StandardMuzzleFlash(Prime)
									
									if Prime then Wep:SetNetworkedFloat( "PFTime", CurTime(), true ) else Wep:SetNetworkedFloat( "SFTime", CurTime(), true ) end
					
									Wep:Recoil(Data.Recoil * .5 * CrouchMod * AkimboPenalty)
									
									Wep:ConsumeAmmo(Prime, 1)
									Wep.NBurst = CurTime() + 0.05
									Wep.Bursting = Wep.Bursting - 1
								end
							else
								Wep:EmitSound( "Weapon_Pistol.Empty" )
								Wep.Bursting = false
								Wep:Reload()
							end
						end
					end
				end,
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "SI-HTR MP2"	] = {
				Model = "models/Slyfo_2/swep_machinepistol2.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(5,12,-7.5),
				IVec = Vector(0,7,0),
				IronSPos = Vector(0,11,-4.5),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,5,2.1),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366),
				Crosshair = true,
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = .3,
				RecoilVulnerability = .3,
				Refire = 0.3, 
				Auto = false,
				Bullets = 1,
				Damage = 20,
				Sound = "Weapon_Glock.Single",
				Cone = 0.015,
				AkimboPenalty = 1,
				ClipSize = 18,
				ReloadLength = 0.8,
				AmmoType = "SMG1",
				RecPos = Vector(0,-3,0),
				Description = "The EU's primary sidearm, while accurate over short range, it should only be considered a last resort in today's confrontation.",
				CustomPrimary = function(Wep,Ply,Prime,Data)
					if Wep:FireCheck(Prime) then
						if Wep.Bursting <= 0 then
							Wep.Bursting = 3
						end
					else
						Wep:EmitSound( "Weapon_Pistol.Empty" )
						Wep:Reload()
					end
					Wep:SetNextPrimaryFire( CurTime() + Data.Refire )
				end,
				CustomThink = function(Wep,Ply,Prime,Data)
					if SERVER then
						Wep.Bursting = Wep.Bursting or 0
						if Wep.Bursting > 0 then
							if Wep:FireCheck(Prime) then
								Wep.NBurst = Wep.NBurst or 0
								if CurTime() > Wep.NBurst then
									local Side = 1
									if !Prime then
										Side = -1
									end
									
									local CrouchMod = 1
									if Ply:Crouching() then
										CrouchMod = 0.5
									end
									local AkimboPenalty = 1
									if (Prime and Ply.Slots.Secondary[Ply.CSlot] > 0) or (!Prime and Ply.Slots.Primary[Ply.CSlot] > 0) then
										AkimboPenalty = Data.AkimboPenalty * 1
									end
									local ISMod = 1
									if Ply.IronSightMode then
										ISMod = Wep.ISAccMod
									end
									Wep:ShootBullet( Data.Damage, Data.Bullets, math.Clamp((Data.Cone * CrouchMod * AkimboPenalty * ISMod) * ((Wep.CRecoil * Data.RecoilVulnerability) + 1),0,0.3) )
									
									Wep:EmitSound("Weapon_XM1014.Single")
									
									Wep:StandardMuzzleFlash(Prime)
									
									if Prime then Wep:SetNetworkedFloat( "PFTime", CurTime(), true ) else Wep:SetNetworkedFloat( "SFTime", CurTime(), true ) end
					
									Wep:Recoil(Data.Recoil * .5 * CrouchMod * AkimboPenalty)
									
									Wep:ConsumeAmmo(Prime, 1)
									Wep.NBurst = CurTime() + 0.075
									Wep.Bursting = Wep.Bursting - 1
								end
							else
								Wep:EmitSound( "Weapon_Pistol.Empty" )
								Wep.Bursting = false
								Wep:Reload()
							end
						end
					end
				end,
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "SI-HTR SMG1"	] = {
				Model = "models/Slyfo_2/swep_smg1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(5,12,-7.5),
				IVec = Vector(0,7,0),
				IronSPos = Vector(0,11,-4.5),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,5,2.1),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366),
				Crosshair = true,
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = .5,
				RecoilVulnerability = .5,
				Refire = 0.075, 
				Auto = true,
				Bullets = 1,
				Damage = 15,
				Sound = "Weapon_USP.Single",
				Cone = 0.025,
				AkimboPenalty = 1,
				ClipSize = 40,
				ReloadLength = 2,
				AmmoType = "SMG1",
				RecPos = Vector(0,-3,0),
				Description = "The EU's primary sidearm, while accurate over short range, it should only be considered a last resort in today's confrontation.",
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "SI-HTR SMG2"	] = {
				Model = "models/Slyfo_2/swep_stowablesmg1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(5,15,-7),
				IVec = Vector(0,7,0),
				IronSPos = Vector(0,11,-4.5),
				IronSAng = Angle(0,0,0),
				MuzzlePos = Vector(0,1,0.1),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366),
				Crosshair = true,
				RAng = Angle(0,0,0), 
				LAng = Angle(0,0,0), 
				Recoil = .4,
				RecoilVulnerability = .4,
				Refire = 0.1, 
				Auto = true,
				Bullets = 1,
				Damage = 10,
				Sound = "Weapon_UMP45.Single",
				Cone = 0.025,
				AkimboPenalty = 1,
				ClipSize = 35,
				ReloadLength = 2,
				AmmoType = "SMG1",
				RecPos = Vector(0,-3,0),
				Description = "The EU's primary sidearm, while accurate over short range, it should only be considered a last resort in today's confrontation.",
				CustomSecondary = function(Wep,Ply,Prime)
					Wep:StandardIronSight(Prime)
				end
				},
	[ "SI-HTR RD-Sight"	] = {
				Model = "models/Slyfo_2/swep_acc_sight2.mdl", 
				Equipable = false,
				ModType = "HTR-Sight",
				AVec = Vector(0,0,-0.5),
				RDPos = Vector(0,0,0),
				IVec = Vector(0,7,0),
				IronSPos = Vector(0,11,-4.5),
				IronSAng = Angle(0,0,0),
				Description = "Standard Red-dot sight for the SI-HTR range of weapons.",
				CustomDraw = function(Wep,Ply,Prime,Data)
					if !Wep.RDMat then
						Wep.RDMat = Material( "sprites/light_glow02_add" )
					end
					if Ply.IronSightMode then
						local RDPos = Data.RDPos or Vector(0,0,0)
						local DVec = Vector(0,0,0)
						local Mdl = nil
						if Prime then
							Mdl = Wep.PModel
						else
							Mdl = Wep.SModel
						end
						if Mdl and Mdl:IsValid() then
							DVec = Mdl:GetPos() + (Mdl:GetRight() * RDPos.x) + (Mdl:GetForward() * RDPos.y) + (Mdl:GetUp() * RDPos.z)
							--print(Mdl:GetUp())
						end
						render.SetMaterial( Wep.RDMat )
						local color = Color( 255, 0, 0, 255 )
						render.DrawSprite( DVec, .2, .2, color )
						--print("Drawing")
					end
				end
				},
	[ "HoloAxe" ] = {
				Model = "models/Slyfo_2/holo_axe1.mdl", 
				LVec = Vector(0,0,0), 
				RVec = Vector(17,25,-11.5),
				IVec = Vector(0,7,0),
				MuzzlePos = Vector(0,5,2.1),
				--OBBMaxs = Vector(7.4234, 1.3236, 7.3366),
				Crosshair = true,
				RAng = Angle(0,180,0), 
				LAng = Angle(0,180,0), 
				Recoil = 0,
				RecoilVulnerability = .3,
				Refire = 0.3, 
				Auto = false,
				Bullets = 0,
				Damage = 20,
				--Sound = "Weapon_Glock.Single",
				Cone = 0.015,
				AkimboPenalty = 1,
				ClipSize = -1,
				ReloadLength = 0.8,
				AmmoType = "SMG1",
				RecPos = Vector(0,20,-10),
				RecAng = Vector(0,0,0),
				Description = "Caution: DO NOT DROP ON FEET! Trust me, it hurts.",
				CustomPrimary = function(Wep,Ply,Prime,Data)
					if Wep:FireCheck(Prime) then
						if Prime then
							Wep:SetNetworkedFloat( "PFTime", CurTime(), true )
						else
							Wep:SetNetworkedFloat( "SFTime", CurTime(), true )
						end
					end
					Wep:SetNextPrimaryFire( CurTime() + Data.Refire )
				end
				}
	}
	
for k,v in pairs( SBEP_SWeps ) do
	if v ~= {} then
		list.Set( "SBEP_SWeaponry", k , v )
	end
end