local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Items = Workspace:FindFirstChild("Items")

local DURATION = 5
local startTime = os.clock()

local connections = {}
local results = {}
local logged = {}

local function active()
    return os.clock() - startTime <= DURATION
end

local function log(text)
    print("[PICKUP SCANNER] " .. text)
    table.insert(results, text)
end

local function once(key, text)
    if logged[key] then return end
    logged[key] = true
    log(text)
end

log("================================")
log("🟢 SCANNER ATTIVO")
log("🍎 Raccogli UN SOLO item")
log("⏱️ 5 secondi")
log("================================")

-- Remote già esistenti
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        -- Registriamo solo il nome, senza creare hook pesanti
        table.insert(results,
            "📡 REMOTE: " .. obj:GetFullName()
        )
    end
end

-- Hook Remote
local oldNamecall

if hookmetamethod and getnamecallmethod and newcclosure then
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if active() then
            local method = getnamecallmethod()

            if method == "FireServer" and self:IsA("RemoteEvent") then
                once(
                    "RE:" .. self:GetFullName(),
                    "📡 FireServer → " .. self:GetFullName()
                )

            elseif method == "InvokeServer" and self:IsA("RemoteFunction") then
                once(
                    "RF:" .. self:GetFullName(),
                    "📡 InvokeServer → " .. self:GetFullName()
                )
            end
        end

        return oldNamecall(self, ...)
    end))
end

-- Osserva solamente gli item
if Items then
    table.insert(connections, Items.DescendantAdded:Connect(function(obj)
        if not active() then return end

        if obj:IsA("ProximityPrompt") then
            log("🔵 ProximityPrompt ADDED → " .. obj:GetFullName())

        elseif obj:IsA("ClickDetector") then
            log("🖱️ ClickDetector ADDED → " .. obj:GetFullName())
        end
    end))
end

-- Backpack
local backpack = player:FindFirstChildOfClass("Backpack")

if backpack then
    table.insert(connections, backpack.ChildAdded:Connect(function(obj)
        if active() then
            log("🎒 BACKPACK ADDED → " .. obj:GetFullName())
        end
    end))

    table.insert(connections, backpack.ChildRemoved:Connect(function(obj)
        if active() then
            log("🎒 BACKPACK REMOVED → " .. obj:GetFullName())
        end
    end))
end

-- Character
local character = player.Character

if character then
    table.insert(connections, character.ChildAdded:Connect(function(obj)
        if active() then
            log("👤 CHARACTER ADDED → " .. obj:GetFullName())
        end
    end))

    table.insert(connections, character.ChildRemoved:Connect(function(obj)
        if active() then
            log("👤 CHARACTER REMOVED → " .. obj:GetFullName())
        end
    end))
end

task.delay(DURATION, function()

    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    log("================================")
    log("🔴 SCANSIONE TERMINATA")
    log("================================")

    local output = table.concat(results, "\n")

    if toclipboard then
        toclipboard(output)
    elseif setclipboard then
        setclipboard(output)
    end

    print("📋 RISULTATI COPIATI")
end)