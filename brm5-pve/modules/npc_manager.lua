-- NPC Manager Module
-- Handles detection and tracking of enemy NPCs
-- Enhanced with aimbot-specific functions

local NPCManager = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

NPCManager.activeNPCs = {}      -- List of enemies currently in the game
NPCManager.wallConnections = {} -- List of connections to clean up later
NPCManager.modelConnections = {} -- Per-model connections for delayed NPC detection

-- Finds the main part of a character (Root)
function NPCManager.getRootPart(model)
    return model:FindFirstChild("Root") or 
           model:FindFirstChild("HumanoidRootPart") or 
           model:FindFirstChild("UpperTorso")
end

-- Get humanoid from NPC
function NPCManager.getHumanoid(model)
    return model:FindFirstChildOfClass("Humanoid")
end

-- Check if NPC is alive
function NPCManager.isAlive(npc)
    local humanoid = NPCManager.getHumanoid(npc)
    return humanoid and humanoid.Health > 0
end

-- Get NPC position (for aimbot)
function NPCManager.getNPCPosition(npc, partType)
    if partType == "Head" then
        local head = npc:FindFirstChild("Head")
        if head then return head.Position end
    elseif partType == "Root" then
        local root = NPCManager.getRootPart(npc)
        if root then return root.Position end
    end
    
    -- Fallback to any visible part
    local parts = {"Head", "HumanoidRootPart", "UpperTorso", "Root"}
    for _, partName in ipairs(parts) do
        local part = npc:FindFirstChild(partName)
        if part then return part.Position end
    end
    
    return npc:GetPivot().Position
end

-- Get NPC velocity for prediction
function NPCManager.getNPCVelocity(npc)
    local humanoid = NPCManager.getHumanoid(npc)
    if humanoid then
        return humanoid:GetVelocity()
    end
    
    local root = NPCManager.getRootPart(npc)
    if root and root.AssemblyLinearVelocity then
        return root.AssemblyLinearVelocity
    end
    
    return Vector3.new(0, 0, 0)
end

-- Get all valid hit parts from an NPC (for aimbot targeting)
function NPCManager.getHitParts(npc)
    local hitParts = {}
    local partNames = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Root"}
    
    for _, partName in ipairs(partNames) do
        local part = npc:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            table.insert(hitParts, part)
        end
    end
    
    return hitParts
end

-- Check if NPC is visible from camera (line of sight)
function NPCManager.isVisible(npc, camera, partType)
    local part = partType == "Head" and npc:FindFirstChild("Head") or NPCManager.getRootPart(npc)
    if not part then return false end
    
    local origin = camera.CFrame.Position
    local direction = (part.Position - origin).Unit
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {localPlayer.Character, npc}
    
    local result = workspace:Raycast(origin, direction * (part.Position - origin).Magnitude, raycastParams)
    return result == nil
end

-- Get distance from player to NPC
function NPCManager.getDistanceToPlayer(npc)
    local character = localPlayer.Character
    if not character then return math.huge end
    
    local playerRoot = NPCManager.getRootPart(character)
    local npcRoot = NPCManager.getRootPart(npc)
    
    if playerRoot and npcRoot then
        return (playerRoot.Position - npcRoot.Position).Magnitude
    end
    
    return math.huge
end

-- Get angle between player's look direction and NPC
function NPCManager.getAngleToNPC(camera, npc)
    local npcPos = NPCManager.getNPCPosition(npc, "Head")
    local cameraPos = camera.CFrame.Position
    local targetDir = (npcPos - cameraPos).Unit
    local lookDir = camera.CFrame.LookVector
    
    return math.acos(math.clamp(lookDir:Dot(targetDir), -1, 1))
end

function NPCManager:getDetectionOrigin(workspace)
    local character = localPlayer and localPlayer.Character
    local root = character and self.getRootPart(character)
    if root then
        return root.Position
    end

    local camera = workspace and workspace.CurrentCamera
    return camera and camera.CFrame.Position or nil
end

