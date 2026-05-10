-- Aimbot Module
-- Mouse-based aiming system that locks onto enemies
-- Fixed to work with NPC Manager

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
Aimbot.hitPart = "Head"           -- "Head", "HumanoidRootPart", or "Random"
Aimbot.aimKey = Enum.UserInputType.MouseButton2  -- Right Mouse Button to aim
Aimbot.aimMethod = "mouse"        -- "mouse" or "mousescript"
Aimbot.autoFire = false           -- Automatically fire when locked on target
Aimbot.autoFireDelay = 0.05       -- Delay between shots in seconds
Aimbot.bulletSpeed = 2500         -- Bullet speed for prediction

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
    
    -- Team check - skip if target is same team as player
    if Aimbot.teamCheck then
        local playerTeam = localPlayer.Team
        local npcTeam = npc:FindFirstChild("Team") or npc:FindFirstChild("team")
        
        -- Check for friendly NPCs by name or tag
        local npcName = npc.Name:lower()
        if npcName:find("civilian") or npcName:find("friendly") or npcName:find("ally") then
            return false
        end
        
        -- Check if NPC has team color that matches player
        if playerTeam and npcTeam then
            if npcTeam.Value == playerTeam.Name or npcTeam.Value == playerTeam then
                return false
            end
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
                data = data,
                root = data.root or targetPart
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

-- Get target velocity for prediction
function Aimbot.getTargetVelocity(targetPart)
    local humanoid = targetPart.Parent:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid:GetVelocity()
    end
    
    -- Check for root part velocity
    local root = targetPart.Parent:FindFirstChild("HumanoidRootPart") or targetPart.Parent:FindFirstChild("Root")
    if root and root.AssemblyLinearVelocity then
        return root.AssemblyLinearVelocity
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
    local distance = camera and (camera.CFrame.Position - targetPart.Position).Magnitude or 100
    local travelTime = distance / (bulletSpeed or Aimbot.bulletSpeed)
    
    return targetPart.Position + (targetVelocity * travelTime * Aimbot.predictionMultiplier)
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
    if not onScreen then
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
            -- Check if target is on screen
            local screenPos, onScreen = Aimbot.worldToScreen(camera, targetPart.Position)
            
            if onScreen then
                local angle = Aimbot.getAngleToTarget(camera, targetPart.Position)
                local distance = Aimbot.getDistanceToTarget(localPlayer, targetPart.Position)
                local screenDistance = Aimbot.getScreenDistanceToCenter(camera, targetPart.Position)
                
                -- Check if within FOV radius (in screen pixels)
                local fovCondition = screenDistance <= Aimbot.fovRadius
                
                if fovCondition then
                    if Aimbot.priorityMode == "distance" then
                        if distance < bestScore then
                            bestScore = distance
                            bestTarget = target
                            Aimbot.targetScreenPos = screenPos
                        end
                    else -- closestToCrosshair (screen distance based)
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

-- Simulate mouse click for auto fire
function Aimbot.simulateMouseClick()
    if not Aimbot.services or not Aimbot.services.UserInputService then
        return
    end
    
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
end

-- Auto fire when aiming at target
function Aimbot.autoFireHandler()
    if not Aimbot.autoFire or not Aimbot.currentTarget then
        return
    end
    
    local currentTime = tick()
    if currentTime - Aimbot.lastAutoFireTime >= Aimbot.autoFireDelay then
        Aimbot.simulateMouseClick()
        Aimbot.lastAutoFireTime = currentTime
    end
end

-- Draw FOV circle
function Aimbot.drawFovCircle()
    if not Aimbot.fovCircle then return end
    
    local camera = Aimbot.services and Aimbot.services.camera or workspace.CurrentCamera
    if not camera then return end
    
    local centerX = camera.ViewportSize.X / 2
    local centerY = camera.ViewportSize.Y / 2
    
    Aimbot.fovCircle.Position = UDim2.fromOffset(centerX - Aimbot.fovRadius, centerY - Aimbot.fovRadius)
end

-- Main aimbot update (uses NPC Manager)
function Aimbot.update(npcManager, services)
    if not Aimbot.enabled then
        if Aimbot.fovCircle then
            Aimbot.fovCircle.Visible = false
        end
        Aimbot.currentTarget = nil
        Aimbot.currentTargetPart = nil
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
    
    -- Update FOV circle position and visibility
    if Aimbot.fovCircle then
        Aimbot.fovCircle.Visible = Aimbot.showFovCircle
        Aimbot.drawFovCircle()
    end
    
    -- Check if aimbot should be active (keybind or always on)
    local shouldAim = Aimbot.keyDown or (Aimbot.aimKey == nil)
    
    if not shouldAim then
        return
    end
    
    -- Get valid targets from NPC Manager
    local targets = Aimbot.getValidTargets(npcManager, localPlayer)
    
    -- Find best target
    local bestTarget, bestPart = Aimbot.findBestTarget(targets, camera, localPlayer)
    
    if bestTarget and bestPart and Aimbot.targetScreenPos then
        Aimbot.currentTarget = bestTarget
        Aimbot.currentTargetPart = bestPart
        
        local targetPos = Aimbot.targetScreenPos
        local centerX = camera.ViewportSize.X / 2
        local centerY = camera.ViewportSize.Y / 2
        
        -- Calculate distance from center
        local dx = targetPos.X - centerX
        local dy = targetPos.Y - centerY
        local distanceFromCenter = math.sqrt(dx * dx + dy * dy)
        
        -- Only aim if within FOV
        if distanceFromCenter <= Aimbot.fovRadius then
            local success = false
            
            -- Move mouse to target
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
        Aimbot.currentTargetPart = nil
        Aimbot.targetScreenPos = nil
    end
end

-- Create FOV circle on screen
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
    
    -- Circle outline
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
    
    -- Center dot
    local dot = Instance.new("Frame", fovCircle)
    dot.Size = UDim2.fromOffset(4, 4)
    dot.Position = UDim2.new(0.5, -2, 0.5, -2)
    dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    Aimbot.fovCircle = fovCircle
    return fovCircle
end

-- Update FOV circle radius
function Aimbot.setFovRadius(radius, services)
    Aimbot.fovRadius = math.clamp(radius, 50, 500)
    if Aimbot.fovCircle then
        Aimbot.fovCircle.Size = UDim2.fromOffset(Aimbot.fovRadius * 2, Aimbot.fovRadius * 2)
        Aimbot.drawFovCircle()
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
        Aimbot.currentTargetPart = nil
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
    
    if not services or not services.UserInputService then
        return
    end
    
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
        if gameProcessed then return end
        
        if Aimbot.aimKey and input.KeyCode == Aimbot.aimKey then
            Aimbot.keyDown = false
            Aimbot.currentTarget = nil
            Aimbot.currentTargetPart = nil
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
    Aimbot.currentTargetPart = nil
    Aimbot.targetScreenPos = nil
    Aimbot.keyDown = false
    Aimbot.enabled = false
    Aimbot.services = nil
    Aimbot.lastAutoFireTime = 0
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
