local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Items = workspace:FindFirstChild("Items")
local Backpack = player:WaitForChild("Backpack")

local results = {}
local connections = {}
local start = os.clock()
local duration = 5

local function active()
    return os.clock() - start <= duration
end

local function log(text)
    print("[PICKUP SCANNER] " .. text)
    table.insert(results, text)
end

log("===== PICKUP SCANNER =====")
log("Raccogli UN SOLO item entro 5 secondi.")

-- Items
if Items then
    connections[#connections + 1] = Items.ChildRemoved:Connect(function(obj)
        if active() then
            log("ITEM REMOVED: " .. obj:GetFullName() .. " [" .. obj.ClassName .. "]")
        end
    end)

    connections[#connections + 1] = Items.DescendantRemoving:Connect(function(obj)
        if active() then
            log("DESCENDANT REMOVED: " .. obj:GetFullName() .. " [" .. obj.ClassName .. "]")
        end
    end)
end

-- Backpack
connections[#connections + 1] = Backpack.ChildAdded:Connect(function(obj)
    if active() then
        log("BACKPACK ADDED: " .. obj:GetFullName() .. " [" .. obj.ClassName .. "]")
    end
end)

connections[#connections + 1] = Backpack.ChildRemoved:Connect(function(obj)
    if active() then
        log("BACKPACK REMOVED: " .. obj:GetFullName() .. " [" .. obj.ClassName .. "]")
    end
end)

-- Character
local function connectCharacter(char)
    connections[#connections + 1] = char.ChildAdded:Connect(function(obj)
        if active() then
            log("CHARACTER ADDED: " .. obj:GetFullName() .. " [" .. obj.ClassName .. "]")
        end
    end)

    connections[#connections + 1] = char.ChildRemoved:Connect(function(obj)
        if active() then
            log("CHARACTER REMOVED: " .. obj:GetFullName() .. " [" .. obj.ClassName .. "]")
        end
    end)
end

if player.Character then
    connectCharacter(player.Character)
end

task.delay(duration, function()
    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    log("===== SCANSIONE TERMINATA =====")

    local output = table.concat(results, "\n")

    if toclipboard then
        toclipboard(output)
    elseif setclipboard then
        setclipboard(output)
    end

    print("📋 RISULTATI COPIATI")
end)