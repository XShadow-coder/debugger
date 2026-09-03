local Players = game:GetService("Players")
local LogService = game:GetService("LogService")

local logs = {}

-- Cattura tutto ciò che passa dal LogService
LogService.MessageOut:Connect(function(message, messageType)
    table.insert(logs, string.format("[%s] %s", messageType.Name, message))
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CopyConsoleGui"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "CopyConsole"
button.Size = UDim2.fromOffset(140, 40)
button.Position = UDim2.new(0, 20, 0.5, 0)
button.Text = "CopyConsole"
button.Parent = gui

button.MouseButton1Click:Connect(function()
    local text = table.concat(logs, "\n")

    if setclipboard then
        setclipboard(text)
        button.Text = "Copied!"
        task.wait(1)
        button.Text = "CopyConsole"
    else
        warn("setclipboard non è disponibile.")
    end
end)

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