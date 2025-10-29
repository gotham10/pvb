local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local blocked = {"egg","seed","[pick up plants]","bat","handcuffs","water","potion","frost blower","frost grenade","banana gun","carrot launcher","base card pack","exp","view cards","taser"}

local knownMutations = {"Gold", "Diamond", "Ruby", "Neon", "Rainbow", "Magma", "Frozen", "Underworld", "UpsideDown", "Galactic"}
local mutationMap = {}
for _,m in ipairs(knownMutations) do mutationMap[m:lower()] = m end

local romanNumeralPattern = "%s+(IX|IV|V|V?I{1,3})$"
local function cleanName(name)
    if not name or name == "Unknown" then return "Unknown" end
    local cleaned = name
    cleaned = cleaned:gsub("%[.-%]%s*", "")
    cleaned = cleaned:gsub(romanNumeralPattern, "")
    cleaned = cleaned:match("^%s*(.-)%s*$")
    return cleaned
end

local function shouldSkip(name)
    local lower = name:lower()
    for _,word in ipairs(blocked) do
        if lower:find(word, 1, true) then
            return true
        end
    end
    return false
end

local function getToolData(tool)
    if shouldSkip(tool.Name) then return nil end
    
    local isPlant = tool:GetAttribute("IsPlant")
    if isPlant then
        local data = {}
        data.Type = "Plant"
        data.Name = cleanName(tool:GetAttribute("ItemName") or tool.Name)
        data.Size = tool:GetAttribute("Size") or "Unknown"
        data.Value = tool:GetAttribute("Value") or "Unknown"
        data.Colors = tool:GetAttribute("Colors") or "Unknown"
        data.Damage = tool:GetAttribute("Damage") or "Unknown"
        return data
    end
    
    local rawName = tool.Name
    local data = {}
    data.Type = "Brainrot"
    
    local weight = "Unknown"
    for content in rawName:gmatch("%[([^%]]-)%]") do
          local kgMatch = content:match("([%d%.]+%s*kg)")
          if kgMatch then
              weight = kgMatch
              break
          end
    end
    
    if weight == "Unknown" then
        local sizeAttr = tool:GetAttribute("Size")
        if sizeAttr then
            weight = tostring(sizeAttr)
        end
    end
    data.Weight = weight

    data.Name = cleanName(rawName)

    local mutationAttrString = tool:GetAttribute("MutationString")
    local mutationAttr = tool:GetAttribute("Mutation")
    local finalMutation = "Unknown"

    if mutationAttrString and mutationAttrString ~= "Unknown" then
        local firstWord = tostring(mutationAttrString):match("^([^%s]+)")
        if firstWord and mutationMap[firstWord:lower()] then
            finalMutation = mutationMap[firstWord:lower()]
        end
    end
    
    if finalMutation == "Unknown" and mutationAttr and mutationAttr ~= "Unknown" then
        local firstWord = tostring(mutationAttr):match("^([^%s]+)")
        if firstWord and mutationMap[firstWord:lower()] then
            finalMutation = mutationMap[firstWord:lower()]
        end
    end

    if finalMutation == "Unknown" then
        local firstBracketContent = rawName:match("%[([^%]]-)%]")
        if firstBracketContent and mutationMap[firstBracketContent:lower()] then
            finalMutation = mutationMap[firstBracketContent:lower()]
        end
    end
    
    if finalMutation == "Unknown" then
        finalMutation = "Normal"
    end
    data.Mutation = finalMutation
    
    if tool:FindFirstChildOfClass("Model") then
        local model = tool:FindFirstChildOfClass("Model")
        data.Rarity = model:GetAttribute("Rarity") or "Unknown"
    else
        data.Rarity = "Unknown"
    end
    
    return data
end

local function scanPlayer(player)
    local items = {}
    local function scan(container)
        if not container then return end
        for _,tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local d = getToolData(tool)
                if d then table.insert(items, d) end
            end
        end
    end
    scan(player:FindFirstChild("Backpack"))
    if player.Character then
        for _, child in ipairs(player.Character:GetChildren()) do
            if child:IsA("Tool") then
                local d = getToolData(child)
                if d then table.insert(items, d) end
            end
        end
    end
    return items
end

local function getPlotBrainrotData(plotModel)
    local data = {}
    data.Type = "Brainrot"
    local brainrotPart = plotModel:FindFirstChild("Brainrot")
    if not brainrotPart then return nil end

    local rawName = brainrotPart:GetAttribute("Brainrot") or "Unknown"
    data.Name = cleanName(rawName)

    local mutationAttrString = brainrotPart:GetAttribute("MutationString")
    local mutationAttr = brainrotPart:GetAttribute("Mutation")
    local finalMutation = "Unknown"
    
    if mutationAttr and mutationAttr ~= "Unknown" then
         finalMutation = mutationAttr
    elseif mutationAttrString and mutationAttrString ~= "Unknown" then
         finalMutation = mutationAttrString
    end

    if finalMutation == "Unknown" then
        finalMutation = "Normal"
    end
    data.Mutation = finalMutation

    data.Rarity = brainrotPart:GetAttribute("Rarity") or "Unknown"
    data.Size = brainrotPart:GetAttribute("Size") or "Unknown"

    local platformUI = brainrotPart:FindFirstChild("PlatformUI")
    if platformUI then
        local moneyLabel = platformUI:FindFirstChild("Money")
        if moneyLabel and moneyLabel:IsA("TextLabel") then
            local text = moneyLabel.Text
            local mps = text:match("%((%$.-/s)")
            data.MoneyPerSecond = mps or "Unknown"
        else
            data.MoneyPerSecond = "Unknown"
        end
    else
        data.MoneyPerSecond = "Unknown"
    end
    return data
