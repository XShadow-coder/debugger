local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "CopyConsoleGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "CopyConsole"
button.Size = UDim2.fromOffset(140, 40)
button.Position = UDim2.new(0, 20, 0.5, 0)
button.Text = "CopyConsole"
button.Parent = gui

button.MouseButton1Click:Connect(function()
    local text = "Console contents cannot be directly read by Roblox Luau."
    
    if setclipboard then
        setclipboard(text)
    end
end)

local Items = workspace:WaitForChild("Items")

local function scan(item)
    print("━━━━━━━━━━━━━━━━━━━━")
    print("📦 ITEM:", item:GetFullName())
    print("📌 CLASS:", item.ClassName)

    for _, obj in ipairs(item:GetDescendants()) do
        print("  └─", obj:GetFullName(), "|", obj.ClassName)
    end

    print("━━━━━━━━━━━━━━━━━━━━")
end

for _, item in ipairs(Items:GetChildren()) do
    scan(item)
end

Items.ChildAdded:Connect(function(item)
    task.wait(0.1)
    scan(item)
end)

print("✅ Scanner attivo")