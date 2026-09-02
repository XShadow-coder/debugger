local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("[RAGDOLL SCANNER] LocalPlayer non disponibile")
    return
end

local function printObject(obj)
    local extra = ""

    if obj:IsA("ValueBase") then
        extra = " | Value = " .. tostring(obj.Value)
    end

    print(
        "[RAGDOLL OBJECT]",
        obj:GetFullName(),
        "| Class =", obj.ClassName .. extra
    )
end

local function scan(character)
    print("")
    print("========================================")
    print("       SLAP ROYALE RAGDOLL SCAN")
    print("========================================")

    -- 1. Tutti gli oggetti sospetti
    for _, obj in ipairs(character:GetDescendants()) do
        local name = obj.Name:lower()

        if name:find("rag")
        or name:find("stun")
        or name:find("knock")
        or name:find("down")
        or name:find("slap")
        or name:find("fall") then
            printObject(obj)
        end
    end

    -- 2. Tutti gli attributi del Character
    print("")
    print("---------- CHARACTER ATTRIBUTES ----------")

    local attributes = character:GetAttributes()

    for name, value in pairs(attributes) do
        print(
            "[ATTRIBUTE]",
            name,
            "=",
            tostring(value)
        )
    end

    -- 3. Humanoid
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        print("")
        print("---------- HUMANOID ----------")

        print("State =", humanoid:GetState())
        print("PlatformStand =", humanoid.PlatformStand)
        print("AutoRotate =", humanoid.AutoRotate)

        print("")
        print("Humanoid Attributes:")

        for name, value in pairs(humanoid:GetAttributes()) do
            print(
                "[HUMANOID ATTRIBUTE]",
                name,
                "=",
                tostring(value)
            )
        end

        -- Monitoraggio degli stati
        humanoid.StateChanged:Connect(function(oldState, newState)
            print(
                "[HUMANOID STATE]",
                tostring(oldState),
                "->",
                tostring(newState)
            )
        end)
    end

    print("========================================")
    print("")
end

local function setup(character)
    task.wait(1)

    scan(character)

    -- Monitora nuovi oggetti aggiunti al Character
    character.DescendantAdded:Connect(function(obj)
        local name = obj.Name:lower()

        if name:find("rag")
        or name:find("stun")
        or name:find("knock")
        or name:find("down")
        or name:find("slap")
        or name:find("fall") then

            printObject(obj)

            if obj:IsA("ValueBase") then
                obj.Changed:Connect(function(value)
                    print(
                        "[VALUE CHANGED]",
                        obj:GetFullName(),
                        "=",
                        tostring(value)
                    )
                end)
            end
        end
    end)

    -- Monitora attributi modificati
    character.AttributeChanged:Connect(function(attribute)
        print(
            "[ATTRIBUTE CHANGED]",
            attribute,
            "=",
            tostring(character:GetAttribute(attribute))
        )
    end)
end

if LocalPlayer.Character then
    setup(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    setup(character)
end)