-- BRM5 v7.0 by dexter 
-- Credits to ryknuq and their overvoltage script, which helped me understand how to integrate the Aim into my script. Without their script, I don't think I could have done this.
-- Coordinates all modules

if typeof(clear) == "function" then
    clear()
end

local MAIN_VERSION = "cache-bust-2026-03-18-01"
local GITHUB_BASE = "https://raw.githubusercontent.com/MavYT29/RBLSCRIPTS/main/brm5-pve/modules/"
local CACHE_BUSTER = MAIN_VERSION .. "-" .. tostring(os.time())

local function loadModule(moduleName)
    local url = GITHUB_BASE .. moduleName .. ".lua?v=" .. CACHE_BUSTER

    local okResponse, response = pcall(function()
        return game:HttpGet(url)
    end)
    if not okResponse then
        warn("Failed to download module: " .. moduleName)
        warn("URL: " .. url)
        warn("HttpGet error: " .. tostring(response))
        return nil
    end

    if type(response) ~= "string" or response == "" then
        warn("Module download returned empty content: " .. moduleName)
        warn("URL: " .. url)
        return nil
    end

    local chunk, compileError = loadstring(response)
    if not chunk then
        warn("Failed to compile module: " .. moduleName)
        warn("URL: " .. url)
        warn("Compile error: " .. tostring(compileError))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("Failed to execute module: " .. moduleName)
        warn("URL: " .. url)
        warn("Runtime error: " .. tostring(result))
        return nil
    end

    return result
end

local Services = loadModule("services")
local Config = loadModule("config")
local NPCManager = loadModule("npc_manager")
local TargetSizing = loadModule("silent")
local Markers = loadModule("walls")
local Lighting = loadModule("fullbright")
local Weapons = loadModule("norecoil")
local Aimbot = loadModule("aimbot")
local GUI = loadModule("gui")

if not (Services and Config and NPCManager and TargetSizing and Markers and Lighting and Weapons and Aimbot and GUI) then
    error("Failed to load one or more modules. Please verify the remote module files.")
end

Config:load()
Lighting:storeOriginalSettings(Services.Lighting)

-- Apply saved aimbot settings to Aimbot module
if Config.aimbotEnabled ~= nil then Aimbot.enabled = Config.aimbotEnabled end
if Config.aimbotSmoothness ~= nil then Aimbot.smoothness = Config.aimbotSmoothness end
if Config.aimbotFovRadius ~= nil then Aimbot.fovRadius = Config.aimbotFovRadius end
if Config.aimbotShowFovCircle ~= nil then Aimbot.showFovCircle = Config.aimbotShowFovCircle end
if Config.aimbotPrediction ~= nil then Aimbot.prediction = Config.aimbotPrediction end
if Config.aimbotPriorityMode ~= nil then Aimbot.priorityMode = Config.aimbotPriorityMode end
if Config.aimbotHitPart ~= nil then Aimbot.hitPart = Config.aimbotHitPart end

local runtimeConnections = {}

local function saveConfig()
    Config:save()
end

local function syncMouseState()
    if Config.guiVisible then
        Services.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        Services.UserInputService.MouseIconEnabled = true
    end
end

local function forceMouseLock()
    Services.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    Services.UserInputService.MouseIconEnabled = false
end

local function toggleGUIVisibility()
    local wasVisible = Config.guiVisible
    Config.guiVisible = GUI:toggleVisibility()
    if Config.guiVisible then
        syncMouseState()
    elseif wasVisible then
        forceMouseLock()
    end
    return Config.guiVisible
end

