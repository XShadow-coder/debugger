local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Items = Workspace:FindFirstChild("Items")

local results = {}

local function log(text)
    print("[ITEMCLIENT SCANNER] " .. text)
    table.insert(results, text)
end

log("===== ITEMCLIENT SCANNER =====")

-- Cerca ItemClient soltanto negli oggetti rilevanti
local containers = {
    Items,
    player.Character,
    player:FindFirstChild("Backpack")
}

for _, container in ipairs(containers) do
    if container then
        for _, obj in ipairs(container:GetDescendants()) do
            if obj.Name == "ItemClient" then
                log("FOUND: " .. obj:GetFullName())
                log("CLASS: " .. obj.ClassName)

                if obj:IsA("LocalScript") then
                    log("RUNNING LOCALSCRIPT: YES")
                elseif obj:IsA("ModuleScript") then
                    log("MODULESCRIPT FOUND")
                end
            end
        end
    end
end

-- Controlla anche ItemClient che vengono creati dopo
local connection

connection = game.DescendantAdded:Connect(function(obj)
    if obj.Name == "ItemClient" then
        log("NEW ItemClient: " .. obj:GetFullName())
        log("CLASS: " .. obj.ClassName)
    end
end)

task.delay(5, function()
    connection:Disconnect()

    log("===== SCANSIONE TERMINATA =====")

    local output = table.concat(results, "\n")

    if toclipboard then
        toclipboard(output)
    elseif setclipboard then
        setclipboard(output)
    end

    print("📋 RISULTATI COPIATI")
end)