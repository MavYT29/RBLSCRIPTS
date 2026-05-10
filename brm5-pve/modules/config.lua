-- Configuration Module
-- Contains all settings, constants, and state variables

local Config = {}
local HttpService = game:GetService("HttpService")

-- CONSTANTS
Config.RAYCAST_COOLDOWN = 0.2
Config.MARKER_MAX_PER_STEP = 12
Config.TARGET_SYNC_INTERVAL = 0.25
Config.NPC_REFRESH_INTERVAL = 0.5
Config.TARGET_BOX_SIZE = Vector3.new(15, 15, 15) -- Size of the adjusted target bounds
Config.MAX_NPC_DETECTION_RADIUS = 3000
Config.npcDetectionRadius = Config.MAX_NPC_DETECTION_RADIUS
Config.CONFIG_FILE = "brm5_pve_config.json"

-- TOGGLES (State)
Config.highlightEnabled = false  -- Visibility markers
Config.sizingEnabled = false     -- Target sizing
Config.showTargetBox = false     -- Shows target bounds
Config.fullBrightEnabled = false -- Removes shadows/darkness
Config.guiVisible = true         -- Menu visibility
Config.isUnloaded = false        -- To stop the script

-- WEAPON PATCHES
Config.patchOptions = { 
    recoil = false, 
    firemodes = false 
}

-- AIMBOT SETTINGS
Config.aimbotEnabled = false
Config.aimbotSmoothness = 0.15        -- 0 = instant, 0.98 = very slow
Config.aimbotFovRadius = 250          -- Field of view radius in pixels
Config.aimbotShowFovCircle = true     -- Show FOV circle on screen
Config.aimbotPrediction = true        -- Predict movement
Config.aimbotPredictionMultiplier = 0.3 -- Prediction strength
Config.aimbotPriorityMode = "distance" -- "distance" or "closestToCrosshair"
Config.aimbotHitPart = "Head"         -- "Head", "HumanoidRootPart", or "Random"
Config.aimbotAimKey = "RightShift"    -- Key to hold for aimbot

-- COLORS (RGB: 0 to 255)
Config.visibleR, Config.visibleG, Config.visibleB = 0, 255, 0    -- Green for visible targets
Config.hiddenR, Config.hiddenG, Config.hiddenB = 255, 0, 0       -- Red for occluded targets
Config.visibleColor = Color3.fromRGB(Config.visibleR, Config.visibleG, Config.visibleB)
Config.hiddenColor = Color3.fromRGB(Config.hiddenR, Config.hiddenG, Config.hiddenB)

-- Update color function
function Config:updateVisibleColor(r, g, b)
    if r then self.visibleR = r end
    if g then self.visibleG = g end
    if b then self.visibleB = b end
    self.visibleColor = Color3.fromRGB(self.visibleR, self.visibleG, self.visibleB)
end

function Config:updateHiddenColor(r, g, b)
    if r then self.hiddenR = r end
    if g then self.hiddenG = g end
    if b then self.hiddenB = b end
    self.hiddenColor = Color3.fromRGB(self.hiddenR, self.hiddenG, self.hiddenB)
end

function Config:updateNPCDetectionRadius(value)
    self.npcDetectionRadius = math.clamp(
        math.floor(value or self.npcDetectionRadius),
        0,
        self.MAX_NPC_DETECTION_RADIUS
    )
end

-- Aimbot update functions
function Config:updateAimbotEnabled(enabled)
    self.aimbotEnabled = enabled
end

function Config:updateAimbotSmoothness(value)
    self.aimbotSmoothness = math.clamp(value, 0, 0.98)
end

function Config:updateAimbotFovRadius(value)
    self.aimbotFovRadius = math.clamp(value, 50, 500)
end

function Config:updateAimbotShowFovCircle(enabled)
    self.aimbotShowFovCircle = enabled
end

function Config:updateAimbotPrediction(enabled)
    self.aimbotPrediction = enabled
end

function Config:updateAimbotPriorityMode(mode)
    if mode == "distance" or mode == "closestToCrosshair" then
        self.aimbotPriorityMode = mode
    end
end

