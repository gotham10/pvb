local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local acceptGiftRemote = Remotes:WaitForChild("AcceptGift")
local giftItemRemote = Remotes:WaitForChild("GiftItem")

giftItemRemote.OnClientEvent:Connect(function(giftPayload)
    if giftPayload and type(giftPayload) == "table" and giftPayload.ID then
        acceptGiftRemote:FireServer({
            ID = giftPayload.ID
        })
    end
end)
