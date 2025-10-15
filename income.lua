local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Modules.Utility.Util)
local player = Players.LocalPlayer

local totalIncome = Util:FetchTotalMoneyPerSecond(player)
print("Your total income per second: $" .. Util:CommaNumber(totalIncome))