function Config:updateAimbotHitPart(part)
    if part == "Head" or part == "HumanoidRootPart" or part == "Random" then
        self.aimbotHitPart = part
    end
end

function Config:isNPCDetectionEnabled()
    return self.sizingEnabled or self.showTargetBox or self.highlightEnabled or self.aimbotEnabled
end

function Config:serialize()
    return {
        highlightEnabled = self.highlightEnabled,
        sizingEnabled = self.sizingEnabled,
        showTargetBox = self.showTargetBox,
        fullBrightEnabled = self.fullBrightEnabled,
        npcDetectionRadius = self.npcDetectionRadius,
        patchOptions = {
            recoil = self.patchOptions.recoil,
            firemodes = self.patchOptions.firemodes
        },
        visibleR = self.visibleR,
        visibleG = self.visibleG,
        visibleB = self.visibleB,
        hiddenR = self.hiddenR,
        hiddenG = self.hiddenG,
        hiddenB = self.hiddenB,
        -- Aimbot settings
        aimbotEnabled = self.aimbotEnabled,
        aimbotSmoothness = self.aimbotSmoothness,
        aimbotFovRadius = self.aimbotFovRadius,
        aimbotShowFovCircle = self.aimbotShowFovCircle,
        aimbotPrediction = self.aimbotPrediction,
        aimbotPriorityMode = self.aimbotPriorityMode,
        aimbotHitPart = self.aimbotHitPart
    }
end

function Config:applySavedData(data)
    if type(data) ~= "table" then
        return
    end

    -- Core toggles
    if data.highlightEnabled ~= nil then self.highlightEnabled = data.highlightEnabled end
    if data.sizingEnabled ~= nil then self.sizingEnabled = data.sizingEnabled end
    if data.showTargetBox ~= nil then self.showTargetBox = data.showTargetBox end
    if data.fullBrightEnabled ~= nil then self.fullBrightEnabled = data.fullBrightEnabled end
    
    -- Weapon patches
    if type(data.patchOptions) == "table" then
        if data.patchOptions.recoil ~= nil then self.patchOptions.recoil = data.patchOptions.recoil end
        if data.patchOptions.firemodes ~= nil then self.patchOptions.firemodes = data.patchOptions.firemodes end
    end

    -- Colors
    self:updateVisibleColor(data.visibleR, data.visibleG, data.visibleB)
    self:updateHiddenColor(data.hiddenR, data.hiddenG, data.hiddenB)
    
    -- NPC detection
    self:updateNPCDetectionRadius(data.npcDetectionRadius)
    
    -- Aimbot settings
    if data.aimbotEnabled ~= nil then self.aimbotEnabled = data.aimbotEnabled end
    if data.aimbotSmoothness ~= nil then self:updateAimbotSmoothness(data.aimbotSmoothness) end
    if data.aimbotFovRadius ~= nil then self:updateAimbotFovRadius(data.aimbotFovRadius) end
    if data.aimbotShowFovCircle ~= nil then self.aimbotShowFovCircle = data.aimbotShowFovCircle end
    if data.aimbotPrediction ~= nil then self.aimbotPrediction = data.aimbotPrediction end
    if data.aimbotPriorityMode ~= nil then self:updateAimbotPriorityMode(data.aimbotPriorityMode) end
    if data.aimbotHitPart ~= nil then self:updateAimbotHitPart(data.aimbotHitPart) end
end

function Config:save()
    if type(writefile) ~= "function" then
        return false
    end

    local okEncode, encoded = pcall(HttpService.JSONEncode, HttpService, self:serialize())
    if not okEncode then
        return false
    end

    local okWrite = pcall(writefile, self.CONFIG_FILE, encoded)
    return okWrite
end

function Config:load()
    if type(isfile) ~= "function" or type(readfile) ~= "function" or not isfile(self.CONFIG_FILE) then
        return false
    end

    local okRead, raw = pcall(readfile, self.CONFIG_FILE)
    if not okRead or type(raw) ~= "string" or raw == "" then
        return false
    end

    local okDecode, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not okDecode then
        return false
    end

    self:applySavedData(data)
    return true
end

return Config
