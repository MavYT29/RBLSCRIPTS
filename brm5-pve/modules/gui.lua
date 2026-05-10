-- GUI Module
-- Creates and manages the user interface

local GUI = {}

GUI.screenGui = nil
GUI.mainFrame = nil
GUI.modalOverlay = nil
GUI.cursorIndicator = nil
GUI.toggleButton = nil
GUI.tabButtons = {}
GUI.tabs = {}

-- Creates a new tab page
local function createTab(container)
    local f = Instance.new("ScrollingFrame", container)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ScrollBarThickness = 2
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local l = Instance.new("UIListLayout", f)
    l.Padding = UDim.new(0, 12)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.SortOrder = Enum.SortOrder.LayoutOrder

    return f
end

-- Creates a toggle button
local function createButton(parent, text, initialActive, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = initialActive and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(35, 35, 35)
    btn.Text = text
    btn.TextColor3 = initialActive and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    btn.Font = "Gotham"
    btn.TextSize = 13
    Instance.new("UICorner", btn)
    
    local active = initialActive and true or false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = active and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
        callback(active)
    end)
end

-- Creates a label
local function createLabel(parent, text, color, layoutIndex)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -10, 0, 30)
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.Font = "GothamBold"
    lbl.BackgroundTransparency = 1
    if layoutIndex then
        lbl.LayoutOrder = layoutIndex
    end
    return lbl
end

local function createInfoLabel(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -10, 0, 74)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(185, 185, 185)
    lbl.Font = "Gotham"
    lbl.TextSize = 12
    lbl.TextWrapped = true
    lbl.TextXAlignment = "Left"
    lbl.TextYAlignment = "Top"
    lbl.BackgroundTransparency = 1
    return lbl
end

local function updateToggleButtonText(button, isVisible)
    if button then
        button.Text = isVisible and "Hide GUI" or "Open GUI"
    end
end

