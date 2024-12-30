-- Orion UI Setup
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "KENJIEHUB | MotorRush v3", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "MotorRushConfig"
})

local MessageTab = Window:MakeTab({
    Name = "Important Notes",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local RaceTab = Window:MakeTab({
    Name = "AutoRace",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Section for warning notes
local WarningSection = MessageTab:AddSection({
    Name = "Important Notes"
})

-- Add warning notes about cracking and misuse
WarningSection:AddParagraph("Warning", "Any attempts to crack or misuse this HUB will result in a permanent ban. All activities are monitored, and violators will face consequences.")
WarningSection:AddParagraph("Security", "This system has built-in security features to detect unauthorized access. Be sure to follow the rules to avoid any penalties.")

local RaceTeleportTab = Window:MakeTab({
    Name = "Race Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local VehicleTab = Window:MakeTab({
    Name = "Vehicle Mics",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Section = RaceTab:AddSection({
    Name = "AutoRace"
})

local Section = RaceTeleportTab:AddSection({
    Name = "Race Teleport"
})

local Section = VehicleTab:AddSection({
    Name = "Vehicle Mics"
})

-- Variable to control the loop
local autoLoop = false

-- Add Motor Movement Toggle
local motorMovementEnabled = false
local movementLoopActive = false

-- Race Data
local raceType = "DragRace" -- Default race type
local autoLoop = false -- AutoLoop toggle state
local loopTime = 15 -- Default loop time in seconds
local dragRaceWaypoints = {
    Vector3.new(6128, 5, 1719) -- DragRace finish line
}
local trackRaceWaypoints = {
    Vector3.new(3815.17, 52.7955, 6836.07),
    Vector3.new(3798.79, 52.7955, 6437.81),
    Vector3.new(3781.09, 52.7955, 6047.7),
    Vector3.new(4151.58, 54.724, 5741.06),
    Vector3.new(3473.56, 52.7955, 5872.5),
    Vector3.new(2702.57, 76.9759, 6017.31),
    Vector3.new(1834.81, 93.6032, 6349.58),
    Vector3.new(1566.46, 93.8003, 6116.47),
    Vector3.new(1882.16, 80.6721, 5349.85),
    Vector3.new(2528.63, 80.6721, 5488.12),
    Vector3.new(1988.66, 80.6721, 5818.44),
    Vector3.new(2308.65, 80.3192, 6013.07),
    Vector3.new(3616.54, 70.0026, 5459.25),
    Vector3.new(3768.06, 70.8873, 5532.49),
    Vector3.new(3869.54, 70.0026, 5403.25),
    Vector3.new(3619.96, 75.5806, 4649.12),
    Vector3.new(4407.96, 77.2038, 4695.58),
    Vector3.new(4393.58, 60.188, 5108.97),
    Vector3.new(4148.97, 55.7955, 6156.83),
	Vector3.new(3940, 53, 6516) -- Gas Station
}

-- Function to teleport player and bike
local function teleportToPosition(position)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local bike = workspace:FindFirstChild("Bikes") and workspace.Bikes:FindFirstChild(player.Name)
    if character and character:FindFirstChild("HumanoidRootPart") then
        -- Check if the player is sitting in the bike's DriveSeat
        if bike and bike:FindFirstChild("DriveSeat") and bike.DriveSeat.Occupant == character:FindFirstChild("Humanoid") then
            bike:SetPrimaryPartCFrame(CFrame.new(position))
        else
            character.HumanoidRootPart.CFrame = CFrame.new(position)
        end
    end
end

-- Start Race Functions
local function startDragRace()
    for _, waypoint in ipairs(dragRaceWaypoints) do
        teleportToPosition(waypoint)
        wait(loopTime)
    end
    print("Drag Race Completed!")
end

local function startTrackRace()
    for lap = 1, 2 do
        for _, waypoint in ipairs(trackRaceWaypoints) do
            teleportToPosition(waypoint)
            wait(loopTime)
        end
        print("Lap " .. lap .. " Completed!")
    end
    print("Track Race Completed!")
end

local function teleportToLocation(position)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
end

-- Set up teleport for "4235, 12, 1742"
local teleportPosition = Vector3.new(4235, 12, 1742)
local teleportPosition1 = Vector3.new(3940, 60, 6481)
local teleportPosition2 = Vector3.new(597, 13, -60)
local teleportPosition3 = Vector3.new(738, 9, 70)
local teleportPosition4 = Vector3.new(-2368, 11, 12173)

local function startTrackRace()
    for lap = 1, 2 do
        for _, waypoint in ipairs(trackRaceWaypoints) do
            teleportToPosition(waypoint)
            wait(loopTime)
        end
        print("Lap " .. lap .. " Completed!")
    end
    -- Teleport to start position after 2 laps
    teleportToPosition(Vector3.new(3940, 51, 6481))
    print("Track Race Finished! Teleporting to Start Position...")
    wait(23) -- Wait for 20 seconds before restarting
end

-- Function to simulate key pressing
local function simulateKeyPress(keyCode)
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
end

-- Function to simulate key releasing
local function simulateKeyRelease(keyCode)
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

-- Function to handle motor movement
local function handleMotorMovement()
    while motorMovementEnabled do
        -- Simulate holding both keys when enabled
        simulateKeyPress(Enum.KeyCode.W) -- Forward
        simulateKeyPress(Enum.KeyCode.S) -- Backward
        wait(0.1) -- Wait briefly to prevent overloading
    end

    -- Release keys when disabled
    simulateKeyRelease(Enum.KeyCode.W)
    simulateKeyRelease(Enum.KeyCode.S)
    movementLoopActive = false -- Mark loop as inactive
end

-- Function to adjust all vehicle positions
local function adjustVehiclePositions()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	
	if not humanoidRootPart then
		warn("HumanoidRootPart not found for the LocalPlayer.")
		return
	end

	local vehiclesFolder = workspace:FindFirstChild("Vehicles")
	if vehiclesFolder then
		for _, vehicle in ipairs(vehiclesFolder:GetChildren()) do
			local main = vehicle:FindFirstChild("Main")
			if main and main:IsA("BasePart") then
				main.Position = humanoidRootPart.Position - Vector3.new(0, 15, 0) -- Move 15m below player
			end
		end
	else
		warn("Vehicles folder not found in the Workspace.")
	end
end

-- Auto-loop to keep adjusting positions
spawn(function()
	while true do
		if autoLoop then
			adjustVehiclePositions()
		end
		wait(1) -- Repeat every second
	end
end)


-- Dropdown for Race Selection
RaceTab:AddDropdown({
    Name = "Select Race Type",
    Default = "TrackRace",
    Options = {"DragRace", "TrackRace"},
    Callback = function(Value)
        raceType = Value
        print("Selected Race Type: " .. Value)
    end
})

-- Slider for Loop Time
RaceTab:AddSlider({
    Name = "Set Loop Time (Seconds)",
    Min = 1,
    Max = 15,
    Default = 2,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Seconds",
    Callback = function(Value)
        loopTime = Value
        print("Loop Time Set to: " .. Value .. " seconds")
    end
})

-- AutoLoop Toggle
RaceTab:AddToggle({
    Name = "Start Loop Race",
    Default = false,
    Callback = function(Value)
        autoLoop = Value
        print("AutoLoop is now " .. (Value and "Enabled" or "Disabled"))
        if autoLoop then
            while autoLoop do
                if raceType == "DragRace" then
                    startDragRace()
                elseif raceType == "TrackRace" then
                    startTrackRace()
                end
                wait(loopTime)
            end
        end
    end
})

-- Add the toggle to enable/disable motor movement
RaceTab:AddToggle({
   Name = "Disable Motor Movement",
    Default = false,
    Callback = function(Value)
        motorMovementEnabled = Value
        if motorMovementEnabled and not movementLoopActive then
            movementLoopActive = true -- Prevent multiple loops
            spawn(handleMotorMovement)
            print("Motor Movement Enabled")
        elseif not motorMovementEnabled then
            print("Motor Movement Disabled")
        end
    end
})

-- Add toggle with Enable/Disable functionality
VehicleTab:AddToggle({
	Name = "Vehicle Remover",
	Default = false,
	Callback = function(Value)
		autoLoop = Value
		if autoLoop then
			print("Vehicle Remove enabled.")
		else
			print("Vehicle Remove disabled.")
		end
	end
})

-- Add button to remove barriers
VehicleTab:AddButton({
	Name = "Barriers Remover",
	Callback = function()
		local barriersFolder = workspace:FindFirstChild("Barriers")
		if barriersFolder then
			barriersFolder:Destroy() -- Delete the folder
			print("Barriers folder removed successfully!")
		else
			warn("Barriers folder not found.")
		end
	end
})

RaceTeleportTab:AddButton({
    Name = "Drag Race",
    Callback = function()
        teleportToLocation(teleportPosition)
    end    
})

RaceTeleportTab:AddButton({
    Name = "Track Race",
    Callback = function()
        teleportToLocation(teleportPosition1)
    end    
})

RaceTeleportTab:AddButton({
    Name = "Spawn / Dealer",
    Callback = function()
        teleportToLocation(teleportPosition2)
    end    
})

RaceTeleportTab:AddButton({
    Name = "Helmet Store",
    Callback = function()
        teleportToLocation(teleportPosition3)
    end    
})

RaceTeleportTab:AddButton({
    Name = "Highway Desert",
    Callback = function()
        teleportToLocation(teleportPosition4)
    end    
})

-- Initialize UI
OrionLib:Init()
