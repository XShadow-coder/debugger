--// REAL-TIME REMOTE DEBUG LOGGER

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Logs = {}
local Watched = {}

--==================================================
-- SERIALIZER
--==================================================

local function serialize(value, depth)
    depth = depth or 0

    if depth > 3 then
        return "<max depth>"
    end

    local t = typeof(value)

    if t == "Instance" then
        return value:GetFullName()

    elseif t == "string" then
        return string.format("%q", value)

    elseif t == "table" then
        local result = "{"

        for k, v in pairs(value) do
            result ..= "[" ..
                serialize(k, depth + 1) ..
                "] = " ..
                serialize(v, depth + 1) ..
                ", "
        end

        return result .. "}"

    elseif t == "Vector3"
        or t == "Vector2"
        or t == "CFrame"
        or t == "Color3" then

        return tostring(value)
    end

    return tostring(value)
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemoteDebugLogger"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 600, 0, 400)
Main.Position = UDim2.new(0.5, -300, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "REMOTE DEBUG LOGGER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 0, 40)
Status.BackgroundTransparency = 1
Status.Text = "Listening..."
Status.TextColor3 = Color3.fromRGB(150, 150, 150)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -115)
Scroll.Position = UDim2.new(0, 10, 0, 70)
Scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 5
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 5)
ScrollCorner.Parent = Scroll

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 3)
Layout.Parent = Scroll

local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(0, 130, 0, 32)
CopyButton.Position = UDim2.new(1, -140, 1, -40)
CopyButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CopyButton.Text = "COPY ALL"
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.TextSize = 13
CopyButton.Font = Enum.Font.GothamBold
CopyButton.Parent = Main

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 5)
ButtonCorner.Parent = CopyButton

--==================================================
-- ADD LOG TO UI
--==================================================

local function addUIEntry(text)
    local Entry = Instance.new("TextLabel")

    Entry.Size = UDim2.new(1, -10, 0, 0)
    Entry.AutomaticSize = Enum.AutomaticSize.Y

    Entry.BackgroundTransparency = 1

    Entry.Text = text
    Entry.TextColor3 = Color3.fromRGB(220, 220, 220)
    Entry.TextSize = 12
    Entry.Font = Enum.Font.Code

    Entry.TextWrapped = true
    Entry.TextXAlignment = Enum.TextXAlignment.Left
    Entry.TextYAlignment = Enum.TextYAlignment.Top

    Entry.Parent = Scroll

    task.defer(function()
        Scroll.CanvasPosition = Vector2.new(
            0,
            math.max(0, Scroll.AbsoluteCanvasSize.Y)
        )
    end)
end

--==================================================
-- LOGGER
--==================================================

local function logRemote(direction, remote, method, args)

    local time = os.date("%H:%M:%S")

    local lines = {}

    table.insert(lines,
        string.format(
            "[%s] %s | %s",
            time,
            direction,
            remote:GetFullName()
        )
    )

    table.insert(lines,
        "Method: " .. method
    )

    table.insert(lines,
        "Arguments: " .. tostring(#args)
    )

    for i, value in ipairs(args) do
        table.insert(lines,
            string.format(
                "  [%d] %s",
                i,
                serialize(value)
            )
        )
    end

    local result = table.concat(lines, "\n")

    -- Save
    table.insert(Logs, result)

    -- Console
    print("========================================")
    print(result)
    print("========================================")

    -- UI
    addUIEntry(result)

    Status.Text =
        "Listening...  |  Events: " .. tostring(#Logs)
end

--==================================================
-- WATCH REMOTES
--==================================================

local function watch(remote)

    if Watched[remote] then
        return
    end

    Watched[remote] = true

    if remote:IsA("RemoteEvent") then

        remote.OnClientEvent:Connect(function(...)
            logRemote(
                "SERVER -> CLIENT",
                remote,
                "OnClientEvent",
                {...}
            )
        end)

        print(
            "[LOGGER] Watching:",
            remote:GetFullName()
        )

    elseif remote:IsA("RemoteFunction") then

        print(
            "[LOGGER] Found RemoteFunction:",
            remote:GetFullName()
        )

    end
end

-- Existing remotes
for _, object in ipairs(
    ReplicatedStorage:GetDescendants()
) do

    if object:IsA("RemoteEvent")
        or object:IsA("RemoteFunction") then

        watch(object)

    end
end

-- New remotes
ReplicatedStorage.DescendantAdded:Connect(function(object)

    if object:IsA("RemoteEvent")
        or object:IsA("RemoteFunction") then

        watch(object)

    end

end)

--==================================================
-- COPY ALL
--==================================================

CopyButton.MouseButton1Click:Connect(function()

    local output = {}

    table.insert(
        output,
        "========== REMOTE DEBUG LOG =========="
    )

    table.insert(
        output,
        "Player: " .. Player.Name
    )

    table.insert(
        output,
        "PlaceId: " .. tostring(game.PlaceId)
    )

    table.insert(
        output,
        "GameId: " .. tostring(game.GameId)
    )

    table.insert(
        output,
        "Events: " .. tostring(#Logs)
    )

    table.insert(
        output,
        "======================================"
    )

    table.insert(output, "")

    for i, log in ipairs(Logs) do

        table.insert(
            output,
            "[" .. tostring(i) .. "]"
        )

        table.insert(
            output,
            log
        )

        table.insert(output, "")

    end

    local finalText = table.concat(output, "\n")

    if toclipboard then

        toclipboard(finalText)

        CopyButton.Text = "COPIED!"

        task.delay(1.5, function()
            if CopyButton then
                CopyButton.Text = "COPY ALL"
            end
        end)

    else

        warn(
            "[LOGGER] toclipboard is unavailable."
        )

    end

end)

print("========================================")
print("REMOTE DEBUG LOGGER STARTED")
print("PlaceId:", game.PlaceId)
print("Player:", Player.Name)
print("========================================")