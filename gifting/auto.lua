local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local MyRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Backpack = LocalPlayer:WaitForChild("Backpack")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local giftItemRemote = Remotes:WaitForChild("GiftItem")
local acceptGiftRemote = Remotes:WaitForChild("AcceptGift")

local function findClosestPlayer()
    local closestPlayer = nil
    local minDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerCharacter = player.Character
            if playerCharacter then
                local playerRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")
                if MyRootPart and playerRootPart then
                    local distance = (MyRootPart.Position - playerRootPart.Position).Magnitude
                    if distance < minDistance then
                        minDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

giftItemRemote.OnClientEvent:Connect(function(giftPayload)
    if giftPayload and type(giftPayload) == "table" and giftPayload.ID then
        acceptGiftRemote:FireServer({
            ID = giftPayload.ID
        })
    end
end)

-- add local name here for the player sending the items
if LocalPlayer.Name == "" then
    Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.spawn(function()
                while child.Parent == Character do
                    local targetPlayer = findClosestPlayer()
                    if targetPlayer then
                        giftItemRemote:FireServer({
                            ToGift = targetPlayer.Name,
                            Item = child
                        })
                        task.wait(4)
                    else
                        task.wait(0.5)
                    end
                end
            end)
        end
    end)

    task.spawn(function()
        while task.wait(1) do
            if Humanoid and Humanoid.Health > 0 and not Character:FindFirstChildOfClass("Tool") then
                local plantTools = {}
                for _, tool in ipairs(Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:GetAttribute("IsPlant") then
                        table.insert(plantTools, tool)
                    end
                end

                if #plantTools > 0 then
                    local randomToolToEquip = plantTools[math.random(#plantTools)]
                    Humanoid:EquipTool(randomToolToEquip)
                end
            end
        end
    end)
end
