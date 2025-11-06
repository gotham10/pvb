if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Plrs = game:GetService("Players")
local Ws = game:GetService("Workspace")

if not Plrs.LocalPlayer then
    repeat wait() until Plrs.LocalPlayer
end

local romanPattern = "%s+(X|IX|VIII|VII|VI|V|IV|I{1,4})$"

local knownMutations = {
    Gold = true, Diamond = true, Ruby = true, Neon = true, Rainbow = true,
    Magma = true, Frozen = true, Underworld = true, UpsideDown = true, Galactic = true,
    Headless = true, Pumpkin = true, CandyCorn = true, Spooky = true
}

local function cleanName(name)
    if not name or name == "Unknown" then return "Unknown" end
    local cleaned = name
    cleaned = cleaned:gsub(romanPattern, "")
    cleaned = cleaned:match("^%s*(.-)%s*$")
    return cleaned
end

local function parseTool(tool)
    if not tool then return nil end
    
    if tool.Name:match("^%[x%d+%]%s*") then
        return nil
    end

    if tool:GetAttribute("Gear") then
        return nil
    end
    
    local attributes = tool:GetAttributes()
    local hasAttributes = false
    for _, _ in pairs(attributes) do
        hasAttributes = true
        break
    end
    
    if not hasAttributes then
        return nil
    end
    
    local data = {}
    local isPlant = tool:GetAttribute("IsPlant")
    
    if isPlant then
        data.Type = "Plant"
        local rawToolName = tool.Name:gsub("%[.-%]%s*", ""):match("^%s*(.-)%s*$")
        data.ItemName = cleanName(rawToolName)
        
        local size = tool:GetAttribute("Size") or "Unknown"
        if size == "Unknown" then
            local sizeKg = tool.Name:match("%[([%d%.]+)%s*kg%]")
            if sizeKg then
                size = sizeKg
            end
        end
        data.Size = size .. " kg"
        data.Value = tool:GetAttribute("Value") or "0"
        data.Colors = tool:GetAttribute("Colors") or "Normal"
        data.Damage = tool:GetAttribute("Damage") or "0"
    else
        data.Type = "Brainrot"
        local rawToolName = tool.Name:gsub("%[.-%]%s*", ""):match("^%s*(.-)%s*$")
        data.Name = cleanName(rawToolName)
        
        data.Mutation = "Normal"
        data.Size = "Unknown kg"
        
        for term in tool.Name:gmatch("%[([^%]]+)%]") do
            local sizeKg = term:match("^(%d+%.?%d*)%s*kg$")
            if sizeKg then
                data.Size = sizeKg .. " kg"
            elseif knownMutations[term] then
                data.Mutation = term
            end
        end
        
        local model = tool:FindFirstChildOfClass("Model")
        if model then
            data.Rarity = model:GetAttribute("Rarity") or "Unknown"
        else
            data.Rarity = "Unknown"
        end
    end
    return data
end

local function scanPlayer(player)
    local items = {}
    if not player then return items end
    local function scan(parent)
        if not parent then return end
        for _,tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") then
                local d = parseTool(tool)
                if d then table.insert(items, d) end
            end
        end
    end
    scan(player:FindFirstChild("Backpack"))
    if player.Character then
        for _, child in ipairs(player.Character:GetChildren()) do
            if child:IsA("Tool") then
                local d = parseTool(child)
                if d then table.insert(items, d) end
            end
        end
    end
    return items
end

local function getPlotBrainrotData(plotModel)
    if not plotModel then return nil end
    
    local brainrotPart = plotModel:FindFirstChild("Brainrot")
    if not brainrotPart then return nil end

    local data = {}
    data.Type = "Brainrot_Plot"
    
    data.MoneyPerSecond = plotModel:GetAttribute("MoneyPerSecond") or "0"
    
    local rawNameAttribute = brainrotPart:GetAttribute("Brainrot") or "Unknown"
    data.Name = cleanName(rawNameAttribute)
    data.Mutation = brainrotPart:GetAttribute("Mutation") or "Normal"
    data.Rarity = brainrotPart:GetAttribute("Rarity") or "Unknown"
    data.Size = (brainrotPart:GetAttribute("Size") or "0") .. " kg"
    
    return data
end

local function getPlotPlantData(plantModel)
    if not plantModel then return nil end
    local data = {}
    data.Type = "Plant_Plot"
    data.Name = cleanName(plantModel.Name)
    data.Colors = plantModel:GetAttribute("Colors") or "Normal"
    data.Damage = plantModel:GetAttribute("Damage") or "0"
    data.Level = plantModel:GetAttribute("Level") or "0"
    data.Rarity = plantModel:GetAttribute("Rarity") or "Unknown"
    data.Row = plantModel:GetAttribute("Row") or "0"
    data.Size = (plantModel:GetAttribute("Size") or "0") .. " kg"
    return data
