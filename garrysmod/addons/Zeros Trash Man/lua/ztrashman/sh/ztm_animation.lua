ztm = ztm or {}
ztm.f = ztm.f or {}

if SERVER then
    util.AddNetworkString("ztm_baseanim_AnimEvent_net")

    function ztm.f.PlayAnimation(ent, anim, speed)
        //ent:ServerAnim(anim, speed)
        local animInfo = {}
        animInfo.anim = anim
        animInfo.speed = speed
        animInfo.ent = ent
        net.Start("ztm_baseanim_AnimEvent_net")
        net.WriteTable(animInfo)
        net.Broadcast()
    end
end

if CLIENT then
    net.Receive("ztm_baseanim_AnimEvent_net", function(len, ply)
        local animInfo = net.ReadTable()

        if animInfo and IsValid(animInfo.ent) and animInfo.anim and animInfo.speed then
            ztm.f.PlayClientAnimation(animInfo.ent,animInfo.anim, animInfo.speed)
        end
    end)

    function ztm.f.PlayClientAnimation(ent,anim, speed)
    	local sequence = ent:LookupSequence(anim)
    	ent:SetCycle(0)
    	ent:ResetSequence(sequence)
    	ent:SetPlaybackRate(speed)
    	ent:SetCycle(0)
    end
end
