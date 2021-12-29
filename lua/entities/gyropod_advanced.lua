AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Advanced Gyro Pod"
ENT.Author = "Paradukes and Data"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.AdminSpawnable = false

if CLIENT then return end

local math_abs, math_round, math_clamp = math.abs, math.Round, math.Clamp
local math_NormalizeAngle = math.NormalizeAngle

local function bool_to_number(bool)
    return Either(bool, 1, 0)
end

ENT.Owner = nil
ENT.SPL = nil
ENT.Firing = false
ENT.Vec = nil
ENT.Pitch = 0
ENT.Yaw = 0
ENT.Roll = 0
ENT.MChange = false
ENT.Speed = 0
ENT.Active = false
ENT.Launchy = false
ENT.Launch = 0
ENT.Land = true
ENT.LandTime = 0
ENT.TakeOff = false
ENT.OldAngle = Angle(0, 0, 0)
ENT.EPrs = false
ENT.LTog = false
ENT.MTog = false
ENT.MCC = false
ENT.GPod = true

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMaterial("spacebuild/SBLight5")

    self.Inputs = WireLib.CreateSpecialInputs(self, {
        "Activate", "Forward", "Back",
        "MoveLeft", "MoveRight",
        "MoveUp", "MoveDown",
        "RollLeft", "RollRight",
        "PitchUp", "PitchDown",
        "YawLeft", "YawRight",
        "PitchMult", "YawMult", "RollMult",
        "ThrustMult",
        "MPH Limit", "Damper", "Level", "Roll Lock", "Freeze", "Antigravity",
        "AimMode", "AimX", "AimY", "AimZ", "AimVec [VECTOR]"
    })

    self.Outputs = WireLib.CreateSpecialOutputs(self, {
        "On", "Frozen", "Targeting Mode", "MPH", "KmPH", "Leveler", "Total Mass", "Props Linked", "Angles [ANGLE]"
    })

    local phys = self:GetPhysicsObject()

    if (IsValid(phys)) then
        phys:Wake()
    end

    self.LogicCases = ents.FindByClass("logic_case")
    self.AllGyroConstraints = {}
    self.MoveTable = {}
    self.SystemOn = false
    self.FreezeOn = false
    self.AimModeOn = false
    self.GyroSpeed = 0
    self.VSpeed = 0
    self.HSpeed = 0
    self.PMult = 1
    self.RMult = 1
    self.YaMult = 1
    self.TMult = 1
    self.SpdL = 250
    self.Damper = 5
    self.Forw = 0
    self.Back = 0
    self.SLeft = 0
    self.SRight = 0
    self.HUp = 0
    self.HDown = 0
    self.RollLeft = 0
    self.RollRight = 0
    self.GyroPitchUp = 0
    self.GyroPitchDown = 0
    self.GyroYawLeft = 0
    self.GyroYawRight = 0
    self.GyroLvl = false
    self.RollLock = false
    self.TarPos = Vector(0, 0, 0)
    self.GyroMass = 0
    self.Debug = 0
    self.GyroPitch = 0
    self.GyroYaw = 0
    self.EntSoundSource = self

    self.EnableAntigravity = false
end

