local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("[RAGDOLL LOGGER] LocalPlayer non disponibile.")
    return
end

local function scanRagdoll(character)
    print("========== RAGDOLL SCAN ==========")

    local found = false

    for _, obj in ipairs(character:GetDescendants()) do
        if obj.Name:lower():find("rag") then
            found = true

            local value = "N/A"

            if obj:IsA("ValueBase") then
                value = tostring(obj.Value)
            end

            print(
                "[FOUND]",
                obj:GetFullName(),
                "|",
                obj.ClassName,
                "| Value:",
                value
            )
        end
    end

    if not found then
        warn("[RAGDOLL LOGGER] Nessun oggetto contenente 'rag' trovato.")
    end

    print("==================================")
end

local function setup(character)
    if not character then
        return
    end

    task.wait(1)
    scanRagdoll(character)
end

-- Character già presente
if LocalPlayer.Character then
    setup(LocalPlayer.Character)
end

-- Nuovo Character / respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    setup(character)
end)