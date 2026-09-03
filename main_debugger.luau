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

local sawFreefall = false
local cycleId = 0

--// Funzioni
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
    sawFreefall = false
end

--// ON / OFF
button.MouseButton1Click:Connect(function()
    enabled = not enabled
    cycleId += 1

    if enabled then
        print("[AutoTP TEST] ON")

        working = false
        resetCycle()
        setWaiting()
    else
        print("[AutoTP TEST] OFF")

        working = false
        resetCycle()
        setOff()
    end
end)

setWaiting()

--// Monitor
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

        --==================================================
        -- INBUS = TRUE
        -- NON FARE ASSOLUTAMENTE NULLA
        --==================================================

        if inBus == true then
            resetCycle()
            continue
        end

        --==================================================
        -- INBUS = NIL
        -- ASPETTA FREEFALL
        --==================================================

        if inBus == nil
            and state == Enum.HumanoidStateType.Freefall
            and not sawFreefall then

            sawFreefall = true

            print("[AutoTP TEST] Freefall rilevato")
        end

        --==================================================
        -- FREEFALL
        -- ↓
        -- RUNNING + INBUS NIL
        --==================================================

        if sawFreefall
            and inBus == nil
            and state == Enum.HumanoidStateType.Running then

            print("[AutoTP TEST] Running + InBus=nil rilevato")

            working = true
            sawFreefall = false

            local thisCycle = cycleId

            -- Attendi 5 secondi
            task.delay(5, function()
                if not enabled or thisCycle ~= cycleId then
                    working = false
                    return
                end

                print("[AutoTP TEST] Worked")

                setWorked()

                -- Rimane Worked per 5 secondi
                task.delay(5, function()
                    if not enabled or thisCycle ~= cycleId then
                        return
                    end

                    print("[AutoTP TEST] Waiting")

                    working = false
                    resetCycle()
                    setWaiting()
                end)
            end)
        end
    end
end)