function ENT:TriggerInput(iname, value)
    if (iname == "Activate") then
        self.SystemOn = value ~= 0
        self:UpdateSystemOn(self.SystemOn)
    elseif (iname == "Freeze") then
        self.FreezeOn = value ~= 0
        self:UpdateFreeze(self.FreezeOn)
    elseif (iname == "AimMode") then
        self.AimModeOn = value ~= 0
        self:UpdateAimMode(self.AimModeOn)
    elseif (iname == "Forward") then
        self.Forw = value
    elseif (iname == "Back") then
        self.Back = value
    elseif (iname == "MoveLeft") then
        self.SLeft = value
    elseif (iname == "MoveRight") then
        self.SRight = value
    elseif (iname == "MoveUp") then
        self.HUp = value
    elseif (iname == "MoveDown") then
        self.HDown = value
    elseif (iname == "RollLeft") then
        self.RollLeft = value
    elseif (iname == "RollRight") then
        self.RollRight = value
    elseif (iname == "PitchUp") then
        self.GyroPitchUp = value
    elseif (iname == "PitchDown") then
        self.GyroPitchDown = value
    elseif (iname == "YawLeft") then
        self.GyroYawLeft = value
    elseif (iname == "YawRight") then
        self.GyroYawRight = value
    elseif (iname == "PitchMult") then
        if value ~= 0 then
            self.PMult = value
        else
            self.PMult = 1
        end
    elseif (iname == "YawMult") then
        if value ~= 0 then
            self.YaMult = value
        else
            self.YaMult = 1
        end
    elseif (iname == "RollMult") then
        if value ~= 0 then
            self.RMult = value
        else
            self.RMult = 1
        end
    elseif (iname == "ThrustMult") then
        if value ~= 0 then
            self.TMult = value
        else
            self.TMult = 1
        end
    elseif (iname == "AimX") then
        self.TarPos.x = value
    elseif (iname == "AimY") then
        self.TarPos.y = value
    elseif (iname == "AimZ") then
        self.TarPos.z = value
    elseif (iname == "AimVec") then
        self.TarPos = value
    elseif (iname == "MPH Limit") then
        if (value ~= 0) then
            self.SpdL = math.Clamp(math.math_abs(value), 0, 999)
        else
            self.SpdL = 250
        end
    elseif (iname == "Damper") then
        if (value ~= 0) then
            self.Damper = math.Clamp(math.math_abs(value), 0.1, 30)
        else
            self.Damper = 5
        end
    elseif (iname == "Level") then
        self.GyroLvl = value ~= 0
    elseif (iname == "Roll Lock") then
        self.RollLock = value ~= 0
    elseif (iname == "Antigravity") then
        self.EnableAntigravity = value ~= 0
    end
end

function ENT:UpdateSystemOn(active)
    if active then
        self.AllGyroConstraints = table.GetKeys(
            constraint.GetAllConstrainedEntities(self)
        )

        if self.HighEngineSound or self.LowDroneSound then
            self.HighEngineSound:Stop()
            self.LowDroneSound:Stop()
        end

        self.HighEngineSound = CreateSound(self.EntSoundSource, Sound("ambient/atmosphere/outdoor2.wav"))
        self.LowDroneSound = CreateSound(self.EntSoundSource, Sound("ambient/atmosphere/indoor1.wav"))
        self.HighEngineSound:Play()
        self.LowDroneSound:Play()
        self.EntSoundSource:EmitSound("buttons/button1.wav")
    else
        self.EntSoundSource:EmitSound("buttons/button18.wav")
    end
end

local function Sign(n)
    if n < 0 then return -1
    elseif n > 0 then return 1
    else return 0 end
end

local function GetSpeed(speed, movement_dir, movement_value, speed_limit, damper)
    local speed_sign = Sign(speed)
    local movement_sign = Sign(movement_dir)

    movement_value = movement_value * math_abs(movement_dir)

    local speed_abs = math_abs(speed)

    if movement_sign == 0 then -- No movement input
        local value = speed_abs / 17.6 * 0.2 + damper

        if speed == 0 then
            return 0
        elseif speed > 0 then
            return speed - value
        else
            return speed + value
        end
    end

    local result_delta

    if speed_sign ~= -movement_sign then -- Forward movement
        if speed_abs / 17.6 >= speed_limit then
            return speed
        end

        result_delta = (speed_limit - speed_abs / 17.6) * movement_value * 0.05
    else -- Backward movement
        result_delta = -speed_abs / 17.6 - damper
    end

    if speed > 0 then
        return speed + result_delta
    else
        return speed - result_delta
    end
end