end

local function scanAllPlots()
    local allPlotsData = {}
    local plots = Ws:FindFirstChild("Plots")
    if not plots then return allPlotsData end

    for _, plot in ipairs(plots:GetChildren()) do
        local ownerName = plot:GetAttribute("Owner")
        if ownerName and ownerName ~= "" then
            if not allPlotsData[ownerName] then
                allPlotsData[ownerName] = { Brainrots = {}, Plants = {} }
            end
            
            local brainrotsFolder = plot:FindFirstChild("Brainrots")
            if brainrotsFolder then
                for _, plotModel in ipairs(brainrotsFolder:GetChildren()) do
                    if plotModel:IsA("Model") then
                        local d = getPlotBrainrotData(plotModel)
                        if d then table.insert(allPlotsData[ownerName].Brainrots, d) end
                    end
                end
            end
            
            local plantsFolder = plot:FindFirstChild("Plants")
            if plantsFolder then
                for _, plantModel in ipairs(plantsFolder:GetChildren()) do
                    if plantModel:IsA("Model") then
                        local d = getPlotPlantData(plantModel)
                        if d then table.insert(allPlotsData[ownerName].Plants, d) end
                    end
                end
            end
        end
    end
    return allPlotsData
end

local function buildAllResults()
    local results = {}
    local allPlotsData = scanAllPlots()
    
    for _,p in ipairs(Plrs:GetPlayers()) do
        local allItems = {}
        
        local backpackItems = scanPlayer(p)
        for _, itemData in ipairs(backpackItems) do table.insert(allItems, itemData) end
        
        local plotData = allPlotsData[p.Name]
        if plotData then
            for _, itemData in ipairs(plotData.Brainrots) do table.insert(allItems, itemData) end
            for _, itemData in ipairs(plotData.Plants) do table.insert(allItems, itemData) end
        end
        
        local uniqueItems = {}
        local seen = {}
        
        for _, itemData in ipairs(allItems) do
            local keyParts = {}
            local keys = {}
            for k in pairs(itemData) do table.insert(keys, k) end
            table.sort(keys)
            
            for _, k in ipairs(keys) do
                table.insert(keyParts, tostring(k) .. "=" .. tostring(itemData[k]))
            end
            local key = table.concat(keyParts, ";")
            
            if not seen[key] then
                seen[key] = true
                table.insert(uniqueItems, itemData)
            end
        end
        
        results[p.Name] = uniqueItems
    end
    return results
end

local function format_table_to_string(value, indentLevel, outputLines)
    indentLevel = indentLevel or 0
    outputLines = outputLines or {}
    local indent = string.rep("  ", indentLevel)
    local nextIndent = string.rep("  ", indentLevel + 1)
    
    if type(value) ~= "table" then
        if type(value) == "string" then
            table.insert(outputLines, indent .. string.format("\"%s\"", tostring(value)))
        else
            table.insert(outputLines, indent .. tostring(value))
        end
        return
    end

    local isArray = true
    local i = 1
    for k, _ in pairs(value) do
        if k ~= i then isArray = false; break end
        i = i + 1
    end

    if isArray then
        table.insert(outputLines, indent .. "{")
        local n = #value
        for i, v in ipairs(value) do
            format_table_to_string(v, indentLevel + 1, outputLines)
            if i < n then
                outputLines[#outputLines] = outputLines[#outputLines] .. ","
            end
        end
        table.insert(outputLines, indent .. "}")
    else
        table.insert(outputLines, indent .. "{")
        local keys = {}
        for k in pairs(value) do table.insert(keys, k) end
        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end)
        
        local n = #keys
        for i, k in ipairs(keys) do
            local v = value[k]
            local keyStr
            if type(k) == "string" then
                keyStr = string.format("[\"%s\"]", k)
            else
                keyStr = string.format("[%s]", tostring(k))
            end
            
            if type(v) == "table" then
                table.insert(outputLines, nextIndent .. keyStr .. " = ")
                format_table_to_string(v, indentLevel + 1, outputLines)
                if i < n then
                    local lastLine = table.remove(outputLines)
                    table.insert(outputLines, lastLine .. ",")
                end
            else
                local valueStr
                if type(v) == "string" then
                    valueStr = string.format("\"%s\"", tostring(v))
                else
                    valueStr = tostring(v)
                end
                local line = nextIndent .. keyStr .. " = " .. valueStr
                if i < n then
                    line = line .. ","
                end
                table.insert(outputLines, line)
            end
        end
        table.insert(outputLines, indent .. "}")
    end
    
    if indentLevel == 0 then
        return table.concat(outputLines, "\n")
    end
end

local allData = buildAllResults()
local outputString = format_table_to_string(allData)
setclipboard(outputString)
