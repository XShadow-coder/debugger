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