function ENT:ThinkActive(entpos, entorparvel, localentorparvel, speedmph, rotation_extra_mul)
    local gyroshipangles = self:GetAngles()

    if not self.weighttrigger then
        self:GyroWeight()
    end

    --changing sounds based on speed
    if speedmph > 80 then
        self.HighEngineVolume = math_clamp(((speedmph * 0.035) - 2.6), 0, 1)
    else
        self.HighEngineVolume = speedmph * 0.0025
    end

    self.HighEnginePitch = (speedmph * 1.2) + 60
    self.LowDronePitch = (speedmph * 0.2) + 35

    self.HighEngineSound.ChangeVolume(self.HighEngineSound, self.HighEngineVolume, 0)

    self.HighEngineSound.ChangePitch(self.HighEngineSound, math.Clamp(self.HighEnginePitch, 0, 255), 0)
    self.LowDroneSound.ChangePitch(self.LowDroneSound, math.Clamp(self.LowDronePitch, 0, 255), 0)

    local MulForward, MulRight, MulUp =
        self.Forw - self.Back,
        self.SRight - self.SLeft,
        self.HUp - self.HDown

    local GyroRoll = self.RollRight - self.RollLeft


    self.GyroSpeed =    GetSpeed(self.GyroSpeed,    MulForward, self.TMult, self.SpdL, self.Damper)
    self.HSpeed =       GetSpeed(self.HSpeed,       MulRight,   self.TMult, self.SpdL, self.Damper)
    self.VSpeed =       GetSpeed(self.VSpeed,       MulUp,      self.TMult, self.SpdL, self.Damper)
    --Force Application
    local mass = self.GyroMass * 0.2

    local entfor, entright, entup = self:GetForward(), self:GetRight(), self:GetUp()

    local velocity = (entfor * self.GyroSpeed) + (entup * self.VSpeed) + (entright * self.HSpeed)

    local pos_front = entpos + entfor * self.frontlength
    local pos_rear = entpos + entfor * -self.rearlength
    local pos_right = entpos + entright * self.rightwidth
    local pos_left = entpos + entright * -self.leftwidth

    local force_pitch
    local force_yaw = entright * self.GyroYaw * self.YaMult * mass * rotation_extra_mul
    local force_roll

    if self.GyroLvl then
        force_pitch = entup * math_NormalizeAngle(-gyroshipangles.p * 0.05) * self.PMult * mass
    else
        force_pitch = entup * self.GyroPitch * self.PMult * mass * rotation_extra_mul
    end

    if self.GyroLvl then
        force_roll = entup * math_NormalizeAngle(gyroshipangles.r * 0.05) * self.RMult * mass
    elseif self.RollLock and GyroRoll == 0 then
        local RMM = mass * self.RMult * 0.0005--0.00005
        local gyrophys = self:GetPhysicsObject():GetAngleVelocity()
        local wlrm

        if math_abs(gyroshipangles.p) > 80 then
            wlrm = gyrophys.r * (-0.0132 * RMM)
            --print(">1", wlrm)
        elseif math_abs(gyroshipangles.r) < 100 then
            wlrm = gyroshipangles.r * (0.25 * RMM)
            --print(">2", wlrm)
        else
            wlrm = math_NormalizeAngle(gyroshipangles.r + 180) * (0.25 * RMM)
            --print(">3", wlrm)
        end

        force_roll = entup * math_abs(wlrm) * wlrm * mass
    else
        force_roll = entup * -GyroRoll * self.RMult * mass
    end

    --[[debugoverlay.Line(entpos + entfor * 16, entpos + entfor * 16 + force_pitch, 1, Color(255,0,0), true)
    debugoverlay.Line(entpos - entfor * 16, entpos - entfor * 16 - force_pitch, 1, Color(0,255,255), true)

    debugoverlay.Line(entpos + entfor * 16, entpos + entfor * 16 + force_yaw, 1, Color(0,255,0), true)
    debugoverlay.Line(entpos - entfor * 16, entpos - entfor * 16 - force_yaw, 1, Color(255,0,255), true)

    debugoverlay.Line(entpos + entright * 16, entpos + entright * 16 + force_roll, 1, Color(0,0,255), true)
    debugoverlay.Line(entpos - entright * 16, entpos - entright * 16 - force_roll, 1, Color(255,255,0), true)]]

    for _, ent in ipairs(self.MoveTable) do
        if not IsValid(ent) then continue end

        local phy = ent:GetPhysicsObject()

        phy:SetVelocity(velocity)
        phy:AddAngleVelocity(-phy:GetAngleVelocity())

        phy:ApplyForceOffset(-force_pitch, pos_front)
        phy:ApplyForceOffset(force_pitch, pos_rear)

        phy:ApplyForceOffset(-force_yaw, pos_front)
        phy:ApplyForceOffset(force_yaw, pos_rear)

        phy:ApplyForceOffset(force_roll, pos_right)
        phy:ApplyForceOffset(-force_roll, pos_left)
    end
