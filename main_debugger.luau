local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "AttributeMonitor"
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
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 22)
status.Position = UDim2.fromOffset(5, 30)
status.BackgroundTransparency = 1
status.Text = "Waiting..."
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -105)
scroll.Position = UDim2.fromOffset(5, 55)
scroll.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
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
copy.Text = "COPY CURRENT"
copy.TextColor3 = Color3.new(1, 1, 1)
copy.Font = Enum.Font.GothamBold
copy.TextSize = 12
copy.Parent = frame

Instance.new("UICorner", copy).CornerRadius = UDim.new(0, 5)

local labels = {}

local function clearLabels()
    for _, label in pairs(labels) do
        label:Destroy()
    end

    labels = {}
end

local function update()
    local character = player.Character

    if not character then
        status.Text = "No Character"
        clearLabels()
        return
    end

    status.Text = "Monitoring: " .. character.Name

    local attributes = character:GetAttributes()

    -- Crea una label solo una volta per ogni Attribute
    for name in pairs(attributes) do
        if not labels[name] then
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -8, 0, 20)
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 11
            label.Parent = scroll

            labels[name] = label
        end
    end

    -- Aggiorna i valori senza aggiungere nuove righe
    for name, label in pairs(labels) do
        local value = character:GetAttribute(name)

        if value == nil then
            label.Text = name .. " = nil"
            label.TextColor3 = Color3.fromRGB(150, 150, 150)
        else
            label.Text = name .. " = " .. tostring(value)

            if value == true then
                label.TextColor3 = Color3.fromRGB(80, 255, 120)
            elseif value == false then
                label.TextColor3 = Color3.fromRGB(255, 100, 100)
            else
                label.TextColor3 = Color3.fromRGB(210, 210, 210)
            end
        end
    end
end

-- Aggiorna ogni 0.5 secondi
task.spawn(function()
    while gui.Parent do
        update()
        task.wait(0.5)
    end
end)

copy.MouseButton1Click:Connect(function()
    local character = player.Character

    if not character then
        return
    end

    local output = {}

    table.insert(output, "========== CURRENT ATTRIBUTES ==========")
    table.insert(output, "Character: " .. character.Name)

    for name, value in pairs(character:GetAttributes()) do
        table.insert(
            output,
            name .. " = " .. tostring(value)
        )
    end

    table.insert(output, "========================================")

    local text = table.concat(output, "\n")

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
            copy.Text = "COPY CURRENT"
        end
    end)
end)