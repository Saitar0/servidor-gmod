    
    --> The function used to tell the client to open the F4 menu <--
    util.AddNetworkString( "OS_UI.Open.F4_Menu" )
    function OS_UI.OpenF4Menu( self )
        net.Start( "OS_UI.Open.F4_Menu" )
        net.Send( self )
    end
    hook.Add( "ShowSpare2", "OS_UI.Open.F4_Menu", OS_UI.OpenF4Menu )

    --> Sends arrest time using Net Messages <--
    util.AddNetworkString( "OS_UI.Send.ArrestTime" )
    function OS_UI.HandleArrestTime( victim, time, inflictor )
        net.Start( "OS_UI.Send.ArrestTime" )
            net.WriteInt( time, 16 )
        net.Send( victim )
    end
    hook.Add( "playerArrested", "OS_UI.HandleArrestTime", OS_UI.HandleArrestTime )
    