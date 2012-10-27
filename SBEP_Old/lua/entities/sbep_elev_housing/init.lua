AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local LMT = {}
LMT.S = {
    ["B"] = { model = "models/SmallBridge/Elevators_Small/sbselevb.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 0 } },
    ["BE"] = { model = "models/SmallBridge/Elevators_Small/sbselevbe.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 1 } },
    ["BEdh"] = { model = "models/SmallBridge/Elevators_Small/sbselevbedh.mdl", ZUD = 195.3, ZDD = 65.1, AT = { 0, 1, 0, 1 }, SD = { IsDH = true } },
    ["BEdw"] = { model = "models/SmallBridge/Elevators_Small/sbselevbedw.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 1 } },
    ["BR"] = { model = "models/SmallBridge/Elevators_Small/sbselevbr.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 0, 0 } },
    ["BT"] = { model = "models/SmallBridge/Elevators_Small/sbselevbt.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 0 } },
    ["BX"] = { model = "models/SmallBridge/Elevators_Small/sbselevbx.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 1 } },
    ["M"] = { model = "models/SmallBridge/Elevators_Small/sbselevm.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 0 } },
    ["ME"] = { model = "models/SmallBridge/Elevators_Small/sbselevme.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 1 } },
    ["MEdh"] = { model = "models/SmallBridge/Elevators_Small/sbselevmedh.mdl", ZUD = 195.3, ZDD = 65.1, AT = { 0, 1, 0, 1 }, SD = { IsDH = true } },
    ["MEdw"] = { model = "models/SmallBridge/Elevators_Small/sbselevmedw.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 1 } },
    ["MR"] = { model = "models/SmallBridge/Elevators_Small/sbselevmr.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 0, 0 } },
    ["MT"] = { model = "models/SmallBridge/Elevators_Small/sbselevmt.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 0 } },
    ["MX"] = { model = "models/SmallBridge/Elevators_Small/sbselevmx.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 1 } },
    ["T"] = { model = "models/SmallBridge/Elevators_Small/sbselevt.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 0 } },
    ["TE"] = { model = "models/SmallBridge/Elevators_Small/sbselevte.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 1 } },
    ["TEdh"] = { model = "models/SmallBridge/Elevators_Small/sbselevtedh.mdl", ZUD = 195.3, ZDD = 65.1, AT = { 0, 1, 0, 1 }, SD = { IsDH = true } },
    ["TEdw"] = { model = "models/SmallBridge/Elevators_Small/sbselevtedw.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 1 } },
    ["TR"] = { model = "models/SmallBridge/Elevators_Small/sbselevtr.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 0, 0 } },
    ["TT"] = { model = "models/SmallBridge/Elevators_Small/sbselevtt.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 0 } },
    ["TX"] = { model = "models/SmallBridge/Elevators_Small/sbselevtx.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 1 } },
    ["S"] = { model = "models/SmallBridge/Elevators_Small/sbselevs.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 0, 0, 0 }, SD = { IsShaft = true } },
    ["S2"] = { model = "models/SmallBridge/Elevators_Small/sbselevs2.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 0, 0, 0 }, SD = { IsShaft = true } },
    ["BV"] = { model = "models/SmallBridge/Station Parts/sbbridgevisorb.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 0, 0, 0 }, SD = { IsVisor = true, IsSpecial = true } },
    ["MV"] = { model = "models/SmallBridge/Station Parts/sbbridgevisorm.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 0, 0, 0 }, SD = { IsVisor = true, IsSpecial = true } },
    ["TV"] = { model = "models/SmallBridge/Station Parts/sbbridgevisort.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 0, 0, 0 }, SD = { IsVisor = true, IsSpecial = true } },
    ["H"] = { model = "models/SmallBridge/Station Parts/sbhuble.mdl", ZUD = 195.3, ZDD = 195.3, AT = { 0, 0, 0, 0 }, SD = { IsHub = true, IsSpecial = true, MFT = { 0, 130.2, 260.4 } } }
}

LMT.L = {
    ["B"] = { model = "models/SmallBridge/Elevators_Large/sblelevb.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 0, 0, 1 } },
    ["BE"] = { model = "models/SmallBridge/Elevators_Large/sblelevbe.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 1 } },
    ["BEdh"] = { model = "models/SmallBridge/Elevators_Large/sblelevbedh.mdl", ZUD = 195.3, ZDD = 65.1, AT = { 0, 1, 0, 1 }, SD = { IsDH = true } },
    ["BR"] = { model = "models/SmallBridge/Elevators_Large/sblelevbr.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 0, 0 } },
    ["BT"] = { model = "models/SmallBridge/Elevators_Large/sblelevbt.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 0 } },
    ["BX"] = { model = "models/SmallBridge/Elevators_Large/sblelevbx.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 1 } },
    ["M"] = { model = "models/SmallBridge/Elevators_Large/sblelevm.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 0, 0, 1 } },
    ["ME"] = { model = "models/SmallBridge/Elevators_Large/sblelevme.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 1 } },
    ["MEdh"] = { model = "models/SmallBridge/Elevators_Large/sblelevmedh.mdl", ZUD = 195.3, ZDD = 65.1, AT = { 0, 1, 0, 1 }, SD = { IsDH = true } },
    ["MR"] = { model = "models/SmallBridge/Elevators_Large/sblelevmr.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 0, 0 } },
    ["MT"] = { model = "models/SmallBridge/Elevators_Large/sblelevmt.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 0 } },
    ["MX"] = { model = "models/SmallBridge/Elevators_Large/sblelevmx.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 1 } },
    ["T"] = { model = "models/SmallBridge/Elevators_Large/sblelevt.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 0, 0, 1 } },
    ["TE"] = { model = "models/SmallBridge/Elevators_Large/sblelevte.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 1, 0, 1 } },
    ["TEdh"] = { model = "models/SmallBridge/Elevators_Large/sblelevtedh.mdl", ZUD = 195.3, ZDD = 65.1, AT = { 0, 1, 0, 1 }, SD = { IsDH = true } },
    ["TR"] = { model = "models/SmallBridge/Elevators_Large/sblelevtr.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 0, 0 } },
    ["TT"] = { model = "models/SmallBridge/Elevators_Large/sblelevtt.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 0 } },
    ["TX"] = { model = "models/SmallBridge/Elevators_Large/sblelevtx.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 1, 1, 1, 1 } },
    ["S"] = { model = "models/SmallBridge/Elevators_Large/sblelevs.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 0, 0, 0 }, SD = { IsShaft = true } },
    ["S2"] = { model = "models/SmallBridge/Elevators_Large/sblelevs2.mdl", ZUD = 65.1, ZDD = 65.1, AT = { 0, 0, 0, 0 }, SD = { IsShaft = true } }
}

ENT.WireDebugName = "SBEP Elevator Housing"

for s, M in pairs(LMT) do
    for t, D in pairs(M) do
        list.Set("SBEP_LiftHousingModels", string.lower(D.model), { t, s })
    end
end

function ENT:Initialize()

    self:SetUseType(SIMPLE_USE)

    self.PD = {} --Part Data
    self.PD.HO = 0
    self.PD.Pitch = 0
    self.PD.Yaw = 0
    self.PD.Roll = 0

    self:PhysicsInitialize()
end

function ENT:PhysicsInitialize()

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if ValidEntity(phys) then
        phys:EnableMotion(false)
        phys:Wake()
    end
end

function ENT:MakeWire(bAdjust)

    if self.PD.SD.MFT then
        self.PD.WI = {} --Wire Inputs
        for k, v in ipairs(self.PD.SD.MFT) do
            self.PD.WI[k] = "Call " .. tostring(k)
        end
    elseif ! self.PD.SD.IsShaft then
    self.PD.WI = { "Call" }
    end

    if bAdjust then
        self.Inputs = Wire_AdjustInputs(self, self.PD.WI)
        --Wire_AdjustInputs(self, self.PD.WI )
    else
        self.Inputs = Wire_CreateInputs(self, self.PD.WI)
        --Wire_CreateInputs(self, self.PD.WI )
    end
end

function ENT:TriggerInput(k, v)
    if table.getn(self.PD.WI) > 1 then
        for m, n in ipairs(self.PD.WI) do
            if k == n and v == 1 then
                if ! self.PD.SD.MFT and self.Cont and self.Cont:IsValid() then
                self:CallLift(m)
                end
            end
        end
    elseif k == "Call" and v == 1 then
        if ! self.PD.SD.MFT and self.Cont and self.Cont:IsValid() then
        self:CallLift()
        end
    end
end

function ENT:SetPartType(type)
    if self.PD.T == type then return end

    local data = LMT[self.Cont.Size[1]][type]
    if ! data then return end
    self.PD.SD = {}
    self.PD = table.Merge(self.PD, data)
    self.PD.T = type
    self.PD.TC = string.Left(type, 1)
    self.PD.TF = string.sub(type, 2)
    self.PD.AT = table.Copy(self.PD.AT)
    self.PD.Usable = self.Cont.Usable and ! self.PD.SD.IsShaft and ! self.PD.SD.MFT
    self:SetModel(self.PD.model)
    self:CheckSkin(self.Cont.Skin)
end

function ENT:GetPartType()
    return self.PD.T
end

function ENT:SetPartClass(class)
    local t = class .. string.sub(self:GetPartType(), 2)
    if LMT[self.Cont.Size[1]][t] then
        self:SetPartType(t)
    end
end

function ENT:GetPartClass()
    return self.PD.TC
end

function ENT:SetPartForm(form)
    local t = string.Left(self:GetPartType(), 1) .. form
    if LMT[self.Cont.Size[1]][t] then
        self:SetPartType(t)
    end
end

function ENT:GetPartForm()
    return self.PD.TF
end

function ENT:UpdateHeightOffsets()
    if self.PD.PN > 1 then
        local P1 = self.Cont.PT[self.PD.PN - 1].PD
        local C1 = math.Clamp(P1.Roll, 0, 1)
        local C2 = math.abs(C1 - 1)
        local P2 = self.PD
        local C3 = math.Clamp(P2.Roll, 0, 1)
        local C4 = math.abs(C3 - 1)
        P2.HO = P1.HO + (C1 * P1.ZDD + C2 * P1.ZUD) + (C3 * P2.ZUD + C4 * P2.ZDD)
    else
        local P2 = self.PD
        local C3 = math.Clamp(P2.Roll, 0, 1)
        local C4 = math.abs(C3 - 1)
        P2.HO = C3 * (P2.ZUD - P2.ZDD)
    end
    self:RefreshPos()
end

function ENT:RefreshPos()
    self:SetPos(self.Cont:LocalToWorld(Vector(0, 0, self.PD.HO + 60.45)))
end

function ENT:RefreshAng()
    self:SetAngles(Angle(self.PD.Pitch, self.PD.Yaw, self.PD.Roll))
end

function ENT:RotatePartPitch(pitch)
    self.PD.Pitch = (self.PD.Pitch + pitch) % 360
    self:RefreshAng()
end

function ENT:RotatePartYaw(yaw)
    self.PD.Yaw = (self.PD.Yaw + yaw) % 360
    self:RefreshAng()
end

function ENT:RotatePartRoll(roll)
    self.PD.Roll = (self.PD.Roll + roll) % 360
    self:RefreshAng()
end

function ENT:Invert()
    self.PD.Roll = (self.PD.Roll + 180) % 360
    self.PD.Inv = ! self.PD.Inv
    self:RefreshAng()
end

function ENT:CheckSkin(skin)
    if self:SkinCount() > 5 then
        self:SetSkin(skin * 2)
    else
        self:SetSkin(skin)
    end
end

function ENT:CallLift(m)
    if m then
        self.Cont:AddCallFloorNum(self.PD.FN[m])
    else
        self.Cont:AddCallFloorNum(self.PD.FN)
    end
end

function ENT:Use()
    if ! self.PD.Usable or self.PD.SD.MFT or ! self.Cont or ! self.Cont:IsValid() then return end
    self:CallLift()
end

function ENT:PreEntityCopy()
    local DI = {}
    DI.PD = self.PD
    DI.Cont = self.Cont:EntIndex()
    if self.PD.FDT then
        DI.FDT = {}
        for n, D in ipairs(self.PD.FDT) do
            DI.FDT[n] = D:EntIndex()
        end
    end
    if WireAddon then
        DI.WireData = WireLib.BuildDupeInfo(self)
    end
    duplicator.StoreEntityModifier(self, "SBEPLP", DI)
end

duplicator.RegisterEntityModifier("SBEPLP", function() end)

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
    local DI = Ent.EntityMods.SBEPLP
    self.PD = DI.PD
    self.Cont = CreatedEntities[DI.Cont]
    if DI.FDT then
        for n, K in ipairs(DI.FDT) do
            self.PD.FDT[n] = CreatedEntities[K]
        end
    end
    self:MakeWire()
    if (Ent.EntityMods and DI.WireData) then
        WireLib.ApplyDupeInfo(pl, Ent, DI.WireData, function(id) return CreatedEntities[id] end)
    end
end