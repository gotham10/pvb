function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback
end
local queueteleport = missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))

local loaderScript = [[
    _G.ScannerConfig = {
        SCRIPT_URL = "https://raw.githubusercontent.com/gotham10/pvb/refs/heads/main/alldata/neygs.lua",
        NotSameServersFile = "NotSameServers.json",
        AutoHopFile = "ScannerAutoHop.json",
        HIDE_MY_DATA = true,
        MAX_KG_THRESHOLD_PLANT = 10,
        MAX_KG_THRESHOLD_BRAINROT = 100,
        ScanPlants = {
            ["Troll Mango"] = { kg = 0, mutations = { Gold = 0 , Diamond = 0, Ruby = 0, Neon = 0, Frozen = 0}, mutationsBypassKg = true, ignore = false },
            ["Starfruit"] = { kg = 0, mutations = { Gold = 0 , Diamond = 0, Ruby = 0, Neon = 0, Frozen = 0}, mutationsBypassKg = true, ignore = false },
            ["Hallow Tree"] = { kg = 0, mutations = { Gold = 0 , Diamond = 0, Ruby = 0, Neon = 0, Frozen = 0}, mutationsBypassKg = true, ignore = false },
            ["Commando Apple"] = { kg = 0, mutations = { Gold = 0 , Diamond = 0, Ruby = 0, Neon = 0, Frozen = 0}, mutationsBypassKg = true, ignore = false },
            ["King Limone"] = { kg = 4, mutations = { Gold = 3, Diamond = 2, Ruby = 0, Neon = 0, Frozen = 0}, mutationsBypassKg = true, ignore = false },
            ["Carnivorous Plant"] = { kg = 20, mutations = { Gold = 10, Diamond = 10, Ruby = 5, Neon = 2, Frozen = 0}, mutationsBypassKg = true, ignore = false },
            ["Copuccino"] = { kg = 10, mutations = { Gold = 5, Diamond = 3, Ruby = 2, Neon = 2, Frozen = 0}, mutationsBypassKg = true, ignore = false },
            ["Mango"] = { kg = 6, mutations = { Gold = 5, Diamond = 3, Ruby = 2.5, Neon = 2.5, Frozen = 0}, mutationsBypassKg = true, ignore = false },
            ["Mr Carrot"] = { kg = 10, mutations = { Gold = 5, Diamond = 3, Ruby = 4, Neon = 4, Frozen = 2.5}, mutationsBypassKg = true, ignore = false },
            ["Pine-a-Painter"] = { kg = 10, mutations = { Gold = 5, Diamond = 2.5, Ruby = 2, Neon = 2, Frozen = 2}, mutationsBypassKg = true, ignore = false },
            ["Shroombino"] = { kg = 10, mutations = { Gold = 5, Diamond = 3, Ruby = 2.5, Neon = 0, Frozen = 3}, mutationsBypassKg = true, ignore = false },
            ["Tomade Torelli"] = { kg = 10, mutations = { Gold = 5, Diamond = 3, Ruby = 3, Neon = 3, Frozen = 3}, mutationsBypassKg = true, ignore = false },
            ["Tomatrio"] = { kg = 10, mutations = { Gold = 5, Diamond = 3, Ruby = 3, Neon = 2, Frozen = 2}, mutationsBypassKg = true, ignore = false },
            ["Aubie"] = {ignore = true},
            ["Cactus"] = {ignore = true},
            ["Cocotank"] = {ignore = true},
            ["Don Fragola"] = {ignore = true},
            ["Dragon Fruit"] = {ignore = true},
            ["Eggplant"] = {ignore = true},
            ["Grape"] = {ignore = true},
            ["Pumpkin"] = {ignore = true},
            ["Strawberry"] = {ignore = true},
            ["Sunflower"] = {ignore = true},
            ["Sunzio"] = {ignore = true},
            ["Watermelon"] = {ignore = true},
        },
        ScanBrainrots = {["Pacchetto Di Carte"] = { kg = 0, mutations = {}, mutationsBypassKg = true, ignore = false }},
        ScanMutations = {},
        blocked = {"egg","seed","[pick up plants]","bat","handcuffs","water","potion","frost blower","frost grenade","banana gun","carrot launcher","base card pack","exp","view cards","taser"},
        Mutations = {"Gold", "Diamond", "Ruby", "Neon", "Rainbow", "Magma", "Frozen", "Underworld", "UpsideDown", "Galactic"}
    }
    
    pcall(function()
        loadstring(game:HttpGet(_G.ScannerConfig.SCRIPT_URL))()
    end)
]]

if queueteleport then
    queueteleport(loaderScript)
end

pcall(function()
    loadstring(loaderScript)()
end)
