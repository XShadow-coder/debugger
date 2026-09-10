local success, result = pcall(function()
    return game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
end)

if success then
    print("HttpGet funziona! Lunghezza codice:", #result)
    local loadedFunc, err = loadstring(result)
    if loadedFunc then
        print("Loadstring funziona correttamente!")
    else
        warn("Loadstring fallito:", err)
    end
else
    warn("HttpGet fallito o bloccato:", result)
end
