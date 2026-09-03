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

local wasInBus = false
local wasFreefall = false

local cycleStarted = false
local cycleId = 0

--// Funzioni
local function resetCycle()
    wasInBus = false
    wasFreefall = false
    cycleStarted = false
end

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

--// Pulsante ON/OFF
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

--// Loop principale
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
        -- RILEVA INBUS
        --==================================================

        if inBus == true and not wasInBus then
            print("[AutoTP TEST] InBus = true")

            wasInBus = true
            wasFreefall = false
            cycleStarted = true

            local thisCycle = cycleId

            -- Se il loop NON viene rilevato entro 0.5 secondi,
            -- procediamo comunque.
            task.delay(0.5, function()
                if not enabled
                    or working
                    or thisCycle ~= cycleId
                    or not cycleStarted then
                    return
                end

                -- Controlliamo se nel frattempo il loop è stato completato
                local currentInBus = char:GetAttribute("InBus")
                local currentState = humanoid:GetState()

                local loopCompleted =
                    wasInBus
                    and wasFreefall
                    and currentState == Enum.HumanoidStateType.Running
                    and currentInBus == nil

                if not loopCompleted then
                    print("[AutoTP TEST] Loop NON rilevato")
                    print("[AutoTP TEST] Attesa: 0.5 secondi")

                    working = true
                    setWorked()

                    task.delay(5, function()
                        if enabled and thisCycle == cycleId then
                            working = false
                            resetCycle()
                            setWaiting()

                            print("[AutoTP TEST] Tornato a Waiting")
                        end
                    end)
                end
            end)
        end

        --==================================================
        -- RILEVA FREEFALL
        --==================================================

        if wasInBus
            and state == Enum.HumanoidStateType.Freefall
            and not wasFreefall then

            wasFreefall = true

            print("[AutoTP TEST] Freefall rilevato")
        end

        --==================================================
        -- RILEVA FINE LOOP
        --
        -- InBus=true
        --      ↓
        -- Freefall
        --      ↓
        -- Running
        --      ↓
        -- InBus=nil
        --==================================================

        if wasInBus
            and wasFreefall
            and state == Enum.HumanoidStateType.Running
            and inBus == nil then

            print("[AutoTP TEST] LOOP RILEVATO!")

            working = true
            cycleStarted = false

            local thisCycle = cycleId

            -- Loop rilevato → attesa 5 secondi
            task.delay(5, function()
                if enabled and thisCycle == cycleId then
                    print("[AutoTP TEST] Attesa loop: 5 secondi")

                    setWorked()

                    -- Rimane Worked per 5 secondi
                    task.delay(5, function()
                        if enabled and thisCycle == cycleId then
                            working = false
                            resetCycle()
                            setWaiting()

                            print("[AutoTP TEST] Tornato a Waiting")
                        end
                    end)
                end
            end)
        end
    end
end)