local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("HitlistTargetDisplay") then
    PlayerGui.HitlistTargetDisplay:Destroy()
end

local brainrotRewards = {
    ["Brr Brr Patapim"] = {
        { Type = "Gear", Amount = 1, Name = "Banana Gun" }
    },
    ["Cappuccino Assasino"] = {
        { Type = "Gear", Amount = 1, Name = "Premium Water Bucket" }
    },
    ["Svinino Bombondino"] = {
        { Type = "Brainrot", Amount = 1, Name = "Orcalero Orcala" },
        { Type = "Gear", Amount = 1, Name = "Frost Grenade" }
    },
    ["Trippi Troppi"] = {
        { Type = "CardPack", Amount = 1, Name = "Base" }
    },
    ["Bandito Bobrito"] = {
        { Type = "Gear", Amount = 2, Name = "Frost Grenade" },
        { Type = "Seed", Amount = 1, Name = "Pumpkin Seed" }
    },
    ["Alessio"] = {
        { Type = "Gear", Amount = 1, Name = "Damage Potion" },
        { Type = "Gear", Amount = 2, Name = "Water Bucket" }
    },
    ["Bananita Dolphinita"] = {
        { Type = "Gear", Amount = 1, Name = "Riot Potion" }
    },
    ["Gangster Footera"] = {
        { Type = "Seed", Amount = 1, Name = "Dragon Fruit Seed" }
    },
    ["Las Tralaleritas"] = {
        { Type = "Brainrot", Amount = 1, Name = "Pesto Mortioni" },
        { Type = "Seed", Amount = 1, Name = "Pumpkin Seed" }
    },
    ["Bambini Crostini"] = {
        { Type = "Gear", Amount = 2, Name = "Water Bucket" }
    },
    ["Elefanto Cocofanto"] = {
        { Type = "Gear", Amount = 1, Name = "Frost Grenade" },
        { Type = "Gear", Amount = 1, Name = "Banana Gun" }
    },
    ["Madung"] = {
        { Type = "Gear", Amount = 1, Name = "Premium Water Bucket" },
        { Type = "Brainrot", Amount = 1, Name = "Bananita Dolphinita" }
    },
    ["Bombini Gussini"] = {
        { Type = "Seed", Amount = 1, Name = "Watermelon Seed" },
        { Type = "Seed", Amount = 1, Name = "Strawberry Seed" }
    },
    ["Bombardiro Crocodilo"] = {
        { Type = "Gear", Amount = 1, Name = "Frost Grenade" }
    },
    ["Frigo Camelo"] = {
        { Type = "Gear", Amount = 1, Name = "Speed Potion" }
    },
    ["Matteo"] = {
        { Type = "Gear", Amount = 1, Name = "Riot Potion" }
    },
    ["Giraffa Celeste"] = {
        { Type = "Gear", Amount = 2, Name = "Premium Water Bucket" },
        { Type = "Brainrot", Amount = 1, Name = "Burbaloni Lulliloli" }
    },
    ["Luis Traffico"] = {
        { Type = "Brainrot", Amount = 1, Name = "Pesto Mortioni" },
        { Type = "Gear", Amount = 1, Name = "Frost Grenade" }
    },
    ["Kiwissimo"] = {
        { Type = "CardPack", Amount = 1, Name = "Base" }
    },
    ["Tralalero Tralala"] = {
        { Type = "Seed", Amount = 1, Name = "Tomade Torelli Seed" },
        { Type = "Gear", Amount = 1, Name = "Lucky Potion" }
    }
}

local brainrotOrder = {
    "Brr Brr Patapim", "Cappuccino Assasino", "Svinino Bombondino", "Trippi Troppi",
    "Bandito Bobrito", "Alessio", "Bananita Dolphinita", "Gangster Footera",
    "Las Tralaleritas", "Bambini Crostini", "Elefanto Cocofanto", "Madung",
    "Bombini Gussini", "Bombardiro Crocodilo", "Frigo Camelo", "Matteo",
    "Giraffa Celeste", "Luis Traffico", "Kiwissimo", "Tralalero Tralala"
}

local isClaiming = false

local function createHitlistDisplay()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HitlistTargetDisplay"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 250, 0, 120)
    mainFrame.Position = UDim2.new(1, -260, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
    stroke.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 150, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Text = "Hitlist Progress"
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame
    
    local progressLabel = Instance.new("TextLabel")
    progressLabel.Name = "ProgressLabel"
    progressLabel.Size = UDim2.new(0, 80, 0, 25)
    progressLabel.Position = UDim2.new(1, -90, 0, 5)
    progressLabel.BackgroundTransparency = 1
    progressLabel.Font = Enum.Font.SourceSansBold
    progressLabel.Text = "0/20"
    progressLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    progressLabel.TextSize = 18
    progressLabel.TextXAlignment = Enum.TextXAlignment.Right
    progressLabel.Parent = mainFrame

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0, 15, 0, 35)
    icon.BackgroundTransparency = 1
    icon.Parent = mainFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -85, 0, 25)
    nameLabel.Position = UDim2.new(0, 70, 0, 40)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Text = "None"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = mainFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -85, 0, 20)
    statusLabel.Position = UDim2.new(0, 70, 0, 65)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Text = "In Progress"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    local rewardLabel = Instance.new("TextLabel")
    rewardLabel.Name = "RewardLabel"
    rewardLabel.Size = UDim2.new(1, -20, 0, 20)
    rewardLabel.Position = UDim2.new(0, 10, 1, -25)
    rewardLabel.BackgroundTransparency = 1
    rewardLabel.Font = Enum.Font.SourceSansItalic
    rewardLabel.Text = "Reward: "
    rewardLabel.TextColor3 = Color3.fromRGB(255, 223, 128)
    rewardLabel.TextSize = 14
    rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
    rewardLabel.Parent = mainFrame

    screenGui.Parent = PlayerGui
    
    return nameLabel, icon, statusLabel, rewardLabel, progressLabel
