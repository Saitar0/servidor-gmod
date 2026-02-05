    local PANEL = {}

    --[[
        This function just makes attaching panels to a DCollapsibleCategory a lot easier.
    --]]

    function PANEL:Init()
        local scr_h = ScrH()
        self.PlayerPanel = vgui.Create( "DCollapsibleCategory", self )
        self.PlayerPanel:SetExpanded( 0 )
        self.PlayerPanel:SetLabel( '' )

        self.PlayerPanel.Paint = function( me, w, h ) 
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_HEADER )
        end
                
        self.HiddenList = vgui.Create( 'DPanelList', self.PlayerPanel )
        --self.HiddenList:SetSize( self.PlayerPanel:GetWide(), self.PlayerPanel:GetTall() )
        self.HiddenList:SetSpacing( 1 )
        self.PlayerPanel:SetContents( self.HiddenList )

        self.HiddenPanel = vgui.Create( "DPanel", self.HiddenList )
        self.HiddenList:AddItem( self.HiddenPanel )
    end

    function PANEL:PerformLayout()
        self.PlayerPanel:SetSize( self:GetWide(), self:GetTall() )
        self.PlayerPanel:GetChildren()[ 1 ]:SetTall( 39 )

        self.HiddenList:SetSize( self.PlayerPanel:GetWide(), self.PlayerPanel:GetTall() )
        self.HiddenPanel:SetSize( self.HiddenList:GetWide(), 39 )
        --self.BaseClass.PerformLayout( self )
    end

    vgui.Register( "OS.ScoreboardRow", PANEL )