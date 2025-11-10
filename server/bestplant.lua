local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plotsFolder = Workspace:WaitForChild("Plots")
local plantAssetsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Plants")

local allData = {}

local plantRarity = {
	["Starfruit"] = 1,
	["King Limone"] = 2,
	["Mango"] = 3,
	["Shroombino"] = 4,
	["Tomatrio"] = 5,
	["Mr Carrot"] = 6,
	["Carnivorous Plant"] = 7,
	["Cocotank"] = 8,
	["Grape"] = 9,
	["Watermelon"] = 10,
	["Eggplant"] = 11,
	["Dragon Fruit"] = 12,
	["Pumpkin"] = 13,
	["Sunflower"] = 14,
	["Strawberry"] = 15,
	["Cactus"] = 16,
	["Pine-a-Painter"] = 4,
	["Copuccino"] = 9,
	["Aubie"] = 12,
	["Sunzio"] = 14,
	["Don Fragola"] = 15,
	["Commando Apple"] = 7,
	["Tomade Torelli"] = 5,
	["Troll Mango"] = 3,
	["Skullflower"] = 1,
	["Hallow Tree"] = 2,
	["Sinister Grape"] = 9,
	["Cursed Pumpkin"] = 13,
	["Biohazelino"] = 10,
	["Tropic Sparino"] = 8,
}
local defaultPlantRank = 999

local colorBoosts = {
    Normal = 1,
    Gold = 2,
    Diamond = 3,
    Ruby = 4,
    Neon = 5,
    Frozen = 4,
    Electrified = 2,
    Scorched = 2,
    Foggy = 2,
    Rainbow = 6,
    Galactic = 8,
    UpsideDown = 6,
    Magma = 6.5,
    Underworld = 6.5,
    Headless = 8.5,
    Pumpkin = 7.5,
    CandyCorn = 4.25
}

local mutationBaseNames = {"Diamond", "Electrified", "Foggy", "Frozen", "Gold", "Neon", "Ruby", "Scorched"}
table.sort(mutationBaseNames)

local function calculateBoost(boostA, boostB)
    local bA = boostA + 1
    local bB = boostB + 1
    local newBoost = (bA + bB) / 1.9
    local maxB = math.max(bA, bB)
    if newBoost <= maxB then
        newBoost = maxB + 0.25
    end
    return math.floor(newBoost * 20 + 0.5) / 20
end

for i = 1, #mutationBaseNames do
    for j = i + 1, #mutationBaseNames do
        local name1 = mutationBaseNames[i]
        local name2 = mutationBaseNames[j]
        local boost1 = colorBoosts[name1]
        local boost2 = colorBoosts[name2]
        
        local mixedName = name1 .. name2
        local mixedBoost = calculateBoost(boost1, boost2)
        colorBoosts[mixedName] = mixedBoost
    end
end

local sortedColorList = {}
for name, boost in pairs(colorBoosts) do
    table.insert(sortedColorList, {Name = name, Boost = boost})
end

table.sort(sortedColorList, function(a, b)
    if a.Boost ~= b.Boost then
        return a.Boost > b.Boost
    end
    return a.Name < b.Name
end)

local colorRarity = {}
for i, data in ipairs(sortedColorList) do
    colorRarity[data.Name] = i
end

