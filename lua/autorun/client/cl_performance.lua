local PerformanceMod = PerformanceMod or {}
PerformanceMod.Config = PerformanceMod.Config or {}
PerformanceMod.Config.ApplyDelay = 2.5 -- Delay in seconds before starting optimizations
PerformanceMod.Config.CommandInterval = 1.5 -- Interval between applying each command

local performance_commands = {
    {"gmod_mcore_test", "1"},
    {"mem_max_heapsize", "131072"},
    {"mem_max_heapsize_dedicated", "131072"},
    {"mem_min_heapsize", "131072"},
    {"threadpool_affinity", "64"},
    {"mat_queue_mode", "2"},
    {"mat_powersavingsmode", "0"},
    {"r_queued_ropes", "1"},
    {"r_threaded_renderables", "1"},
    {"r_threaded_particles", "1"},
    {"r_threaded_client_shadow_manager", "1"},
    {"cl_threaded_client_leaf_system", "1"},
    {"cl_threaded_bone_setup", "1"},
    {"ai_expression_optimization", "1"},
    {"fast_fogvolume", "1"},
    {"mat_managedtextures", "0"}
}

local network_commands = {
    {"cl_forcepreload", "1"},
    {"cl_lagcompensation", "1"},
    {"cl_timeout", "3600"},
    {"cl_smoothtime", "0.05"},
    {"cl_localnetworkbackdoor", "1"},
    {"cl_cmdrate", "66"},
    {"cl_updaterate", "66"},
    {"cl_interp_ratio", "2"},
    {"net_maxpacketdrop", "0"},
    {"net_chokeloop", "1"},
    {"net_compresspackets", "1"},
    {"net_splitpacket_maxrate", "50000"},
    {"net_compresspackets_minsize", "4097"},
    {"net_maxroutable", "1200"},
    {"net_maxfragments", "1200"},
    {"net_maxfilesize", "64"},
    {"net_maxcleartime", "0"},
    {"rate", "1048576"}
}

local other_commands = {
    {"snd_mix_async", "1"},
    {"snd_async_fullyasync", "1"},
    {"snd_async_minsize", "0"},
    {"sv_forcepreload", "1"},
    {"studio_queue_mode", "1"},
    {"filesystem_max_stdio_read", "64"},
    {"in_usekeyboardsampletime", "1"},
    {"r_radiosity", "4"},
    {"mat_frame_sync_enable", "0"},
    {"mat_framebuffercopyoverlaysize", "0"},
    {"lod_TransitionDist", "2000"},
    {"filesystem_unbuffered_io", "0"}
}

CreateClientConVar("performancemod_network_enabled", "1", true, false, "Enable network optimizations")
CreateClientConVar("performancemod_other_enabled", "1", true, false, "Enable other optimizations")
CreateClientConVar("performancemod_fps_boost", "1", true, false, "Enable FPS boost")

local function GetOptimizationType(commands)
    if commands == performance_commands then
        return "FPS Boost"
    elseif commands == network_commands then
        return "Network Optimization"
    elseif commands == other_commands then
        return "Other Optimizations"
    else
        return "Custom Optimization"
    end
end

local function RunCommands(commands, isOptimizing)
    local optimizationType = GetOptimizationType(commands)
    local currentCommand = 1
    local function ApplyNextCommand()
        if currentCommand <= #commands then
            RunConsoleCommand(unpack(commands[currentCommand]))
            PerformanceMod:Log("Applied command: " .. table.concat(commands[currentCommand], " "))
            currentCommand = currentCommand + 1
            timer.Simple(PerformanceMod.Config.CommandInterval, ApplyNextCommand)
        else
            local action = isOptimizing and "applied" or "reverted"
            local message = string.format("Finished %s %s", action, optimizationType)
            PerformanceMod:Log(message)
            chat.AddText(Color(0, 255, 0), "[PerformanceMod] " .. message .. ".")
        end
    end
    
    local action = isOptimizing and "Applying" or "Reverting"
    local startMessage = string.format("Starting to %s %s", action:lower(), optimizationType)
    PerformanceMod:Log(startMessage)
    chat.AddText(Color(255, 255, 0), "[PerformanceMod] " .. startMessage .. "...")
    
    timer.Simple(PerformanceMod.Config.CommandInterval, ApplyNextCommand)
end

