include('shared.lua')
--killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))
local Glow = Material( "sprites/light_glow02_add" )
local FesterMat = Material("models/barnacle/roots")
local AntMat = Material("models/antlion/antlion_innards")
function ENT:Initialize()
        self.STime = math.Rand(0,20)--CurTime()
        self.OldMutation = 0
        self.VEn = 0
        self.SizeMin = 0.2
        self.SizeMul = 0.06
        self.SizeSpeed = 0.1
        --print("Initializing")
        self.Accs = {}
        self.AccIn = 0
        self.DeployTime = 0
        self.LTT = 0
end
 
function ENT:Draw()
        self:DrawModel()
end
 
function ENT:Think()
        local Delta = CurTime() - self.LTT
        --self.AccIn = 0
        local Mutation = self.dt.Mutation
        if Mutation ~= self.OldMutation then
                --self.VEn = 0
        end
        local Dist = math.abs(self.dt.Energy - self.VEn)
        self.VEn = math.Approach(self.VEn,self.dt.Energy,Dist * 0.01)
       
        --local Age = math.Clamp(CurTime() - self.STime,0,60)
        local Size = (self.VEn * self.SizeMul) + self.SizeMin
       
        local Cycle = math.fmod(CurTime() + self.STime,36) * 2 --Note to self: Ask Hysteria if using sine on massive numbers makes any difference in speed.
       
        local W = ((math.sin(Cycle) * 0.002) * 0.2)
       
        --
        ----render.SetMaterial( FesterMat )
        --local Up = self:GetUp()
        --local Rg = self:GetRight()
        --local GW = Age * 0.5
        --local C1 = self:GetPos() + (Rg * GW) + (Up * GW)
        --local C2 = self:GetPos() - (Rg * GW) + (Up * GW)
        --local C3 = self:GetPos() - (Rg * GW) - (Up * GW)
        --local C4 = self:GetPos() + (Rg * GW) - (Up * GW)
        --render.DrawQuad( C1, C2, C3, C4 )    
        --
       
        --self:SetModelScale(Vector(Size - W,Size + W,Size + W))
        --self:SetModel( "models/Items/AR2_Grenade.mdl" )
        --self:SetModel( "models/Weapons/w_bugbait.mdl" )
        --self:SetModel( "models/Gibs/Antlion_gib_small_1.mdl" )
        --self:SetMaterial("models/antlion/antlion_innards")
        --self:SetModel( "models/props_phx/gibs/flakgib1.mdl" )
        --self.Entity:SetModel( "models/props_junk/watermelon01.mdl" )
       
       
        ---------------------------------------------------------- Seedling ----------------------------------------------------------
        if Mutation == 0 then
                self:SetModelScale(Size - W,  0.07)
                self.Entity:SetModel( "models/props_junk/watermelon01.mdl" )
                self:SetMaterial("models/antlion/antlion_innards")
                if self.VEn > 20 then
                        self.VEn = 20
                end
                self.SizeMin = 0.2
                self.SizeMul = 0.06
                self.SizeSpeed = 0.01
               
        ---------------------------------------------------------- Spreader ----------------------------------------------------------
        elseif Mutation == 1 then
                self:SetModelScale(Size - W * 0.8)
                self:SetModel( "models/Weapons/w_bugbait.mdl" )
                self:SetMaterial()
                if self.VEn > 100 then
                        self.VEn = 100
                end
                self.SizeMin = 0.2
                self.SizeMul = 0.06
                self.SizeSpeed = 0.01
               
        ---------------------------------------------------------- Overlord ----------------------------------------------------------
        elseif Mutation == 2 then
                self:SetModelScale(Size + W * 0.8)
                self:SetModel( "models/Weapons/w_bugbait.mdl" )
                self:SetMaterial()
                if !self.Accs[0] then
                        --print("Making the model...")
                        self.Accs[0] = ClientsideModel("models/Gibs/Antlion_gib_medium_3a.mdl", RENDERGROUP_OPAQUE)
                        self.AccIn = 0
                else
                        self.AccIn = math.Approach(self.AccIn,1,0.005)
                        --print("Model exists, moving it into position...")
                        local Horn = self.Accs[0]
                        local RA = self:GetAngles()
                        RA:RotateAroundAxis(self:GetUp(),-90)
                        RA:RotateAroundAxis(self:GetRight(),(5*W)-20)
                        Horn:SetAngles(RA)
                        local HScale = (0.2 * self.AccIn)
                        --print(Size)
                        Horn:SetPos(self:GetPos() + (self:GetUp() * ((Size + (W * 3)) * 1.5 * self.AccIn)) + (self:GetForward() * ((Size - W) * 3 * self.AccIn)))
                        Horn:SetModelScale(Size*HScale)
                end
               
                if !self.Accs[1] then
                        --print("Making the model...")
                        self.Accs[1] = ClientsideModel("models/Gibs/Antlion_gib_medium_3a.mdl", RENDERGROUP_OPAQUE)
                        self.AccIn = 0
                else
                        --print("Model exists, moving it into position...")
                        local Horn = self.Accs[1]
                        local RA = self:GetAngles()
                        RA:RotateAroundAxis(self:GetUp(),-90)
                        RA:RotateAroundAxis(self:GetRight(),(5*W)-20)
                        RA:RotateAroundAxis(self:GetForward(),180)
                        Horn:SetAngles(RA)
                        local HScale = (0.2 * self.AccIn)
                        Horn:SetPos(self:GetPos() + (self:GetUp() * ((Size + (W * 3)) * -1.5 * self.AccIn)) + (self:GetForward() * ((Size - W) * 3 * self.AccIn)))
                        Horn:SetModelScale(Size*HScale)
                end
                self.SizeMin = 1
                self.SizeMul = 0.05
                self.SizeSpeed = 0.1
               
        ---------------------------------------------------------- Queen ----------------------------------------------------------
        elseif Mutation == 3 then
                self:SetModelScale(Size - W * 0.8)
                self:SetModel( "models/Weapons/w_bugbait.mdl" )
                self:SetMaterial()
                if !self.Accs[0] then
                        --print("Making the model...")
                        self.Accs[0] = ClientsideModel("models/Gibs/Antlion_gib_medium_3a.mdl", RENDERGROUP_OPAQUE)
                else
                        --print("Model exists, moving it into position...")
                        local Horn = self.Accs[0]
                        local RA = self:GetAngles()
                        RA:RotateAroundAxis(self:GetUp(),-90)
                        RA:RotateAroundAxis(self:GetRight(),(5*W)-20)
                        Horn:SetAngles(RA)
                        local HScale = 0.2
                        --print(Size)
                        Horn:SetPos(self:GetPos() + (self:GetUp() * ((Size + (W * 3)) * 1.5)) + (self:GetForward() * ((Size - W) * 3)))
                        Horn:SetModelScale(Size*HScale)
                end
               
                if !self.Accs[1] then
                        --print("Making the model...")
                        self.Accs[1] = ClientsideModel("models/Gibs/Antlion_gib_medium_3a.mdl", RENDERGROUP_OPAQUE)
                        self.AccIn = 0
                else
                        --print("Model exists, moving it into position...")
                        local Horn = self.Accs[1]
                        local RA = self:GetAngles()
                        RA:RotateAroundAxis(self:GetUp(),-90)
                        RA:RotateAroundAxis(self:GetRight(),(5*W)-20)
                        RA:RotateAroundAxis(self:GetForward(),180)
                        Horn:SetAngles(RA)
                        local HScale = 0.2
                        Horn:SetPos(self:GetPos() + (self:GetUp() * ((Size + (W * 3)) * -1.5)) + (self:GetForward() * ((Size - W) * 3)))
                        Horn:SetModelScale(Size*HScale)
                end
               
                if !self.Accs[2] then
                        --print("Making the model...")
                        self.Accs[2] = ClientsideModel("models/Gibs/gunship_gibs_sensorarray.mdl", RENDERGROUP_OPAQUE)
                        self.AccIn = 0
                else
                        self.AccIn = math.Approach(self.AccIn,1,0.005)
                        --print("Model exists, moving it into position...")
                        local Eye = self.Accs[2]
                        local RA = self:GetAngles()
                        --RA:RotateAroundAxis(self:GetUp(),-10)
                        RA:RotateAroundAxis(self:GetRight(),25)
                        RA:RotateAroundAxis(self:GetForward(),90)
                        Eye:SetAngles(RA)
                        local HScale = (0.1 + (W * -0.005)) * self.AccIn
                        Eye:SetPos(self:GetPos() + (self:GetForward() * ((Size - W) * 4 * self.AccIn)))
                        Eye:SetModelScale(Size*HScale)
                end
                self.SizeMin = 1
                self.SizeMul = 0.05
                self.SizeSpeed = 0.1
               
       
        ---------------------------------------------------------- Gnat ----------------------------------------------------------     
        elseif Mutation == 10 then
                self:SetModelScale(Size - W, 1)
                if self.VEn > 10 then
                        self.VEn = 10
                end
               
                self:SetModel( "models/Gibs/Antlion_gib_small_1.mdl" )
                self.SizeMin = .1
                self.SizeMul = 0.05
                self.SizeSpeed = 0.1
               
               
        ---------------------------------------------------------- Spitter ----------------------------------------------------------  
        elseif Mutation == 20 then
       
                self:SetModelScale(Size - W * 0.8)
                self:SetModel( "models/Weapons/w_bugbait.mdl" )
                self:SetMaterial()
                if self.dt.Deploy then
                        self.DeployTime = math.Approach(self.DeployTime,1,2 * Delta)
                else
                        self.DeployTime = math.Approach(self.DeployTime,0,2 * Delta)
                end
               
                if !self.Accs[0] then
                        --print("Making the model...")
                        --self.Accs[0] = ClientsideModel("models/Weapons/w_physics.mdl", RENDERGROUP_OPAQUE)
                        self.Accs[0] = ClientsideModel("models/Weapons/w_portalgun.mdl", RENDERGROUP_OPAQUE)
                       
                        self.Accs[0]:SetMaterial("models/flesh")
                else
                        local D = self.DeployTime
                        local ET = math.Clamp(D,0,0.25) * 4
                        local RT = math.Clamp(D - 0.25,0,0.25) * 4
                        local MT = math.Clamp(D - 0.5,0,0.25) * 4
                        local AT = math.Clamp(D - 0.75,0,0.25) * 4
                        local Spout = self.Accs[0]
                        if D < 1 then
                                local Dir = (Spout:GetPos() - self.dt.Target):Angle()
                                Dir:RotateAroundAxis(Dir:Forward(),-90)
                                local RA = (self:GetAngles():Forward() * -1):Angle()
                                RA:RotateAroundAxis(self:GetRight(),-90*RT)
                                RA:RotateAroundAxis(RA:Forward(),-90)
                                local Ang = LerpAngle( AT, RA, Dir )
                                Spout:SetAngles(Ang)
                        else
                                local Dir = (Spout:GetPos() - self.dt.Target):Angle()
                                Dir:RotateAroundAxis(Dir:Forward(),-90)
                                Spout:SetAngles(Dir)
                        end
                        local HScale = (((Size * 0.04) + (W * -0.005)) * D) + 0.16
                        Spout:SetPos(self:GetPos() + (self:GetForward() * ((Size * 6 * ET) - (W*2) + 2 )) + Spout:GetForward() * ((Size - W + 2) * 2 * MT) )
                        Spout:SetModelScale(Size*HScale)
                       
                        if D >= 1 then
                                local effectdata = EffectData()
                                local MPos = Spout:GetPos() + Spout:GetForward() * (-20*Size*HScale)
                                effectdata:SetOrigin( MPos )
                                --effectdata:SetStart( Spout:GetPos() + Spout:GetForward() * (10*Size*HScale) )
                                --effectdata:SetAngle( Spout:GetAngles() )
                                effectdata:SetNormal( Spout:GetForward() * -1 )
                                effectdata:SetScale( Size * 0.1 )
                                util.Effect( "StriderBlood", effectdata )
                               
                                /*
                                local effectdata = EffectData()
                                local RVec = Vector(math.Rand(-10,10),math.Rand(-10,10),math.Rand(-10,10))
                                local Vec = ((self.dt.Target + RVec) - MPos)
                                effectdata:SetStart( MPos )
                                effectdata:SetOrigin( MPos + (Vec * math.Rand(0.3,0.7)) )
                                --effectdata:SetNormal( (self.dt.Target - self:GetPos()) * 0.5 )
                                effectdata:SetScale( 1000 )
                                util.Effect( "AR2Tracer", effectdata )
                                */
                        end
                       
                        if !self.Accs[1] then
                                --print("Making the model...")
                                --self.Accs[0] = ClientsideModel("models/Weapons/w_physics.mdl", RENDERGROUP_OPAQUE)
                                self.Accs[1] = ClientsideModel("models/weapons/w_models/w_bat.mdl", RENDERGROUP_OPAQUE)
                               
                                self.Accs[1]:SetMaterial("models/props_combine/prtl_sky_sheet")
                        else
                                local Pos = self:GetPos() + self:GetForward() * ((Size * 1) + 1 - (W*3))
                                local Limb = self.Accs[1]
                                local Vec = Pos - (Spout:GetPos() + Spout:GetForward() * (-1 * Size))
                                local Dir = Vec:Angle()
                                --local AVec = WorldToLocal(Vec,Dir,Vector(0,0,0),Dir)
                                local Length = Vec:Length() + 1
                                Limb:SetAngles(Dir:Up():Angle())
                                local HScale = (Size * 0.2)
                                Limb:SetPos( Pos )
                                Limb:SetModelScale(HScale)
                        end
                end
               
                self.SizeMin = 1
                self.SizeMul = 0.05
                self.SizeSpeed = 0.1
        end
               
        self.OldMutation = self.dt.Mutation
       
        self.LTT = CurTime()
end
 
function ENT:OnRemove()
        for i=0,10 do
                if self.Accs[i] then
                        self.Accs[i]:Remove()
                end
        end
end