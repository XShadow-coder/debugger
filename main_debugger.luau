local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoTPTest"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 220, 0, 50)
button.Position = UDim2.new(0, 20, 0.5, -25)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.BorderSizePixel = 0
button.Text = "Waiting"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 16
button.Font = Enum.Font.SourceSansBold
button.Parent = gui

--// Stato
local enabled = false
local working = false

local busDetected = false
local gliderDetected = false
local freefallDetected = false

local cycleId = 0

--// UI
local function setStatus(text)
    button.Text = text
end

local function resetCycle()
    busDetected = false
    gliderDetected = false
    freefallDetected = false
end

--// ON / OFF
button.MouseButton1Click:Connect(function()
    enabled = not enabled
    cycleId += 1

    if enabled then
        working = false
        resetCycle()

        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        setStatus("Waiting")

        print("[AutoTP TEST] ON")
    else
        working = false
        resetCycle()

        button.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        setStatus("OFF")

        print("[AutoTP TEST] OFF")
    end
end)

setStatus("Waiting")

--// MAIN LOOP
task.spawn(function()
    while gui.Parent do
        task.wait(0.1)

        if not enabled or working then
            continue
        end

        local char = player.Character
        if not char then
            resetCycle()
            setStatus("Waiting for character...")
            continue
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            setStatus("Waiting for Humanoid...")
            continue
        end

        local inBus = char:GetAttribute("InBus")
        local state = humanoid:GetState()

        local glider = char:FindFirstChild("Glider")

        --==================================================
        -- BUS
        --==================================================

        if inBus == true and not busDetected then
            busDetected = true
            gliderDetected = false
            freefallDetected = false

            setStatus("Bus detected")

            print("[AutoTP TEST] Bus detected")
        end

        --==================================================
        -- BUS ENDED
        --==================================================

        if busDetected
            and inBus == nil
            and not gliderDetected then

            setStatus("Bus ended - waiting Glider")

            print("[AutoTP TEST] InBus = nil")
        end

        --==================================================
        -- GLIDER
        --==================================================

        if busDetected
            and inBus == nil
            and glider
            and not gliderDetected then

            gliderDetected = true

            setStatus("Glider detected")

            print("[AutoTP TEST] Glider detected")
        end

        --==================================================
        -- FREEFALL
        --==================================================

        if gliderDetected
            and state == Enum.HumanoidStateType.Freefall
            and not freefallDetected then

            freefallDetected = true

            setStatus("Freefall detected")

            print("[AutoTP TEST] Freefall detected")
        end

        --==================================================
        -- GLIDER FINISHED
        --==================================================

        if freefallDetected
            and not glider then

            setStatus("Glider ended - waiting Running")

            print("[AutoTP TEST] Glider removed")
        end

        --==================================================
        -- RUNNING + INBUS NIL
        --==================================================

        if freefallDetected
            and state == Enum.HumanoidStateType.Running
            and inBus == nil then

            working = true

            local thisCycle = cycleId

            setStatus("Loop complete - 5s")

            print("[AutoTP TEST] =======================")
            print("[AutoTP TEST] LOOP COMPLETE")
            print("[AutoTP TEST] Waiting 5 seconds...")
            print("[AutoTP TEST] =======================")

            task.delay(5, function()
                if not enabled or thisCycle ~= cycleId then
                    return
                end

                button.BackgroundColor3 = Color3.fromRGB(50, 140, 70)
                setStatus("Worked")

                print("[AutoTP TEST] WORKED")

                task.delay(5, function()
                    if not enabled or thisCycle ~= cycleId then
                        return
                    end

                    working = false
                    resetCycle()

                    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    setStatus("Waiting")

                    print("[AutoTP TEST] Waiting")
                end)
            end)

            continue
        end

        --==================================================
        -- NO GLIDER / ALREADY ON GROUND
        --==================================================

        if not busDetected
            and state == Enum.HumanoidStateType.Running
            and inBus == nil then

            working = true

            local thisCycle = cycleId

            setStatus("Ground detected - 0.5s")

            print("[AutoTP TEST] No glider loop detected")
            print("[AutoTP TEST] Running + InBus=nil")
            print("[AutoTP TEST] Waiting 0.5 seconds...")

            task.delay(0.5, function()
                if not enabled or thisCycle ~= cycleId then
                    return
                end

                button.BackgroundColor3 = Color3.fromRGB(80, 100, 150)
                setStatus("On ground")

                print("[AutoTP TEST] ON GROUND")

                task.delay(5, function()
                    if not enabled or thisCycle ~= cycleId then
                        return
                    end

                    working = false
                    resetCycle()

                    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    setStatus("Waiting")

                    print("[AutoTP TEST] Waiting")
                end)
            end)
        end
    end
end)