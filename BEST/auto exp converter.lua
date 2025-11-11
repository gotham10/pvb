local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local utilFolder = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utility")
local notifContainer = utilFolder:WaitForChild("Notification")
local template = notifContainer:FindFirstChild("Notification") or notifContainer:WaitForChild("Notification")
local pg = Player:WaitForChild("PlayerGui")
local notificationsGui = pg:FindFirstChild("Notifications") or Instance.new("ScreenGui", pg)
notificationsGui.Name = "Notifications"
notificationsGui.ResetOnSpawn = false
local notificationsFolder = notificationsGui:FindFirstChild("Notifications") or Instance.new("Folder", notificationsGui)
notificationsFolder.Name = "Notifications"

local gradientFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("MutationGradients")
local ruby = gradientFolder:WaitForChild("RubyScorched")

local function spawnNotification(text)
    local clone = template:Clone()
    local Message = clone:FindFirstChild("Message") or clone:FindFirstChildWhichIsA("TextLabel") or clone
    local Shadow = Message and Message:FindFirstChild("Shadow")
    if Message then
        Message.TextSize = 20
        Message.Text = text or ""
        Message.TextTransparency = 1
        if Message:FindFirstChild("UIStroke") then
            Message.UIStroke.Transparency = 1
        end
    end
    if Shadow then
        for _, v in ipairs(Shadow:GetChildren()) do v:Destroy() end
        local g = ruby:Clone()
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.15),
            NumberSequenceKeypoint.new(1, 0.15)
        })
        g.Parent = Shadow
        Shadow.ImageTransparency = 0.15
    end
    clone.LayoutOrder = -(math.floor(tick() * 1000))
    clone.Parent = notificationsFolder
    local showTI = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if Shadow then TweenService:Create(Shadow, showTI, { ImageTransparency = 0.05 }):Play() end
    if Message then TweenService:Create(Message, showTI, { TextTransparency = 0 }):Play() end
    if Message and Message:FindFirstChild("UIStroke") then TweenService:Create(Message.UIStroke, showTI, { Transparency = 0 }):Play() end
    task.delay(3, function()
        local hideTI = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        if Shadow then TweenService:Create(Shadow, hideTI, { ImageTransparency = 1 }):Play() end
        if Message then TweenService:Create(Message, hideTI, { TextTransparency = 1 }):Play() end
        if Message and Message:FindFirstChild("UIStroke") then TweenService:Create(Message.UIStroke, hideTI, { Transparency = 1 }):Play() end
        task.wait(0.25)
        clone:Destroy()
    end)
end

local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Backpack = Player:WaitForChild("Backpack")

local extractor = Workspace:WaitForChild("ScriptedMap"):WaitForChild("PlantExtractor"):WaitForChild("PlantExtractor")
local timerLabel = extractor.UI.GUI.Timer
local lightsFolder = extractor.Input.Lights
local targetPos = Vector3.new(-123, 14, 966)

local notifiedNoPlants = false

local function tpBack()
    local distance = (HRP.Position - targetPos).Magnitude
    if distance > 5 then
        HRP.CFrame = CFrame.new(targetPos)
    end
end

local function findPromptByText(text)
    for _, part in ipairs(extractor:GetChildren()) do
        if part:IsA("BasePart") then
            local prompt = part:FindFirstChild("Prompt")
            if prompt and prompt:IsA("ProximityPrompt") then
                if string.find(string.lower(prompt.ActionText), string.lower(text)) then
                    return prompt
                end
            end
        end
    end
    return nil
end

local function triggerPrompt(prompt)
    if prompt then
        prompt.Enabled = true
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 1000
        prompt:InputHoldBegin()
        task.wait(0.2)
        prompt:InputHoldEnd()
        return true
    else
        return false
    end
end

while true do
    Character = Player.Character or Player.CharacterAdded:Wait()
    HRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
    
    tpBack()
    
    local text = timerLabel.Text

    if text == "~ Convert Plants to EXP ~" then
        local placePrompt = findPromptByText("Place Plant")
        
        if not placePrompt then
        
        else
            local humanoid = Character:FindFirstChildOfClass("Humanoid")
            
            if not humanoid then
            
            else
                local plantToPlace
                for _, tool in ipairs(Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:GetAttribute("IsPlant") then
                        plantToPlace = tool
                        break
                    end
                end

                if not plantToPlace then
                    if not notifiedNoPlants then
                        spawnNotification("I got no more left")
                        notifiedNoPlants = true
                    end
                else
                    notifiedNoPlants = false
                    local emptySlot = -1
                    
                    for i = 1, 5 do
                        local lightPart = lightsFolder:FindFirstChild(tostring(i)):FindFirstChild("FillColor")
                        local r = math.floor(lightPart.Color.R * 255 + 0.5)
                        local g = math.floor(lightPart.Color.G * 255 + 0.5)
                        local b = math.floor(lightPart.Color.B * 255 + 0.5)
                        
                        if r == 44 and g == 44 and b == 44 then
                            emptySlot = i
                            break
                        end
                    end
                    
                    if emptySlot == -1 then
                    
                    else
                        spawnNotification("Placing Plant (" .. emptySlot .. "/5)")
                        humanoid:EquipTool(plantToPlace)
                        task.wait(0.4)
                        
                        if Character:FindFirstChild(plantToPlace.Name) then
                            triggerPrompt(placePrompt)
                            
                            local timeout = 5 
                            local success = false
                            while timeout > 0 do
                                local newLightPart = lightsFolder[tostring(emptySlot)].FillColor
                                local nr = math.floor(newLightPart.Color.R * 255 + 0.5)
                                local ng = math.floor(newLightPart.Color.G * 255 + 0.5)
                                local nb = math.floor(newLightPart.Color.B * 255 + 0.5)
                                
                                if nr == 62 and ng == 173 and nb == 50 then
                                    success = true
                                    break
                                end
                                
                                if timerLabel.Text ~= "~ Convert Plants to EXP ~" then
                                    break
                                end
                                
                                task.wait(0.5)
                                timeout = timeout - 0.5
                            end
                            
                        else
                            humanoid:UnequipTools()
                        end
                    end
                end
            end
        end
        
    elseif string.find(text, "Time Remaining:") then
        if not notifiedNoPlants then
            spawnNotification("Converting plants to EXP...")
            notifiedNoPlants = true
        end
        repeat
            task.wait(1)
            text = timerLabel.Text
        until text == "Ready!"
        
    elseif text == "Ready!" then
        notifiedNoPlants = false
        spawnNotification("Extractor Ready! Attempting to claim...")
        local claimPrompt
        local attempts = 0
        repeat
            attempts = attempts + 1
            claimPrompt = findPromptByText("Claim")
            
            if claimPrompt then
                triggerPrompt(claimPrompt)
                spawnNotification("Claimed EXP!")
                break
            else
                task.wait(0.5)
            end
        until claimPrompt or attempts > 10
        
    else
        notifiedNoPlants = false
    end
    
    task.wait(1)
end