end

function ENT:ThinkUnactive(localentorparvel, speedmph)
    if speedmph > 10 then
        self:UpdateGravity()
    end

    if self.weighttrigger then
        self:GyroWeight()
    end

    self.GyroSpeed, self.VSpeed, self.HSpeed = localentorparvel.x, localentorparvel.z, -localentorparvel.y

    --Wind down engine sound when turned off
    if self.HighEngineSound or self.LowDroneSound then
        self.HighEnginePitch = math_clamp(self.HighEnginePitch - 0.7, 0, 300)
        self.LowDronePitch = math_clamp(self.LowDronePitch - 0.3, 0, 300)
        self.HighEngineVolume = math_clamp(self.HighEngineVolume - 0.005, 0, 2)
        self.HighEngineSound.ChangeVolume(self.HighEngineSound, self.HighEngineVolume, 0)
        self.HighEngineSound.ChangePitch(self.HighEngineSound, self.HighEnginePitch, 0)
        self.LowDroneSound.ChangePitch(self.LowDroneSound, self.LowDronePitch, 0)

        if self.LowDronePitch < 1 then
            self.LowDroneSound:Stop()
            self.HighEngineSound:Stop()
        end
    end
end

function ENT:Think()
    --Determines whether stuff comes from vehicle or entity
    if IsValid(self.Pod) then
        self.GyroDriver, self.EntSoundSource = self.Pod:GetDriver(), self.Pod
    else
        self.EntSoundSource = self
    end

    local ent_measure = self

    while IsValid(ent_measure:GetParent()) do
        ent_measure = ent_measure:GetParent()
    end

    local entpos, entorparvel = self:GetPos(), ent_measure:GetVelocity()
    local localentorparvel = self:WorldToLocal(entorparvel + entpos) --most of the features rely on these numbers
    local speedmph = math_round(localentorparvel:Length() / 17.6)

    if self.FreezeOn then
        self.GyroSpeed, self.VSpeed, self.HSpeed = 0, 0, 0
    end

    if self.SystemOn then
        local rotation_extra_mul = 1

        if self.AimModeOn then
            self:AimByTarPos()
        else
            --increase pitch yaw during high speeds
            if speedmph > 75 then
                rotation_extra_mul = speedmph / 75
            end

            if (self.GyroDriver and IsValid(self.GyroDriver)) then
                self:AimByMouse()
            else
                self.GyroPitch = (self.GyroPitchDown - self.GyroPitchUp) * 2
                self.GyroYaw = self.GyroYawLeft - self.GyroYawRight
                self.ViewDelay = true
            end
        end

        self:ThinkActive(entpos, entorparvel, localentorparvel, speedmph, rotation_extra_mul)
    else
        self:ThinkUnactive(localentorparvel, speedmph)
    end

    Wire_TriggerOutput(self, "On", bool_to_number(self.SystemOn))
    Wire_TriggerOutput(self, "Frozen", bool_to_number(self.FreezeOn))
    Wire_TriggerOutput(self, "Targeting Mode", bool_to_number(self.AimModeOn))
    Wire_TriggerOutput(self, "MPH", speedmph)
    Wire_TriggerOutput(self, "KmPH", math_round(localentorparvel:Length() / 10.93613297222))
    Wire_TriggerOutput(self, "Leveler", bool_to_number(self.GyroLvl))
    Wire_TriggerOutput(self, "Total Mass", self.GyroMass)
    Wire_TriggerOutput(self, "Props Linked", table.Count(self.MoveTable))
    Wire_TriggerOutput(self, "Angles", self:GetAngles())
    self:NextThink(CurTime() + 0.01)

    return true
end

