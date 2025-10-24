local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FinderGui"
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 37, 40)
mainFrame.BorderColor3 = Color3.fromRGB(110, 110, 110)
mainFrame.BorderSizePixel = 1
mainFrame.Position = UDim2.new(1, -410, 1, -310)
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Active = true
mainFrame.Draggable = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(50, 52, 55)
titleBar.BorderSizePixel = 0
titleBar.Size = UDim2.new(1, 0, 0, 30)

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleRounder = Instance.new("UICorner")
titleRounder.Parent = titleBar
titleRounder.CornerRadius = UDim.new(0,8)
titleBar.ClipsDescendants = true
local titleUnrounder = Instance.new("Frame")
titleUnrounder.Parent = titleBar
titleUnrounder.BackgroundColor3 = titleBar.BackgroundColor3
titleUnrounder.BorderSizePixel = 0
titleUnrounder.Position = UDim2.new(0,0,0.5,0)
titleUnrounder.Size = UDim2.new(1,0,0.5,0)


local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = titleBar
titleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.Font = Enum.Font.SourceSansSemibold
titleLabel.Text = "Pacchetto Di Carte Finder"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Name = "ResultsFrame"
resultsFrame.Parent = mainFrame
resultsFrame.BackgroundColor3 = Color3.fromRGB(45, 47, 50)
resultsFrame.BorderSizePixel = 0
resultsFrame.Position = UDim2.new(0, 10, 0, 40)
resultsFrame.Size = UDim2.new(1, -20, 1, -85)
resultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
resultsFrame.ScrollBarThickness = 6

local resultsCorner = Instance.new("UICorner")
resultsCorner.CornerRadius = UDim.new(0, 6)
resultsCorner.Parent = resultsFrame

local resultsLayout = Instance.new("UIListLayout")
resultsLayout.Name = "ResultsLayout"
resultsLayout.Parent = resultsFrame
resultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
resultsLayout.Padding = UDim.new(0, 5)

local resultsPadding = Instance.new("UIPadding")
resultsPadding.Parent = resultsFrame
resultsPadding.PaddingLeft = UDim.new(0, 5)
resultsPadding.PaddingRight = UDim.new(0, 5)
resultsPadding.PaddingTop = UDim.new(0, 5)
resultsPadding.PaddingBottom = UDim.new(0, 5)


local resultTemplate = Instance.new("TextLabel")
resultTemplate.Name = "ResultTemplate"
resultTemplate.Parent = mainFrame
resultTemplate.Visible = false
resultTemplate.BackgroundColor3 = Color3.fromRGB(55, 57, 60)
resultTemplate.BorderSizePixel = 0
resultTemplate.Size = UDim2.new(1, 0, 0, 50)
resultTemplate.Font = Enum.Font.SourceSans
resultTemplate.Text = "PlayerName has Item | Worth: 100 | Size: 100 | ID: 12345 | Mutation: None"
resultTemplate.TextColor3 = Color3.fromRGB(230, 230, 230)
resultTemplate.TextSize = 14
resultTemplate.TextWrapped = true
resultTemplate.TextXAlignment = Enum.TextXAlignment.Left
resultTemplate.TextYAlignment = Enum.TextYAlignment.Top

local templateCorner = Instance.new("UICorner")
templateCorner.CornerRadius = UDim.new(0, 4)
templateCorner.Parent = resultTemplate

local templatePadding = Instance.new("UIPadding")
templatePadding.Parent = resultTemplate
templatePadding.PaddingLeft = UDim.new(0, 5)
templatePadding.PaddingRight = UDim.new(0, 5)
templatePadding.PaddingTop = UDim.new(0, 5)
templatePadding.PaddingBottom = UDim.new(0, 5)

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Parent = mainFrame
statusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 10, 0, 40)
statusLabel.Size = UDim2.new(1, -20, 1, -85)
statusLabel.Font = Enum.Font.SourceSansItalic
statusLabel.Text = "Click 'Refresh' to scan..."
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 16
statusLabel.TextWrapped = true
statusLabel.Visible = true

local refreshButton = Instance.new("TextButton")
refreshButton.Name = "RefreshButton"
refreshButton.Parent = mainFrame
refreshButton.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
refreshButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
refreshButton.BorderSizePixel = 0
refreshButton.Position = UDim2.new(0, 310, 1, -35)
refreshButton.Size = UDim2.new(0, 80, 0, 25)
refreshButton.Font = Enum.Font.SourceSansSemibold
refreshButton.Text = "Refresh"
refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshButton.TextSize = 16

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 6)
refreshCorner.Parent = refreshButton

