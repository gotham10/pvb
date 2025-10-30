_G.ScannerConfig = {
    NotSameServersFile = "NotSameServers.json",
    AutoHopFile = "ScannerAutoHop.json",
    HIDE_MY_DATA = true,
    MAX_KG_THRESHOLD_PLANT = 10,
    MAX_KG_THRESHOLD_BRAINROT = 100,
    ScanPlants = {
    ["Troll Mango"] = { kg = 0, mutations = {Diamond = 0, Ruby = 0, Neon = 0, Frozen = 0}, mutationsBypassKg = true, ignore = false },
    ["Commando Apple"] = { kg = 0, mutations = {Diamond = 0, Ruby = 0, Neon = 0, Frozen = 0}, mutationsBypassKg = true, ignore = false },
    ["King Limone"] = { kg = 3, mutations = {Diamond = 0, Ruby = 0, Neon = 0, Frozen = 0}, mutationsBypassKg = true, ignore = false },
    ["Aubie"] = { kg = 100, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Cactus"] = { kg = 100, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Carnivorous Plant"] = { kg = 20, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Cocotank"] = { kg = 20, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Copuccino"] = { kg = 10, mutations = {Diamond = 5, Ruby = 3, Neon = 3, Frozen = 0}, mutationsBypassKg = true, ignore = false },
    ["Don Fragola"] = { kg = 100, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Dragon Fruit"] = { kg = 100, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Eggplant"] = { kg = 75, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Grape"] = { kg = 50, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Mango"] = { kg = 6, mutations = {Diamond = 2, Ruby = 0, Neon = 0, Frozen = 0}, mutationsBypassKg = true, ignore = false },
    ["Mr Carrot"] = { kg = 10, mutations = {Diamond = 5, Ruby = 3, Neon = 3, Frozen = 3}, mutationsBypassKg = true, ignore = false },
    ["Pine-a-Painter"] = { kg = 10, mutations = {Diamond = 0, Ruby = 0, Neon = 0, Frozen = 0}, mutationsBypassKg = true, ignore = false },
    ["Pumpkin"] = { kg = 100, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Shroombino"] = { kg = 10, mutations = {Diamond = 3, Ruby = 3, Neon = 0, Frozen = 0}, mutationsBypassKg = true, ignore = false },
    ["Strawberry"] = { kg = 100, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Sunflower"] = { kg = 100, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Sunzio"] = { kg = 100, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Tomade Torelli"] = { kg = 15, mutations = {}, mutationsBypassKg = false, ignore = false },
    ["Tomatrio"] = { kg = 15, mutations = {Diamond = 5, Ruby = 3, Neon = 3, Frozen = 0}, mutationsBypassKg = true, ignore = false },
    ["Watermelon"] = { kg = 50, mutations = {}, mutationsBypassKg = false, ignore = false }
},
    ScanBrainrots = {
        ["Pacchetto Di Carte"] = { kg = 0, mutations = {}, mutationsBypassKg = false, ignore = false }
    },
    ScanMutations = {},
    blocked = {"egg","seed","[pick up plants]","bat","handcuffs","water","potion","frost blower","frost grenade","banana gun","carrot launcher","base card pack","exp","view cards","taser"},
    Mutations = {"Gold", "Diamond", "Ruby", "Neon", "Rainbow", "Magma", "Frozen", "Underworld", "UpsideDown", "Galactic"}
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/gotham10/pvb/refs/heads/main/alldata/test5.lua"))()
