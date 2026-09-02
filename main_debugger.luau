local function scanRagdoll(character)
    print("========== RAGDOLL SCAN ==========")

    local found = false

    for _, obj in ipairs(character:GetDescendants()) do
        if string.lower(obj.Name):find("rag") then
            found = true

            print(
                "[FOUND]",
                obj:GetFullName(),
                "| Class:",
                obj.ClassName,
                "| Value:",
                obj:IsA("ValueBase") and tostring(obj.Value) or "N/A"
            )
        end
    end

    if not found then
        warn("[RAGDOLL] Nessun oggetto contenente 'rag' trovato nel Character")
    end

    print("==================================")
end

if LocalPlayer.Character then
    scanRagdoll(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    scanRagdoll(character)
end)