local serverHopButton = Instance.new("TextButton")
serverHopButton.Name = "ServerHopButton"
serverHopButton.Parent = mainFrame
serverHopButton.BackgroundColor3 = Color3.fromRGB(100, 102, 105)
serverHopButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
serverHopButton.BorderSizePixel = 0
serverHopButton.Position = UDim2.new(0, 10, 1, -35)
serverHopButton.Size = UDim2.new(0, 80, 0, 25)
serverHopButton.Font = Enum.Font.SourceSansSemibold
serverHopButton.Text = "Server Hop"
serverHopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
serverHopButton.TextSize = 16

local hopCorner = Instance.new("UICorner")
hopCorner.CornerRadius = UDim.new(0, 6)
hopCorner.Parent = serverHopButton

local copyJobIdButton = Instance.new("TextButton")
copyJobIdButton.Name = "CopyJobIdButton"
copyJobIdButton.Parent = mainFrame
copyJobIdButton.BackgroundColor3 = Color3.fromRGB(100, 102, 105)
copyJobIdButton.BorderSizePixel = 0
copyJobIdButton.Position = UDim2.new(0, 110, 1, -35)
copyJobIdButton.Size = UDim2.new(0, 80, 0, 25)
copyJobIdButton.Font = Enum.Font.SourceSansSemibold
copyJobIdButton.Text = "Copy Job ID"
copyJobIdButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyJobIdButton.TextSize = 16

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 6)
copyCorner.Parent = copyJobIdButton

local copyAllButton = Instance.new("TextButton")
copyAllButton.Name = "CopyAllButton"
copyAllButton.Parent = mainFrame
copyAllButton.BackgroundColor3 = Color3.fromRGB(100, 102, 105)
copyAllButton.BorderSizePixel = 0
copyAllButton.Position = UDim2.new(0, 210, 1, -35)
copyAllButton.Size = UDim2.new(0, 80, 0, 25)
copyAllButton.Font = Enum.Font.SourceSansSemibold
copyAllButton.Text = "Copy All"
copyAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyAllButton.TextSize = 16

local copyAllCorner = Instance.new("UICorner")
copyAllCorner.CornerRadius = UDim.new(0, 6)
copyAllCorner.Parent = copyAllButton

local Time = 1
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false

pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)

function TPReturner()
    local Site
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    
    local url
    if foundAnything == "" then
        url = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'
    else
        url = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything
    end

    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    if not success then
        warn("Failed to get server list:", response)
        statusLabel.Text = "Error hopping: Could not get server list."
        statusLabel.Visible = true
        resultsFrame.Visible = false
        return
    end

    Site = response
    
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end

    local num = 0
    local teleported = false
    
    if not Site.data then
        warn("Server list 'data' field is missing.")
        statusLabel.Text = "Error hopping: Invalid server response."
        statusLabel.Visible = true
        resultsFrame.Visible = false
        return
    end

    for i, v in pairs(Site.data) do
        if teleported then break end
        
        local Possible = true
        ID = tostring(v.id)
        
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _, Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                        break
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            
            if Possible == true then
                table.insert(AllIDs, ID)
                wait()
                
                local tpSuccess, tpError = pcall(function()
                    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                    wait()
                    statusLabel.Text = "Teleporting to new server..."
                    statusLabel.Visible = true
                    resultsFrame.Visible = false
                    TeleportService:TeleportToPlaceInstance(PlaceID, ID, Players.LocalPlayer)
                end)
                
                if tpSuccess then
                    teleported = true
                else
                    warn("Teleport failed:", tpError)
                    for k, existingId in pairs(AllIDs) do
                        if existingId == ID then
                            table.remove(AllIDs, k)
                            break
                        end
                    end
                end
                wait(4)
            end
        end
    end
    
    if not teleported then
        statusLabel.Text = "No new servers found on this page. Try hopping again."
        statusLabel.Visible = true
        resultsFrame.Visible = false
        
        if not Site.nextPageCursor or Site.nextPageCursor == "null" or Site.nextPageCursor == nil then
            foundAnything = ""
            statusLabel.Text = "Searched all servers. Resetting hop list. Try again."
        end
    end
end

