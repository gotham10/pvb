local Players = game:GetService("Players")

local function analyzeBackpackPlants()
    local player = Players.LocalPlayer
    if not player then
        return
    end
    
    local backpack = player:WaitForChild("Backpack")
    if not backpack then
        return
    end

    local plantCounts = {}

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:GetAttribute("Plant") ~= nil then
            local plantName = tool.Name
            plantCounts[plantName] = (plantCounts[plantName] or 0) + 1
        end
    end

    local processedPlants = {}
    
    for plantName, count in pairs(plantCounts) do
        local weight, baseName = string.match(plantName, "^%[([%d%.]+)%s*kg%]%s*(.+)")
        local itemWeight = nil

        if weight and baseName then
            itemWeight = tonumber(weight)
        else
            baseName = plantName
        end
        
        if not processedPlants[baseName] then
            processedPlants[baseName] = { weighted = {}, unweightedCount = 0 }
        end
        
        if itemWeight then
            table.insert(processedPlants[baseName].weighted, { weight = itemWeight, count = count })
        else
            processedPlants[baseName].unweightedCount = processedPlants[baseName].unweightedCount + count
        end
    end

    local sortedBaseNames = {}
    for baseName in pairs(processedPlants) do
        table.insert(sortedBaseNames, baseName)
    end
    table.sort(sortedBaseNames)

    local reportLines = {}
    
    for _, baseName in ipairs(sortedBaseNames) do
        local data = processedPlants[baseName]
        
        table.sort(data.weighted, function(a, b)
            return a.weight > b.weight
        end)
        
        for _, item in ipairs(data.weighted) do
            local line = string.format("[%s kg] %s: %d", tostring(item.weight), baseName, item.count)
            table.insert(reportLines, line)
        end
        
        if data.unweightedCount > 0 then
            local line = string.format("%s: %d", baseName, data.unweightedCount)
            table.insert(reportLines, line)
        end
    end

    local finalReport
    local reportTitle = string.format("--- %s's Backpack Plant Report ---", player.Name)
    
    if #reportLines > 0 then
        finalReport = reportTitle .. "\n" .. table.concat(reportLines, "\n")
    else
        finalReport = string.format("No plants with the 'Plant' attribute found in %s's backpack.", player.Name)
    end
    
    print(finalReport)
    
    if setclipboard then
        setclipboard(finalReport)
        print("Report copied to clipboard.")
    end
end

local success, errorMessage = pcall(analyzeBackpackPlants)
if not success then
    print("Error while analyzing backpack:", errorMessage)
end
