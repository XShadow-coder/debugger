local Players = game:GetService("Players")
local player = Players.LocalPlayer

local lastSnapshot = {}

local function valueToString(v)
    if typeof(v) == "EnumItem" then
        return tostring(v)
    elseif typeof(v) == "Vector3" then
        return string.format("(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z)
    else
        return tostring(v)
    end
end

local function getSnapshot()
    local character = player.Character
    if not character then
        return {}
    end

    local snapshot = {}

    -- Character Attributes
    for name, value in pairs(character:GetAttributes()) do
        snapshot["ATTR." .. name] = value
    end

    -- Humanoid
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        snapshot["HUMANOID.State"] = humanoid:GetState()
        snapshot["HUMANOID.PlatformStand"] = humanoid.PlatformStand
        snapshot["HUMANOID.AutoRotate"] = humanoid.AutoRotate
        snapshot["HUMANOID.Health"] = humanoid.Health
    end

    -- Important objects
    snapshot["OBJECT.Ragdollballsocket"] =
        character:FindFirstChild("Ragdollballsocket", true) ~= nil

    snapshot["OBJECT.SlapKnockback"] =
        character:FindFirstChild("SlapKnockback", true) ~= nil

    snapshot["OBJECT.QueuedToRespawn"] =
        character:FindFirstChild("QueuedToRespawn", true) ~= nil

    return snapshot
end

local firstScan = true

while task.wait(0.5) do
    local snapshot = getSnapshot()

    if firstScan then
        print("========== INITIAL STATE ==========")

        for name, value in pairs(snapshot) do
            print("[CURRENT]", name, "=", valueToString(value))
        end

        print("===================================")

        firstScan = false
    else
        -- Detect changed / added values
        for name, value in pairs(snapshot) do
            local oldValue = lastSnapshot[name]

            if oldValue == nil then
                print(
                    "[ADDED]",
                    name,
                    "=",
                    valueToString(value)
                )

            elseif oldValue ~= value then
                print(
                    "[CHANGED]",
                    name,
                    ":",
                    valueToString(oldValue),
                    "->",
                    valueToString(value)
                )
            end
        end

        -- Detect removed values
        for name, oldValue in pairs(lastSnapshot) do
            if snapshot[name] == nil then
                print(
                    "[REMOVED]",
                    name,
                    "=",
                    valueToString(oldValue)
                )
            end
        end
    end

    lastSnapshot = snapshot
end