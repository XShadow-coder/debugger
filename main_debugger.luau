local Items = workspace:WaitForChild("Items")

local function scanObject(obj)
    print("━━━━━━━━━━━━━━━━━━━━")
    print("📦 ITEM:", obj:GetFullName())
    print("📌 Class:", obj.ClassName)

    if obj:IsA("BasePart") then
        print("🟢 BasePart")
    elseif obj:IsA("Model") then
        print("🟡 Model")
    end

    for _, v in ipairs(obj:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            print("🔵 ProximityPrompt:", v:GetFullName())
        elseif v:IsA("ClickDetector") then
            print("🖱️ ClickDetector:", v:GetFullName())
        elseif v:IsA("TouchTransmitter") then
            print("👆 TouchInterest:", v:GetFullName())
        elseif v:IsA("RemoteEvent") then
            print("📡 RemoteEvent:", v:GetFullName())
        elseif v:IsA("RemoteFunction") then
            print("📡 RemoteFunction:", v:GetFullName())
        elseif v:IsA("Tool") then
            print("🛠️ Tool:", v:GetFullName())
        end
    end

    print("━━━━━━━━━━━━━━━━━━━━")
end

-- Scansiona gli item già presenti
for _, item in ipairs(Items:GetChildren()) do
    scanObject(item)
end

-- Rileva anche quelli che spawnano dopo
Items.ChildAdded:Connect(function(item)
    task.wait(0.1)
    scanObject(item)
end)

print("✅ Item scanner attivo")