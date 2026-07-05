-- Seeker Picker Client Script
-- Place this in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for the RemoteEvent
local SeekerSelectionEvent = ReplicatedStorage:WaitForChild("SeekerSelectionEvent")

local selectedSeekers = {}
local allPlayers = {}
local seekerCount = 1

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SeekerPickerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0, 400, 0, 50)
titleLabel.Position = UDim2.new(0.5, -200, 0, 20)
titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Select Seeker"
titleLabel.Parent = screenGui

-- Subtitle Label
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "SubtitleLabel"
subtitleLabel.Size = UDim2.new(0, 400, 0, 30)
subtitleLabel.Position = UDim2.new(0.5, -200, 0, 75)
subtitleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
subtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitleLabel.TextSize = 14
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Text = "Click on a player to select them as seeker"
subtitleLabel.Parent = screenGui

-- ScrollingFrame for player buttons
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "PlayerListFrame"
scrollFrame.Size = UDim2.new(0, 400, 0, 300)
scrollFrame.Position = UDim2.new(0.5, -200, 0, 110)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.BorderSizePixel = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = screenGui

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.Parent = scrollFrame

-- Selected Seekers Display
local selectedLabel = Instance.new("TextLabel")
selectedLabel.Name = "SelectedLabel"
selectedLabel.Size = UDim2.new(0, 400, 0, 30)
selectedLabel.Position = UDim2.new(0.5, -200, 0, 420)
selectedLabel.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
selectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
selectedLabel.TextSize = 14
selectedLabel.Font = Enum.Font.GothamBold
selectedLabel.Text = "Selected Seekers: 0"
selectedLabel.Parent = screenGui

-- Timer Label
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(0, 400, 0, 30)
timerLabel.Position = UDim2.new(0.5, -200, 0, 460)
timerLabel.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 14
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Text = "Time remaining: --"
timerLabel.Parent = screenGui

-- Function to create player button
local function createPlayerButton(playerName)
    local button = Instance.new("TextButton")
    button.Name = playerName .. "Button"
    button.Size = UDim2.new(1, -10, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.Text = playerName
    button.Parent = scrollFrame
    
    -- Detect if player is already selected
    local isSelected = false
    
    button.MouseButton1Click:Connect(function()
        isSelected = not isSelected
        
        if isSelected then
            button.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            SeekerSelectionEvent:FireServer("SelectSeeker", {playerName = playerName})
        else
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            SeekerSelectionEvent:FireServer("DeselectSeeker", {playerName = playerName})
        end
    end)
    
    -- Mark as selected initially if needed
    if table.find(selectedSeekers, playerName) then
        button.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        isSelected = true
    end
    
    return button
end

-- Function to update player list
local function updatePlayerList(playerNames)
    scrollFrame:ClearAllChildren()
    uiListLayout.Parent = scrollFrame
    
    allPlayers = playerNames
    
    for _, playerName in pairs(playerNames) do
        if playerName ~= player.Name then -- Don't show yourself
            createPlayerButton(playerName)
        end
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end

-- Function to handle seeker selected
local function onSeekerSelected(playerName)
    if not table.find(selectedSeekers, playerName) then
        table.insert(selectedSeekers, playerName)
    end
    selectedLabel.Text = "Selected Seekers: " .. #selectedSeekers .. "/" .. seekerCount
    
    -- Update button color
    local button = scrollFrame:FindFirstChild(playerName .. "Button")
    if button then
        button.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end
end

-- Function to handle seeker deselected
local function onSeekerDeselected(playerName)
    local index = table.find(selectedSeekers, playerName)
    if index then
        table.remove(selectedSeekers, index)
    end
    selectedLabel.Text = "Selected Seekers: " .. #selectedSeekers .. "/" .. seekerCount
    
    -- Update button color
    local button = scrollFrame:FindFirstChild(playerName .. "Button")
    if button then
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
end

-- Connect RemoteEvent signals
SeekerSelectionEvent.OnClientSignal:Connect(function(action, data1, data2)
    if action == "UpdatePlayerList" then
        updatePlayerList(data1)
    elseif action == "StartSelection" then
        seekerCount = data1
        local timeRemaining = data2
        selectedLabel.Text = "Selected Seekers: 0/" .. seekerCount
        
        -- Start countdown
        local startTime = tick()
        while tick() - startTime < timeRemaining do
            local remaining = math.ceil(timeRemaining - (tick() - startTime))
            timerLabel.Text = "Time remaining: " .. remaining .. "s"
            wait(0.1)
        end
        timerLabel.Text = "Selection Complete!"
    elseif action == "SeekerSelected" then
        onSeekerSelected(data1)
    elseif action == "SeekerDeselected" then
        onSeekerDeselected(data1)
    elseif action == "SelectionComplete" then
        screenGui:Destroy()
    end
end)
