-- Aimbot Module
-- Camera-based aiming system that locks onto enemies

local Aimbot = {}

-- Settings
Aimbot.enabled = false
Aimbot.smoothness = 0.15          -- 0 = instant, 1 = very slow (default: 0.15)
Aimbot.fovRadius = 250            -- Field of view radius in pixels
Aimbot.showFovCircle = true       -- Show FOV circle on screen
Aimbot.prediction = true          -- Predict movement
Aimbot.predictionMultiplier = 0.3 -- Prediction strength
Aimbot.priorityMode = "distance"  -- "distance" or "closestToCrosshair"
Aimbot.teamCheck = true           -- Only target enemies
Aimbot.hitPart = "Head"           -- "Head", "HumanoidRootPart", or "Random"
Aimbot.aimKey = Enum.KeyCode.RightShift  -- Key to hold for aimbot (nil = always on)

-- Internal variables
Aimbot.fovCircle = nil
Aimbot.currentTarget = nil
Aimbot.latestCameraCFrame = nil
Aimbot.isAiming = false
Aimbot.keyDown = false
Aimbot.connections = {}
Aimbot.screenGui = nil
Aimbot.cameraOffset = Vector3.new(0, 0, 0) -- Camera shake compensation

-- Get valid hit parts from an NPC
function Aimbot.getHitPart(npc)
    if Aimbot.hitPart == "Head" then
        return npc:FindFirstChild("Head")
    elseif Aimbot.hitPart == "HumanoidRootPart" then
        return npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Root")
    else -- Random
        local parts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
        local randomPart = parts[math.random(1, #parts)]
        return npc:FindFirstChild(randomPart) or npc:FindFirstChild("Head")
    end
end

-- Check if a target is valid
function Aimbot.isValidTarget(npc, targetPart, localPlayer, camera)
    if not npc or not targetPart or not targetPart.Parent then
        return false
    end
    
    local character = localPlayer.Character
    if not character then
        return false
    end
    
    -- Check if target is alive
    local humanoid = npc:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    
    -- Team check (assuming NPCs have team color or name pattern)
    if Aimbot.teamCheck then
        local npcName = npc.Name:lower()
        if npcName:find("civilian") or npcName:find("friendly") then
            return false
        end
    end
    
    return true
end

-- Get all valid targets from NPCManager
function Aimbot.getValidTargets(npcManager, localPlayer, camera)
    local targets = {}
    local activeNPCs = npcManager.getActiveNPCs and npcManager:getActiveNPCs() or {}
    
    for npc, data in pairs(activeNPCs) do
        local targetPart = Aimbot.getHitPart(npc)
        if Aimbot.isValidTarget(npc, targetPart, localPlayer, camera) then
            table.insert(targets, {
                npc = npc,
                part = targetPart,
                data = data
            })
        end
    end
    
    return targets
end

-- Get screen position of a world point
function Aimbot.worldToScreen(camera, worldPoint)
    local vector, onScreen = camera:WorldToScreenPoint(worldPoint)
    return Vector2.new(vector.X, vector.Y), onScreen
end

-- Calculate angle between camera look vector and target direction
function Aimbot.getAngleToTarget(camera, targetPosition)
    local cameraCFrame = camera.CFrame
    local cameraPos = cameraCFrame.Position
    local targetDir = (targetPosition - cameraPos).Unit
    local lookDir = cameraCFrame.LookVector
    
    return math.acos(math.clamp(lookDir:Dot(targetDir), -1, 1))
end

-- Calculate distance to target
function Aimbot.getDistanceToTarget(localPlayer, targetPosition)
    local character = localPlayer.Character
    if not character then return math.huge end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Root")
    if not rootPart then return math.huge end
    
    return (targetPosition - rootPart.Position).Magnitude
end

-- Predict target movement
function Aimbot.predictPosition(targetPart, bulletSpeed)
    if not Aimbot.prediction then
        return targetPart.Position
    end
    
    local targetVelocity = Vector3.new(0, 0, 0)
    local humanoid = targetPart.Parent:FindFirstChildOfClass("Humanoid")
    if humanoid then
        targetVelocity = humanoid:GetVelocity()
    end
    
    local distance = (Services.camera.CFrame.Position - targetPart.Position).Magnitude
    local travelTime = distance / (bulletSpeed or 2500) -- Default bullet speed
    
    return targetPart.Position + (targetVelocity * travelTime * Aimbot.predictionMultiplier)
end

-- Find best target based on priority mode
function Aimbot.findBestTarget(targets, camera, localPlayer)
    if #targets == 0 then
        return nil
    end
    
    local bestTarget = nil
    local bestScore = Aimbot.priorityMode == "distance" and math.huge or -math.huge
    
    for _, target in ipairs(targets) do
        local targetPart = target.part
        if targetPart and targetPart.Parent then
            local screenPos, onScreen = Aimbot.worldToScreen(camera, targetPart.Position)
            local angle = Aimbot.getAngleToTarget(camera, targetPart.Position)
            local distance = Aimbot.getDistanceToTarget(localPlayer, targetPart.Position)
            
            -- Check if within FOV
            local fovCondition = Aimbot.fovRadius >= 999 or angle <= math.rad(Aimbot.fovRadius)
            
            if onScreen and fovCondition then
                if Aimbot.priorityMode == "distance" then
                    if distance < bestScore then
                        bestScore = distance
                        bestTarget = target
                    end
                else -- closestToCrosshair (angle based)
                    if angle < bestScore then
                        bestScore = angle
                        bestTarget = target
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- Get aim position with prediction
function Aimbot.getAimPosition(target, bulletSpeed)
    if not target or not target.part then
        return nil
    end
    
    local targetPart = target.part
    local predictedPos = Aimbot.predictPosition(targetPart, bulletSpeed)
    
    return predictedPos
end

-- Apply smooth aiming
function Aimbot.smoothAim(currentCFrame, targetCFrame, smoothness)
    if smoothness <= 0 then
        return targetCFrame
    end
    
    local smoothFactor = math.clamp(1 - smoothness, 0.05, 0.95)
    
    -- Interpolate position
    local newPosition = currentCFrame.Position:Lerp(targetCFrame.Position, smoothFactor)
    
    -- Interpolate rotation using quaternion slerp equivalent
    local currentLook = currentCFrame.LookVector
    local targetLook = targetCFrame.LookVector
    local newLook = currentLook:Lerp(targetLook, smoothFactor).Unit
    
    return CFrame.new(newPosition, newPosition + newLook)
end

-- Calculate camera CFrame to aim at target
function Aimbot.calculateAimCFrame(camera, targetPosition)
    local cameraPos = camera.CFrame.Position
    local direction = (targetPosition - cameraPos).Unit
    return CFrame.new(cameraPos, cameraPos + direction)
end

-- Main aimbot update
function Aimbot.update(npcManager, services, config)
    if not Aimbot.enabled then
        if Aimbot.fovCircle then
            Aimbot.fovCircle.Visible = false
        end
        Aimbot.currentTarget = nil
        return
    end
    
    local camera = services.camera
    local localPlayer = services.localPlayer
    local workspace = services.Workspace
    
    if not camera or not localPlayer then
        return
    end
    
    -- Check if aimbot should be active (keybind or always on)
    local shouldAim = Aimbot.keyDown or (Aimbot.aimKey == nil)
    
    -- Update FOV circle visibility
    if Aimbot.fovCircle then
        Aimbot.fovCircle.Visible = Aimbot.showFovCircle and Aimbot.enabled
        if Aimbot.fovCircle.Visible then
            Aimbot.fovCircle.Position = UDim2.fromOffset(
                camera.ViewportSize.X / 2,
                camera.ViewportSize.Y / 2
            )
        end
    end
    
    -- Get valid targets
    local targets = Aimbot.getValidTargets(npcManager, localPlayer, camera)
    local bestTarget = Aimbot.findBestTarget(targets, camera, localPlayer)
    
    if bestTarget and shouldAim then
        Aimbot.currentTarget = bestTarget
        
        local aimPos = Aimbot.getAimPosition(bestTarget, 2500)
        if aimPos then
            local targetCFrame = Aimbot.calculateAimCFrame(camera, aimPos)
            local smoothAmount = Aimbot.smoothness
            
            if not Aimbot.keyDown then
                -- If no keybind, use smoothness directly
                smoothAmount = Aimbot.smoothness
            end
            
            -- Apply smoothing to camera
            local newCFrame = Aimbot.smoothAim(camera.CFrame, targetCFrame, smoothAmount)
            
            -- Only update if changed significantly
            if (newCFrame.Position - camera.CFrame.Position).Magnitude > 0.01 or
               (newCFrame.LookVector - camera.CFrame.LookVector).Magnitude > 0.001 then
                camera.CFrame = newCFrame
            end
        end
    else
        Aimbot.currentTarget = nil
    end
end

-- Create FOV circle on screen
function Aimbot.createFovCircle(services, screenGui)
    if Aimbot.fovCircle then
        Aimbot.fovCircle:Destroy()
    end
    
    local camera = services.camera
    local fovCircle = Instance.new("Frame", screenGui)
    fovCircle.Name = "AimbotFOV"
    fovCircle.Size = UDim2.fromOffset(Aimbot.fovRadius * 2, Aimbot.fovRadius * 2)
    fovCircle.Position = UDim2.fromOffset(
        camera.ViewportSize.X / 2 - Aimbot.fovRadius,
        camera.ViewportSize.Y / 2 - Aimbot.fovRadius
    )
    fovCircle.BackgroundTransparency = 1
    fovCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    fovCircle.Visible = Aimbot.showFovCircle and Aimbot.enabled
    fovCircle.ZIndex = 1000
    
    local circle = Instance.new("Frame", fovCircle)
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.BackgroundTransparency = 1
    circle.BorderSizePixel = 0
    
    local uiStroke = Instance.new("UIStroke", circle)
    uiStroke.Color = Color3.fromRGB(0, 255, 0)
    uiStroke.Thickness = 2
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local uiCorner = Instance.new("UICorner", circle)
    uiCorner.CornerRadius = UDim.new(1, 0)
    
    -- Add center dot
    local dot = Instance.new("Frame", fovCircle)
    dot.Size = UDim2.fromOffset(4, 4)
    dot.Position = UDim2.new(0.5, -2, 0.5, -2)
    dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    Aimbot.fovCircle = fovCircle
    return fovCircle
end

-- Update FOV circle position (called on viewport resize)
function Aimbot.updateFovCirclePosition(services)
    if not Aimbot.fovCircle then return end
    
    local camera = services.camera
    Aimbot.fovCircle.Position = UDim2.fromOffset(
        camera.ViewportSize.X / 2 - Aimbot.fovRadius,
        camera.ViewportSize.Y / 2 - Aimbot.fovRadius
    )
end

-- Update FOV circle radius
function Aimbot.setFovRadius(radius, services)
    Aimbot.fovRadius = math.clamp(radius, 50, 500)
    if Aimbot.fovCircle then
        Aimbot.fovCircle.Size = UDim2.fromOffset(Aimbot.fovRadius * 2, Aimbot.fovRadius * 2)
        Aimbot.updateFovCirclePosition(services)
    end
end

-- Toggle aimbot enabled
function Aimbot.setEnabled(enabled, services, screenGui)
    Aimbot.enabled = enabled
    
    if Aimbot.fovCircle then
        Aimbot.fovCircle.Visible = Aimbot.showFovCircle and enabled
    end
    
    if enabled and Aimbot.fovCircle == nil and screenGui then
        Aimbot.createFovCircle(services, screenGui)
    end
    
    if not enabled then
        Aimbot.currentTarget = nil
    end
end

-- Set smoothness
function Aimbot.setSmoothness(value)
    Aimbot.smoothness = math.clamp(value, 0, 0.98)
end

-- Set prediction
function Aimbot.setPredictionEnabled(enabled)
    Aimbot.prediction = enabled
end

-- Set priority mode
function Aimbot.setPriorityMode(mode)
    Aimbot.priorityMode = mode -- "distance" or "closestToCrosshair"
end

-- Set hit part
function Aimbot.setHitPart(part)
    Aimbot.hitPart = part -- "Head", "HumanoidRootPart", "Random"
end

-- Set aim key
function Aimbot.setAimKey(keyCode)
    Aimbot.aimKey = keyCode
end

-- Setup keybind listeners
function Aimbot.setupKeybinds(services)
    -- Clear existing connections
    for _, conn in ipairs(Aimbot.connections) do
        pcall(function() conn:Disconnect() end)
    end
    Aimbot.connections = {}
    
    -- InputBegan connection
    local inputBeganConn = services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if Aimbot.aimKey and input.KeyCode == Aimbot.aimKey then
            Aimbot.keyDown = true
        end
    end)
    table.insert(Aimbot.connections, inputBeganConn)
    
    -- InputEnded connection
    local inputEndedConn = services.UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if Aimbot.aimKey and input.KeyCode == Aimbot.aimKey then
            Aimbot.keyDown = false
            Aimbot.currentTarget = nil
        end
    end)
    table.insert(Aimbot.connections, inputEndedConn)
end

-- Cleanup
function Aimbot.cleanup()
    for _, conn in ipairs(Aimbot.connections) do
        pcall(function() conn:Disconnect() end)
    end
    Aimbot.connections = {}
    
    if Aimbot.fovCircle then
        Aimbot.fovCircle:Destroy()
        Aimbot.fovCircle = nil
    end
    
    Aimbot.currentTarget = nil
    Aimbot.keyDown = false
    Aimbot.enabled = false
end

-- Get current target info (for GUI display)
function Aimbot.getTargetInfo()
    if not Aimbot.currentTarget or not Aimbot.currentTarget.npc then
        return nil
    end
    
    local npc = Aimbot.currentTarget.npc
    local distance = "Unknown"
    
    local localPlayer = Services and Services.localPlayer
    if localPlayer and localPlayer.Character then
        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetPart = Aimbot.getHitPart(npc)
        if rootPart and targetPart then
            distance = string.format("%.1f", (targetPart.Position - rootPart.Position).Magnitude)
        end
    end
    
    return {
        name = npc.Name,
        distance = distance,
        part = Aimbot.hitPart
    }
end

return Aimbot