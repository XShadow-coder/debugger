local Players = game:GetService("Players")
local player = Players.LocalPlayer

local INTERVAL = 0.1

local gui = Instance.new("ScreenGui")
gui.Name = "SlapRoyaleStateLogger"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 110)
frame.Position = UDim2.new(0, 15, 0.5, -55)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "SLAP ROYALE STATE LOGGER"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0,5,0,30)
status.Size = UDim2.new(1,-10,0,25)
status.BackgroundTransparency = 1
status.Text = "Logging..."
status.TextColor3 = Color3.fromRGB(180,180,180)
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local copy = Instance.new("TextButton")
copy.Position = UDim2.new(0,5,0,60)
copy.Size = UDim2.new(0.48,-5,0,35)
copy.BackgroundColor3 = Color3.fromRGB(45,45,45)
copy.Text = "COPY LOG"
copy.TextColor3 = Color3.new(1,1,1)
copy.TextSize = 13
copy.Font = Enum.Font.SourceSansBold
copy.Parent = frame

local clear = Instance.new("TextButton")
clear.Position = UDim2.new(0.52,0,0,60)
clear.Size = UDim2.new(0.48,-5,0,35)
clear.BackgroundColor3 = Color3.fromRGB(45,45,45)
clear.Text = "CLEAR"
clear.TextColor3 = Color3.new(1,1,1)
clear.TextSize = 13
clear.Font = Enum.Font.SourceSansBold
clear.Parent = frame

--==========================================================
-- LOGGER
--==========================================================

local previous = {}
local log = {}
local initialized = false

local function fmt(v)
    if typeof(v) == "EnumItem" then
        return tostring(v)

    elseif typeof(v) == "Vector3" then
        return string.format(
            "(%.2f, %.2f, %.2f)",
            v.X, v.Y, v.Z
        )

    elseif typeof(v) == "CFrame" then
        local p = v.Position
        return string.format(
            "CFrame(%.2f, %.2f, %.2f)",
            p.X, p.Y, p.Z
        )

    elseif typeof(v) == "Color3" then
        return string.format(
            "Color3(%.2f, %.2f, %.2f)",
            v.R, v.G, v.B
        )

    elseif v == nil then
        return "nil"

    else
        return tostring(v)
    end
end

local function addLog(text)
    local line = os.date("[%H:%M:%S] ") .. text

    table.insert(log, line)

    print(line)
end

local function scan()

    local snapshot = {}

    local char = player.Character

    snapshot["PLAYER.Character"] =
        char and char.Name or nil

    snapshot["PLAYER.CharacterParent"] =
        char and char.Parent and char.Parent:GetFullName() or nil

    --======================================================
    -- PLAYER ATTRIBUTES
    --======================================================

    for name,value in pairs(player:GetAttributes()) do
        snapshot["PLAYER.Attribute." .. name] = value
    end

    if char then

        --==================================================
        -- CHARACTER ATTRIBUTES
        --==================================================

        for name,value in pairs(char:GetAttributes()) do
            snapshot["CHAR.Attribute." .. name] = value
        end

        --==================================================
        -- HUMANOID
        --==================================================

        local humanoid =
            char:FindFirstChildOfClass("Humanoid")

        if humanoid then

            snapshot["Humanoid.State"] =
                humanoid:GetState()

            snapshot["Humanoid.Health"] =
                humanoid.Health

            snapshot["Humanoid.MaxHealth"] =
                humanoid.MaxHealth

            snapshot["Humanoid.PlatformStand"] =
                humanoid.PlatformStand

            snapshot["Humanoid.AutoRotate"] =
                humanoid.AutoRotate

            snapshot["Humanoid.Sit"] =
                humanoid.Sit

            snapshot["Humanoid.WalkSpeed"] =
                humanoid.WalkSpeed

            snapshot["Humanoid.JumpPower"] =
                humanoid.JumpPower
        end

        --==================================================
        -- CHARACTER DESCENDANTS
        --==================================================

        local objects = {}

        for _,obj in ipairs(char:GetDescendants()) do

            -- Ignore common animation spam
            if not obj:IsA("Animation")
            and not obj:IsA("Motor6D")
            and not obj:IsA("Weld")
            and not obj:IsA("Attachment") then

                objects[obj:GetFullName()] =
                    obj.ClassName
            end
        end

        for path,className in pairs(objects) do
            snapshot["OBJECT." .. path] = className
        end

        --==================================================
        -- ROOT PART
        --==================================================

        local root =
            char:FindFirstChild("HumanoidRootPart")

        if root then

            snapshot["ROOT.Anchored"] =
                root.Anchored

            snapshot["ROOT.CanCollide"] =
                root.CanCollide

            -- Don't log velocity continuously.
            -- Only useful when a major state changes.
            snapshot["ROOT.AssemblyLinearVelocity"] =
                root.AssemblyLinearVelocity
        end
    end

    --======================================================
    -- PLAYER GUI
    --======================================================

    local pg =
        player:FindFirstChild("PlayerGui")

    if pg then

        for _,obj in ipairs(pg:GetDescendants()) do

            if obj:IsA("ScreenGui") then
                snapshot["GUI." .. obj:GetFullName()] =
                    obj.Enabled
            end
        end
    end

    --======================================================
    -- WORKSPACE PLAYER MODEL
    --======================================================

    if char then

        local ws = workspace

        for _,obj in ipairs(ws:GetDescendants()) do

            if obj:IsA("Model")
            and obj ~= char
            and obj.Name == player.Name then

                snapshot["WORKSPACE.PlayerModel." ..
                    obj:GetFullName()] = obj.ClassName
            end
        end
    end

    return snapshot
end

--==========================================================
-- COPY
--==========================================================

copy.MouseButton1Click:Connect(function()

    local text = table.concat(log,"\n")

    if setclipboard then
        setclipboard(text)

    elseif toclipboard then
        toclipboard(text)

    else
        warn("No clipboard function available.")
        return
    end

    status.Text =
        "Copied " .. #log .. " log lines!"
end)

--==========================================================
-- CLEAR
--==========================================================

clear.MouseButton1Click:Connect(function()

    table.clear(log)

    status.Text = "Log cleared."

    print("========== LOG CLEARED ==========")
end)

--==========================================================
-- START
--==========================================================

addLog("========== LOGGER STARTED ==========")
addLog("PlaceId = " .. tostring(game.PlaceId))
addLog("JobId = " .. tostring(game.JobId))

while gui.Parent do

    local current = scan()

    if not initialized then

        addLog("========== INITIAL SNAPSHOT ==========")

        for key,value in pairs(current) do
            addLog(
                "[INITIAL] " ..
                key ..
                " = " ..
                fmt(value)
            )
        end

        addLog("======================================")

        initialized = true

    else

        -- Changed / added
        for key,value in pairs(current) do

            local old = previous[key]

            if old == nil then

                addLog(
                    "[ADDED] " ..
                    key ..
                    " = " ..
                    fmt(value)
                )

            elseif old ~= value then

                addLog(
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

                addLog(
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
        "Logging • " ..
        #log ..
        " changes"

    task.wait(INTERVAL)
end