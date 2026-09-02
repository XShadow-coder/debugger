local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local INTERVAL = 0.1

--// UI
local gui = Instance.new("ScreenGui")
gui.Name = "MatchStateLogger"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 105)
frame.Position = UDim2.new(0, 15, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "MATCH STATE LOGGER"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0, 5, 0, 28)
status.Size = UDim2.new(1, -10, 0, 25)
status.BackgroundTransparency = 1
status.Text = "Scanning..."
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local copy = Instance.new("TextButton")
copy.Position = UDim2.new(0, 5, 0, 62)
copy.Size = UDim2.new(0.48, -5, 0, 35)
copy.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
copy.Text = "COPY LOG"
copy.TextColor3 = Color3.new(1, 1, 1)
copy.TextSize = 13
copy.Font = Enum.Font.SourceSansBold
copy.Parent = frame

local clear = Instance.new("TextButton")
clear.Position = UDim2.new(0.52, 0, 0, 62)
clear.Size = UDim2.new(0.48, -5, 0, 35)
clear.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
clear.Text = "CLEAR"
clear.TextColor3 = Color3.new(1, 1, 1)
clear.TextSize = 13
clear.Font = Enum.Font.SourceSansBold
clear.Parent = frame

--// Keywords: only objects potentially related to match state
local keywords = {
    "match",
    "round",
    "game",
    "arena",
    "lobby",
    "alive",
    "spectat",
    "spawn",
    "zone",
    "bus",
    "glider",
    "respawn",
    "death",
    "dead",
    "playing",
    "started",
    "ended",
    "state",
    "phase",
}

local function relevant(name)
    name = string.lower(name)

    for _, keyword in ipairs(keywords) do
        if string.find(name, keyword, 1, true) then
            return true
        end
    end

    return false
end

local function stringify(value)
    if typeof(value) == "EnumItem" then
        return tostring(value)

    elseif typeof(value) == "Vector3" then
        return string.format(
            "(%.2f, %.2f, %.2f)",
            value.X,
            value.Y,
            value.Z
        )

    elseif typeof(value) == "CFrame" then
        local p = value.Position

        return string.format(
            "CFrame(%.2f, %.2f, %.2f)",
            p.X,
            p.Y,
            p.Z
        )

    elseif value == nil then
        return "nil"
    end

    return tostring(value)
end

--// Log
local log = {}
local previous = {}
local initialized = false

local function addLog(text)
    local line = os.date("[%H:%M:%S] ") .. text

    table.insert(log, line)
    print(line)
end

--// Scan values / attributes
local function scanContainer(container, prefix, snapshot)

    -- Container attributes
    for name, value in pairs(container:GetAttributes()) do
        if relevant(name) then
            snapshot[
                prefix .. ".Attribute." .. name
            ] = value
        end
    end

    for _, obj in ipairs(container:GetDescendants()) do

        -- Attributes on potentially relevant objects
        if relevant(obj.Name) then

            for name, value in pairs(obj:GetAttributes()) do
                snapshot[
                    prefix .. "." ..
                    obj:GetFullName() ..
                    ".Attribute." ..
                    name
                ] = value
            end
        end

        -- Value objects
        if obj:IsA("BoolValue")
        or obj:IsA("StringValue")
        or obj:IsA("IntValue")
        or obj:IsA("NumberValue") then

            if relevant(obj.Name) or relevant(obj.Parent.Name) then

                snapshot[
                    prefix .. "." ..
                    obj:GetFullName() ..
                    ".Value"
                ] = obj.Value
            end
        end
    end
end

local function scan()

    local snapshot = {}

    --==================================================
    -- GLOBAL CONTAINERS
    --==================================================

    scanContainer(
        workspace,
        "WORKSPACE",
        snapshot
    )

    scanContainer(
        ReplicatedStorage,
        "REPLICATED",
        snapshot
    )

    --==================================================
    -- PLAYER
    --==================================================

    for name, value in pairs(player:GetAttributes()) do
        snapshot[
            "PLAYER.Attribute." .. name
        ] = value
    end

    --==================================================
    -- CHARACTER
    --==================================================

    local char = player.Character

    if char then

        for name, value in pairs(char:GetAttributes()) do
            snapshot[
                "CHAR.Attribute." .. name
            ] = value
        end

        local humanoid =
            char:FindFirstChildOfClass("Humanoid")

        if humanoid then
            snapshot["HUMANOID.State"] =
                humanoid:GetState()

            snapshot["HUMANOID.Health"] =
                humanoid.Health

            snapshot["HUMANOID.PlatformStand"] =
                humanoid.PlatformStand

            snapshot["HUMANOID.Sit"] =
                humanoid.Sit
        end

        -- Relevant objects directly in Character
        for _, obj in ipairs(char:GetDescendants()) do

            if relevant(obj.Name) then
                snapshot[
                    "CHAR.Object." ..
                    obj:GetFullName()
                ] = obj.ClassName
            end
        end
    end

    return snapshot
end

--==========================================================
-- COPY
--==========================================================

copy.MouseButton1Click:Connect(function()

    local text = table.concat(log, "\n")

    if setclipboard then
        setclipboard(text)

    elseif toclipboard then
        toclipboard(text)

    else
        warn("Clipboard function unavailable.")
        return
    end

    status.Text = "Copied " .. #log .. " lines"
end)

--==========================================================
-- CLEAR
--==========================================================

clear.MouseButton1Click:Connect(function()

    table.clear(log)

    print("========== LOG CLEARED ==========")

    status.Text = "Log cleared"
end)

--==========================================================
-- START
--==========================================================

addLog("========== MATCH LOGGER START ==========")
addLog("PlaceId = " .. tostring(game.PlaceId))
addLog("JobId = " .. tostring(game.JobId))
addLog("Player = " .. player.Name)
addLog("========================================")

while gui.Parent do

    local current = scan()

    if not initialized then

        addLog("========== INITIAL STATE ==========")

        for key, value in pairs(current) do
            addLog(
                "[INITIAL] " ..
                key ..
                " = " ..
                stringify(value)
            )
        end

        addLog("==================================")

        initialized = true

    else

        -- Changed / added
        for key, value in pairs(current) do

            local old = previous[key]

            if old == nil then

                addLog(
                    "[ADDED] " ..
                    key ..
                    " = " ..
                    stringify(value)
                )

            elseif old ~= value then

                addLog(
                    "[CHANGED] " ..
                    key ..
                    " : " ..
                    stringify(old) ..
                    " -> " ..
                    stringify(value)
                )
            end
        end

        -- Removed
        for key, old in pairs(previous) do

            if current[key] == nil then

                addLog(
                    "[REMOVED] " ..
                    key ..
                    " = " ..
                    stringify(old)
                )
            end
        end
    end

    previous = current

    status.Text =
        "Scanning • " ..
        #log ..
        " events"

    task.wait(INTERVAL)
end