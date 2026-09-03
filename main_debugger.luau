local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local running = false
local log = {}
local previous = {}

--========================================================--
-- GUI
--========================================================--

local gui = Instance.new("ScreenGui")
gui.Name = "ItemPickupScanner"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 105)
frame.Position = UDim2.new(0, 15, 0.5, -52)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,28)
title.BackgroundTransparency = 1
title.Text = "ITEM PICKUP SCANNER"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local start = Instance.new("TextButton")
start.Position = UDim2.new(0,5,0,32)
start.Size = UDim2.new(0.31,-5,0,32)
start.Text = "START"
start.TextColor3 = Color3.new(1,1,1)
start.BackgroundColor3 = Color3.fromRGB(45,45,45)
start.Parent = frame

local copy = Instance.new("TextButton")
copy.Position = UDim2.new(0.345,0,0,32)
copy.Size = UDim2.new(0.31,-5,0,32)
copy.Text = "COPY LOG"
copy.TextColor3 = Color3.new(1,1,1)
copy.BackgroundColor3 = Color3.fromRGB(45,45,45)
copy.Parent = frame

local clear = Instance.new("TextButton")
clear.Position = UDim2.new(0.69,0,0,32)
clear.Size = UDim2.new(0.31,-5,0,32)
clear.Text = "CLEAR"
clear.TextColor3 = Color3.new(1,1,1)
clear.BackgroundColor3 = Color3.fromRGB(45,45,45)
clear.Parent = frame

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0,5,0,68)
status.Size = UDim2.new(1,-10,0,30)
status.BackgroundTransparency = 1
status.Text = "Stopped"
status.TextColor3 = Color3.fromRGB(180,180,180)
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

--========================================================--
-- HELPERS
--========================================================--

local function fmt(v)
    if typeof(v) == "EnumItem" then
        return tostring(v)
    elseif typeof(v) == "Vector3" then
        return string.format(
            "(%.2f, %.2f, %.2f)",
            v.X,v.Y,v.Z
        )
    elseif typeof(v) == "CFrame" then
        local p = v.Position
        return string.format(
            "CFrame(%.2f, %.2f, %.2f)",
            p.X,p.Y,p.Z
        )
    elseif v == nil then
        return "nil"
    else
        return tostring(v)
    end
end

local function add(text)
    local line =
        string.format(
            "[%.3f] %s",
            os.clock(),
            text
        )

    table.insert(log,line)
    print(line)
end

--========================================================--
-- SNAPSHOT
--========================================================--

local function snapshot()

    local s = {}

    local char = player.Character

    -- Character
    if char then

        s["Character.Parent"] =
            char.Parent and char.Parent:GetFullName() or nil

        for name,value in pairs(char:GetAttributes()) do
            s["Character.Attribute." .. name] = value
        end

        local humanoid =
            char:FindFirstChildOfClass("Humanoid")

        if humanoid then
            s["Humanoid.State"] =
                humanoid:GetState()

            s["Humanoid.Health"] =
                humanoid.Health

            s["Humanoid.PlatformStand"] =
                humanoid.PlatformStand

            s["Humanoid.Sit"] =
                humanoid.Sit
        end

        -- All direct children of character
        for _,obj in ipairs(char:GetChildren()) do
            s["Character.Child." .. obj.Name] =
                obj.ClassName
        end
    end

    --====================================================--
    -- ITEMS
    --====================================================--

    local items = Workspace:FindFirstChild("Items")

    if items then

        s["Items.Exists"] = true

        for _,obj in ipairs(items:GetDescendants()) do

            -- Record item identity + position
            if obj:IsA("BasePart") then

                local parent = obj.Parent

                s[
                    "ITEM." ..
                    obj:GetFullName()
                ] =
                    string.format(
                        "%s | Pos=%s",
                        obj.ClassName,
                        fmt(obj.Position)
                    )

            elseif obj:IsA("Model") then

                s[
                    "ITEMMODEL." ..
                    obj:GetFullName()
                ] =
                    obj.ClassName
            end
        end

    else
        s["Items.Exists"] = false
    end

    return s
end

--========================================================--
-- START SCAN
--========================================================--

local function scan()

    local current = snapshot()

    if not next(previous) then

        add("========== INITIAL SNAPSHOT ==========")

        for key,value in pairs(current) do
            add(
                "[INITIAL] " ..
                key ..
                " = " ..
                fmt(value)
            )
        end

        add("======================================")

    else

        -- Added / changed
        for key,value in pairs(current) do

            local old = previous[key]

            if old == nil then

                add(
                    "[ADDED] " ..
                    key ..
                    " = " ..
                    fmt(value)
                )

            elseif old ~= value then

                add(
                    "[CHANGED] " ..
                    key ..
                    " : " ..
                    fmt(old) ..
                    " -> " ..
                    fmt(value)
                )
            end
        end

        -- Removed
        for key,old in pairs(previous) do

            if current[key] == nil then

                add(
                    "[REMOVED] " ..
                    key ..
                    " = " ..
                    fmt(old)
                )
            end
        end
    end

    previous = current

    status.Text =
        "Running • " .. #log .. " events"
end

--========================================================--
-- BUTTONS
--========================================================--

start.MouseButton1Click:Connect(function()

    running = not running

    if running then

        previous = {}

        add("========== SCAN STARTED ==========")

        status.Text = "Running..."

        task.spawn(function()

            while running and gui.Parent do
                scan()
                task.wait(0.1)
            end

        end)

        start.Text = "STOP"

    else

        start.Text = "START"
        status.Text = "Stopped"
        add("========== SCAN STOPPED ==========")
    end
end)

clear.MouseButton1Click:Connect(function()

    table.clear(log)
    table.clear(previous)

    print("========== LOG CLEARED ==========")

    status.Text = "Log cleared"
end)

copy.MouseButton1Click:Connect(function()

    local text = table.concat(log,"\n")

    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    else
        warn("Clipboard function unavailable")
        return
    end

    status.Text =
        "Copied " .. #log .. " events"
end)