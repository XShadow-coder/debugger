local Players = game:GetService("Players")
local LogService = game:GetService("LogService")

local player = Players.LocalPlayer
local logs = {}

-- Cattura i nuovi messaggi della Developer Console
LogService.MessageOut:Connect(function(message, messageType)
    table.insert(logs, ("[%s] %s"):format(messageType.Name, message))
end)

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "CopyConsoleGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "CopyConsole"
button.Size = UDim2.fromOffset(150, 40)
button.Position = UDim2.new(0, 20, 0.5, -20)
button.Text = "CopyConsole"
button.TextSize = 16
button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
button.TextColor3 = Color3.new(1, 1, 1)
button.BorderSizePixel = 0
button.Parent = gui

button.MouseButton1Click:Connect(function()
    local output = table.concat(logs, "\n")

    if toclipboard then
        toclipboard(output)
        button.Text = "Copied!"
        task.wait(1)
        button.Text = "CopyConsole"
    else
        warn("toclipboard non disponibile")
    end
end)

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
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Items = Workspace:FindFirstChild("Items")

local START = os.clock()
local DURATION = 5
local connections = {}
local logged = {}

local function active()
    return os.clock() - START <= DURATION
end

local function log(...)
    print("[PICKUP SCANNER]", ...)
end

local function once(key, ...)
    if logged[key] then return end
    logged[key] = true
    log(...)
end

log("================================")
log("🟢 PICKUP SCANNER ATTIVO")
log("🍎 Ora raccogli UN SOLO item")
log("⏱️ Durata: 5 secondi")
log("================================")

-- RemoteEvent / RemoteFunction
local oldNamecall

if hookmetamethod and getnamecallmethod and newcclosure then
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if active() then
            local method = getnamecallmethod()

            if method == "FireServer" and self:IsA("RemoteEvent") then
                once(
                    "RE:" .. self:GetFullName(),
                    "📡 RemoteEvent:",
                    self:GetFullName(),
                    "| FireServer"
                )
            elseif method == "InvokeServer" and self:IsA("RemoteFunction") then
                once(
                    "RF:" .. self:GetFullName(),
                    "📡 RemoteFunction:",
                    self:GetFullName(),
                    "| InvokeServer"
                )
            end
        end

        return oldNamecall(self, ...)
    end))
end

-- ProximityPrompt
local function watch(obj)
    if obj:IsA("ProximityPrompt") then
        table.insert(connections, obj.Triggered:Connect(function(plr)
            if active() then
                log("🔵 ProximityPrompt TRIGGERED:", obj:GetFullName())
                log("   Player:", plr and plr.Name or "nil")
            end
        end))

    elseif obj:IsA("ClickDetector") then
        table.insert(connections, obj.MouseClick:Connect(function(plr)
            if active() then
                log("🖱️ ClickDetector CLICKED:", obj:GetFullName())
                log("   Player:", plr and plr.Name or "nil")
            end
        end))

    elseif obj:IsA("Tool") then
        table.insert(connections, obj.Activated:Connect(function()
            if active() then
                log("🛠️ Tool ACTIVATED:", obj:GetFullName())
            end
        end))
    end
end

-- Scansiona tutto il gioco per i metodi di interazione
for _, obj in ipairs(game:GetDescendants()) do
    if not active() then break end
    watch(obj)
end

-- Rileva eventuali oggetti creati durante il test
table.insert(connections, game.DescendantAdded:Connect(function(obj)
    if active() then
        watch(obj)
    end
end))

task.delay(DURATION, function()
    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    log("================================")
    log("🔴 SCANSIONE TERMINATA")
    log("================================")
end)    log("🔴 SCANSIONE TERMINATA")
    log("================================")
end)