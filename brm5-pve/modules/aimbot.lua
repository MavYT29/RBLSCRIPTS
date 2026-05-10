-- Aimbot Module - FIXED for Target Sizing / Hitbox system
-- Uses the Root part (which is enlarged as hitbox) instead of Head

local Aimbot = {}

-- Settings
Aimbot.enabled = false
Aimbot.smoothness = 0.15          -- 0 = instant, 1 = very slow
Aimbot.fovRadius = 250            -- Field of view radius in pixels
Aimbot.showFovCircle = true       -- Show FOV circle on screen
Aimbot.prediction = true          -- Predict movement
Aimbot.predictionMultiplier = 0.3 -- Prediction strength
Aimbot.priorityMode = "distance"  -- "distance" or "closestToCrosshair"
Aimbot.teamCheck = true           -- Only target enemies
Aimbot.hitPart = "Root"           -- CHANGED: "Root" (the enlarged hitbox), "Head", or "HumanoidRootPart"
Aimbot.aimKey = Enum.UserInputType.MouseButton2
Aimbot.aimMethod = "mouse"
Aimbot.autoFire = false
Aimbot.autoFireDelay = 0.05
Aimbot.bulletSpeed = 2500

-- Internal variables
Aimbot.fovCircle = nil
Aimbot.currentTarget = nil
Aimbot.currentTargetPart = nil
Aimbot.keyDown = false
Aimbot.connections = {}
Aimbot.screenGui = nil
Aimbot.lastAutoFireTime = 0
Aimbot.targetScreenPos = nil
Aimbot.services = nil

-- CRITICAL FIX: Get the hitbox part (Root is enlarged by TargetSizing)
function Aimbot.getHitPart(npc)
    if Aimbot.hitPart == "Root" then
        -- Priority: Root (enlarged hitbox) -> HumanoidRootPart -> Head
        local root = npc:FindFirstChild("Root")
        if root then return root end
        
        local humanoidRoot = npc:FindFirstChild("HumanoidRootPart")
        if humanoidRoot then return humanoidRoot end
        
        return npc:FindFirstChild("Head")
    elseif Aimbot.hitPart == "Head" then
        return npc:FindFirstChild("Head")
    elseif Aimbot.hitPart == "HumanoidRootPart" then
        return npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Root")
    else -- Random
        local parts = {"Root", "HumanoidRootPart", "Head", "UpperTorso"}
        for _, partName in ipairs(parts) do
            local part = npc:FindFirstChild(partName)
            if part then return part end
        end
        return npc:FindFirstChild("Head")
    end
end

-- Check if target is a valid enemy (not player, not friendly)
function Aimbot.isValidTarget(npc, targetPart, localPlayer)
    if not npc or not targetPart or not targetPart.Parent then
        return false
    end
    
    -- Skip if it's the player themselves
    if npc == localPlayer.Character then
        return false
    end
    
    -- Check if target is alive
    local humanoid = npc:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    
    -- Team check - skip friendly NPCs
    if Aimbot.teamCheck then
        local npcName = npc.Name:lower()
        -- Skip civilian/friendly names
        if npcName:find("civilian") or npcName:find("friendly") or npcName:find("ally") or npcName:find("friend") then
            return false
        end
        
        -- Check for team color or badge
        local isFriendly = false
        
        -- Look for any sign of being friendly
        local billboard = npc:FindFirstChildOfClass("BillboardGui")
        if billboard then
            local textLabel = billboard:FindFirstChild("TextLabel")
            if textLabel and textLabel.Text then
                local text = textLabel.Text:lower()
                if text:find("friendly") or text:find("ally") or text:find("civilian") then
                    isFriendly = true
                end
            end
        end
        
        if isFriendly then
            return false
        end
    end
    
    return true
end

