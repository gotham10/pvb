local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local MyRootPart = Character:WaitForChild("HumanoidRootPart")

local giftItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GiftItem")

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

Character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        local targetPlayer = findClosestPlayer()
        if targetPlayer then
            local giftPayload = {
                ToGift = targetPlayer.Name,
                Item = child
            }
            giftItemRemote:FireServer(giftPayload)
        end
    end
end)
