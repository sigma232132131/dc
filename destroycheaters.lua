-- Define a new section for the example addon
local Example = ObeseAddons:Section({Name = "Game Utilities", Side = "left"})

-- Variables and Flags for internal usage
local flags = {}
local callbacks, connections = {}, {}
local lplr_parts, lplr_character = {}, nil

-- Helper Functions
local function newConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function insert(array, value)
    table.insert(array, value)
end

local function remove(array, value)
    for i, v in ipairs(array) do
        if v == value then
            table.remove(array, i)
            break
        end
    end
end

-- Feature: Destroy Cheaters
flags["destroy_cheaters"] = false
flags["destroy_cheaters_keybind"] = {active = false}

Example:Toggle({
    Name = "Destroy Cheaters",
    Def = false,
    Callback = function(state)
        flags["destroy_cheaters"] = state
    end
})

Example:Button({
    Name = "Activate Destroy Cheaters",
    Callback = function()
        flags["destroy_cheaters_keybind"].active = not flags["destroy_cheaters_keybind"].active
        print("Destroy Cheaters Keybind active:", flags["destroy_cheaters_keybind"].active)
    end
})

local function destroyCheaters()
    if not flags["destroy_cheaters_keybind"].active then return end
    if not lplr_character then return end

    local hrp = lplr_parts["HumanoidRootPart"]
    if not hrp then return end

    local old = hrp.CFrame
    hrp.CFrame = CFrame.new(9e9, 0, math.huge)
    game:GetService("RunService").RenderStepped:Wait()
    hrp.CFrame = old
end

-- Feature: Random Target Teleport
flags["random_target_teleport"] = false
flags["random_target_teleport_keybind"] = {active = false}
flags["random_target_teleport_range"] = 10

Example:Toggle({
    Name = "Random Target Teleport",
    Def = false,
    Callback = function(state)
        flags["random_target_teleport"] = state
    end
})

Example:Button({
    Name = "Activate Random Target Teleport",
    Callback = function()
        flags["random_target_teleport_keybind"].active = not flags["random_target_teleport_keybind"].active
        print("Random Target Teleport Keybind active:", flags["random_target_teleport_keybind"].active)
    end
})

Example:Slider({
    Name = "Target Teleport Range",
    Min = 2,
    Max = 30,
    Default = 10,
    Decimals = 1,
    Suffix = "studs",
    Callback = function(value)
        flags["random_target_teleport_range"] = value
    end
})

local function targetTeleport()
    if not flags["random_target_teleport_keybind"].active then return end

    local target = get_aimbot_target()
    if not target or not lplr_character then return end

    local hrp = lplr_parts["HumanoidRootPart"]
    if not hrp then return end

    local target_hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not target_hrp then return end

    local range = flags["random_target_teleport_range"]
    hrp.CFrame = target_hrp.CFrame + Vector3.new(math.random(-range, range), math.random(-range, range), math.random(-range, range))
end

-- Feature: 0 Camlock Smoothness
Example:Button({
    Name = "Set 0 Camlock Smoothness",
    Callback = function()
        flags["Default_aim_assist_horizontal_smoothness"] = 0
        flags["Pistols_aim_assist_horizontal_smoothness"] = 0
        flags["Shotguns_aim_assist_horizontal_smoothness"] = 0
        flags["Automatics_aim_assist_horizontal_smoothness"] = 0
        print("Set all aim assist horizontal smoothness values to 0")
    end
})

-- Feature: Force Reset
Example:Button({
    Name = "Force Reset",
    Callback = function()
        local humanoid = lplr_parts["Humanoid"]
        if humanoid then
            humanoid.Health = 0
            print("Forced player reset")
        end
    end
})

-- Character Management
local plrs = game:GetService("Players")
local lplr = plrs.LocalPlayer

local function onCharacterAdded(char)
    lplr_character = char
    lplr_parts = {}
    for _, instance in pairs(char:GetChildren()) do
        lplr_parts[instance.Name] = instance
    end

    newConnection(char.ChildAdded, function(instance)
        lplr_parts[instance.Name] = instance
    end)

    newConnection(char.ChildRemoved, function(instance)
        lplr_parts[instance.Name] = nil
    end)
end

newConnection(lplr.CharacterAdded, onCharacterAdded)
if lplr.Character then
    onCharacterAdded(lplr.Character)
end

-- Heartbeat Event: Update Callbacks
newConnection(game:GetService("RunService").Heartbeat, function()
    for _, callback in pairs(callbacks) do
        callback()
    end
end)

-- Clean up on script unload
newConnection(juju.script_unloaded, function(name)
    if name == "Game Utilities" then
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
        Example:Destroy()
    end
end)

-- Register Callbacks
insert(callbacks, destroyCheaters)
insert(callbacks, targetTeleport)