local defaultColorRank = (colorRarity["Normal"] or #sortedColorList) + 1

local function getPlantRank(name)
	if not name then return defaultPlantRank end
	if plantRarity[name] then return plantRarity[name] end
	for key, rank in pairs(plantRarity) do
		if string.find(name, key) then
			return rank
		end
	end
	return defaultPlantRank
end

local function getColorRank(colorsStr)
	if not colorsStr then
		return defaultColorRank
	end
	local rank = colorRarity[colorsStr]
	if rank then
		return rank
	else
		return defaultColorRank
	end
end

local function formatValue(value)
	if type(value) == "string" then
		return '"' .. value .. '"'
	elseif type(value) == "number" then
		return tostring(value)
	elseif value == nil then
		return "null"
	else
		return "null"
	end
end

local function processItem(item, isModel, playerName, location)
	local plantName
	local damage, cooldown, size, level, colors
	
	if isModel then
		plantName = item.Name
		damage = tonumber(item:GetAttribute("Damage") or 0)
		cooldown = tonumber(item:GetAttribute("Cooldown") or 0)
		size = tonumber(item:GetAttribute("Size") or 0)
		level = tonumber(item:GetAttribute("Level") or 0)
		colors = item:GetAttribute("Colors") or "Normal"
	else
		plantName = item:GetAttribute("IsPlant")
		if not plantName then return end
		
		damage = tonumber(item:GetAttribute("Damage") or 0)
		size = tonumber(item:GetAttribute("Size") or 0)
		level = nil
		colors = item:GetAttribute("Colors") or "Normal"
		
		local plantModel = plantAssetsFolder:FindFirstChild(plantName)
		if plantModel and plantName ~= "Hedge" then
			cooldown = tonumber(plantModel:GetAttribute("Cooldown") or 0)
		else
			cooldown = 0
		end
	end
	
	local data = {
		Owner = playerName,
		Location = location,
		Name = plantName,
		Colors = colors,
		Damage = damage,
		Size = size,
		Level = level,
		Cooldown = cooldown,
		PlantRank = getPlantRank(plantName),
		ColorRank = getColorRank(colors)
	}
	
	if cooldown > 0 then
		data.PerSecond = math.floor(damage / cooldown)
		data.EffectiveDPS = data.PerSecond
	else
		data.EffectiveDPS = damage
	end
	
	table.insert(allData, data)
end

for _, player in ipairs(Players:GetPlayers()) do
	local playerName = player.Name
	local backpack = player:FindFirstChild("Backpack")
	
	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") and item:GetAttribute("IsPlant") then
				processItem(item, false, playerName, "Backpack")
			end
		end
	end

	for i = 1, 5 do
		local plot = plotsFolder:FindFirstChild(tostring(i))
		if plot and plot:GetAttribute("Owner") == playerName then
			local plants = plot:FindFirstChild("Plants")
			if plants then
				for _, plant in ipairs(plants:GetChildren()) do
					if plant:IsA("Model") then
						processItem(plant, true, playerName, "Plot")
					end
				end
			end
		end
	end
end

table.sort(allData, function(a, b)
	if a.EffectiveDPS ~= b.EffectiveDPS then
		return a.EffectiveDPS > b.EffectiveDPS
	end
	if a.PlantRank ~= b.PlantRank then
		return a.PlantRank < b.PlantRank
	end
	if a.ColorRank ~= b.ColorRank then
		return a.ColorRank < b.ColorRank
	end
	return a.Damage > b.Damage
end)

if #allData > 0 then
	local outputLines = {"["}
	for i, data in ipairs(allData) do
		table.insert(outputLines, "\t{")
		
		local lines = {
			string.format("\t\t\"Owner\": %s", formatValue(data.Owner)),
			string.format("\t\t\"Location\": %s", formatValue(data.Location)),
			string.format("\t\t\"Name\": %s", formatValue(data.Name)),
			string.format("\t\t\"Colors\": %s", formatValue(data.Colors)),
			string.format("\t\t\"Damage\": %s", formatValue(data.Damage)),
			string.format("\t\t\"Size\": %s", formatValue(data.Size))
		}
		
		if data.Level ~= nil then
			table.insert(lines, string.format("\t\t\"Level\": %s", formatValue(data.Level)))
		end
		
		if data.PerSecond then
			table.insert(lines, string.format("\t\t\"Cooldown\": %s", formatValue(data.Cooldown)))
			table.insert(lines, string.format("\t\t\"PerSecond\": %s", formatValue(data.PerSecond)))
		else
			table.insert(lines, string.format("\t\t\"Cooldown\": %s", formatValue(data.Cooldown)))
		end
		
		for j = 1, #lines - 1 do
			table.insert(outputLines, lines[j] .. ",")
		end
		table.insert(outputLines, lines[#lines])
		
		if i < #allData then
			table.insert(outputLines, "\t},")
		else
			table.insert(outputLines, "\t}")
		end
	end
	table.insert(outputLines, "]")
	setclipboard(table.concat(outputLines, "\n"))
	print("Copied all sorted plant data to clipboard.")
else
	print("No plant data found.")
end
