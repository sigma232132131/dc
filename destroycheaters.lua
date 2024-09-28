-- Assuming you have defined the flags and desync functions somewhere else in your script
local flags = {
    [Desync] = false,  -- Default value for desync toggle
    [Desync Key] = false, -- Default value for desync key
    [Destroy Cheaters] = false,
    [Destroy Cheaters Key] = false,
    [Desync Type] = Random,  -- Default desync type
    [Desync Strafe Speed] = 0.1,
    [Desync Random Range] = 5,
    [Desync Strafe Height] = 0,
    [Desync Strafe Radius] = 10,
    [Desync X] = 0,
    [Desync Y] = 0,
    [Desync Z] = 0,
    [Rotation X] = 0,
    [Rotation Y] = 0,
    [Rotation Z] = 0,
}

-- Create the desync toggle in the example UI
ExampleToggle({
    Name = Enable Desync,  -- Toggle button name
    Def = false,  -- Default state (off)
    Callback = function(value)
        -- Update the desync flag based on the toggle state
        flags[Desync] = value
        
        if value then
            -- Code to enable desync
            print(Desync Enabled)
        else
            -- Code to disable desync
            print(Desync Disabled)
        end
    end
})

-- Example of how you might integrate this toggle into your main loop or event
local function updateDesync()
    -- This function runs continuously or within an update loop to apply the desync logic
    if flags[Desync] and flags[Desync Key] and LocalPlayer.Character then
        -- Your desync code implementation here
        C_Desync[OldPosition] = LocalPlayer.Character.HumanoidRootPart.CFrame
        local Origin = (flags[Attach Target] and checks and utility.target and utility.target.Character and utility.target.Character.HumanoidRootPart) or LocalPlayer.Character.HumanoidRootPart
        local randomRange = flags[Desync Random Range]
        Radians += flags[Desync Strafe Speed]
        
        local calculatedPositions = {
            [Random] = (NewCFrame(Origin.Position) + Vector3.new(math.random(-randomRange, randomRange), math.random(-randomRange, randomRange), math.random(-randomRange, randomRange)))  CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180))),
            [Roll] = Origin.CFrame  NewCFrame(0, -4, 0)  CFrame.Angles(0, math.rad(math.random(1, 360)), math.rad(-180)),
            [Target Strafe] = Origin.CFrame  CFrame.Angles(0, math.rad(Radians), 0)  NewCFrame(0, flags[Desync Strafe Height], flags[Desync Strafe Radius]),
            [Custom] = Origin.CFrame  NewCFrame(flags[Desync X], flags[Desync Y], flags[Desync Z])  CFrame.Angles(math.rad(flags[Rotation X]), math.rad(flags[Rotation Y]), math.rad(flags[Rotation Z])), 
            [Destroy Cheaters] = Origin.CFrame  NewCFrame(9e9, 9e9, 9e9)
        }

        -- Set the predicted position based on the current desync type
        C_Desync[PredictedPosition] = flags[Destroy Cheaters] and flags[Destroy Cheaters Key] and calculatedPositions[Destroy Cheaters] or calculatedPositions[flags[Desync Type]]
    end
end

-- You might call updateDesync() inside a loop or a specific event handler
gameGetService(RunService).RenderSteppedConnect(updateDesync)