function NPCManager:isWithinDetectionRadius(model, workspace, config)
    if not config then
        return true
    end

    local origin = self:getDetectionOrigin(workspace)
    if not origin then
        return true
    end

    local root = self.getRootPart(model) or model:FindFirstChild("Head")
    local targetPosition = root and root.Position or model:GetPivot().Position
    return (targetPosition - origin).Magnitude <= (config.npcDetectionRadius or math.huge)
end

-- Gets all valid NPC models from Workspace.Model children.
function NPCManager:getNPCModels(container, workspace, config)
    if not (config and config.isNPCDetectionEnabled and config:isNPCDetectionEnabled()) then
        return {}
    end

    if not container or not container:IsA("Model") then
        return {}
    end

    if container.Name ~= "Model" then
        return {}
    end

    local npcs = {}
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Model") then
            if child.Name == "NPCS" then
                if self:isWithinDetectionRadius(child, workspace, config) then
                    table.insert(npcs, child)
                end
            elseif child.Name == "Male" then
                local hasBillboard = child:FindFirstChildOfClass("BillboardGui") ~= nil
                if not hasBillboard and self:isWithinDetectionRadius(child, workspace, config) then
                    child.Name = "NPCS"
                    table.insert(npcs, child)
                end
            end
        end
    end

    return npcs
end

-- Checks if the container matches the new NPC structure
function NPCManager:isNPCModel(container, workspace, config)
    return #self:getNPCModels(container, workspace, config) > 0
end

-- Adds a specific NPC model to our tracking list
function NPCManager:addNPCModel(npc, container, markerModule, config)
    if not npc or self.activeNPCs[npc] then
        return
    end
    local head = npc:FindFirstChild("Head")
    local root = self.getRootPart(npc)
    
    if not head or not root then 
        return 
    end
    
    -- Store additional data for aimbot
    local humanoid = self.getHumanoid(npc)
    
    self.activeNPCs[npc] = { 
        head = head, 
        root = root, 
        character = npc, 
        container = container,
        humanoid = humanoid,
        lastPosition = root.Position,
        lastUpdate = tick()
    }
    
    -- Create marker box if visibility markers are enabled
    if markerModule and markerModule.isEnabled() then
        markerModule.createBoxForPart(head, config)
    end
end

-- Adds all valid NPCs under a container
function NPCManager:addNPC(container, workspace, markerModule, config)
    local npcs = self:getNPCModels(container, workspace, config)
    if #npcs == 0 then
        return
    end

    for _, npc in ipairs(npcs) do
        self:addNPCModel(npc, container, markerModule, config)
    end
end

-- Tracks a model and waits for Male if it appears later
function NPCManager:trackPotentialNPC(container, workspace, markerModule, config)
    if not (config and config.isNPCDetectionEnabled and config:isNPCDetectionEnabled()) then
        return
    end

    local npcs = self:getNPCModels(container, workspace, config)
    local hasUntracked = false
    for _, npc in ipairs(npcs) do
        if not self.activeNPCs[npc] then
            hasUntracked = true
            break
        end
    end
    if #npcs > 0 and not hasUntracked then
        return
    end
    if #npcs > 0 then
        self:addNPC(container, workspace, markerModule, config)
        return
    end
    if not container:IsA("Model") then
        return
    end
    if container.Name ~= "Model" or self.modelConnections[container] then
        return
    end

    local connection
    connection = container.ChildAdded:Connect(function(child)
        if child:IsA("Model") and (child.Name == "Male" or child.Name == "NPCS") then
            self:addNPC(container, workspace, markerModule, config)
        end
    end)
    self.modelConnections[container] = connection
end

-- Removes an NPC from tracking
function NPCManager:removeNPC(model)
    self.activeNPCs[model] = nil
end

-- Gets all active NPCs for aimbot
function NPCManager:getActiveNPCs()
    return self.activeNPCs
end

-- Get active NPCs as a simplified array (for aimbot iteration)
function NPCManager:getActiveNPCsArray()
    local npcs = {}
    for npc, data in pairs(self.activeNPCs) do
        table.insert(npcs, {
            npc = npc,
            data = data,
            head = data.head,
            root = data.root,
            humanoid = data.humanoid
        })
    end
    return npcs
