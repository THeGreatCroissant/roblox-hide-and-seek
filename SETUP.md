# Roblox Hide and Seek Game - Setup Guide

## Overview
This is a complete hide and seek game system for Roblox with an interactive UI seeker picker.

## Features
- 🎮 Multiplayer hide and seek gameplay
- 🖱️ Interactive seeker selection UI
- ⏱️ Countdown timer during seeker selection
- 🎯 Auto-selection of random seekers if not enough players select
- 👥 Real-time player list updates

## Installation

### Step 1: Create Spawn Locations
In your Roblox Studio, create two parts in your workspace:

1. **HiderSpawn** - Where hiders will spawn
   - Name it exactly: `HiderSpawn`
   - Position it in a safe area

2. **SeekerSpawn** - Where seekers will spawn
   - Name it exactly: `SeekerSpawn`
   - Position it in a different area (e.g., in a room with limited vision)

### Step 2: Add Server Scripts

Place the following scripts in **ServerScriptService**:

1. **SeekerPickerServer.lua** - Handles seeker selection logic
2. **HideAndSeekGame.lua** - Handles main game logic

### Step 3: Add Client Script

Place the following script in **StarterPlayer > StarterPlayerScripts**:

1. **SeekerPickerClient.lua** - Handles the UI for selecting seekers

## Configuration

You can customize the game by editing these variables:

### In SeekerPickerServer.lua:
```lua
local SEEKER_COUNT = 1        -- Number of seekers
local SELECTION_TIME = 30     -- Time to select seekers (seconds)
```

### In HideAndSeekGame.lua:
```lua
local GAME_DURATION = 300     -- Game duration (seconds, 5 minutes)
local SEEKER_COUNT = 1        -- Number of seekers
local HIDER_SPAWN = ...       -- Position where hiders spawn
local SEEKER_SPAWN = ...      -- Position where seekers spawn
```

## How to Play

1. **Game Starts** - Players join the game
2. **Seeker Selection** - UI appears showing all players
3. **Click to Select** - Players click other players to select them as seekers
4. **Timer** - You have 30 seconds to select seekers
5. **Game Begins** - Seekers and hiders are placed at their spawn locations
6. **Objective**
   - **Hiders**: Find hiding spots and survive the timer
   - **Seekers**: Find and tag all hiders
7. **Win Condition**
   - **Seekers Win**: Find all hiders before time runs out
   - **Hiders Win**: Survive until the timer ends

## Customization

### Change Game Duration
Edit `HideAndSeekGame.lua` line 8:
```lua
local GAME_DURATION = 600  -- 10 minutes instead of 5
```

### Change Number of Seekers
Edit both `SeekerPickerServer.lua` and `HideAndSeekGame.lua`:
```lua
local SEEKER_COUNT = 2  -- 2 seekers instead of 1
```

### Change UI Colors
Edit `SeekerPickerClient.lua` to modify RGB values:
```lua
button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)  -- Change these numbers
```

### Change Selection Time
Edit `SeekerPickerServer.lua` line 9:
```lua
local SELECTION_TIME = 45  -- 45 seconds instead of 30
```

## Troubleshooting

**Problem: UI doesn't appear**
- Make sure `SeekerPickerClient.lua` is in `StarterPlayer > StarterPlayerScripts`
- Check that `SeekerPickerServer.lua` is in `ServerScriptService`

**Problem: Seekers don't spawn at correct location**
- Create parts named `SeekerSpawn` and `HiderSpawn` in workspace
- Make sure the scripts can find these parts

**Problem: Game doesn't start**
- Ensure at least 2 players are in the game
- Check the Output console for error messages

## File Structure
```
roblox-hide-and-seek/
├── SeekerPickerServer.lua      (Server script for seeker selection)
├── SeekerPickerClient.lua      (Client script for UI)
├── HideAndSeekGame.lua         (Main game logic)
├── SETUP.md                    (This file)
└── README.md                   (Project overview)
```

## Support
If you encounter issues, check the Roblox Output console (View > Output) for error messages and debug information.

Enjoy your hide and seek game! 🎉
