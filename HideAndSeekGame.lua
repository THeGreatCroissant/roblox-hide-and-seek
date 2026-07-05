-- Hide and Seek Game Script
-- Place this in ServerScriptService

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")

-- Game Configuration
local GAME_DURATION = 300 -- 5 minutes
local SEEKER_COUNT = 1
local HIDER_SPAWN = workspace:FindFirstChild("HiderSpawn") or Vector3.new(0, 5, 0)
local SEEKER_SPAWN = workspace:FindFirstChild("SeekerSpawn") or Vector3.new(0, 5, 50)

local gameState = "waiting" -- waiting, playing, ended
local gameTimer = 0
local seekers = {}
local hiders = {}

-- Function to assign players to roles
local function assignRoles()
    local players = Players:GetPlayers()
    
    if #players < 2 then
        print("Not enough players")
        return
    end
    
    -- Shuffle players
    for i = #players, 2, -1 do
        local j = math.random(i)
        players[i], players[j] = players[j], players[i]
    end
    
    -- Assign seekers
    for i = 1, math.min(SEEKER_COUNT, #players) do
        table.insert(seekers, players[i])
    end
    
    -- Assign hiders
    for i = SEEKER_COUNT + 1, #players do
        table.insert(hiders, players[i])
    end
end

-- Function to spawn players
local function spawnPlayers()
    for _, seeker in pairs(seekers) do
        if seeker.Character then
            seeker.Character:MoveTo(SEEKER_SPAWN)
        end
    end
    
    for _, hider in pairs(hiders) do
        if hider.Character then
            hider.Character:MoveTo(HIDER_SPAWN)
        end
    end
end

-- Function to check win conditions
local function checkWinCondition()
    local hidersAlive = 0
    
    for _, hider in pairs(hiders) do
        if hider.Parent and hider.Character and hider.Character:FindFirstChild("Humanoid") and hider.Character.Humanoid.Health > 0 then
            hidersAlive = hidersAlive + 1
        end
    end
    
    if hidersAlive == 0 then
        print("Seekers win!")
        gameState = "ended"
        return true
    end
    
    return false
end

-- Main game loop
local function gameLoop()
    gameState = "playing"
    gameTimer = GAME_DURATION
    
    assignRoles()
    spawnPlayers()
    
    print("Game started! " .. #seekers .. " seekers vs " .. #hiders .. " hiders")
    
    while gameState == "playing" and gameTimer > 0 do
        gameTimer = gameTimer - 1
        
        if checkWinCondition() then
            break
        end
        
        wait(1)
    end
    
    if gameTimer <= 0 then
        print("Time's up! Hiders win!")
    end
    
    gameState = "ended"
    wait(5)
    gameState = "waiting"
    seekers = {}
    hiders = {}
end

-- Main loop
while true do
    if gameState == "waiting" and #Players:GetPlayers() >= 2 then
        gameLoop()
    end
    wait(1)
end
