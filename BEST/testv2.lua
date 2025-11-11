local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local itemConfig = {
    ["Brainrot"] = {},
    ["Plant"] = {}
}

local ignoreRarities = {
    ["Rare"] = true,
    ["Epic"] = true,
    ["Legendary"] = true,
    ["Mythic"] = true,
    ["Godly"] = true,
}

local playerGui = localPlayer:WaitForChild("PlayerGui")
local playerBackpack = localPlayer:WaitForChild("Backpack")
local playerCharacter = localPlayer.Character

local backpackGui = playerGui:WaitForChild("BackpackGui")
local backpackFrame = backpackGui:WaitForChild("Backpack")

local hotbar = backpackFrame:WaitForChild("Hotbar")
local inventory = backpackFrame:WaitForChild("Inventory")
local scrollingFrame = inventory:WaitForChild("ScrollingFrame")
local uiGridFrame = scrollingFrame:WaitForChild("UIGridFrame")

local favoriteRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FavoriteItem")

local toolMap = {}

local function scanTool(tool)
    if tool:IsA("Tool") then
        local toolId = tool:GetAttribute("ID")
        if toolId then
            toolMap[toolId] = tool
        end
    end
end

for _, tool in ipairs(playerBackpack:GetChildren()) do
    scanTool(tool)
end

if playerCharacter then
    for _, tool in ipairs(playerCharacter:GetChildren()) do
        scanTool(tool)
    end
end

playerBackpack.ChildAdded:Connect(scanTool)
if playerCharacter then
    playerCharacter.ChildAdded:Connect(scanTool)
end

playerBackpack.ChildRemoved:Connect(function(tool)
    if tool:IsA("Tool") then
        local toolId = tool:GetAttribute("ID")
        if toolId and toolMap[toolId] then
            toolMap[toolId] = nil
        end
    end
end)
if playerCharacter then
    playerCharacter.ChildRemoved:Connect(function(tool)
        if tool:IsA("Tool") then
            local toolId = tool:GetAttribute("ID")
            if toolId and toolMap[toolId] then
                toolMap[toolId] = nil
            end
        end
    end)
end

local function processGuiItem(guiItem)
    local heartIcon = guiItem:FindFirstChild("HeartIcon")
    local isGuiHearted = (heartIcon ~= nil)
    
    local toolId = guiItem:GetAttribute("ID")
    
    if not toolId then return end

    local toolObject = toolMap[toolId]
    
    if not toolObject then return end
    
    local attributeHolder = toolObject:FindFirstChildWhichIsA("Model")
    if not attributeHolder then
        attributeHolder = toolObject
    end
    
    local isBoss = attributeHolder:GetAttribute("Boss")
    local rarity = attributeHolder:GetAttribute("Rarity")
    local plantName = attributeHolder:GetAttribute("IsPlant")
    local brainrotName = attributeHolder:GetAttribute("Brainrot")
    local toolName = toolObject.Name

    if isBoss then
        if isGuiHearted then
            favoriteRemote:FireServer(toolId)
        end
        return
    end
    
    if plantName then
        if not isGuiHearted then
            favoriteRemote:FireServer(toolId)
        end
        return
    end

    local weightStr = string.match(toolName, "%[([%d%.]+)%s*kg%]")
    local weightNum = nil
    if weightStr then
        weightNum = tonumber(weightStr)
    end
    
    if brainrotName or weightNum then
        if weightNum and weightNum > 100 then
            if not isGuiHearted then
                favoriteRemote:FireServer(toolId)
            end
        else
            if rarity and ignoreRarities[rarity] then
                if isGuiHearted then
                    favoriteRemote:FireServer(toolId)
                end
            end
        end
        
        return
    end

end

for _, item in ipairs(hotbar:GetChildren()) do
    if item:IsA("TextButton") then
        processGuiItem(item)
    end
end

for _, item in ipairs(uiGridFrame:GetChildren()) do
    if not item:IsA("Layout") and not item:IsA("UIs") then
        processGuiItem(item)
    end
end
