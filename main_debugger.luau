local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// UI
local gui = Instance.new("ScreenGui")
gui.Name = "StateMonitor"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 330, 0, 430)
frame.Position = UDim2.new(0, 15, 0.5, -215)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "STATE MONITOR • 0.5s"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 15
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0, 5, 0, 30)
status.Size = UDim2.new(1, -10, 0, 25)
status.BackgroundTransparency = 1
status.Text = "Waiting for character..."
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.TextSize = 13
status.Font = Enum.Font.SourceSans
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0, 5, 0, 60)
scroll.Size = UDim2.new(1, -10, 1, -100)
scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.Parent = scroll

local copy = Instance.new("TextButton")
copy.Position = UDim2.new(0, 5, 1, -35)
copy.Size = UDim2.new(1, -10, 0, 30)
copy.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
copy.Text = "COPY CURRENT STATE"
copy.TextColor3 = Color3.new(1, 1, 1)
copy.TextSize = 13
copy.Font = Enum.Font.SourceSansBold
copy.Parent = frame

--// Monitor
local labels = {}
local lastSnapshot = {}

local function valueToString(v)
    if typeof(v) == "EnumItem" then
        return tostring(v)
    end

    if typeof(v) == "Vector3" then
        return string.format(
            "(%.1f, %.1f, %.1f)",
            v.X, v.Y, v.Z
        )
    end

    return tostring(v)
end

local function setLine(name, value, changed)
    local label = labels[name]

    if not label then
        label = Instance.new("TextLabel")
        label.Name = name
        label.Size = UDim2.new(1, -8, 0, 22)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextSize = 13
        label.Font = Enum.Font.SourceSans
        label.Parent = scroll

        labels[name] = label
    end

    label.Text = name .. " = " .. valueToString(value)

    if changed then
        label.TextColor3 = Color3.fromRGB(255, 220, 80)
    elseif typeof(value) == "boolean" then
        label.TextColor3 =
            value
            and Color3.fromRGB(100, 255, 100)
            or Color3.fromRGB(255, 100, 100)
    else
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
    end
end

local function update()
    local character = player.Character

    if not character then
        status.Text = "Character: NONE"
        return
    end

    local snapshot = {}

    -- Character Attributes
    for name, value in pairs(character:GetAttributes()) do
        snapshot["ATTR." .. name] = value
    end

    -- Humanoid
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        snapshot["HUMANOID.State"] = humanoid:GetState()
        snapshot["HUMANOID.PlatformStand"] = humanoid.PlatformStand
        snapshot["HUMANOID.AutoRotate"] = humanoid.AutoRotate
        snapshot["HUMANOID.Health"] = humanoid.Health
    end

    -- Important objects
    snapshot["OBJECT.Ragdollballsocket"] =
        #character:GetDescendants() > 0 and
        (character:FindFirstChild("Ragdollballsocket", true) ~= nil)

    snapshot["OBJECT.SlapKnockback"] =
        character:FindFirstChild("SlapKnockback", true) ~= nil

    snapshot["OBJECT.QueuedToRespawn"] =
        character:FindFirstChild("QueuedToRespawn", true) ~= nil

    -- Detect changes
    for name, value in pairs(snapshot) do
        local old = lastSnapshot[name]
        local changed = old ~= nil and old ~= value

        setLine(name, value, changed)
    end

    -- Remove disappeared values
    for name, label in pairs(labels) do
        if snapshot[name] == nil then
            label:Destroy()
            labels[name] = nil
        end
    end

    lastSnapshot = snapshot

    scroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        layout.AbsoluteContentSize.Y + 5
    )

    status.Text = "Character: " .. character.Name
end

copy.MouseButton1Click:Connect(function()
    local lines = {}

    for name, label in pairs(labels) do
        table.insert(lines, label.Text)
    end

    table.sort(lines)

    local text = table.concat(lines, "\n")

    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    end
end)

--// Poll every 0.5 seconds
task.spawn(function()
    while gui.Parent do
        update()
        task.wait(0.5)
    end
end)

player.CharacterAdded:Connect(function()
    lastSnapshot = {}
    labels = {}

    task.wait(1)
    update()
end)

update()