-- Creates a slider
local function createSlider(parent, label, initialValue, maxValue, callback, layoutIndex, services)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -10, 0, 50)
    f.BackgroundTransparency = 1
    if layoutIndex then
        f.LayoutOrder = layoutIndex
    end

    local l = Instance.new("TextLabel", f)
    l.Text = label .. ": " .. initialValue
    l.Size = UDim2.new(1, 0, 0, 20)
    l.TextColor3 = Color3.new(1, 1, 1)
    l.BackgroundTransparency = 1
    l.TextXAlignment = "Left"

    local bar = Instance.new("Frame", f)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(maxValue > 0 and (initialValue / maxValue) or 0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(85, 170, 255)

    local dragging = false
    local function update()
        local mousePos = services.UserInputService:GetMouseLocation().X
        local p = math.clamp((mousePos - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(p * maxValue)
        fill.Size = UDim2.new(p, 0, 1, 0)
        l.Text = label .. ": " .. val
        callback(val)
    end

    bar.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = true 
            update() 
        end 
    end)
    
    services.UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
        end 
    end)
    
    services.RunService.RenderStepped:Connect(function() 
        if dragging then 
            update() 
        end 
    end)
end

-- Initialize the GUI
function GUI:init(services, config, callbacks, aimbot)
    local localPlayer = services.localPlayer
    local playerMouse = localPlayer:GetMouse()
    
    -- Create ScreenGui
    self.screenGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
    self.screenGui.Name = "BRM5_V6_Final"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.DisplayOrder = 9999
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local modalOverlay = Instance.new("TextButton", self.screenGui)
    modalOverlay.Name = "ModalOverlay"
    modalOverlay.Size = UDim2.fromScale(1, 1)
    modalOverlay.Position = UDim2.fromScale(0, 0)
    modalOverlay.BackgroundTransparency = 1
    modalOverlay.BorderSizePixel = 0
    modalOverlay.Text = ""
    modalOverlay.AutoButtonColor = false
    modalOverlay.Modal = true
    modalOverlay.Active = true
    modalOverlay.Visible = config.guiVisible
    modalOverlay.ZIndex = 0
    self.modalOverlay = modalOverlay

    local cursorIndicator = Instance.new("Frame", self.screenGui)
    cursorIndicator.Name = "CursorIndicator"
    cursorIndicator.Size = UDim2.fromOffset(10, 10)
    cursorIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
    cursorIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    cursorIndicator.BorderSizePixel = 0
    cursorIndicator.Visible = config.guiVisible
    cursorIndicator.ZIndex = 100
    Instance.new("UICorner", cursorIndicator).CornerRadius = UDim.new(1, 0)
    self.cursorIndicator = cursorIndicator

    local cursorStroke = Instance.new("UIStroke", cursorIndicator)
    cursorStroke.Color = Color3.fromRGB(0, 0, 0)
    cursorStroke.Thickness = 1.5

    local toggleButton = Instance.new("TextButton", self.screenGui)
    toggleButton.Name = "GuiToggleButton"
    toggleButton.Size = UDim2.fromOffset(110, 36)
    toggleButton.Position = UDim2.new(0, 20, 0.5, -18)
    toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    toggleButton.BorderSizePixel = 0
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = "GothamBold"
    toggleButton.TextSize = 13
    toggleButton.ZIndex = 101
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)
    self.toggleButton = toggleButton
    updateToggleButtonText(toggleButton, config.guiVisible)

    toggleButton.MouseButton1Click:Connect(function()
        if callbacks.onVisibilityToggle then
            callbacks.onVisibilityToggle()
        else
            self:toggleVisibility()
        end
    end)

    -- Main Window Frame
    local main = Instance.new("Frame", self.screenGui)
    main.Size = UDim2.new(0, 500, 0, 450)
    main.Position = UDim2.new(0.5, -250, 0.5, -225)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    main.BorderSizePixel = 0
    main.Active = true
    main.Visible = config.guiVisible
    main.ZIndex = 1
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    self.mainFrame = main

    -- Make draggable
    local dragging, dragInput, dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local topBar = Instance.new("Frame", main)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    topBar.BorderSizePixel = 0
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                end
            end)
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then 
            dragInput = input 
        end
    end)

    services.RunService.RenderStepped:Connect(function()
        if dragging and dragInput then 
            updateDrag(dragInput) 
        end

        if self.cursorIndicator then
            self.cursorIndicator.Position = UDim2.fromOffset(
                playerMouse.X,
                playerMouse.Y
            )
        end
    end)

    -- Title
    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "BRM5 v7.0 🎇 PVE"
    title.Font = "GothamBold"
    title.TextColor3 = Color3.fromRGB(85, 170, 255)
    title.TextSize = 16
    title.TextXAlignment = "Left"
    title.BackgroundTransparency = 1

    -- Sidebar
    local sidebar = Instance.new("Frame", main)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.Size = UDim2.new(0, 130, 1, -40)
    sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    sidebar.BorderSizePixel = 0

    local sideLayout = Instance.new("UIListLayout", sidebar)
    sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sideLayout.Padding = UDim.new(0, 8)

    -- Content Container
    local container = Instance.new("Frame", main)
    container.Position = UDim2.new(0, 140, 0, 50)
    container.Size = UDim2.new(1, -150, 1, -60)
    container.BackgroundTransparency = 1

    -- Create Tabs
    local tabCombat = createTab(container)
    local tabAimbot = createTab(container)
    local tabVisuals = createTab(container)
    local tabWeapons = createTab(container)
    local tabColors = createTab(container)
    local tabCredits = createTab(container)
    tabCombat.Visible = true

    self.tabs = {
        combat = tabCombat,
        aimbot = tabAimbot,
        visuals = tabVisuals,
        weapons = tabWeapons,
        colors = tabColors,
        credits = tabCredits
    }

    -- Add Tab Buttons
    local function addTabBtn(name, targetTab)
        local b = Instance.new("TextButton", sidebar)
        b.Size = UDim2.new(1, -20, 0, 35)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        b.Font = "GothamMedium"
        b.TextSize = 13
        Instance.new("UICorner", b)

        self.tabButtons[name] = b
        if name == "Combat" then
            b.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
            b.TextColor3 = Color3.new(0, 0, 0)
        end

        b.Text = name
        b.MouseButton1Click:Connect(function()
            for _, btn in pairs(self.tabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            end
            b.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
            b.TextColor3 = Color3.new(0, 0, 0)

            for _, tab in pairs(self.tabs) do
                tab.Visible = false
            end
            targetTab.Visible = true
        end)
    end

    addTabBtn("Combat", tabCombat)
    addTabBtn("Aimbot", tabAimbot)
    addTabBtn("Visuals", tabVisuals)
    addTabBtn("Weapons", tabWeapons)
    addTabBtn("Colors", tabColors)
    addTabBtn("Credits", tabCredits)

    -- COMBAT TAB
    createButton(tabCombat, "Silent Aim 🎯", config.sizingEnabled, callbacks.onSizingToggle)
    createButton(tabCombat, "Show HitBox", config.showTargetBox, callbacks.onShowTargetBoxToggle)

    -- AIMBOT TAB
    -- Aimbot main toggle
    createButton(tabAimbot, "Aimbot 🔫", aimbot and aimbot.enabled or false, function(enabled)
        if callbacks.onAimbotToggle then
            callbacks.onAimbotToggle(enabled)
        end
    end)

    -- Smoothness slider (0-100 scale converted to 0-0.98)
    createSlider(
        tabAimbot,
        "Smoothness",
        aimbot and math.floor(aimbot.smoothness * 100) or 15,
        100,
        function(value)
            if callbacks.onSmoothnessChange then
                callbacks.onSmoothnessChange(value / 100)
            end
        end,
        nil,
        services
    )

    -- FOV Radius slider
    createSlider(
        tabAimbot,
        "FOV Radius",
        aimbot and aimbot.fovRadius or 250,
        500,
        function(value)
            if callbacks.onFovRadiusChange then
                callbacks.onFovRadiusChange(value)
            end
        end,
        nil,
        services
    )

    -- Priority Mode buttons
    local priorityGroup = Instance.new("Frame", tabAimbot)
    priorityGroup.Size = UDim2.new(1, -10, 0, 70)
    priorityGroup.BackgroundTransparency = 1

    local priorityLabel = Instance.new("TextLabel", priorityGroup)
    priorityLabel.Text = "Target Priority"
    priorityLabel.Size = UDim2.new(1, 0, 0, 20)
    priorityLabel.TextColor3 = Color3.new(1, 1, 1)
    priorityLabel.BackgroundTransparency = 1
    priorityLabel.TextXAlignment = "Left"

    local priorityDistance = Instance.new("TextButton", priorityGroup)
    priorityDistance.Size = UDim2.new(0.5, -5, 0, 30)
    priorityDistance.Position = UDim2.new(0, 0, 0, 25)
    priorityDistance.Text = "Distance"
    priorityDistance.BackgroundColor3 = (aimbot and aimbot.priorityMode == "distance") and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(35, 35, 35)
    priorityDistance.TextColor3 = (aimbot and aimbot.priorityMode == "distance") and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    Instance.new("UICorner", priorityDistance)

    local priorityAngle = Instance.new("TextButton", priorityGroup)
    priorityAngle.Size = UDim2.new(0.5, -5, 0, 30)
    priorityAngle.Position = UDim2.new(0.5, 5, 0, 25)
    priorityAngle.Text = "Closest to Crosshair"
    priorityAngle.BackgroundColor3 = (aimbot and aimbot.priorityMode == "closestToCrosshair") and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(35, 35, 35)
    priorityAngle.TextColor3 = (aimbot and aimbot.priorityMode == "closestToCrosshair") and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    Instance.new("UICorner", priorityAngle)

    priorityDistance.MouseButton1Click:Connect(function()
        priorityDistance.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
        priorityDistance.TextColor3 = Color3.new(0, 0, 0)
        priorityAngle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        priorityAngle.TextColor3 = Color3.new(1, 1, 1)
        if callbacks.onPriorityModeChange then
            callbacks.onPriorityModeChange("distance")
        end
    end)

    priorityAngle.MouseButton1Click:Connect(function()
        priorityAngle.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
        priorityAngle.TextColor3 = Color3.new(0, 0, 0)
        priorityDistance.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        priorityDistance.TextColor3 = Color3.new(1, 1, 1)
        if callbacks.onPriorityModeChange then
            callbacks.onPriorityModeChange("closestToCrosshair")
        end
    end)

    -- Hit Part selection
    local hitPartGroup = Instance.new("Frame", tabAimbot)
    hitPartGroup.Size = UDim2.new(1, -10, 0, 70)
    hitPartGroup.BackgroundTransparency = 1

    local hitPartLabel = Instance.new("TextLabel", hitPartGroup)
    hitPartLabel.Text = "Aim Target"
    hitPartLabel.Size = UDim2.new(1, 0, 0, 20)
    hitPartLabel.TextColor3 = Color3.new(1, 1, 1)
    hitPartLabel.BackgroundTransparency = 1
    hitPartLabel.TextXAlignment = "Left"

    local hitPartHead = Instance.new("TextButton", hitPartGroup)
    hitPartHead.Size = UDim2.new(0.33, -4, 0, 30)
    hitPartHead.Position = UDim2.new(0, 0, 0, 25)
    hitPartHead.Text = "Head"
    hitPartHead.BackgroundColor3 = (aimbot and aimbot.hitPart == "Head") and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(35, 35, 35)
    hitPartHead.TextColor3 = (aimbot and aimbot.hitPart == "Head") and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    Instance.new("UICorner", hitPartHead)

    local hitPartRoot = Instance.new("TextButton", hitPartGroup)
    hitPartRoot.Size = UDim2.new(0.34, -4, 0, 30)
    hitPartRoot.Position = UDim2.new(0.33, 4, 0, 25)
    hitPartRoot.Text = "Body"
    hitPartRoot.BackgroundColor3 = (aimbot and aimbot.hitPart == "HumanoidRootPart") and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(35, 35, 35)
    hitPartRoot.TextColor3 = (aimbot and aimbot.hitPart == "HumanoidRootPart") and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    Instance.new("UICorner", hitPartRoot)

    local hitPartRandom = Instance.new("TextButton", hitPartGroup)
    hitPartRandom.Size = UDim2.new(0.33, -4, 0, 30)
    hitPartRandom.Position = UDim2.new(0.67, 4, 0, 25)
    hitPartRandom.Text = "Random"
    hitPartRandom.BackgroundColor3 = (aimbot and aimbot.hitPart == "Random") and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(35, 35, 35)
    hitPartRandom.TextColor3 = (aimbot and aimbot.hitPart == "Random") and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    Instance.new("UICorner", hitPartRandom)

    hitPartHead.MouseButton1Click:Connect(function()
        hitPartHead.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
        hitPartHead.TextColor3 = Color3.new(0, 0, 0)
        hitPartRoot.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        hitPartRoot.TextColor3 = Color3.new(1, 1, 1)
        hitPartRandom.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        hitPartRandom.TextColor3 = Color3.new(1, 1, 1)
        if callbacks.onHitPartChange then
            callbacks.onHitPartChange("Head")
        end
    end)

    hitPartRoot.MouseButton1Click:Connect(function()
        hitPartRoot.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
        hitPartRoot.TextColor3 = Color3.new(0, 0, 0)
        hitPartHead.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        hitPartHead.TextColor3 = Color3.new(1, 1, 1)
        hitPartRandom.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        hitPartRandom.TextColor3 = Color3.new(1, 1, 1)
        if callbacks.onHitPartChange then
            callbacks.onHitPartChange("HumanoidRootPart")
        end
    end)

    hitPartRandom.MouseButton1Click:Connect(function()
        hitPartRandom.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
        hitPartRandom.TextColor3 = Color3.new(0, 0, 0)
        hitPartHead.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        hitPartHead.TextColor3 = Color3.new(1, 1, 1)
        hitPartRoot.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        hitPartRoot.TextColor3 = Color3.new(1, 1, 1)
        if callbacks.onHitPartChange then
            callbacks.onHitPartChange("Random")
        end
    end)

    -- Prediction toggle
    createButton(tabAimbot, "Movement Prediction", aimbot and aimbot.prediction or false, function(enabled)
        if callbacks.onPredictionToggle then
            callbacks.onPredictionToggle(enabled)
        end
    end)

    -- Show FOV toggle
    createButton(tabAimbot, "Show FOV Circle", aimbot and aimbot.showFovCircle or true, function(enabled)
        if callbacks.onShowFovToggle then
            callbacks.onShowFovToggle(enabled)
        end
    end)

    -- Keybind info label
    local keybindInfo = Instance.new("TextLabel", tabAimbot)
    keybindInfo.Size = UDim2.new(1, -10, 0, 50)
    keybindInfo.Text = "Hold Right Shift to aim\n(Can be changed in aimbot.lua)"
    keybindInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
    keybindInfo.Font = "Gotham"
    keybindInfo.TextSize = 11
    keybindInfo.TextWrapped = true
    keybindInfo.BackgroundTransparency = 1

    -- VISUALS TAB
    createButton(tabVisuals, "Walls 🔎", config.highlightEnabled, callbacks.onHighlightsToggle)
    createButton(tabVisuals, "FullBright 💡", config.fullBrightEnabled, callbacks.onFullBrightToggle)
    createSlider(
        tabVisuals,
        "NPC Range",
        config.npcDetectionRadius,
        config.MAX_NPC_DETECTION_RADIUS,
        callbacks.onNPCDetectionRadiusChange,
        nil,
        services
    )
    createInfoLabel(
        tabVisuals,
        "If you're having performance issues, try lowering the NPC Range to the minimum and then gradually increasing it until you achieve good performance with the maximum possible distance."
    )

    -- WEAPONS TAB
    local weaponNote = createLabel(tabWeapons, "Reset character to apply changes", 
                                   Color3.fromRGB(255, 100, 100))
    createButton(tabWeapons, "No recoil", config.patchOptions.recoil, callbacks.onStabilityToggle)
    createButton(tabWeapons, "All Firemodes", config.patchOptions.firemodes, callbacks.onFiremodeOptionsToggle)

    -- COLORS TAB
    local layoutIndex = 1
    createLabel(tabColors, "-- VISIBLE COLOR --", Color3.new(0.5, 1, 0.5), layoutIndex)
    layoutIndex = layoutIndex + 1
    
    createSlider(tabColors, "R", config.visibleR, 255, callbacks.onVisibleRChange, layoutIndex, services)
    layoutIndex = layoutIndex + 1
    createSlider(tabColors, "G", config.visibleG, 255, callbacks.onVisibleGChange, layoutIndex, services)
    layoutIndex = layoutIndex + 1
    createSlider(tabColors, "B", config.visibleB, 255, callbacks.onVisibleBChange, layoutIndex, services)
    layoutIndex = layoutIndex + 1

    createLabel(tabColors, "-- HIDDEN COLOR --", Color3.new(1, 0.5, 0.5), layoutIndex)
    layoutIndex = layoutIndex + 1
    
    createSlider(tabColors, "R", config.hiddenR, 255, callbacks.onHiddenRChange, layoutIndex, services)
    layoutIndex = layoutIndex + 1
    createSlider(tabColors, "G", config.hiddenG, 255, callbacks.onHiddenGChange, layoutIndex, services)
    layoutIndex = layoutIndex + 1
    createSlider(tabColors, "B", config.hiddenB, 255, callbacks.onHiddenBChange, layoutIndex, services)

    -- CREDITS TAB
    local function addCredit(text, font, size)
        local c = Instance.new("TextLabel", tabCredits)
        c.Size = UDim2.new(1, -10, 0, size or 50)
        c.Text = text
        c.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        c.Font = font or "Gotham"
        c.TextSize = 12
        c.TextWrapped = true
        c.BackgroundTransparency = 1
    end
    
    local clipboardStatus = createInfoLabel(tabCredits, "Click a link to copy it to the clipboard.")
    clipboardStatus.Size = UDim2.new(1, -10, 0, 40)
    clipboardStatus.TextColor3 = Color3.fromRGB(140, 200, 255)

    local function copyToClipboard(text, label)
        if type(setclipboard) == "function" then
            local ok = pcall(setclipboard, text)
            if ok then
                clipboardStatus.Text = "Copied to clipboard: " .. label
                return
            end
        end
        clipboardStatus.Text = "Clipboard is not available in this executor."
    end

    local function addLinkButton(label, url, accentColor)
        local btn = Instance.new("TextButton", tabCredits)
        btn.Size = UDim2.new(1, -10, 0, 44)
        btn.BackgroundColor3 = accentColor
        btn.Text = label
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = "GothamBold"
        btn.TextSize = 13
        btn.AutoButtonColor = true
        Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(function()
            copyToClipboard(url, label)
        end)

        local urlLabel = Instance.new("TextLabel", btn)
        urlLabel.Size = UDim2.new(1, -16, 0, 16)
        urlLabel.Position = UDim2.new(0, 8, 1, -18)
        urlLabel.BackgroundTransparency = 1
        urlLabel.Text = url
        urlLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
        urlLabel.Font = "Gotham"
        urlLabel.TextSize = 10
    end

    addCredit("Credits and Help", "GothamBold", 28)
    addCredit("Made by: HiIxX0Dexter0XxIiH", "GothamBold", 24)
    addCredit("Aimbot Module: Camera-based aiming", "Gotham", 18)
    addLinkButton("GitHub", "https://github.com/HiIxX0Dexter0XxIiH/Roblox-Dexter-Scripts", Color3.fromRGB(45, 95, 160))
    addLinkButton("Reddit", "https://www.reddit.com/r/BRM5Scripts/", Color3.fromRGB(185, 75, 45))

    -- UNLOAD BUTTON
    local unl = Instance.new("TextButton", sidebar)
    unl.Size = UDim2.new(0, 110, 0, 35)
    unl.AnchorPoint = Vector2.new(0.5, 0)
    unl.Position = UDim2.new(0.5, 0, 0, 0)
    unl.Text = "Unload Script"
    unl.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    unl.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", unl)
    unl.MouseButton1Click:Connect(callbacks.onUnload)
end

function GUI:setVisibleState(isVisible)
    if self.mainFrame then
        self.mainFrame.Visible = isVisible
    end
    if self.modalOverlay then
        self.modalOverlay.Visible = isVisible
    end
    if self.cursorIndicator then
        self.cursorIndicator.Visible = isVisible
    end
    updateToggleButtonText(self.toggleButton, isVisible)
    return isVisible
end

-- Toggle GUI visibility
function GUI:toggleVisibility()
    if self.mainFrame then
        return self:setVisibleState(not self.mainFrame.Visible)
    end
    return false
end

-- Destroy GUI
function GUI:destroy()
    if self.screenGui then
        self.screenGui:Destroy()
    end
    self.screenGui = nil
    self.mainFrame = nil
    self.modalOverlay = nil
    self.cursorIndicator = nil
    self.toggleButton = nil
end

return GUI
