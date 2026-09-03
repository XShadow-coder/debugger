local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local DURATION = 5

local startTime = os.clock()
local connections = {}
local logged = {}
local results = {}

local function active()
    return os.clock() - startTime <= DURATION
end

local function log(...)
    local args = {...}
    local text = table.concat(
        table.pack(table.unpack(args)),
        " "
    )

    print("[PICKUP SCANNER]", text)
    table.insert(results, text)
end

local function once(key, ...)
    if logged[key] then return end
    logged[key] = true
    log(...)
end

log("================================")
log("🟢 PICKUP SCANNER ATTIVO")
log("🍎 Raccogli UN SOLO item")
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

-- Interazioni
local function watch(obj)
    if obj:IsA("ProximityPrompt") then

        table.insert(connections, obj.Triggered:Connect(function(plr)
            if active() then
                log(
                    "🔵 ProximityPrompt TRIGGERED:",
                    obj:GetFullName(),
                    "| Player:",
                    plr and plr.Name or "nil"
                )
            end
        end))

    elseif obj:IsA("ClickDetector") then

        table.insert(connections, obj.MouseClick:Connect(function(plr)
            if active() then
                log(
                    "🖱️ ClickDetector CLICKED:",
                    obj:GetFullName(),
                    "| Player:",
                    plr and plr.Name or "nil"
                )
            end
        end))

    elseif obj:IsA("Tool") then

        table.insert(connections, obj.Activated:Connect(function()
            if active() then
                log(
                    "🛠️ Tool ACTIVATED:",
                    obj:GetFullName()
                )
            end
        end))
    end
end

-- Scansione iniziale
for _, obj in ipairs(game:GetDescendants()) do
    if not active() then break end
    watch(obj)
end

-- Nuovi oggetti
table.insert(connections, game.DescendantAdded:Connect(function(obj)
    if active() then
        watch(obj)
    end
end))

-- Fine scansione
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
        print("📋 RISULTATI COPIATI NEGLI APPUNTI")
    elseif setclipboard then
        setclipboard(output)
        print("📋 RISULTATI COPIATI NEGLI APPUNTI")
    else
        warn("❌ toclipboard/setclipboard non disponibile")
    end
end)