-- Get all valid targets from NPCManager
function Aimbot.getValidTargets(npcManager, localPlayer)
    local targets = {}
    local activeNPCs = npcManager.getActiveNPCs and npcManager:getActiveNPCs() or {}
    
    print("[Aimbot] Checking NPCs:", tableCount(activeNPCs)) -- Debug
    
    for npc, data in pairs(activeNPCs) do
        local targetPart = Aimbot.getHitPart(npc)
        
        -- Debug: Print found NPCs
        if targetPart then
            print("[Aimbot] Found NPC:", npc.Name, "Part:", targetPart.Name, "Part Size:", targetPart.Size)
        else
            print("[Aimbot] NPC has no valid hit part:", npc.Name)
        end
        
        if Aimbot.isValidTarget(npc, targetPart, localPlayer) and targetPart then
            table.insert(targets, {
                npc = npc,
                part = targetPart,
                data = data
            })
        end
    end
    
    print("[Aimbot] Valid targets found:", #targets)
    return targets
end

-- Helper function for debugging
function tableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Get screen position of a world point
function Aimbot.worldToScreen(camera, worldPoint)
    local success, vector, onScreen = pcall(function()
        return camera:WorldToScreenPoint(worldPoint)
    end)
    
    if success and vector then
        return Vector2.new(vector.X, vector.Y), onScreen
    end
    return nil, false
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

-- Get target velocity for prediction
function Aimbot.getTargetVelocity(targetPart)
    -- Check if part has velocity
    if targetPart.AssemblyLinearVelocity then
        return targetPart.AssemblyLinearVelocity
    end
    
    local humanoid = targetPart.Parent:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid:GetVelocity()
    end
    
    return Vector3.new(0, 0, 0)
end

-- Predict target movement
function Aimbot.predictPosition(targetPart, bulletSpeed)
    if not Aimbot.prediction then
        return targetPart.Position
    end
    
    local targetVelocity = Aimbot.getTargetVelocity(targetPart)
    
    local camera = Aimbot.services and Aimbot.services.camera or workspace.CurrentCamera
    if not camera then return targetPart.Position end
    
    local distance = (camera.CFrame.Position - targetPart.Position).Magnitude
    local travelTime = distance / (bulletSpeed or Aimbot.bulletSpeed)
    
    -- Predict position with multiplier
    local predictedPos = targetPart.Position + (targetVelocity * travelTime * Aimbot.predictionMultiplier)
    
    return predictedPos
end

-- Get screen position of target with prediction
function Aimbot.getTargetScreenPosition(camera, target)
    if not target or not target.part then
        return nil, false
    end
    
    local aimPos = Aimbot.predictPosition(target.part, Aimbot.bulletSpeed)
    return Aimbot.worldToScreen(camera, aimPos)
end

-- Calculate distance from crosshair to target (in pixels)
function Aimbot.getScreenDistanceToCenter(camera, targetPosition)
    local screenPos, onScreen = Aimbot.worldToScreen(camera, targetPosition)
    if not onScreen or not screenPos then
        return math.huge
    end
    
    local centerX = camera.ViewportSize.X / 2
    local centerY = camera.ViewportSize.Y / 2
    local dx = screenPos.X - centerX
    local dy = screenPos.Y - centerY
    
    return math.sqrt(dx * dx + dy * dy)
end

-- Find best target based on priority mode
function Aimbot.findBestTarget(targets, camera, localPlayer)
    if #targets == 0 then
        return nil, nil
    end
    
    local bestTarget = nil
    local bestScore = Aimbot.priorityMode == "distance" and math.huge or -math.huge
    
    for _, target in ipairs(targets) do
        local targetPart = target.part
        if targetPart and targetPart.Parent then
            -- Always use predicted position for aiming
            local aimPos = Aimbot.predictPosition(targetPart, Aimbot.bulletSpeed)
            local screenPos, onScreen = Aimbot.worldToScreen(camera, aimPos)
            
            if onScreen and screenPos then
                local angle = Aimbot.getAngleToTarget(camera, aimPos)
                local distance = Aimbot.getDistanceToTarget(localPlayer, aimPos)
                local screenDistance = Aimbot.getScreenDistanceToCenter(camera, aimPos)
                
                -- Check FOV (using screen pixels)
                if screenDistance <= Aimbot.fovRadius then
                    if Aimbot.priorityMode == "distance" then
                        if distance < bestScore then
                            bestScore = distance
                            bestTarget = target
                            Aimbot.targetScreenPos = screenPos
                        end
                    else -- closestToCrosshair
                        if screenDistance < bestScore then
                            bestScore = screenDistance
                            bestTarget = target
                            Aimbot.targetScreenPos = screenPos
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget, bestTarget and bestTarget.part or nil
end

-- Move mouse to target position (MouseScript method)
function Aimbot.moveMouseMouseScript(targetX, targetY, smoothness)
    if type(mousemoveabs) ~= "function" then
        return false
    end
    
    local currentX, currentY = mouseposition()
    local deltaX = targetX - currentX
    local deltaY = targetY - currentY
    
    if smoothness > 0 and smoothness < 1 then
        local step = 1 - smoothness
        local newX = currentX + (deltaX * step)
        local newY = currentY + (deltaY * step)
        mousemoveabs(newX, newY)
    else
        mousemoveabs(targetX, targetY)
    end
    
    return true
end

-- Move mouse to target position (Standard method)
function Aimbot.moveMouseStandard(targetX, targetY, smoothness, userInputService)
    if not userInputService then
        return false
    end
    
    local currentPos = userInputService:GetMouseLocation()
    local deltaX = targetX - currentPos.X
    local deltaY = targetY - currentPos.Y
    
    if smoothness > 0 and smoothness < 1 then
        local step = 1 - smoothness
        deltaX = deltaX * step
        deltaY = deltaY * step
    end
    
    if math.abs(deltaX) > 0.5 or math.abs(deltaY) > 0.5 then
        if type(mousemoverel) == "function" then
            mousemoverel(deltaX, deltaY)
            return true
        end
    end
    
    return false
end

-- Main aimbot update
function Aimbot.update(npcManager, services)
    if not Aimbot.enabled then
        if Aimbot.fovCircle then
            Aimbot.fovCircle.Visible = false
        end
        Aimbot.currentTarget = nil
        return
    end
    
    Aimbot.services = services
    
    local camera = services.camera
    local localPlayer = services.localPlayer
    local userInputService = services.UserInputService
    
    if not camera or not localPlayer then
        return
    end
    
    -- Update FOV circle
    if Aimbot.fovCircle then
        Aimbot.fovCircle.Visible = Aimbot.showFovCircle
        local centerX = camera.ViewportSize.X / 2
        local centerY = camera.ViewportSize.Y / 2
        Aimbot.fovCircle.Position = UDim2.fromOffset(centerX - Aimbot.fovRadius, centerY - Aimbot.fovRadius)
    end
    
    -- Check if aiming
    local shouldAim = Aimbot.keyDown or (Aimbot.aimKey == nil)
    if not shouldAim then
        return
    end
    
    -- Get targets from NPC Manager
    local targets = Aimbot.getValidTargets(npcManager, localPlayer)
    
    if #targets == 0 then
        Aimbot.currentTarget = nil
        return
    end
    
    -- Find best target
    local bestTarget = Aimbot.findBestTarget(targets, camera, localPlayer)
    
    if bestTarget and bestTarget.part and Aimbot.targetScreenPos then
        Aimbot.currentTarget = bestTarget
        
        local targetPos = Aimbot.targetScreenPos
        local centerX = camera.ViewportSize.X / 2
        local centerY = camera.ViewportSize.Y / 2
        local dx = targetPos.X - centerX
        local dy = targetPos.Y - centerY
        local distanceFromCenter = math.sqrt(dx * dx + dy * dy)
        
        if distanceFromCenter <= Aimbot.fovRadius then
            -- Move mouse to target
            if Aimbot.aimMethod == "mousescript" and type(mousemoveabs) == "function" then
                Aimbot.moveMouseMouseScript(targetPos.X, targetPos.Y, Aimbot.smoothness)
            else
                Aimbot.moveMouseStandard(targetPos.X, targetPos.Y, Aimbot.smoothness, userInputService)
            end
        end
    else
        Aimbot.currentTarget = nil
        Aimbot.targetScreenPos = nil
    end
end

-- Create FOV circle
function Aimbot.createFovCircle(services, screenGui)
    if Aimbot.fovCircle then
        Aimbot.fovCircle:Destroy()
    end
    
    local camera = services.camera
    if not camera then return nil end
    
    local centerX = camera.ViewportSize.X / 2
    local centerY = camera.ViewportSize.Y / 2
    
    local fovCircle = Instance.new("Frame", screenGui)
    fovCircle.Name = "AimbotFOV"
    fovCircle.Size = UDim2.fromOffset(Aimbot.fovRadius * 2, Aimbot.fovRadius * 2)
    fovCircle.Position = UDim2.fromOffset(centerX - Aimbot.fovRadius, centerY - Aimbot.fovRadius)
    fovCircle.BackgroundTransparency = 1
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
    
    local dot = Instance.new("Frame", fovCircle)
    dot.Size = UDim2.fromOffset(4, 4)
    dot.Position = UDim2.new(0.5, -2, 0.5, -2)
    dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    Aimbot.fovCircle = fovCircle
    return fovCircle
end

-- Setup keybinds
function Aimbot.setupKeybinds(services)
    for _, conn in ipairs(Aimbot.connections) do
        pcall(function() conn:Disconnect() end)
    end
    Aimbot.connections = {}
    
    if not services or not services.UserInputService then
        return
    end
    
    local inputBeganConn = services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if Aimbot.aimKey and input.KeyCode == Aimbot.aimKey then
            Aimbot.keyDown = true
        end
    end)
    table.insert(Aimbot.connections, inputBeganConn)
    
    local inputEndedConn = services.UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if Aimbot.aimKey and input.KeyCode == Aimbot.aimKey then
            Aimbot.keyDown = false
            Aimbot.currentTarget = nil
        end
    end)
    table.insert(Aimbot.connections, inputEndedConn)