local function ApplyClientSettings()
    if GetConVar("performancemod_fps_boost"):GetBool() then
        RunCommands(performance_commands, true)
    else
        RunCommands({
            {"gmod_mcore_test", "0"},
            {"mat_queue_mode", "-1"},
            {"r_queued_ropes", "0"},
            {"r_threaded_renderables", "0"},
            {"r_threaded_particles", "0"},
            {"r_threaded_client_shadow_manager", "0"},
            {"cl_threaded_client_leaf_system", "0"},
            {"cl_threaded_bone_setup", "0"},
            {"ai_expression_optimization", "0"},
            {"fast_fogvolume", "0"},
            {"mat_managedtextures", "1"}
        }, false)
    end

    if GetConVar("performancemod_network_enabled"):GetBool() then
        RunCommands(network_commands, true)
    else
        RunCommands({
            {"cl_forcepreload", "0"},
            {"cl_lagcompensation", "1"},
            {"cl_timeout", "30"},
            {"cl_smoothtime", "0.1"},
            {"cl_localnetworkbackdoor", "0"},
            {"cl_cmdrate", "30"},
            {"cl_updaterate", "20"},
            {"cl_interp_ratio", "2"},
            {"net_maxpacketdrop", "5000"},
            {"net_chokeloop", "0"},
            {"net_compresspackets", "1"},
            {"net_splitpacket_maxrate", "1048576"},
            {"net_compresspackets_minsize", "1024"},
            {"net_maxroutable", "1200"},
            {"net_maxfragments", "1260"},
            {"net_maxfilesize", "16"},
            {"net_maxcleartime", "4"},
            {"rate", "196608"}
        }, false)
    end

    if GetConVar("performancemod_other_enabled"):GetBool() then
        RunCommands(other_commands, true)
    else
        RunCommands({
            {"snd_mix_async", "0"},
            {"snd_async_fullyasync", "0"},
            {"snd_async_minsize", "262144"},
            {"sv_forcepreload", "0"},
            {"studio_queue_mode", "0"},
            {"filesystem_max_stdio_read", "32"},
            {"in_usekeyboardsampletime", "0"},
            {"r_radiosity", "2"},
            {"mat_frame_sync_enable", "1"},
            {"mat_framebuffercopyoverlaysize", "128"},
            {"lod_TransitionDist", "800"},
            {"filesystem_unbuffered_io", "1"}
        }, false)
    end
end

function PerformanceMod:Log(message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logMessage = string.format("[PerformanceMod] %s: %s", timestamp, message)
    print(logMessage)  -- Log to console
    file.Append("performancemod/log.txt", logMessage .. "\n")  -- Log to file
end

-- Clear log file on mod load
file.Write("performancemod/log.txt", "")
PerformanceMod:Log("Log file cleared on mod load")

timer.Simple(PerformanceMod.Config.ApplyDelay, function()
    PerformanceMod:Log("Initial application of client settings")
    ApplyClientSettings()
end)

cvars.AddChangeCallback("performancemod_network_enabled", function(_, _, newValue) 
    PerformanceMod:Log("Network optimization setting changed to " .. newValue)
    timer.Simple(0.1, ApplyClientSettings) 
end, "PerformanceMod")

cvars.AddChangeCallback("performancemod_other_enabled", function(_, _, newValue) 
    PerformanceMod:Log("Other optimizations setting changed to " .. newValue)
    timer.Simple(0.1, ApplyClientSettings) 
end, "PerformanceMod")

cvars.AddChangeCallback("performancemod_fps_boost", function(_, _, newValue) 
    PerformanceMod:Log("FPS boost setting changed to " .. newValue)
    timer.Simple(0.1, ApplyClientSettings) 
end, "PerformanceMod")

local function CreateSettingsMenu()
    spawnmenu.AddToolMenuOption("Utilities", "User", "Performance Mod", "Performance Mod", "", "", function(panel)
        panel:ClearControls()

        local warningLabel = panel:Help("WARNING: Toggling optimizations may cause the game to freeze for a few seconds.")
        warningLabel:SetColor(Color(255, 0, 0)) 
        local noteLabel = panel:Help("Changes are applied immediately. If issues persist, try reconnecting or restarting the game.")
        noteLabel:SetColor(Color(255, 0, 0)) 
        panel:Help("")

        panel:Help("Client-side Optimizations")
        panel:CheckBox("Enable FPS Boost", "performancemod_fps_boost")
        panel:ControlHelp("Applies performance commands to potentially increase FPS.")

        panel:CheckBox("Enable Network Optimization", "performancemod_network_enabled")
        panel:ControlHelp("Adjusts network-related settings to potentially reduce lag and improve connection stability.")

        panel:CheckBox("Enable Other Optimizations", "performancemod_other_enabled")
        panel:ControlHelp("Optimizes various game systems including sound processing and file I/O.")

        if LocalPlayer():IsAdmin() then
            panel:Help("")
            panel:Help("Server-side Optimizations (Admin Only)")
            local serverWarning = panel:Help("WARNING: These optimizations are experimental and may affect gameplay.")
            serverWarning:SetColor(Color(255, 0, 0)) 
            panel:CheckBox("Optimize Server Animations", "performancemod_server_optimize_animations")
            panel:ControlHelp("Disables certain animations on the server to reduce CPU usage.")

            panel:CheckBox("Optimize Server Memory", "performancemod_server_optimize_memory")
            panel:ControlHelp("Adjusts memory-related settings on the server for better performance.")
        end
    end)
end

hook.Add("PopulateToolMenu", "PerformanceModMenu", CreateSettingsMenu)

net.Receive("PerformanceModApplyServer", function()
    PerformanceMod:Log("Server-side optimizations applied.")
end)

local function ApplyServerOptimizations()
    if LocalPlayer():IsAdmin() then
        net.Start("PerformanceModApplyServer")
        net.SendToServer()
    end
end

cvars.AddChangeCallback("performancemod_server_optimize_animations", function() timer.Simple(0.1, ApplyServerOptimizations) end, "PerformanceModServer")
cvars.AddChangeCallback("performancemod_server_optimize_memory", function() timer.Simple(0.1, ApplyServerOptimizations) end, "PerformanceModServer")