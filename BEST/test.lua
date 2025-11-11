local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local itemConfig = {
    ["Brainrot"] = {
        ["Garamararam"] = {
            ["Normal"] = false,
            ["Gold"] = true,
            ["Diamond"] = false,
            ["Neon"] = false,
            ["Rainbow"] = false,
            ["Galactic"] = false,
            ["Frozen"] = false,
            ["UpsideDown"] = false,
            ["Underworld"] = false,
            ["Magma"] = false,
            ["Ruby"] = false,
            ["Headless"] = false,
            ["Pumpkin"] = false,
            ["CandyCorn"] = false,
            ["Electrified"] = false,
            ["Scorched"] = false,
            ["Foggy"] = false,
            ["DiamondNeon"] = false,
            ["ElectrifiedFoggy"] = false,
            ["GoldRuby"] = false,
            ["FoggyRuby"] = false,
            ["ElectrifiedRuby"] = false,
            ["DiamondFrozen"] = false,
            ["DiamondFoggy"] = false,
            ["GoldNeon"] = false,
            ["ElectrifiedNeon"] = false,
            ["NeonScorched"] = false,
            ["FrozenRuby"] = false,
            ["DiamondRuby"] = false,
            ["NeonRuby"] = false,
            ["FoggyFrozen"] = false,
            ["ElectrifiedGold"] = false,
            ["FoggyNeon"] = false,
            ["RubyScorched"] = false,
            ["DiamondElectrified"] = false,
            ["FrozenScorched"] = false,
            ["GoldScorched"] = false,
            ["ElectrifiedFrozen"] = false,
            ["FoggyGold"] = false,
            ["DiamondScorched"] = false,
            ["FrozenNeon"] = false,
            ["DiamondGold"] = false,
            ["FoggyScorched"] = false,
            ["FrozenGold"] = false,
            ["ElectrifiedScorched"] = false,
            ["FrozenPumpkin"] = false,
            ["CandyCornRuby"] = false,
            ["UnderworldUpsideDown"] = false,
            ["GalacticUnderworld"] = false,
            ["NeonPumpkin"] = false,
            ["FrozenUnderworld"] = false,
            ["CandyCornHeadless"] = false,
            ["DiamondRainbow"] = false,
            ["DiamondMagma"] = false,
            ["GalacticMagma"] = false,
            ["GalacticNeon"] = false,
            ["CandyCornNeon"] = false,
            ["DiamondUnderworld"] = false,
            ["RainbowRuby"] = false,
            ["DiamondGalactic"] = false,
            ["FrozenMagma"] = false,
            ["GoldPumpkin"] = false,
            ["HeadlessUpsideDown"] = false,
            ["GoldUpsideDown"] = false,
            ["GalacticGold"] = false,
            ["NeonUnderworld"] = false,
            ["CandyCornUnderworld"] = false,
            ["PumpkinRuby"] = false,
            ["GalacticRuby"] = false,
            ["DiamondUpsideDown"] = false,
            ["HeadlessMagma"] = false,
            ["RainbowUnderworld"] = false,
            ["MagmaUnderworld"] = false,
            ["HeadlessRainbow"] = false,
            ["MagmaRuby"] = false,
            ["HeadlessPumpkin"] = false,
            ["GalacticRainbow"] = false,
            ["CandyCornUpsideDown"] = false,
            ["MagmaNeon"] = false,
            ["GoldUnderworld"] = false,
            ["GalacticUpsideDown"] = false,
            ["FrozenHeadless"] = false,
            ["GoldHeadless"] = false,
            ["CandyCornFrozen"] = false,
            ["FrozenRainbow"] = false,
            ["GoldMagma"] = false,
            ["MagmaPumpkin"] = false,
            ["CandyCornDiamond"] = false,
            ["NeonUpsideDown"] = false,
            ["MagmaRainbow"] = false,
            ["RainbowUpsideDown"] = false,
            ["MagmaUpsideDown"] = false,
            ["PumpkinUnderworld"] = false,
            ["FrozenUpsideDown"] = false,
            ["CandyCornMagma"] = false,
            ["PumpkinRainbow"] = false,
            ["RubyUpsideDown"] = false,
            ["CandyCornPumpkin"] = false,
            ["NeonRainbow"] = false,
            ["FrozenGalactic"] = false,
            ["CandyCornGalactic"] = false,
            ["PumpkinUpsideDown"] = false,
            ["RubyUnderworld"] = false,
            ["GalacticPumpkin"] = false,
            ["DiamondHeadless"] = false,
            ["HeadlessUnderworld"] = false,
            ["HeadlessRuby"] = false,
            ["DiamondPumpkin"] = false,
            ["HeadlessNeon"] = false,
            ["GoldRainbow"] = false,
            ["CandyCornRainbow"] = false,
            ["GalacticHeadless"] = false,
            ["CandyCornGold"] = false
        }
    },
    ["Plant"] = {
        ["Cursed Pumpkin"] = {
            ["Normal"] = false,
            ["Gold"] = false,
            ["Diamond"] = false,
            ["Neon"] = false,
            ["Rainbow"] = false,
            ["Galactic"] = false,
            ["Frozen"] = false,
            ["UpsideDown"] = false,
            ["Underworld"] = false,
            ["Magma"] = false,
            ["Ruby"] = false,
            ["Headless"] = false,
            ["Pumpkin"] = false,
            ["CandyCorn"] = false,
            ["Electrified"] = false,
            ["Scorched"] = false,
            ["Foggy"] = false,
            ["DiamondNeon"] = false,
            ["ElectrifiedFoggy"] = false,
            ["GoldRuby"] = false,
            ["FoggyRuby"] = false,
            ["ElectrifiedRuby"] = false,
            ["DiamondFrozen"] = false,
            ["DiamondFoggy"] = false,
            ["GoldNeon"] = false,
            ["ElectrifiedNeon"] = false,
            ["NeonScorched"] = false,
            ["FrozenRuby"] = false,
            ["DiamondRuby"] = false,
            ["NeonRuby"] = false,
            ["FoggyFrozen"] = false,
            ["ElectrifiedGold"] = false,
            ["FoggyNeon"] = false,
            ["RubyScorched"] = false,
            ["DiamondElectrified"] = false,
            ["FrozenScorched"] = false,
            ["GoldScorched"] = false,
            ["ElectrifiedFrozen"] = false,
            ["FoggyGold"] = false,
            ["DiamondScorched"] = false,
            ["FrozenNeon"] = false,
            ["DiamondGold"] = false,
            ["FoggyScorched"] = false,
            ["FrozenGold"] = false,
            ["ElectrifiedScorched"] = false,
            ["FrozenPumpkin"] = false,
            ["CandyCornRuby"] = false,
            ["UnderworldUpsideDown"] = false,
            ["GalacticUnderworld"] = false,
            ["NeonPumpkin"] = false,
            ["FrozenUnderworld"] = false,
            ["CandyCornHeadless"] = false,
            ["DiamondRainbow"] = false,
            ["DiamondMagma"] = false,
            ["GalacticMagma"] = false,
            ["GalacticNeon"] = false,
            ["CandyCornNeon"] = false,
            ["DiamondUnderworld"] = false,
            ["RainbowRuby"] = false,
            ["DiamondGalactic"] = false,
            ["FrozenMagma"] = false,
            ["GoldPumpkin"] = false,
            ["HeadlessUpsideDown"] = false,
            ["GoldUpsideDown"] = false,
            ["GalacticGold"] = false,
            ["NeonUnderworld"] = false,
            ["CandyCornUnderworld"] = false,
            ["PumpkinRuby"] = false,
            ["GalacticRuby"] = false,
            ["DiamondUpsideDown"] = false,
            ["HeadlessMagma"] = false,
            ["RainbowUnderworld"] = false,
            ["MagmaUnderworld"] = false,
            ["HeadlessRainbow"] = false,
            ["MagmaRuby"] = false,
            ["HeadlessPumpkin"] = false,
            ["GalacticRainbow"] = false,
            ["CandyCornUpsideDown"] = false,
            ["MagmaNeon"] = false,
            ["GoldUnderworld"] = false,
            ["GalacticUpsideDown"] = false,
            ["FrozenHeadless"] = false,
            ["GoldHeadless"] = false,
            ["CandyCornFrozen"] = false,
            ["FrozenRainbow"] = false,
            ["GoldMagma"] = false,
            ["MagmaPumpkin"] = false,
            ["CandyCornDiamond"] = false,
            ["NeonUpsideDown"] = false,
            ["MagmaRainbow"] = false,
            ["RainbowUpsideDown"] = false,
            ["MagmaUpsideDown"] = false,
            ["PumpkinUnderworld"] = false,
            ["FrozenUpsideDown"] = false,
            ["CandyCornMagma"] = false,
            ["PumpkinRainbow"] = false,
            ["RubyUpsideDown"] = false,
            ["CandyCornPumpkin"] = false,
            ["NeonRainbow"] = false,
            ["FrozenGalactic"] = false,
            ["CandyCornGalactic"] = false,
            ["PumpkinUpsideDown"] = false,
            ["RubyUnderworld"] = false,
            ["GalacticPumpkin"] = false,
            ["DiamondHeadless"] = false,
            ["HeadlessUnderworld"] = false,
            ["HeadlessRuby"] = false,
            ["DiamondPumpkin"] = false,
            ["HeadlessNeon"] = false,
            ["GoldRainbow"] = false,
            ["CandyCornRainbow"] = false,
            ["GalacticHeadless"] = false,
            ["CandyCornGold"] = false
        }
    }
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
    
    if isBoss or (rarity and ignoreRarities[rarity]) then
        if isGuiHearted then
            favoriteRemote:FireServer(toolId)
        end
        return
    end
    
    local brainrotName = attributeHolder:GetAttribute("Brainrot")
    local plantName = attributeHolder:GetAttribute("IsPlant")
    local mutationString = attributeHolder:GetAttribute("MutationString")
    local colorName = attributeHolder:GetAttribute("Colors")
    
    local itemType = brainrotName and "Brainrot" or (plantName and "Plant" or nil)
    local itemName = brainrotName or plantName
    
    if not itemType then
        return
    end

    local finalMutationName = "Normal"
    
    if mutationString then
        local mutationOnly = string.gsub(mutationString, itemName, "")
        mutationOnly = string.gsub(mutationOnly, "%s*$", "")
        if mutationOnly ~= "" then
            finalMutationName = mutationOnly
        end
    elseif colorName then
        finalMutationName = colorName
    else
        finalMutationName = "Normal"
    end
    
    local shouldBeHearted = true

    if itemConfig[itemType] and itemConfig[itemType][itemName] then
        if itemConfig[itemType][itemName][finalMutationName] ~= nil then
            shouldBeHearted = itemConfig[itemType][itemName][finalMutationName]
        else
            shouldBeHearted = false
        end
    else
        shouldBeHearted = true
    end
    
    if shouldBeHearted and not isGuiHearted then
        favoriteRemote:FireServer(toolId)
    elseif not shouldBeHearted and isGuiHearted then
        favoriteRemote:FireServer(toolId)
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