end

-- Toggle aimbot
function Aimbot.setEnabled(enabled, services, screenGui)
    Aimbot.enabled = enabled
    Aimbot.services = services
    
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

-- Getters and setters
function Aimbot.setSmoothness(value) Aimbot.smoothness = math.clamp(value, 0, 0.98) end
function Aimbot.setFovRadius(radius, services) 
    Aimbot.fovRadius = math.clamp(radius, 50, 500)
    if Aimbot.fovCircle and services then
        local camera = services.camera
        if camera then
            local centerX = camera.ViewportSize.X / 2
            local centerY = camera.ViewportSize.Y / 2
            Aimbot.fovCircle.Size = UDim2.fromOffset(Aimbot.fovRadius * 2, Aimbot.fovRadius * 2)
            Aimbot.fovCircle.Position = UDim2.fromOffset(centerX - Aimbot.fovRadius, centerY - Aimbot.fovRadius)
        end
    end
end
function Aimbot.setPredictionEnabled(enabled) Aimbot.prediction = enabled end
function Aimbot.setPriorityMode(mode) Aimbot.priorityMode = mode end
function Aimbot.setHitPart(part) Aimbot.hitPart = part end
function Aimbot.setAimKey(keyCode) Aimbot.aimKey = keyCode end
function Aimbot.setAimMethod(method) 
    if method == "mouse" or method == "mousescript" then
        Aimbot.aimMethod = method
    end
end
function Aimbot.setAutoFire(enabled) Aimbot.autoFire = enabled end

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

return Aimbot
