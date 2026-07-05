-- Seeker Picker Server Script
-- Place this in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local SEEKER_COUNT = 1
local SELECTION_TIME = 30 -- Time to select seekers in seconds

local gameState = "selecting" -- selecting, playing, ended
local selectedSeekers = {}
local allPlayers = {}

-- Create a RemoteEvent for communication
local SeekerSelectionEvent = Instance.new("RemoteEvent")
SeekerSelectionEvent.Name = "SeekerSelectionEvent"
SeekerSelectionEvent.Parent = ReplicatedStorage

-- Function to get all players
local function updatePlayerList()
    allPlayers = Players:GetPlayers()
    return allPlayers
end

-- Function to broadcast player list to all clients
local function broadcastPlayerList()
    local playerNames = {}
    for _, player in pairs(allPlayers) do
        table.insert(playerNames, player.Name)
    end
    SeekerSelectionEvent:FireAllClients("UpdatePlayerList", playerNames)
end

-- Function to start seeker selection
local function startSeekerSelection()
    gameState = "selecting"
    selectedSeekers = {}
    updatePlayerList()
    broadcastPlayerList()
    
    print("Seeker selection started! Select " .. SEEKER_COUNT .. " seeker(s)")
    SeekerSelectionEvent:FireAllClients("StartSelection", SEEKER_COUNT, SELECTION_TIME)
    
    wait(SELECTION_TIME)
    
    if #selectedSeekers < SEEKER_COUNT then
        print("Not enough seekers selected. Auto-selecting random players...")
        while #selectedSeekers < SEEKER_COUNT do
            local randomPlayer = allPlayers[math.random(1, #allPlayers)]
            if not table.find(selectedSeekers, randomPlayer) then
                table.insert(selectedSeekers, randomPlayer)
            end
        end
    end
    
    print("Seekers selected: ")
    for _, seeker in pairs(selectedSeekers) do
        print("- " .. seeker.Name)
    end
    
    gameState = "playing"
    SeekerSelectionEvent:FireAllClients("SelectionComplete", {seekers = selectedSeekers})
end

-- Handle player selection from clients
SeekerSelectionEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "SelectSeeker" then
        local targetPlayer = Players:FindFirstChild(data.playerName)
        
        if targetPlayer and gameState == "selecting" then
            if not table.find(selectedSeekers, targetPlayer) then
                if #selectedSeekers < SEEKER_COUNT then
                    table.insert(selectedSeekers, targetPlayer)
                    print(player.Name .. " selected " .. targetPlayer.Name .. " as a seeker!")
                    SeekerSelectionEvent:FireAllClients("SeekerSelected", targetPlayer.Name)
                else
                    print("Maximum seekers already selected!")
                end
            else
                print(targetPlayer.Name .. " is already selected!")
            end
        end
    elseif action == "DeselectSeeker" then
        local targetPlayer = Players:FindFirstChild(data.playerName)
        
        if targetPlayer and gameState == "selecting" then
            local index = table.find(selectedSeekers, targetPlayer)
            if index then
                table.remove(selectedSeekers, index)
                print(player.Name .. " deselected " .. targetPlayer.Name)
                SeekerSelectionEvent:FireAllClients("SeekerDeselected", targetPlayer.Name)
            end
        end
    end
end)

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
    updatePlayerList()
    broadcastPlayerList()
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
    -- Remove from selectedSeekers if they were selected
    local index = table.find(selectedSeekers, player)
    if index then
        table.remove(selectedSeekers, index)
        SeekerSelectionEvent:FireAllClients("SeekerDeselected", player.Name)
    end
    
    updatePlayerList()
    broadcastPlayerList()
end)

-- Main game loop
while true do
    if gameState == "selecting" or gameState == "ended" then
        startSeekerSelection()
    end
    wait(1)
end
