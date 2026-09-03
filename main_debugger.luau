local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// UI
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

--// State
local enabled = false
local wasInBus = false
local wasFreefall = false
local working = false

local function resetCycle()
    wasInBus = false
    wasFreefall = false
end

local function setWaiting()
    button.Text = "Waiting"
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end

local function setWorked()
    button.Text = "Worked"
    button.BackgroundColor3 = Color3.fromRGB(50, 140, 70)
end

button.MouseButton1Click:Connect(function()
    enabled = not enabled

    if enabled then
        print("[AutoTP TEST] ON")
        setWaiting()
        resetCycle()
    else
        print("[AutoTP TEST] OFF")
        working = false
        resetCycle()
        button.Text = "OFF"
        button.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
    end
end)

setWaiting()

--// Detection loop
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
        -- 1. InBus = true
        --========================================

        if inBus == true and not wasInBus then
            wasInBus = true
            wasFreefall = false

            print("[AutoTP TEST] InBus detected")
        end

        --========================================
        -- 2. Freefall
        --========================================

        if wasInBus
            and state == Enum.HumanoidStateType.Freefall
            and not wasFreefall then

            wasFreefall = true

            print("[AutoTP TEST] Freefall detected")
        end

        --========================================
        -- 3. Freefall -> Running
        --========================================

        if wasInBus
            and wasFreefall
            and state == Enum.HumanoidStateType.Running then

            print("[AutoTP TEST] Landing detected")

            --====================================
            -- 4. InBus must be nil
            --====================================

            if inBus == nil then

                working = true

                print("[AutoTP TEST] =====================")
                print("[AutoTP TEST] WORKED")
                print("[AutoTP TEST] =====================")

                setWorked()

                task.delay(5, function()

                    if enabled then
                        working = false
                        resetCycle()
                        setWaiting()

                        print("[AutoTP TEST] Back to Waiting")
                    end

                end)

            else
                print(
                    "[AutoTP TEST] Landing detected, but InBus =",
                    tostring(inBus)
                )
            end
        end
    end
end)