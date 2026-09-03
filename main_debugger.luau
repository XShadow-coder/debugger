local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoTPTest"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 180, 0, 45)
button.Position = UDim2.new(0, 20, 0.5, -22)
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

local waitingForFreefall = false
local waitingForRunning = false

local cycleId = 0

--// GUI functions
local function setWaiting()
    button.Text = "Waiting"
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end

local function setWorked()
    button.Text = "Worked"
    button.BackgroundColor3 = Color3.fromRGB(50, 140, 70)
end

local function setOff()
    button.Text = "OFF"
    button.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
end

local function resetCycle()
    waitingForFreefall = false
    waitingForRunning = false
end

--// ON / OFF
button.MouseButton1Click:Connect(function()
    enabled = not enabled
    cycleId += 1

    if enabled then
        working = false
        resetCycle()
        setWaiting()

        print("[AutoTP TEST] ON")
    else
        working = false
        resetCycle()
        setOff()

        print("[AutoTP TEST] OFF")
    end
end)

setWaiting()

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
            continue
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            continue
        end

        local inBus = char:GetAttribute("InBus")
        local state = humanoid:GetState()

        --========================================
        -- 1. INBUS = NIL
        --========================================

        if inBus == nil then
            if not waitingForFreefall and not waitingForRunning then
                waitingForFreefall = true

                print("[AutoTP TEST] InBus = nil")
                print("[AutoTP TEST] Attendo Freefall...")
            end
        end

        --========================================
        -- 2. ATTENDI FREEFALL
        --========================================

        if waitingForFreefall
            and state == Enum.HumanoidStateType.Freefall then

            waitingForFreefall = false
            waitingForRunning = true

            print("[AutoTP TEST] Freefall rilevato")
            print("[AutoTP TEST] Attendo Running + InBus = nil...")
        end

        --========================================
        -- 3. RUNNING + INBUS = NIL
        --========================================

        if waitingForRunning
            and state == Enum.HumanoidStateType.Running
            and inBus == nil then

            waitingForRunning = false
            working = true

            local thisCycle = cycleId

            print("[AutoTP TEST] Running + InBus = nil")
            print("[AutoTP TEST] Loop completato")
            print("[AutoTP TEST] Aspetto 5 secondi...")

            -- Attesa di 5 secondi
            task.delay(5, function()

                if not enabled or thisCycle ~= cycleId then
                    return
                end

                setWorked()

                print("[AutoTP TEST] WORKED")

                -- Worked per 5 secondi
                task.delay(5, function()

                    if not enabled or thisCycle ~= cycleId then
                        return
                    end

                    working = false
                    resetCycle()
                    setWaiting()

                    print("[AutoTP TEST] WAITING")
                end)
            end)
        end
    end
end)