end

local function scanPlotBrainrots(player)
    local items = {}
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return items end

    for _, plot in ipairs(plots:GetChildren()) do
        local owner = plot:GetAttribute("Owner")
        if owner and owner == player.Name then
            local brainrotsFolder = plot:FindFirstChild("Brainrots")
            if brainrotsFolder then
                for _, plotModel in ipairs(brainrotsFolder:GetChildren()) do
                    if plotModel:IsA("Model") then
                        local d = getPlotBrainrotData(plotModel)
                        if d then table.insert(items, d) end
                    end
                end
            end
            break
        end
    end
    return items
end

local function getPlotPlantData(plantModel)
    local data = {}
    data.Type = "Plant"
    data.Name = cleanName(plantModel.Name)
    data.Colors = plantModel:GetAttribute("Colors") or "Unknown"
    data.Damage = plantModel:GetAttribute("Damage") or "Unknown"
    data.Level = plantModel:GetAttribute("Level") or "Unknown"
    data.Rarity = plantModel:GetAttribute("Rarity") or "Unknown"
    data.Row = plantModel:GetAttribute("Row") or "Unknown"
    data.Size = plantModel:GetAttribute("Size") or "Unknown"
    return data
end

local function scanPlotPlants(player)
    local items = {}
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return items end

    for _, plot in ipairs(plots:GetChildren()) do
        local owner = plot:GetAttribute("Owner")
        if owner and owner == player.Name then
            local plantsFolder = plot:FindFirstChild("Plants")
            if plantsFolder then
                for _, plantModel in ipairs(plantsFolder:GetChildren()) do
                    if plantModel:IsA("Model") then
                        local d = getPlotPlantData(plantModel)
                        if d then table.insert(items, d) end
                    end
                end
            end
            break
        end
    end
    return items
end

local results = {}
for _,p in ipairs(Players:GetPlayers()) do
    local allItems = {}
    local backpackItems = scanPlayer(p)
    for _, itemData in ipairs(backpackItems) do
        table.insert(allItems, itemData)
    end
    
    local plotBrainrots = scanPlotBrainrots(p)
    for _, itemData in ipairs(plotBrainrots) do
        table.insert(allItems, itemData)
    end
    
    local plotPlants = scanPlotPlants(p)
    for _, itemData in ipairs(plotPlants) do
        table.insert(allItems, itemData)
    end
    
    local playerResults = {
        Brainrots = {
            Items = {}
        },
        Plants = {
            Items = {}
        }
    }
    
    for _, itemData in ipairs(allItems) do
        local itemType = itemData.Type
        local itemName = itemData.Name or "Unknown"
        local itemRarity = itemData.Rarity or "Unknown"
        
        local categoryResults
        local itemSummaryKey
        local itemSummaryValue
        
        if itemType == "Plant" then
            categoryResults = playerResults.Plants
            itemSummaryKey = "ColorCounts"
            itemSummaryValue = itemData.Colors or "Unknown"
        else
            categoryResults = playerResults.Brainrots
            itemSummaryKey = "MutationCounts"
            itemSummaryValue = itemData.Mutation or "Normal"
        end
        
        local itemTable = categoryResults.Items
        if not itemTable[itemName] then
            itemTable[itemName] = {
                Instances = {},
                Summary = {
                    TotalCount = 0
                }
            }
            itemTable[itemName].Summary[itemSummaryKey] = {}
        end
        
        local entry = itemTable[itemName]
        
        entry.Summary.TotalCount = entry.Summary.TotalCount + 1
        entry.Summary[itemSummaryKey][itemSummaryValue] = (entry.Summary[itemSummaryKey][itemSummaryValue] or 0) + 1
        
        local dataForJson = {}
        for k, v in pairs(itemData) do
            if k ~= "Name" and k ~= "Type" then
                dataForJson[k] = v
            end
        end
        
        table.insert(entry.Instances, dataForJson)
    end
    
    results[p.Name] = playerResults
end

local success, jsonOutput = pcall(HttpService.JSONEncode, HttpService, results)
if not success then
    print("Failed to encode JSON data:", jsonOutput)
    return
end

local FIREBASE_URL = "https://pvballgamedata-default-rtdb.firebaseio.com/playerdata.json"

local requestData = {
    Url = FIREBASE_URL,
    Method = "PUT",
    Body = jsonOutput,
    Headers = {
        ["Content-Type"] = "application/json"
    }
}

pcall(function()
    request(requestData)
end)
