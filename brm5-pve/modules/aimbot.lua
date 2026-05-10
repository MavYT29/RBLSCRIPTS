-- Aimbot Module
-- Mouse-based aiming system that locks onto enemies

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
Aimbot.aimMethod = "mouse"        -- "mouse" or "mousescript" (MouseScript is faster for some executors)
Aimbot.autoFire = false           -- Automatically fire when locked on target
Aimbot.autoFireDelay = 0.05       -- Delay between shots in seconds

-- Internal variables
Aimbot.fovCircle = nil
Aimbot.currentTarget = nil
Aimbot.keyDown = false
Aimbot.connections = {}
Aimbot.screenGui = nil
Aimbot.lastAutoFireTime = 0
Aimbot.targetScreenPos = nil
Aimbot.services = nil

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
function Aimbot.isValidTarget(npc, targetPart, localPlayer)
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
function Aimbot.getValidTargets(npcManager, localPlayer)
    local targets = {}
    local activeNPCs = npcManager.getActiveNPCs and npcManager:getActiveNPCs() or {}
    
    for npc, data in pairs(activeNPCs) do
        local targetPart = Aimbot.getHitPart(npc)
        if Aimbot.isValidTarget(npc, targetPart, localPlayer) then
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
    
    local camera = Aimbot.services and Aimbot.services.camera or workspace.CurrentCamera
    local distance = camera and (camera.CFrame.Position - targetPart.Position).Magnitude or 100
    local travelTime = distance / (bulletSpeed or 2500) -- Default bullet speed
    
    return targetPart.Position + (targetVelocity * travelTime * Aimbot.predictionMultiplier)
end

-- Get screen position of target with prediction
function Aimbot.getTargetScreenPosition(camera, target)
    if not target or not target.part then
        return nil, false
    end
    
    local aimPos = Aimbot.predictPosition(target.part, 2500)
    return Aimbot.worldToScreen(camera, aimPos)
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
                        Aimbot.targetScreenPos = screenPos
                    end
                else -- closestToCrosshair (angle based)
                    if angle < bestScore then
                        bestScore = angle
                        bestTarget = target
                        Aimbot.targetScreenPos = screenPos
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- Move mouse to target position (MouseScript method - faster)
function Aimbot.moveMouseMouseScript(targetX, targetY, smoothness)
    if type(mousemoveabs) ~= "function" then
        return false
    end
    
    local currentX, currentY = mouseposition()
    local deltaX = targetX - currentX
    local deltaY = targetY - currentY
    
    if smoothness > 0 then
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
    
    if smoothness > 0 then
        local step = 1 - smoothness
        deltaX = deltaX * step
        deltaY = deltaY * step
    end
    
    if deltaX ~= 0 or deltaY ~= 0 then
        if type(mousemoverel) == "function" then
            mousemoverel(deltaX, deltaY)
            return true
        end
    end
    
    return false
end

-- Auto fire when aiming at target
function Aimbot.autoFireHandler()
    if not Aimbot.autoFire or not Aimbot.currentTarget then
        return
    end
    
    local currentTime = tick()
    if currentTime - Aimbot.lastAutoFireTime >= Aimbot.autoFireDelay then
        -- Simulate mouse button click using UserInputService
        if Aimbot.services and Aimbot.services.UserInputService then
            local inputService = Aimbot.services.UserInputService
            
            -- Send mouse button down
            local downArgs = {
                UserInputType = Enum.UserInputType.MouseButton1
            }
            pcall(function()
                inputService:SendInput(downArgs)
            end)
            
            -- Small delay then send up
            task.delay(0.01, function()
                local upArgs = {
                    UserInputType = Enum.UserInputType.MouseButton1,
                    UserInputState = Enum.UserInputState.End
                }
                pcall(function()
                    inputService:SendInput(upArgs)
                end)
            end)
            
            Aimbot.lastAutoFireTime = currentTime
        end
    end
end

-- Main aimbot update (mouse-based)
function Aimbot.update(npcManager, services, config)
    if not Aimbot.enabled then
        if Aimbot.fovCircle then
            Aimbot.fovCircle.Visible = false
        end
        Aimbot.currentTarget = nil
        return
    end
    
    -- Store services for other functions
    Aimbot.services = services
    
    local camera = services.camera
    local localPlayer = services.localPlayer
    local userInputService = services.UserInputService
    
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
                camera.ViewportSize.X / 2 - Aimbot.fovRadius,
                camera.ViewportSize.Y / 2 - Aimbot.fovRadius
            )
        end
    end
    
    -- Get valid targets
    local targets = Aimbot.getValidTargets(npcManager, localPlayer)
    local bestTarget = Aimbot.findBestTarget(targets, camera, localPlayer)
    
    if bestTarget and shouldAim and Aimbot.targetScreenPos then
        Aimbot.currentTarget = bestTarget
        
        local targetPos = Aimbot.targetScreenPos
        local centerX = camera.ViewportSize.X / 2
        local centerY = camera.ViewportSize.Y / 2
        
        -- Check if target is within FOV circle (pixel distance)
        local dx = targetPos.X - centerX
        local dy = targetPos.Y - centerY
        local distanceFromCenter = math.sqrt(dx * dx + dy * dy)
        
        if distanceFromCenter <= Aimbot.fovRadius then
            -- Move mouse to target
            local success = false
            
            if Aimbot.aimMethod == "mousescript" and type(mousemoveabs) == "function" then
                success = Aimbot.moveMouseMouseScript(targetPos.X, targetPos.Y, Aimbot.smoothness)
            else
                success = Aimbot.moveMouseStandard(targetPos.X, targetPos.Y, Aimbot.smoothness, userInputService)
            end
            
            -- Auto fire if enabled
            if success and Aimbot.autoFire then
                Aimbot.autoFireHandler()
            end
        end
    else
        Aimbot.currentTarget = nil
        Aimbot.targetScreenPos = nil
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
    Aimbot.services = services
    
    if Aimbot.fovCircle then
        Aimbot.fovCircle.Visible = Aimbot.showFovCircle and enabled
    end
    
    if enabled and Aimbot.fovCircle == nil and screenGui then
        Aimbot.createFovCircle(services, screenGui)
    end
    
    if not enabled then
        Aimbot.currentTarget = nil
        Aimbot.targetScreenPos = nil
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
    Aimbot.priorityMode = mode
end

-- Set hit part
function Aimbot.setHitPart(part)
    Aimbot.hitPart = part
end

-- Set aim key
function Aimbot.setAimKey(keyCode)
    Aimbot.aimKey = keyCode
end

-- Set aim method
function Aimbot.setAimMethod(method)
    if method == "mouse" or method == "mousescript" then
        Aimbot.aimMethod = method
    end
end

-- Set auto fire
function Aimbot.setAutoFire(enabled)
    Aimbot.autoFire = enabled
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
            Aimbot.targetScreenPos = nil
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
    Aimbot.targetScreenPos = nil
    Aimbot.keyDown = false
    Aimbot.enabled = false
    Aimbot.services = nil
end

-- Get current target info (for GUI display)
function Aimbot.getTargetInfo()
    if not Aimbot.currentTarget or not Aimbot.currentTarget.npc then
        return nil
    end
    
    local npc = Aimbot.currentTarget.npc
    local distance = "Unknown"
    
    local localPlayer = Aimbot.services and Aimbot.services.localPlayer
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