end

-- Get nearest NPC to player
function NPCManager:getNearestNPC()
    local nearest = nil
    local nearestDistance = math.huge
    
    for npc, data in pairs(self.activeNPCs) do
        local distance = self.getDistanceToPlayer(npc)
        if distance < nearestDistance then
            nearestDistance = distance
            nearest = {npc = npc, data = data, distance = distance}
        end
    end
    
    return nearest
end

-- Get NPCs within a certain distance
function NPCManager:getNPCsInRange(maxDistance)
    local inRange = {}
    
    for npc, data in pairs(self.activeNPCs) do
        local distance = self.getDistanceToPlayer(npc)
        if distance <= maxDistance then
            table.insert(inRange, {npc = npc, data = data, distance = distance})
        end
    end
    
    return inRange
end

-- Update NPC data (call this in a loop for smooth tracking)
function NPCManager:updateNPCData()
    for npc, data in pairs(self.activeNPCs) do
        if data.root and data.root.Parent then
            -- Store previous position for velocity calculation
            data.lastPosition = data.root.Position
            data.lastUpdate = tick()
            
            -- Update references in case parts changed
            local newHead = npc:FindFirstChild("Head")
            local newRoot = self.getRootPart(npc)
            local newHumanoid = self.getHumanoid(npc)
            
            if newHead then data.head = newHead end
            if newRoot then data.root = newRoot end
            if newHumanoid then data.humanoid = newHumanoid end
        end
    end
end

function NPCManager:removeNPCModel(model, markerModule, targetSizing)
    local data = self.activeNPCs[model]
    if not data then
        return
    end

    if targetSizing then
        targetSizing:restoreOriginalSize(model, self)
    end
    if markerModule and data.head then
        markerModule.destroyBoxForPart(data.head)
    end

    self.activeNPCs[model] = nil
end

function NPCManager:refreshTrackedNPCs(workspace, markerModule, targetSizing, config)
    if not (config and config.isNPCDetectionEnabled and config:isNPCDetectionEnabled()) then
        local trackedModels = {}
        for model, _ in pairs(self.activeNPCs) do
            table.insert(trackedModels, model)
        end
        for _, model in ipairs(trackedModels) do
            self:removeNPCModel(model, markerModule, targetSizing)
        end
        return
    end

    local modelsToRemove = {}
    for model, _ in pairs(self.activeNPCs) do
        if not model.Parent or not self:isWithinDetectionRadius(model, workspace, config) then
            table.insert(modelsToRemove, model)
        end
    end
    for _, model in ipairs(modelsToRemove) do
        self:removeNPCModel(model, markerModule, targetSizing)
    end

    for _, container in ipairs(workspace:GetChildren()) do
        if container:IsA("Model") and container.Name == "Model" then
            self:trackPotentialNPC(container, workspace, markerModule, config)
        end
    end
end

-- Scans workspace for existing NPCs
function NPCManager:scanWorkspace(workspace, markerModule, config)
    for _, m in ipairs(workspace:GetChildren()) do
        if m:IsA("Model") and m.Name == "Model" then 
            self:trackPotentialNPC(m, workspace, markerModule, config)
        end
    end
end

-- Sets up listener for new NPCs
function NPCManager:setupListener(workspace, markerModule, config)
    local connection = workspace.ChildAdded:Connect(function(m)
        if m:IsA("Model") and m.Name == "Model" then 
            task.delay(0.2, function() 
                self:trackPotentialNPC(m, workspace, markerModule, config)
            end) 
        end
    end)
    
    table.insert(self.wallConnections, connection)
end

-- Cleanup all connections
function NPCManager:cleanup()
    for _, c in ipairs(self.wallConnections) do 
        pcall(function() c:Disconnect() end) 
    end
    self.wallConnections = {}
    for _, c in pairs(self.modelConnections) do
        pcall(function() c:Disconnect() end)
    end
    self.modelConnections = {}
    self.activeNPCs = {}
end

return NPCManager