--Aiming mode Calculations
function ENT:AimByTarPos()
    self:PodModelFix()
    local PodPos, PodUp = self.EntSoundSource:GetPos(), self.EntSoundSource:GetUp()
    local TarPosVec = self.TarPos - PodPos
    TarPosVec:Normalize()
    local TarMod = PodPos + TarPosVec * 100
    local FDistP = TarMod:Distance(PodPos + PodUp * 500)
    local BDistP = TarMod:Distance(PodPos + PodUp * -500)
    self.GyroPitch = (FDistP - BDistP) * 0.1
    local FDistY = TarMod:Distance(PodPos + self.T90 * -self.Tmod)
    local BDistY = TarMod:Distance(PodPos + self.T90 * self.Tmod)
    self.GyroYaw = (BDistY - FDistY) * 0.1
end

--Mouselook Calculations (whoever figured this out is my personal hero)
function ENT:AimByMouse()
    --small delay beofre mouse look is enabled
    if self.ViewDelay then
        self.ViewDelayOut = 0

        timer.Simple(1.5, function()
            self.ViewDelay = false
        end)
    else
        self.GyroDriver:CrosshairEnable()
        self.ViewDelayOut = 1
    end

    self:PodModelFix()
    local PodPos, PodUp = self.Pod:GetPos(), self.Pod:GetUp()
    local PodAim = self.GyroDriver:GetAimVector()
    local PRel = PodPos + PodAim * 100
    local FDistP = PRel:Distance(PodPos + PodUp * 500)
    local BDistP = PRel:Distance(PodPos + PodUp * -500)
    local PitchA = math_clamp((FDistP - BDistP) * 0.03, -7, 7)

    if (PitchA > 0.3) then
        self.GyroPitch = (PitchA - 0.3) * self.ViewDelayOut
    elseif (PitchA < -0.3) then
        self.GyroPitch = (PitchA + 0.3) * self.ViewDelayOut
    else
        self.GyroPitch = 0
    end

    local FDistY = PRel:Distance(PodPos + self.T90 * -self.Tmod)
    local BDistY = PRel:Distance(PodPos + self.T90 * self.Tmod)
    local YawA = math_clamp((BDistY - FDistY) * 0.03, -7, 7)

    if (YawA > 0.3) then
        self.GyroYaw = (YawA - 0.3) * self.ViewDelayOut
    elseif (YawA < -0.3) then
        self.GyroYaw = (YawA + 0.3) * self.ViewDelayOut
    else
        self.GyroYaw = 0
    end
end

function ENT:UpdateAimMode(active)
    if active then
        self.EntSoundSource:EmitSound("buttons/combine_button3.wav")
    else
        self.EntSoundSource:EmitSound("buttons/combine_button2.wav")
    end
end

--fixing the strange bug where some vehicles are rotated 90 degrees
function ENT:PodModelFix()
    if (self.Pod and IsValid(self.Pod)) then
        local podmodel = self.Pod:GetModel()

        if (string.find(podmodel, "carseat") or string.find(podmodel, "nova") or string.find(podmodel, "prisoner_pod_inner")) then
            local podright = self.Pod:GetRight()
            self.T90, self.Tmod = podright, 500
        else
            local podfor = self.Pod:GetForward()
            self.T90, self.Tmod = podfor, -500
        end
    else
        local entright = self:GetRight()
        self.T90, self.Tmod = entright, 500
    end
end

