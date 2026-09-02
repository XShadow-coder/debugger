local Players = game:GetService("Players")
local player = Players.LocalPlayer

local logs = {}
local connections = {}

local gui = Instance.new("ScreenGui")
gui.Name = "AttributeLogger"
gui.ResetOnSpawn = false
gui.Parent = (gethui and gethui()) or player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(240, 230)
frame.Position = UDim2.fromOffset(20, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 28)
title.Position = UDim2.fromOffset(5, 2)
title.BackgroundTransparency = 1
title.Text = "Attribute Monitor"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 25)
status.Position = UDim2.fromOffset(5, 30)
status.BackgroundTransparency = 1
status.Text = "Waiting..."
status.TextColor3 = Color3.fromRGB(180,180,180)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -105)
scroll.Position = UDim2.fromOffset(5, 55)
scroll.BackgroundColor3 = Color3.fromRGB(18,18,18)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = frame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 5)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 1)
layout.Parent = scroll

local copy = Instance.new("TextButton")
copy.Size = UDim2.new(1, -10, 0, 38)
copy.Position = UDim2.new(0, 5, 1, -43)
copy.BackgroundColor3 = Color3.fromRGB(45, 110, 190)
copy.Text = "COPY LOG"
copy.TextColor3 = Color3.new(1,1,1)
copy.Font = Enum.Font.GothamBold
copy.TextSize = 12
copy.Parent = frame
Instance.new("UICorner", copy).CornerRadius = UDim.new(0, 5)

local labels = {}

local function log(...)
    local args = {...}
    local text = ""

    for i, v in ipairs(args) do
        text = text .. tostring(v) .. (i < #args and " " or "")
    end

    table.insert(logs, text)
    print(text)
end

local function updateAttribute(name, value)
    if not labels[name] then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -8, 0, 20)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextColor3 = Color3.fromRGB(210,210,210)
        label.Parent = scroll
        labels[name] = label
    end

    labels[name].Text = name .. " = " .. tostring(value)

    -- Evidenzia i valori booleani
    if value == true then
        labels[name].TextColor3 = Color3.fromRGB(80,255,120)
    elseif value == false then
        labels[name].TextColor3 = Color3.fromRGB(255,100,100)
    else
        labels[name].TextColor3 = Color3.fromRGB(210,210,210)
    end
end

local function setup(character)
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    connections = {}
    labels = {}
    logs = {}

    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    status.Text = "Monitoring: " .. character.Name

    log("========== NEW CHARACTER ==========")

    -- Valori attuali
    for name, value in pairs(character:GetAttributes()) do
        updateAttribute(name, value)
        log("[CURRENT]", name, "=", value)
    end

    log("===================================")

    -- Cambiamenti in tempo reale
    table.insert(connections,
        character.AttributeChanged:Connect(function(name)
            local value = character:GetAttribute(name)

            updateAttribute(name, value)
            log("[CHANGED]", name, "=", value)
        end)
    )
end

if player.Character then
    setup(player.Character)
end

player.CharacterAdded:Connect(setup)

copy.MouseButton1Click:Connect(function()
    local text = table.concat(logs, "\n")

    if toclipboard then
        toclipboard(text)
    elseif setclipboard then
        setclipboard(text)
    else
        warn("Clipboard API non disponibile")
        return
    end

    copy.Text = "COPIED!"
    task.delay(1.5, function()
        if copy then
            copy.Text = "COPY LOG"
        end
    end)
end)