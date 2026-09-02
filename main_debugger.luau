local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// UI
local gui = Instance.new("ScreenGui")
gui.Name = "RagdollLogger"
gui.ResetOnSpawn = false
gui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 190, 0, 70)
frame.Position = UDim2.new(0.5, -95, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "Ragdoll Logger"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 35)
status.Position = UDim2.new(0, 0, 0, 28)
status.BackgroundTransparency = 1
status.Text = "Ragdolled: UNKNOWN"
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.Parent = frame

--// Logger
local lastState = nil

local function update(character)
    local ragdolled = character:FindFirstChild("Ragdolled")

    if not ragdolled then
        status.Text = "Ragdolled: NOT FOUND"
        status.TextColor3 = Color3.fromRGB(180, 180, 180)
        return
    end

    local currentState = ragdolled.Value

    if currentState ~= lastState then
        lastState = currentState

        print(
            "[RAGDOLL]",
            currentState and "RAGDOLLED" or "NOT RAGDOLLED"
        )

        if currentState then
            status.Text = "Ragdolled: YES"
            status.TextColor3 = Color3.fromRGB(255, 80, 80)
        else
            status.Text = "Ragdolled: NO"
            status.TextColor3 = Color3.fromRGB(80, 255, 120)
        end
    end
end

--// Stesso principio dello script originale:
--// controlla continuamente ragdolled.Value
task.spawn(function()
    while gui.Parent do
        local character = LocalPlayer.Character

        if character then
            update(character)
        else
            status.Text = "Ragdolled: NO CHARACTER"
            status.TextColor3 = Color3.fromRGB(180, 180, 180)
        end

        task.wait(0.05)
    end
end)

--// Reset/respawn
LocalPlayer.CharacterAdded:Connect(function()
    lastState = nil
end)