function ENT:GyroWeight()
    if not self.SystemOn then
        self.MoveTable = {}
        self.GyroMass = 0
        self.weighttrigger = false

        return
    end

    local entities = {}

    local GyroPos = self:GetPos()
    local gyrofor = GyroPos + (self:GetForward() * 5000)
    local gyroback = GyroPos + (self:GetForward() * -5000)
    local gyroright = GyroPos + (self:GetRight() * 5000)
    local gyroleft = GyroPos + (self:GetRight() * -5000)

    local mindist_front, mindist_back, mindist_right, mindist_left = math.huge, math.huge, math.huge, math.huge
    local max_mass = 0

    for _, ent in ipairs(self.AllGyroConstraints) do
        if not IsValid(ent) then continue end

        local linkphys = ent:GetPhysicsObject()
        local mass = linkphys:GetMass()
        local entspos = ent:GetPos()
        local frontdist = entspos:Distance(gyrofor)
        local backdist = entspos:Distance(gyroback)
        local rightdist = entspos:Distance(gyroright)
        local leftdist = entspos:Distance(gyroleft)
        self.GyroMass = (self.GyroMass + mass)

        if mass > 10 then
            mindist_front = math.min(mindist_front, frontdist)
            mindist_back =  math.min(mindist_back,  backdist)
            mindist_right = math.min(mindist_right, rightdist)
            mindist_left =  math.min(mindist_left, leftdist)
            max_mass = math.max(max_mass, mass)

            table.insert(entities, ent)
        end
    end

    self.frontlength, self.rearlength, self.rightwidth, self.leftwidth =
        math_round(mindist_front), math_round(mindist_back),
        math_round(mindist_right), math_round(mindist_left)

    max_mass = math_round(max_mass)


    local parent = self:GetParent()

    --[[
    for _, ent in ipairs(entities) do
        local ilinkphys = ent:GetPhysicsObject()
        local ipos = ent:GetPos()

        if  math_round(ipos:Distance(gyrofor))      == self.frontlength or
            math_round(ipos:Distance(gyroback))     == self.rearlength or
            math_round(ipos:Distance(gyroright))    == self.rightwidth or
            math_round(ipos:Distance(gyroleft))     == self.leftwidth or
            math_round(ilinkphys:GetMass())         == max_mass or
            ent == parent then

            table.insert(self.MoveTable, ent)
        end
    end]]

    if IsValid(parent) then
        table.insert(entities, parent)
    end

    self.MoveTable = entities

    self:UpdateGravity()
    self.weighttrigger = true
end

--Turns on/off gravity for all constrained entities
function ENT:UpdateGravity()
    for _, ent in ipairs(self.AllGyroConstraints) do
        if (not IsValid(ent)) then return end
        local linkphys = ent:GetPhysicsObject()
        linkphys:EnableDrag(false)

        if self.SystemOn or self.EnableAntigravity then
            linkphys:EnableGravity(false)
        else
            linkphys:EnableGravity(true)
        end
    end
end

--Freezes all constrained entities
function ENT:UpdateFreeze(activate)
    local constrainedents = constraint.GetAllConstrainedEntities(self)

    if activate then
        self.EntSoundSource:EmitSound("buttons/lever7.wav")
    else
        self.EntSoundSource:EmitSound("buttons/button6.wav")
    end

    for _, ent in pairs(constrainedents) do
        if not IsValid(ent) then return end
        local physobj = ent:GetPhysicsObject()

        physobj:EnableMotion(not activate)
        physobj:Wake()
    end
end

function ENT:Link(pod)
    if not pod then return false end
    self.Pod = pod

    return true
end

function ENT:OnRemove()
    if self.sound then
        self.HighEngineSound:Stop()
        self.LowDroneSound:Stop()
    end

    for _, ent in ipairs(self.AllGyroConstraints) do
        if (not IsValid(ent)) then return end
        local linkphys = ent:GetPhysicsObject()

        if IsValid(linkphys) then
            linkphys:EnableDrag(true)
            linkphys:EnableGravity(true)
        end
    end
end

function ENT:PreEntityCopy()
    local DI = {}

    if (self.Pod and IsValid(self.Pod)) then
        DI.Pod = self.Pod:EntIndex()
    end

    if WireAddon then
        DI.WireData = WireLib.BuildDupeInfo(self)
    end

    duplicator.StoreEntityModifier(self, "SBEPGyroAdv", DI)
end

duplicator.RegisterEntityModifier("SBEPGyroAdv", function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
    local DI = Ent.EntityMods.SBEPGyroAdv

    if (DI.Pod) then
        self.Pod = CreatedEntities[DI.Pod]
        --[[if (!self.Pod) then
            self.Pod = ents.GetByIndex(DI.Pod)
        end]]
    end

    if (Ent.EntityMods and Ent.EntityMods.SBEPGyroAdv.WireData) then
        WireLib.ApplyDupeInfo(pl, Ent, Ent.EntityMods.SBEPGyroAdv.WireData, function(id) return CreatedEntities[id] end)
    end
end