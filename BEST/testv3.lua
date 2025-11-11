local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local Config = {
    MaxBrainrotWeight = 100,
    IgnoreRarities = {"Rare", "Epic", "Legendary", "Mythic", "Godly"},
    ItemConfig = {["Brainrot"] = {},["Plant"] = {}}
}

local IgnoreRaritiesSet = {}
for _, rarityName in ipairs(Config.IgnoreRarities) do
    IgnoreRaritiesSet[rarityName] = true
end

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
    local isGuiHearted = (heartIcon ~= nil and heartIcon.Visible == true)
    
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
    
    if weightNum and weightNum > Config.MaxBrainrotWeight then
        if not isGuiHearted then
            favoriteRemote:FireServer(toolId)
        end
        return
    end

    if rarity and IgnoreRaritiesSet[rarity] then
        if isGuiHearted then
            favoriteRemote:FireServer(toolId)
        end
    else
        if not isGuiHearted then
            favoriteRemote:FireServer(toolId)
        end
    end
end

local function setupItem(item)
    if not (item:IsA("TextButton") or (not item:IsA("Layout") and not item:IsA("UIs"))) then
        return
    end
    
    local function connectVisibilitySignal(heartIcon)
        heartIcon:GetPropertyChangedSignal("Visible"):Connect(function()
            processGuiItem(item)
        end)
    end

    item.ChildAdded:Connect(function(child)
        if child.Name == "HeartIcon" then
            processGuiItem(item)
            connectVisibilitySignal(child)
        end
    end)
    
    item.ChildRemoved:Connect(function(child)
        if child.Name == "HeartIcon" then
            processGuiItem(item)
        end
    end)
    
    local existingHeartIcon = item:FindFirstChild("HeartIcon")
    if existingHeartIcon then
        connectVisibilitySignal(existingHeartIcon)
    end

    processGuiItem(item)
end

for _, item in ipairs(hotbar:GetChildren()) do
    setupItem(item)
end

for _, item in ipairs(uiGridFrame:GetChildren()) do
    setupItem(item)
end

hotbar.ChildAdded:Connect(setupItem)
uiGridFrame.ChildAdded:Connect(setupItem)
