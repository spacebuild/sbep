    AddCSLuaFile( "cl_init.lua" )
    AddCSLuaFile( "shared.lua" )
    include( 'shared.lua' )
     
    local MaxInfestorLimit = 200
     
    /*
    Types:
    0 = Seedling
    1 = Spreader
    2 = Overlord
    3 = Queen
     
    10 = Gnat
     
    20 = Spitter
    21 = Needler
    22 = Spiner
     
    30 = Gasser
     
    40 = Ripper
     
    50 = SporeCannon
    */
     
    function ENT:Initialize()
           
            --self.Entity:SetModel( "models/Weapons/w_bugbait.mdl" )
            --self.Entity:SetModel( "models/Items/combine_rifle_ammo01.mdl" )
            self.Entity:SetModel( "models/props_junk/watermelon01.mdl" )
            self.Entity:SetName("Infestor")
            self.Entity:PhysicsInit( SOLID_VPHYSICS )
            self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
            self.Entity:SetSolid( SOLID_VPHYSICS )
            self.Entity:SetUseType( 3 )
            self:DrawShadow( false )
     
            local phys = self.Entity:GetPhysicsObject()
            if (phys:IsValid()) then
                    phys:Wake()
                    phys:EnableGravity(true)
                    phys:EnableDrag(true)
                    phys:EnableCollisions(true)
                    phys:SetMass(1)
            end
     
            self.PhysObj = self.Entity:GetPhysicsObject()
           
            self.Mutation = 0
            self.dt.Energy = 0
            self.LTT = CurTime()
            self.Children = {}
            self.Spawnlings = {}
            self.ChildCount = 0
            self.NextMainThink = CurTime() + math.Rand(1,5)
            self.MaxEnergy = 10
            self.EnergyGain = 1
            self.TitheMul = 1
            self.TargetLength = 0
            self.CurrentTarget = nil
            self.NFTime = 0
            self.DeployTime = 0
            self.IsInfestor = true
           
            self.hasdamagecase = true
    end
     
    function ENT:SpawnFunction( ply, tr )
     
            if ( !tr.Hit ) then return end
           
            local SpawnPos = tr.HitPos + tr.HitNormal * 2
           
            local ent = ents.Create( "Infestor" )
            ent:SetPos( SpawnPos )
            local RA = tr.HitNormal:Angle()
            RA:RotateAroundAxis(tr.HitNormal,math.Rand(0,360))
            ent:SetAngles(RA)
            ent:Spawn()
            ent:Initialize()
            ent:Activate()
            ent.SPL = ply
            ent.Weld = constraint.Weld(ent,tr.Entity)
            if !tr.Entity:IsWorld() then
                    --ent:SetParent(tr.Entity)
                    ent.Perch = tr.Entity
            end
           
           
            local P1 = tr.HitPos + tr.HitNormal
            local P2 = tr.HitPos - tr.HitNormal
            --util.Decal("Infestation",P1,P2)
            --util.Decal("Scorch",P1,P2)
            util.Decal("BeerSplash",P1,P2)
           
            --ent:NextThink(CurTime() + math.Rand(5,10))
           
           
            return ent
           
    end
     
    function ENT:PhysicsUpdate( phys )
            --local Size = self.dt.Energys
            --self.Entity:PhysicsInitSphere(Size)
            --self.Entity:SetCollisionBounds(Vector(-Size,-Size,-Size),Vector(Size,Size,Size))
            --phys:Wake()
           
            --local Delta = CurTime() - self.LTT
            --self.dt.Energy = self.dt.Energy + Delta
            --self.LTT = CurTime()
            if self.dt.Mutation == 10 then
                    if !(self.Sire and self.Sire:IsValid()) then
                            self:Remove()
                            return
                    end
           
                    if !self.Sire.CurrentTarget or !self.Sire.CurrentTarget:IsValid() then
                           
                            local Vec,Ang = WorldToLocal(self:GetPos(),self:GetAngles(),self.Sire:GetPos(),self.Sire:GetAngles())
                            local r = math.fmod((math.deg(math.atan2( Vec.z, Vec.y )) + 180) + 99,360)
                            --player.GetByID( 1 ):PrintMessage( HUD_PRINTCENTER, r )
                            local Scale = self.Sire.dt.Energy * 0.001
                            local Dist = self.SwarmDist + (Scale * self.SwarmDist)
                            local TVec = self.Sire:GetPos() + (self.Sire:GetForward() * ((Scale*self.SwarmHeight) + self.SwarmHeight)) + (self.Sire:GetUp() * (math.cos(math.rad(r)) * Dist)) + (self.Sire:GetRight() * (math.sin(math.rad(r)) * Dist)) --* (self.Sire.dt.Energy * 0.1))
                            local AVec = (TVec - self:GetPos() ):Angle()
                            self:SetAngles(AVec)
                            phys:SetVelocity(self:GetForward() * self.SwarmSpeed)
                           
                    else
                            local T = self.Sire.CurrentTarget
                            local TVec = T:GetPos() + Vector(math.Rand(-20,20),math.Rand(-20,20),math.Rand(10,50))
                            local AVec = (TVec - self:GetPos() ):Angle()
                            self:SetAngles(AVec)
                            phys:SetVelocity(self:GetForward() * 650)
                    end
            end
    end
     
    function ENT:Think()
            self:GetPhysicsObject():Wake()
            local Delta = CurTime() - self.LTT
            self:AddEn(Delta * self.EnergyGain)
            if self.Perch and self.Perch:IsValid() then
                    if self.Perch.GetResourceAmount then
                            local e = self.Perch:GetResourceAmount( "energy" )
                            if e >= Delta * 10 then
                                    self.Perch:ConsumeResource( "energy", Delta * 10 * self.EnergyGain)
                                    self:AddEn(Delta * 10 * self.EnergyGain)
                            else
                                    self.Perch:ConsumeResource( "energy", e )
                                    self:AddEn(e)
                            end
                            local a = self.Perch:GetResourceAmount( "oxygen" )
                            if a >= Delta * 10 then
                                    self.Perch:ConsumeResource( "oxygen", Delta * 10 * self.EnergyGain)
                                    self:AddEn(Delta * 10 * self.EnergyGain)
                            else
                                    self.Perch:ConsumeResource( "oxygen", a )
                                    self:AddEn(a)
                            end
                            local a = self.Perch:GetResourceAmount( "water" )
                            if a >= Delta * 10 then
                                    self.Perch:ConsumeResource( "water", Delta * 10 * self.EnergyGain)
                                    self:AddEn(Delta * 10 * self.EnergyGain)
                            else
                                    self.Perch:ConsumeResource( "water", a )
                                    self:AddEn(a)
                            end    
                    end
            end
            self.LTT = CurTime()
            if self.dt.Energy > self.MaxEnergy then
                    self:Tithe(self.dt.Energy - self.MaxEnergy)
            elseif self.dt.Energy < self.MaxEnergy * 0.5 then
                    self:RequestResources()
            end
            if !self.Sire then
                    --player.GetByID( 1 ):PrintMessage( HUD_PRINTCENTER, " "..self.dt.Energy..", "..self:CCount() )
            end
            if self.CurrentTarget then
                    self.TargetLength = math.Approach(self.TargetLength,0,Delta)
                    if self.TargetLength <= 0 or !self.CurrentTarget:IsValid() or self.CurrentTarget:Health() <= 0 then
                            self.CurrentTarget = nil
                    end
                    if self.dt.Deploy == false then
                            self.dt.Deploy = true
                            self.NFTime = CurTime() + self.DeployTime
                    end
            elseif self:GetSire().CurrentTarget then
                    if self.dt.Deploy == false then
                            self.dt.Deploy = true
                            self.NFTime = CurTime() + self.DeployTime
                    end
            else
                    self.dt.Deploy = false
            end
           
           
            --player.GetByID( 1 ):PrintMessage( HUD_PRINTCENTER, self.dt.Energy )
            --print(self.dt.Energy,Delta)
                   
            if CurTime() >= self.NextMainThink then
                    self.Entity:EmitSound("Weapon_Bugbait.Splat")
                    local n = math.Clamp(1 - self:EnergyPercent(),0.2,1)
                    local NThink = math.Rand(8,16) * n
                    self.ChildCount = self:CCount() or 0
                    if self:GetSire() == self then self.Sire = nil end
                   
                   
                    if self.dt.Mutation == 0 then
                            if self.dt.Energy >= 20 then
                                    self.dt.Mutation = 1
                                    self.dt.Energy = self.dt.Energy - 20
                            end
                           
                            self.MaxEnergy = 20
                            self.EnergyGain = 2
                            --self:NextThink(CurTime() + math.Rand(0.1,0.5))
                           
                    elseif self.dt.Mutation == 1 then
                            self.MaxEnergy = 100
                            self.EnergyGain = 1
                                   
                            local T = table.Count(ents.FindByClass("Infestor"))
                           
                            if self.dt.Energy >= 15 and T < MaxInfestorLimit and self.ChildCount <= 5 then self:Reproduce() end
                           
                            if !(self.Sire and self.Sire:IsValid()) and self:CCount() >= 10 and self.dt.Energy >= self.MaxEnergy * .7 then
                                    --self.dt.Energy = 0
                                    self.dt.Mutation = 3
                            end
                           
                            --self:NextThink(CurTime() + math.Rand(0.1,0.5))
                           
                    elseif self.dt.Mutation == 2 then
                            self.MaxEnergy = 200
                            self.EnergyGain = 2
                           
                            local T = table.Count(ents.FindByClass("Infestor"))
                            if self.dt.Energy >= 15 and T < MaxInfestorLimit and self.ChildCount <= 5 then
                                    self:Reproduce()
                            end
                                           
                            if !(self.Sire and self.Sire:IsValid()) and self:CCount() >= 25 and self.dt.Energy >= self.MaxEnergy * .8 then
                                    --self.dt.Energy = 0
                                    self.dt.Mutation = 4
                                    self:AddEn(-100)
                            end
                           
                            NThink = math.Rand(4,8)
                           
                    elseif self.dt.Mutation == 3 then
                            local T = table.Count(ents.FindByClass("Infestor"))
                            if self.dt.Energy >= 15 and T < MaxInfestorLimit and self.ChildCount <= 5 then
                                    self:Reproduce()
                            end
                           
                            if self.dt.Energy >= 10 and self:SCount() <= 3 then
                                    --self:FreeSpawn(10)
                                    self:AddEn(-10)
                            end
                                                   
                            if self.dt.Energy >= 250 then
                                    --print("Lets make something nasty...")
                                    local ent = table.Random( self.Children )
                                    --print(ent)
                                    if ent and ent:IsValid() and ent ~= self then
                                            --print("Looks good...")
                                            if ent.dt.Mutation == 1 then
                                                    --print("It's a spreader")
                                                    ent.dt.Mutation = 20
                                                    self:AddEn(-50)
                                            end
                                    end
                            end
                                   
                            NThink = math.Rand(1,5)
                           
                            self.MaxEnergy = 300
                            self.EnergyGain = 3
                           
                    elseif self.dt.Mutation == 10 then
                            self.MaxEnergy = 20
                            self.EnergyGain = 2
                            self.TitheMul = 0
                           
                    elseif self.dt.Mutation == 20 then
                            self.MaxEnergy = 100
                            self.EnergyGain = 5
                            self.TitheMul = 0.2
                            self.DeployTime = .5
                           
                            local T = table.Count(ents.FindByClass("Infestor"))
                            if self.dt.Energy >= 15 and T < MaxInfestorLimit and self.ChildCount <= 5 then
                                    --self:Reproduce()
                            end
                           
                    end
                    self.NextMainThink = CurTime() + NThink
            end
           
           
            -- For the stuff that needs to think faster
     
            if self.dt.Mutation == 20 then
                    local T = self:GetSire().CurrentTarget
                    if self.dt.Deploy and T and T:IsValid() then
                            self.dt.Target = (T:GetPos() + Vector(0,0,280))
                            if CurTime() >= self.NFTime then
                                    local Dmg = self.dt.Energy * 0.1
                                    local Dir = self.dt.Target - self:GetPos()
                                   
                                    /*
                                    local bullet = {}
                                    bullet.Src                      = self:GetPos() + self:GetForward() * 10
                                    bullet.Attacker         = self
                                    bullet.Dir                      = Dir
                                    bullet.Spread           = Vector(0.6,0.6,0.6)
                                    bullet.Num                      = 1
                                    bullet.Damage           = Dmg * 0.7
                                    bullet.Force            = 4
                                    bullet.Tracer           = 1    
                                    bullet.TracerName       = "None"--"AR2Tracer"
                                    self:FireBullets(bullet)
                                    */
                                   
                                    local ent = ents.Create( "grenade_spit" )
                                    ent:SetPos( self:GetPos() + self:GetForward() * (self.dt.Energy * 0.9) )
                                    local Acc = 20
                                    local RVec = Vector(math.Rand(-Acc,Acc),math.Rand(-Acc,Acc),math.Rand(-Acc,Acc))
                                    ent:SetVelocity((Dir + RVec) * 1.1)
                                    ent:SetKeyValue("Size",1000)
                                    ent:Spawn()
                                    ent:Activate()
                                    ent:SetOwner(self)
                                    --ent:Input( SetSpitSize, self, self, 3 )
                                    --ent:Size(1)
                                   
                                    self:AddEn(-Dmg)
                                    self.NFTime = CurTime() + 0.15
                                   
                            end
                    end
            end
                   
            self:NextThink(CurTime() + 0.1)
            return true
    end
     
    function ENT:Tithe(eng)
            self.dt.Energy = self.dt.Energy - eng
            if self.Sire and self.Sire:IsValid() then
                    self.Sire:AddEn(eng*self.TitheMul)
            end
    end
     
    function ENT:RequestResources()
            if self.Sire and self.Sire:IsValid() then
                    if self.Sire.dt.Energy >= self.Sire.MaxEnergy * 0.8 then
                            local Gift = self.MaxEnergy * 0.1
                            self.Sire.dt.Energy = self.Sire.dt.Energy - Gift
                            self.dt.Energy = self.dt.Energy + Gift
                    end
            end
    end
     
    function ENT:EnergyPercent()
            return self.dt.Energy / self.MaxEnergy
    end
     
    function ENT:AddEn(val)
            self.dt.Energy = self.dt.Energy + val
    end
     
    function ENT:GetSire()
            if self.Sire and self.Sire:IsValid() and self.Sire ~= self then
                    return self.Sire:GetSire()
            else
                    return self
            end
    end
     
    function ENT:Reproduce()
            --print("Trying to reproduce...")
            local n = math.Rand(0,360)
            local d = math.Rand(10,100)
            local trace = {}
            trace.start = self:GetPos()
            trace.endpos = self:GetPos() + (self:GetForward() * 40) + (self:GetRight() * (math.cos(n) * d)) + (self:GetUp() * (math.sin(n) * d))
            trace.filter = self
            local tr = util.TraceLine( trace )
            if tr.Hit then
                    --print("First time lucky!")
                    if !tr.HitWorld and tr.Entity:GetClass() ~= "Infestor" then return end
                    --print("We hit either the world or something infestable...")
                    if !ZoneCheck(tr.HitPos,100) then return end
                    --print("Area seems clear...")
                    self:Generate(tr.HitPos,tr.HitNormal,tr.Entity)
            else
                    local d2 = math.Rand(10,100) + d
                    local trace2 = {}
                    trace2.start = tr.HitPos
                    trace2.endpos = self:GetPos() + (self:GetForward() * -20) + (self:GetRight() * (math.cos(n) * d2)) + (self:GetUp() * (math.sin(n) * d2))
                    trace2.filter = self
                    local tr2 = util.TraceLine( trace2 )
                    if tr2.Hit then
                    --      print("Second trace landed...")
                            if !tr2.HitWorld and !tr2.Entity:GetClass() == "Infestor" then return end
                    --      print("We hit either the world or something infestable...")
                            if !ZoneCheck(tr2.HitPos,100) then return end
                    --      print("Area seems clear...")
                            self:Generate(tr2.HitPos,tr2.HitNormal,tr2.Entity)
                           
                            --local effectdata = EffectData()
                            --effectdata:SetOrigin( tr2.HitPos )
                            --effectdata:SetStart( tr2.HitPos + tr2.HitNormal * 10 )
                            --util.Effect( "AntlionGib", effectdata )
                    end
            end
    end
     
    function ENT:Generate(Pos,Norm,HEnt)
            local P1 = Pos + Norm
            local P2 = Pos - Norm
            --util.Decal("Infestation",P1,P2)
            --util.Decal("Scorch",P1,P2)
            util.Decal("BeerSplash",P1,P2)
            local ent = ents.Create( "Infestor" )
            local RA = Norm:Angle()
            RA:RotateAroundAxis(Norm,math.Rand(0,360))
            ent:SetAngles(RA)
            ent:SetPos( Pos + Norm * 2 )
            ent:Spawn()
            ent:Initialize()
            ent:Activate()
            ent.Sire = self
            table.insert(self.Children,ent)
            --ent:NextThink(CurTime() + math.Rand(5,10))
            ent.Weld = constraint.Weld(ent,HEnt)
            if !HEnt:IsWorld() then
                    ent:SetParent(HEnt)
                    ent.Perch = HEnt
            end
           
            self.dt.Energy = self.dt.Energy - 15
    end
     
    function ENT:Reattach(Pos,Norm,HEnt)
     
    end
     
    function ENT:FreeSpawn(Mut)
            local ent = ents.Create( "Infestor" )
            local r = math.Rand(0,360)
            local Scale = self.dt.Energy * 0.001
            local TVec = self:GetPos() + (self:GetForward() * ((Scale*math.Rand(50,90)) + math.Rand(50,90))) + (self:GetUp() * (math.cos(math.rad(r)) * math.Rand(40,60))) + (self:GetRight() * (math.sin(math.rad(r)) * math.Rand(40,60))) --* (self.Sire.dt.Energy * 0.1))
            ent:SetPos( TVec )
            ent:Spawn()
            ent:Activate()
            if Mut == 10 then
                    ent:SetModel("models/Gibs/Antlion_gib_small_1.mdl")
                    ent.dt.Mutation = 10
                    ent.SwarmSpeed = math.Rand(50,80)
                    ent.SwarmDist = math.Rand(40,60)
                    ent.SwarmHeight = math.Rand(50,90)
                    ent.dt.Energy = 10
                    util.SpriteTrail( ent, 0,  Color(190,180,20,200), false, 5, 1, 0.5, 1, "trails/smoke.vmt" )
            end
            ent.Sire = self
            table.insert(self.Spawnlings,ent)
    end
     
    function ENT:OnTakeDamage( dmg )
            if dmg:GetAttacker():GetClass() == self:GetClass() then return end
            if dmg:GetAttacker():IsPlayer() or dmg:GetAttacker():IsNPC() then
                    local Sire = self:GetSire()
                    Sire.CurrentTarget = dmg:GetAttacker()
                    Sire.TargetLength = math.Clamp(Sire.TargetLength + math.Rand(3,7),0,20)
            end
            local D = dmg:GetDamage()
            self.dt.Energy = self.dt.Energy - D
            if self.dt.Energy < 0 then
                    self:Remove()
            end
    end
     
    function ENT:PhysicsCollide( data, physobj )
            if self.dt.Mutation == 10 then
                    if data.HitEntity:GetClass() ~= self:GetClass() then
                            util.BlastDamage(self, self, self:GetPos(), 20, self.dt.Energy)
                            self:Remove()
                    end
            end
    end
     
    function ENT:Touch( ent )
            if self.dt.Mutation == 0 then
                    if ent:GetClass() == self:GetClass() then
                            --self:Remove()
                    end
            elseif self.dt.Mutation >= 1 then
                    if ent:IsPlayer() or ent:IsNPC() then
                            if self.dt.Mutation == 10 then
                                    util.BlastDamage(self, self, self:GetPos(), 20, self.dt.Energy)
                                    self:Remove()
                            else
                                    ent:TakeDamage(.1,self)
                                    self.dt.Energy = self.dt.Energy + .1
                            end
                    end
            end
            if ent:IsPlayer() then
                    local Sire = self:GetSire()
                    Sire.CurrentTarget = ent
                    Sire.TargetLength = math.Clamp(Sire.TargetLength + math.Rand(0,1),0,10)
            end
    end
     
    function ENT:Use( activator, caller )
           
    end
     
    function ENT:CCount()
            local Count = 0
            for k,e in pairs(self.Children) do
                    if !e:IsValid() or e == self then
                            table.remove(self.Children,k)
                            --print("It's dead. Removing from our list...")
                    else
                            local c = e.ChildCount or 0
                            Count = Count + c + 1
                    end
            end
            return Count
    end
     
    function ENT:RandomSpreader()
            local Ent
            for k,e in pairs(self.Children) do
                    if e and e:IsValid() and e ~= self and e.dt.Mutation == 1 then
                            Ent = e
                            break
                    end
            end
            return Ent
    end
     
    function ENT:SCount()
            local Count = 0
            for k,e in pairs(self.Spawnlings) do
                    if !e:IsValid() then
                            table.remove(self.Spawnlings,k)
                            --print("It's dead. Removing from our list...")
                    else
                            Count = Count + 1
                    end
            end
            --print(Count)
            return Count
    end
     
    function ZoneCheck(Pos,Size)
           
            local XB, YB, ZB = Size * 0.5, Size * 0.5, Size * 0.5
            local Results = {}
            local Clear = true
            for k,e in pairs(ents.FindByClass("Infestor")) do
                    local EP = e:GetPos()
                   
                    local EPL = WorldToLocal( EP, Angle(0,0,0), Pos, Angle(0,0,0))
                    local X,Y,Z = EPL.x, EPL.y, EPL.z
                   
                    if X <= XB and X >= -XB and Y <= YB and Y >= -YB and Z <= ZB and Z >= -ZB then
                            Clear = false
                    end
            end
            return Clear
    end
     
    function ENT:OnRemove()
            local Sire = self:GetSire()
            if Sire and Sire:IsValid() and Sire ~= self then
                    --print("In our father we trust...")
                    for k,e in pairs(self.Children) do
                            e.Sire = Sire
                            table.insert(Sire.Children,e)
                    end
            else
                    local Successor = nil
                    for k,e in pairs(self.Children) do
                            --print("Looking for a responsible child...")
                            if e:IsValid() and e ~= self then
                                    --print("They're valid")
                                    Successor = e
                                    break
                            end
                    end
                   
                    if Successor and Successor:IsValid() and Successor ~= self then
                            if type(Successor.Children) == "table" and Successor.Children ~= self.Children then
                                    --print("They have children of their own")
                                    table.Add(Successor.Children,self.Children)
                                    for k,e in pairs(self.Children) do
                                            e.Sire = Successor
                                    end
                            end
                    end
            end
            local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() + self:GetForward() * 20 )
            util.Effect( "AntlionGib", effectdata )
    end
     
    function ENT:gcbt_breakactions(Dmg, Prc)
            self.dt.Energy = self.dt.Energy - Dmg
            if self.dt.Energy < 0 then
                    self:Remove()
            end
    end
