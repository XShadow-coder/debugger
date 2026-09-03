local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Items = workspace:FindFirstChild("Items")
local Character = player.Character or player.CharacterAdded:Wait()

local running = true
local connections = {}

local function log(...)
    print("[PICKUP SCANNER]", ...)
end

local function describe(obj)
    return obj:GetFullName() .. " [" .. obj.ClassName .. "]"
end

local function watchContainer(container)
    if not container then return end

    table.insert(connections, container.ChildAdded:Connect(function(obj)
        if running then
            log("➕ ADDED:", describe(obj))
        end
    end))

    table.insert(connections, container.ChildRemoved:Connect(function(obj)
        if running then
            log("➖ REMOVED:", describe(obj))
        end
    end))
end

-- Container principali
watchContainer(Items)
watchContainer(Character)
watchContainer(player.Backpack)

-- Attributi del Character
for _, attribute in ipairs(Character:GetAttributes()) do
    -- niente: serve solo a inizializzare il controllo
end

local lastAttributes = {}

for name, value in pairs(Character:GetAttributes()) do
    lastAttributes[name] = value
end

table.insert(connections, Character.AttributeChanged:Connect(function(name)
    if not running then return end

    local newValue = Character:GetAttribute(name)
    local oldValue = lastAttributes[name]

    if oldValue ~= newValue then
        log(
            "🔄 ATTRIBUTE:",
            name,
            "|",
            tostring(oldValue),
            "→",
            tostring(newValue)
        )

        lastAttributes[name] = newValue
    end
end))

-- ChildAdded/Removed ricorsivi per gli oggetti principali
local function watchDescendants(container)
    if not container then return end

    table.insert(connections, container.DescendantAdded:Connect(function(obj)
        if running then
            log("🔹 DESCENDANT ADDED:", describe(obj))
        end
    end))

    table.insert(connections, container.DescendantRemoving:Connect(function(obj)
        if running then
            log("🔸 DESCENDANT REMOVED:", describe(obj))
        end
    end))
end

watchDescendants(Items)
watchDescendants(Character)
watchDescendants(player.Backpack)

-- Backpack può cambiare durante il test
player.Backpack.ChildAdded:Connect(function(obj)
    if running then
        log("🎒 BACKPACK ADDED:", describe(obj))
    end
end)

player.Backpack.ChildRemoved:Connect(function(obj)
    if running then
        log("🎒 BACKPACK REMOVED:", describe(obj))
    end
end)

log("================================")
log("🟢 PICKUP SCANNER ATTIVO")
log("⏱️ Hai 5 secondi per raccogliere UN item")
log("================================")

task.delay(5, function()
    running = false

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    log("================================")
    log("🔴 SCANSIONE TERMINATA")
    log("================================")
end)