local function disconnectRuntimeConnections()
    for _, connection in ipairs(runtimeConnections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    runtimeConnections = {}
end

local callbacks = {
    onSizingToggle = function(enabled)
        Config.sizingEnabled = enabled
        if not enabled then
            TargetSizing:cleanup(NPCManager)
        end
        NPCManager:refreshTrackedNPCs(Services.Workspace, Markers, TargetSizing, Config)
        saveConfig()
    end,

    onShowTargetBoxToggle = function(enabled)
        Config.showTargetBox = enabled
        NPCManager:refreshTrackedNPCs(Services.Workspace, Markers, TargetSizing, Config)
        saveConfig()
    end,

    onHighlightsToggle = function(enabled)
        Config.highlightEnabled = enabled
        NPCManager:refreshTrackedNPCs(Services.Workspace, Markers, TargetSizing, Config)
        if enabled then
            Markers.enable(NPCManager, Config)
        else
            Markers.disable()
        end
        saveConfig()
    end,

    onFullBrightToggle = function(enabled)
        Config.fullBrightEnabled = enabled
        if not enabled then
            Lighting:restoreOriginal(Services.Lighting)
        end
        saveConfig()
    end,

    onStabilityToggle = function(enabled)
        Config.patchOptions.recoil = enabled
        Weapons.patchWeapons(Services.ReplicatedStorage, Config.patchOptions)
        saveConfig()
    end,

    onFiremodeOptionsToggle = function(enabled)
        Config.patchOptions.firemodes = enabled
        Weapons.patchWeapons(Services.ReplicatedStorage, Config.patchOptions)
        saveConfig()
    end,

    onVisibleRChange = function(value)
        Config:updateVisibleColor(value, nil, nil)
        saveConfig()
    end,

    onVisibleGChange = function(value)
        Config:updateVisibleColor(nil, value, nil)
        saveConfig()
    end,

    onVisibleBChange = function(value)
        Config:updateVisibleColor(nil, nil, value)
        saveConfig()
    end,

    onHiddenRChange = function(value)
        Config:updateHiddenColor(value, nil, nil)
        saveConfig()
    end,

    onHiddenGChange = function(value)
        Config:updateHiddenColor(nil, value, nil)
        saveConfig()
    end,

    onHiddenBChange = function(value)
        Config:updateHiddenColor(nil, nil, value)
        saveConfig()
    end,

    onNPCDetectionRadiusChange = function(value)
        Config:updateNPCDetectionRadius(value)
        NPCManager:refreshTrackedNPCs(Services.Workspace, Markers, TargetSizing, Config)
        saveConfig()
    end,

    -- Aimbot Callbacks
    onAimbotToggle = function(enabled)
        Config:updateAimbotEnabled(enabled)
        NPCManager:refreshTrackedNPCs(Services.Workspace, Markers, TargetSizing, Config)
        Aimbot.setEnabled(enabled, Services, GUI.screenGui)
        saveConfig()
    end,

    onSmoothnessChange = function(value)
        Config:updateAimbotSmoothness(value)
        Aimbot.setSmoothness(value)
        saveConfig()
    end,

    onFovRadiusChange = function(value)
        Config:updateAimbotFovRadius(value)
        Aimbot.setFovRadius(value, Services)
        saveConfig()
    end,

    onPriorityModeChange = function(mode)
        Config:updateAimbotPriorityMode(mode)
        Aimbot.setPriorityMode(mode)
        saveConfig()
    end,

    onHitPartChange = function(part)
        Config:updateAimbotHitPart(part)
        Aimbot.setHitPart(part)
        saveConfig()
    end,

    onPredictionToggle = function(enabled)
        Config:updateAimbotPrediction(enabled)
        Aimbot.setPredictionEnabled(enabled)
        saveConfig()
    end,

    onShowFovToggle = function(enabled)
        Config:updateAimbotShowFovCircle(enabled)
        Aimbot.showFovCircle = enabled
        if Aimbot.fovCircle then
            Aimbot.fovCircle.Visible = enabled and Aimbot.enabled
        end
        saveConfig()
    end,

    onVisibilityToggle = function()
        toggleGUIVisibility()
    end,

    onUnload = function()
        if Config.isUnloaded then
            return
        end

        Config.isUnloaded = true
        disconnectRuntimeConnections()
        Markers.disable()
        TargetSizing:cleanup(NPCManager)
        NPCManager:cleanup()
        Aimbot.cleanup()
        Lighting:restoreOriginal(Services.Lighting)
        Config.guiVisible = false
        saveConfig()
        forceMouseLock()
        GUI:destroy()
    end
}

-- Initialize GUI with aimbot parameter
GUI:init(Services, Config, callbacks, Aimbot)
syncMouseState()

-- Setup NPC detection
NPCManager:scanWorkspace(Services.Workspace, Markers, Config)
NPCManager:setupListener(Services.Workspace, Markers, Config)

-- Setup Aimbot
Aimbot.setupKeybinds(Services)
Aimbot.createFovCircle(Services, GUI.screenGui)

-- Enable features based on config
if Config.highlightEnabled then
    Markers.enable(NPCManager, Config)
end

if Config.aimbotEnabled then
    Aimbot.setEnabled(true, Services, GUI.screenGui)
end

if Config.patchOptions.recoil or Config.patchOptions.firemodes then
    Weapons.patchWeapons(Services.ReplicatedStorage, Config.patchOptions)
end

local markerAccumulator = 0
local targetAccumulator = 0
local npcAccumulator = 0
local aimbotAccumulator = 0
local AIMBOT_UPDATE_INTERVAL = 0.016 -- ~60fps

table.insert(runtimeConnections, Services.RunService.Heartbeat:Connect(function(dt)
    if Config.isUnloaded then
        return
    end

    if Config.guiVisible then
        syncMouseState()
    end
    
    Lighting:update(Services.Lighting, Config)

    -- Update NPC tracking
    npcAccumulator = npcAccumulator + dt
    if npcAccumulator >= Config.NPC_REFRESH_INTERVAL then
        NPCManager:refreshTrackedNPCs(Services.Workspace, Markers, TargetSizing, Config)
        npcAccumulator = 0
    end

    -- Update marker colors (wallhack)
    markerAccumulator = markerAccumulator + dt
    if markerAccumulator >= Config.RAYCAST_COOLDOWN then
        local okMarkers, markerError = pcall(
            Markers.updateColors,
            NPCManager,
            Services.Workspace.CurrentCamera or Services.camera,
            Services.Workspace,
            Services.localPlayer,
            Config
        )
        if not okMarkers then
            warn("Markers.updateColors failed: " .. tostring(markerError))
        end
        markerAccumulator = 0
    end

    -- Update target sizing (silent aim)
    targetAccumulator = targetAccumulator + dt
    if targetAccumulator >= Config.TARGET_SYNC_INTERVAL then
        TargetSizing:updateAllTargets(NPCManager, Config)
        targetAccumulator = 0
    end

    -- Update aimbot (high frequency for smooth aiming)
    aimbotAccumulator = aimbotAccumulator + dt
    if aimbotAccumulator >= AIMBOT_UPDATE_INTERVAL then
        local okAimbot, aimbotError = pcall(
            Aimbot.update,
            NPCManager,
            Services,
            Config
        )
        if not okAimbot then
            warn("Aimbot.update failed: " .. tostring(aimbotError))
        end
        aimbotAccumulator = 0
    end
end))

table.insert(runtimeConnections, Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if Config.isUnloaded then
        return
    end

    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        toggleGUIVisibility()
    end
end))

-- FIXED: Viewport resize handler for FOV circle
-- Use camera's GetPropertyChangedSignal for ViewportSize, NOT UserInputService
local currentCamera = Services.Workspace.CurrentCamera
if currentCamera then
    local viewportChangedConn = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if Aimbot and Aimbot.fovCircle then
            Aimbot.updateFovCirclePosition(Services)
        end
    end)
    table.insert(runtimeConnections, viewportChangedConn)
end

print("BRM5 PVE Script v7.0 Loaded Successfully!")
print("Press Insert to toggle GUI")
print("Hold Right Shift for Aimbot (configurable)")
