local Items = workspace:WaitForChild("Items")

local function scanTool(tool)
    print("━━━━━━━━━━━━━━━━━━━━")
    print("🛠️ TOOL:", tool:GetFullName())

    for _, v in ipairs(tool:GetDescendants()) do
        print(
            "  ├─",
            v:GetFullName(),
            "| Class:",
            v.ClassName
        )
    end

    print("━━━━━━━━━━━━━━━━━━━━")
end

for _, item in ipairs(Items:GetChildren()) do
    if item:IsA("Tool") then
        scanTool(item)
    end
end

Items.ChildAdded:Connect(function(item)
    task.wait(0.1)

    if item:IsA("Tool") then
        scanTool(item)
    end
end)

print("✅ Tool scanner attivo")