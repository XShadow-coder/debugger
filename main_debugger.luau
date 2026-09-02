--// REAL-TIME EVENT DEBUG LOGGER
--// For debugging your own Roblox experience

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Logs = {}
local Watched = {}
local LogCounter = 0

--==================================================
-- SERIALIZER
--==================================================

local function serialize(value, depth)
    depth = depth or 0

    if depth > 4 then
        return "<max depth>"
    end

    local t = typeof(value)

    if t == "Instance" then
        return value:GetFullName()

    elseif t == "string" then
        return string.format("%q", value)

    elseif t == "table" then
        local parts = {"{"}

        for k, v in pairs(value) do
            table.insert(parts,
                "[" .. serialize(k, depth + 1) .. "] = " ..
                serialize(v, depth + 1)
            )
        end

        table.insert(parts, "}")

        return table.concat(parts, ", ")

    elseif t == "Vector3"
        or t == "Vector2"
        or t == "CFrame"
        or t == "Color3"
        or t == "UDim2" then

        return tostring(value)
    end

    return tostring(value)
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventDebugLogger"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 650, 0, 450)
Main.Position = UDim2.new(0.5, -325, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "EVENT DEBUG LOGGER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 22)
Status.Position = UDim2.new(0, 10, 0, 38)
Status.BackgroundTransparency = 1
Status.Text = "Listening..."
Status.TextColor3 = Color3.fromRGB(150, 150, 150)
Status.TextSize = 12
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

--==================================================
-- SCROLLING LOG AREA
--==================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -115)
Scroll.Position = UDim2.new(0, 10, 0, 65)

Scroll.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Scroll.BorderSizePixel = 0

Scroll.ScrollBarThickness = 6
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

Scroll.Parent = Main

Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 5)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 5)
Padding.PaddingBottom = UDim.new(0, 5)
Padding.PaddingLeft = UDim.new(0, 5)
Padding.PaddingRight = UDim.new(0, 5)
Padding.Parent = Scroll

--==================================================
-- BUTTONS
--==================================================

local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(0, 120, 0, 32)
CopyButton.Position = UDim2.new(0, 10, 1, -42)

CopyButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CopyButton.Text = "COPY ALL"
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.TextSize = 12
CopyButton.Font = Enum.Font.GothamBold
CopyButton.Parent = Main

Instance.new("UICorner", CopyButton).CornerRadius = UDim.new(0, 5)

local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0, 120, 0, 32)
ClearButton.Position = UDim2.new(0, 140, 1, -42)

ClearButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ClearButton.Text = "CLEAR ALL"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.TextSize = 12
ClearButton.Font = Enum.Font.GothamBold
ClearButton.Parent = Main

Instance.new("UICorner", ClearButton).CornerRadius = UDim.new(0, 5)

--==================================================
-- DELETE SINGLE LOG
--==================================================

local function deleteLog(index, frame)

    if Logs[index] then
        table.remove(Logs, index)
    end

    if frame then
        frame:Destroy()
    end

    Status.Text =
        "Listening... | Logs: " .. tostring(#Logs)
end

--==================================================
-- CREATE UI LOG
--==================================================

local function createLogUI(index, text)

    local Frame = Instance.new("Frame")

    Frame.Size = UDim2.new(1, -10, 0, 80)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Frame.BorderSizePixel = 0
    Frame.LayoutOrder = index

    Frame.Parent = Scroll

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)

    local Text = Instance.new("TextLabel")

    Text.Size = UDim2.new(1, -40, 1, -10)
    Text.Position = UDim2.new(0, 8, 0, 5)

    Text.BackgroundTransparency = 1

    Text.Text = text
    Text.TextColor3 = Color3.fromRGB(220, 220, 220)
    Text.TextSize = 11
    Text.Font = Enum.Font.Code

    Text.TextWrapped = true
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.TextYAlignment = Enum.TextYAlignment.Top

    Text.Parent = Frame

    local Delete = Instance.new("TextButton")

    Delete.Size = UDim2.new(0, 25, 0, 25)
    Delete.Position = UDim2.new(1, -30, 0, 5)

    Delete.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Delete.Text = "X"
    Delete.TextColor3 = Color3.fromRGB(255, 255, 255)
    Delete.TextSize = 11
    Delete.Font = Enum.Font.GothamBold

    Delete.Parent = Frame

    Instance.new("UICorner", Delete).CornerRadius = UDim.new(0, 5)

    Delete.MouseButton1Click:Connect(function()

        deleteLog(index, Frame)

    end)

    return Frame