function scanPlayers()
    for _, v in pairs(resultsFrame:GetChildren()) do
        if v:IsA("TextLabel") then
            v:Destroy()
        end
    end

    local found = false
    
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        local backpack = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 3)
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool and tool:IsA("Tool") then
                    local cleanName = string.gsub(tool.Name, "%b[]", "")
                    cleanName = string.gsub(cleanName, "^%s*(.-)%s*$", "%1")
                    
                    if tool:GetAttribute("Brainrot") ~= nil and cleanName == "Pacchetto Di Carte" then
                        found = true
                        
                        local worth = tool:GetAttribute("Worth") or "N/A"
                        local size = tool:GetAttribute("Size") or "N/A"
                        local id = tool:GetAttribute("ID") or "N/A"
                        local mutation = tool:GetAttribute("MutationString") or "N/A"
                        
                        local newResult = resultTemplate:Clone()
                        newResult.Text = string.format(
                            "%s has Pacchetto Di Carte (Inventory)\nWorth: %s | Size: %s | ID: %s\nMutation: %s",
                            player.Name,
                            tostring(worth),
                            tostring(size),
                            tostring(id),
                            tostring(mutation)
                        )
                        newResult.Visible = true
                        newResult.Parent = resultsFrame
                    end
                end
            end
        end
    end

    local plotsFolder = game.Workspace:FindFirstChild("Plots")
    if plotsFolder then
        for i = 1, 5 do
            local plotFolder = plotsFolder:FindFirstChild(tostring(i))
            if plotFolder then
                local brainrotsFolder = plotFolder:FindFirstChild("Brainrots")
                if brainrotsFolder then
                    for _, podium in ipairs(brainrotsFolder:GetChildren()) do
                        if podium:IsA("Model") then
                            local brainrotModel = podium:FindFirstChild("Brainrot")
                            if brainrotModel and brainrotModel:IsA("Model") then
                                
                                local brainrotAttrValue = brainrotModel:GetAttribute("Brainrot")
                                
                                if brainrotAttrValue and tostring(brainrotAttrValue) == "Pacchetto Di Carte" then
                                    found = true
                                    
                                    local owner = plotFolder:GetAttribute("Owner") or "N/A"
                                    local plotNum = plotFolder.Name
                                    
                                    local attributes = {}
                                    for attrName, attrValue in pairs(brainrotModel:GetAttributes()) do
                                        if attrName ~= "Owner" and attrName ~= "Brainrot" then
                                            table.insert(attributes, string.format("%s: %s", attrName, tostring(attrValue)))
                                        end
                                    end
                                    local attrString = table.concat(attributes, " | ")
                                    if attrString == "" then
                                        attrString = "No additional attributes."
                                    end

                                    local newResult = resultTemplate:Clone()
                                    newResult.Text = string.format(
                                        "%s's Pacchetto Di Carte (Plot %s)\n%s",
                                        tostring(owner),
                                        plotNum,
                                        attrString
                                    )
                                    newResult.Visible = true
                                    newResult.Parent = resultsFrame
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if not found then
        statusLabel.Text = "No Pacchetto Di Carte found in plots or inventories."
        statusLabel.Visible = true
        resultsFrame.Visible = false
    else
        statusLabel.Visible = false
        resultsFrame.Visible = true
    end
end

refreshButton.MouseButton1Click:Connect(scanPlayers)
serverHopButton.MouseButton1Click:Connect(TPReturner)

local function onCopyJobId()
    local jobId = game.JobId
    local placeId = game.PlaceId
    local teleportString = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s")', placeId, jobId)
    
    local success, err = pcall(function()
        setclipboard(teleportString)
    end)
    
    if success then
        local originalText = copyJobIdButton.Text
        copyJobIdButton.Text = "Copied!"
        wait(2)
        copyJobIdButton.Text = originalText
    else
        warn("Failed to set clipboard:", err)
        local originalText = copyJobIdButton.Text
        copyJobIdButton.Text = "Error!"
        wait(2)
        copyJobIdButton.Text = originalText
    end
end

copyJobIdButton.MouseButton1Click:Connect(onCopyJobId)

local function onCopyAllResults()
    local textToCopy = ""
    
    if statusLabel.Visible then
        textToCopy = statusLabel.Text
    else
        local allResults = {}
        for _, child in pairs(resultsFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                table.insert(allResults, child.Text)
            end
        end
        textToCopy = table.concat(allResults, "\n\n")
    end
    
    if textToCopy == "" then
        textToCopy = "No results to copy."
    end
    
    local success, err = pcall(function()
        setclipboard(textToCopy)
    end)
    
    if success then
        local originalText = copyAllButton.Text
        copyAllButton.Text = "Copied!"
        wait(2)
        copyAllButton.Text = originalText
    else
        warn("Failed to set clipboard:", err)
        local originalText = copyAllButton.Text
        copyAllButton.Text = "Error!"
        wait(2)
        copyAllButton.Text = originalText
    end
end

copyAllButton.MouseButton1Click:Connect(onCopyAllResults)

scanPlayers()