end

local function setupVisualizerMonitor(nameLabel, icon, rewardLabel, progressLabel)
    local visualFolder = Workspace:WaitForChild("ScriptedMap"):WaitForChild("Event"):WaitForChild("HitListVisualizer"):WaitForChild("VisualFolder")

    local function updateDisplay()
        local children = visualFolder:GetChildren()
        if #children > 0 then
            local targetModel = children[1]
            local targetName = targetModel.Name
            local iconId = targetModel:GetAttribute("Icon")
            
            nameLabel.Text = targetName
            if iconId then
                icon.Image = iconId
            else
                icon.Image = ""
            end
            
            local rewards = brainrotRewards[targetName]
            if rewards then
                local rewardString = "Reward: "
                for i, rewardInfo in ipairs(rewards) do
                    rewardString ..= rewardInfo.Amount .. "x " .. rewardInfo.Name
                    if i < #rewards then
                        rewardString ..= ", "
                    end
                end
                rewardLabel.Text = rewardString
            else
                rewardLabel.Text = "Reward: Unknown"
            end

            local progressIndex = table.find(brainrotOrder, targetName)
            if progressIndex then
                progressLabel.Text = progressIndex .. "/" .. #brainrotOrder
            else
                progressLabel.Text = "?/20"
            end
        else
            nameLabel.Text = "None"
            icon.Image = ""
            rewardLabel.Text = "Reward: "
            progressLabel.Text = "0/20"
        end
    end

    visualFolder.ChildAdded:Connect(updateDisplay)
    visualFolder.ChildRemoved:Connect(updateDisplay)
    updateDisplay()
end

local function teleportToPlayerPlot()
    local plotsFolder = Workspace:WaitForChild("Plots")
    if not plotsFolder then return end

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        if plot:IsA("Folder") then
            local ownerName = plot:GetAttribute("Owner")
            if ownerName and ownerName == LocalPlayer.Name then
                local originPart = plot:FindFirstChild("Origin")
                if originPart and originPart:IsA("BasePart") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = originPart.CFrame + Vector3.new(0, 3, 0)
                        return
                    end
                end
            end
        end
    end
end

local function setupTomadeMonitor(statusLabel)
    local tomadeLabel = Workspace:WaitForChild("ScriptedMap"):WaitForChild("Event"):WaitForChild("TomadeFloor"):WaitForChild("GuiAttachment"):WaitForChild("Billboard"):WaitForChild("Display")
    local prompt = Workspace:WaitForChild("ScriptedMap"):WaitForChild("Event"):WaitForChild("EventRewards"):WaitForChild("TalkPart"):WaitForChild("ProximityPrompt")
    local claimPosition = CFrame.new(-160, 14, 1022)

    local function onTomadeTextChanged()
        if tomadeLabel.Text == "Claim" and not isClaiming then
            isClaiming = true
            statusLabel.Text = "Claim Ready!"
            statusLabel.TextColor3 = Color3.fromRGB(85, 255, 127)
            
            task.spawn(function()
                local success, err = pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = claimPosition
                        task.wait(0.5)
                        prompt:InputHoldBegin()
                        task.wait(0.1)
                        prompt:InputHoldEnd()
                    else
                        isClaiming = false
                        statusLabel.Text = "Character Error"
                        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    end
                end)
                
                if not success then
                    isClaiming = false
                    statusLabel.Text = "Claim Error"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end)
            
        elseif tomadeLabel.Text == "Tomade Torelli" and isClaiming then
            isClaiming = false
            statusLabel.Text = "In Progress"
            statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            
            task.spawn(function()
                task.wait(0.5)
                pcall(teleportToPlayerPlot)
            end)
        end
    end
    
    tomadeLabel:GetPropertyChangedSignal("Text"):Connect(onTomadeTextChanged)
    task.wait()
    onTomadeTextChanged()
end

local function setupRestartMonitor(statusLabel)
    local prompt = Workspace:WaitForChild("ScriptedMap"):WaitForChild("Event"):WaitForChild("EventRewards"):WaitForChild("TalkPart"):WaitForChild("ProximityPrompt")
    local claimPosition = CFrame.new(-160, 14, 1022)
    local isRestarting = false

    local function checkAndRestart()
        if prompt.ActionText == "Restart Hitlist (50M)" and not isRestarting then
            isRestarting = true
            statusLabel.Text = "Restarting..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
            
            task.spawn(function()
                local success, err = pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = claimPosition
                        task.wait(0.5)
                        prompt:InputHoldBegin()
                        task.wait(0.1)
                        prompt:InputHoldEnd()
                        task.wait(1)
                        pcall(teleportToPlayerPlot)
                    else
                        error("Character not found for restart.")
                    end
                end)

                if not success then
                    statusLabel.Text = "Restart Error"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
                
                task.wait(5)
                isRestarting = false
            end)
        end
    end

    prompt:GetPropertyChangedSignal("ActionText"):Connect(checkAndRestart)
    task.wait()
    checkAndRestart()
end

local targetNameLabel, targetIcon, claimStatusLabel, rewardLabel, progressLabel = createHitlistDisplay()
setupVisualizerMonitor(targetNameLabel, targetIcon, rewardLabel, progressLabel)
setupTomadeMonitor(claimStatusLabel)
setupRestartMonitor(claimStatusLabel)
