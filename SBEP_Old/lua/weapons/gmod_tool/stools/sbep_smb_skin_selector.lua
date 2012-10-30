TOOL.Category = "SBEP"
TOOL.Name = "#SmallBridge Skin Selector"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["skin"] = 0
TOOL.ClientConVar["glass"] = 0

if (CLIENT) then
    language.Add("Tool.sbep_smb_skin_selector.name", "SBEP SmallBridge Skin Selector Tool")
    language.Add("Tool.sbep_smb_skin_selector.desc", "Easily change skins of SmallBridge props.")
    language.Add("Tool.sbep_smb_skin_selector.0", "Left click a prop to switch to the selected skin.")
end


function TOOL:LeftClick(trace)
    if CLIENT then return end
    if trace.Entity:IsValid() then
        if string.find(string.lower(trace.Entity:GetModel()), "smallbridge") then
            local ply = self:GetOwner()

            local SkinInt = 0
            if trace.Entity:SkinCount() == 10 then
                SkinInt = 1
            else
                SkinInt = 0
            end

            local SkinNumber = ply:GetInfoNum("sbep_smb_skin_selector_skin", 1)
            local GlassNumber = ply:GetInfoNum("sbep_smb_skin_selector_glass", 0)

            local Skin = 1
            if SkinInt == 1 then
                Skin = 2 * SkinNumber + GlassNumber
            elseif SkinInt == 0 then
                Skin = SkinNumber
            end

            trace.Entity:SetSkin(Skin)

            return true
        end
    end
end

function TOOL:RightClick(trace)
end

function TOOL.BuildCPanel(panel)

    panel:SetSpacing(10)
    panel:SetName("SBEP SmallBridge Skin Selector")

    local ModelDisp = vgui.Create("DModelPanel")
    ModelDisp:SetSize(100, 200)
    ModelDisp:SetModel("models/SmallBridge/Hulls_SW/sbhulle1.mdl")
    ModelDisp:SetCamPos(Vector(246, 235, 143))
    ModelDisp:SetLookAt(Vector(-246, -235, -143))
    panel:AddItem(ModelDisp)

    local function SBEP_SMBSkinTool_Skin(skin, glass)
        local var = type(glass)
        if var == "number" then
            glass = glass == 1
        end

        skin = 2 * skin
        if glass then
            skin = skin + 1
        end
        ModelDisp.Entity:SetSkin(skin)
    end

    local SkinTable = {
        "Scrappers",
        "Advanced",
        "SlyBridge",
        "MedBridge2",
        "Jaanus"
    }

    local SLV = vgui.Create("DListView")
    SLV:SetSize(100, 101)
    SLV:SetMultiSelect(false)
    SLV:AddColumn("Skin")
    SLV.OnClickLine = function(parent, line, isselected)
        parent:ClearSelection()
        line:SetSelected(true)
        SBEP_SMBSkinTool_Skin(line:GetID() - 1, GetConVarNumber("sbep_smb_skin_selector_glass"))
        RunConsoleCommand("sbep_smb_skin_selector_skin", line:GetID() - 1)
    end

    for k, v in ipairs(SkinTable) do
        SLV:AddLine(v)
    end
    panel:AddItem(SLV)

    local GlassTable = { "No Glass", "Glass" }

    local SiLV = vgui.Create("DListView")
    SiLV:SetSize(100, 50)
    SiLV:SetMultiSelect(false)
    SiLV:AddColumn("Size")
    SiLV.OnClickLine = function(parent, line, isselected)
        parent:ClearSelection()
        line:SetSelected(true)
        SBEP_SMBSkinTool_Skin(GetConVarNumber("sbep_smb_skin_selector_skin"), line:GetID() - 1)
        RunConsoleCommand("sbep_smb_skin_selector_glass", line:GetID() - 1)
    end

    for k, v in ipairs(GlassTable) do
        SiLV:AddLine(v)
    end
    panel:AddItem(SiLV)
end