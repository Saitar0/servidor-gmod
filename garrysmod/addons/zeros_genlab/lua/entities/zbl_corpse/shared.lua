ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model =  "models/hunter/blocks/cube2x2x1.mdl"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Dummy"
ENT.Category = "Zeros GenLab"
ENT.RenderGroup = RENDERGROUP_BOTH


function ENT:SetupDataTables()
    self:NetworkVar("Int", 2, "PlayerID")
    self:NetworkVar("String", 0, "PlayerName")

    if (SERVER) then
        self:SetPlayerID(-1)
        self:SetPlayerName("")
    end
end