end

--==================================================
-- LOG EVENT
--==================================================

local function logEvent(eventType, object, method, args)

    LogCounter += 1

    local time = os.date("%H:%M:%S")

    local lines = {}

    table.insert(lines,
        string.format(
            "#%d  [%s]  %s",
            LogCounter,
            time,
            eventType
        )
    )

    table.insert(lines,
        "Object: " .. object:GetFullName()
    )

    table.insert(lines,
        "Class: " .. object.ClassName
    )

    if method then
        table.insert(lines,
            "Event: " .. method
        )
    end

    if args then

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
    end

    local text = table.concat(lines, "\n")

    table.insert(Logs, {
        id = LogCounter,
        text = text
    })

    -- Console
    print("========================================")
    print(text)
    print("========================================")

    -- UI
    createLogUI(
        #Logs,
        text
    )

    Status.Text =
        "Listening... | Logs: " .. tostring(#Logs)

end

--==================================================
-- WATCH OBJECT
--==================================================

local function watch(object)

    if Watched[object] then
        return
    end

    Watched[object] = true

    -- RemoteEvent
    if object:IsA("RemoteEvent") then

        object.OnClientEvent:Connect(function(...)

            logEvent(
                "REMOTE EVENT",
                object,
                "OnClientEvent",
                {...}
            )

        end)

    -- BindableEvent
    elseif object:IsA("BindableEvent") then

        object.Event:Connect(function(...)

            logEvent(
                "BINDABLE EVENT",
                object,
                "Event",
                {...}
            )

        end)

    -- RemoteFunction
    elseif object:IsA("RemoteFunction") then

        print(
            "[LOGGER] Found RemoteFunction:",
            object:GetFullName()
        )

    -- BindableFunction
    elseif object:IsA("BindableFunction") then

        print(
            "[LOGGER] Found BindableFunction:",
            object:GetFullName()
        )

    end
end

--==================================================
-- INITIAL SCAN
--==================================================

for _, object in ipairs(
    game:GetDescendants()
) do

    if object:IsA("RemoteEvent")
        or object:IsA("RemoteFunction")
        or object:IsA("BindableEvent")
        or object:IsA("BindableFunction") then

        watch(object)

    end
end

--==================================================
-- NEW OBJECTS
--==================================================

game.DescendantAdded:Connect(function(object)

    if object:IsA("RemoteEvent")
        or object:IsA("RemoteFunction")
        or object:IsA("BindableEvent")
        or object:IsA("BindableFunction") then

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
        "========== EVENT DEBUG LOG =========="
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
        "Logs: " .. tostring(#Logs)
    )

    table.insert(
        output,
        "====================================="
    )

    table.insert(output, "")

    for i, entry in ipairs(Logs) do

        table.insert(
            output,
            "[" .. tostring(i) .. "]"
        )

        table.insert(
            output,
            entry.text
        )

        table.insert(output, "")

    end

    local finalText = table.concat(
        output,
        "\n"
    )

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
            "[LOGGER] toclipboard unavailable."
        )

    end

end)

--==================================================
-- CLEAR ALL
--==================================================

ClearButton.MouseButton1Click:Connect(function()

    table.clear(Logs)

    for _, child in ipairs(Scroll:GetChildren()) do

        if child:IsA("Frame") then
            child:Destroy()
        end

    end

    Status.Text =
        "Listening... | Logs: 0"

    print(
        "[LOGGER] All logs cleared."
    )

end)

--==================================================
-- START
--==================================================

print("========================================")
print("EVENT DEBUG LOGGER STARTED")
print("Player:", Player.Name)
print("PlaceId:", game.PlaceId)
print("========================================")