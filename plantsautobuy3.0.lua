local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local mainGui = playerGui:WaitForChild("Main")

local function runSeedBuyer()
	local MIN_PRICE = 25000000
	
	local seedRegistryTable = {
		["Cactus Seed"] = { Plant = "Cactus", Price = 200, ProductID = 3367832230 },
		["Carnivorous Plant Seed"] = { Plant = "Carnivorous Plant", Price = 25000000, ProductID = 3390308260 },
		["Cocotank Seed"] = { Plant = "Cocotank", Price = 5000000, ProductID = 3367832870 },
		["Copuccino Seed"] = { Plant = "Copuccino", Price = 40000000, Hidden = true },
		["Dragon Fruit Seed"] = { Plant = "Dragon Fruit", Price = 100000, ProductID = 3358537812 },
		["Eggplant Seed"] = { Plant = "Eggplant", Price = 250000, ProductID = 3367831368 },
		["Grape Seed"] = { Plant = "Grape", Price = 2500000, ProductID = 3415139748 },
		["King Limone Seed"] = { Plant = "King Limone", Price = 450000000, ProductID = 3427551837 },
		["Mango Seed"] = { Plant = "Mango", Price = 367000000, ProductID = 3420415830 },
		["Mr Carrot Seed"] = { Plant = "Mr Carrot", Price = 50000000, ProductID = 3397421940 },
		["Pine-a-Punch Seed"] = { Plant = "Pine-a-Punch", Price = 37500000, ProductID = 3419962087, Hidden = true },
		["Pumpkin Seed"] = { Plant = "Pumpkin", Price = 5000, ProductID = 3367832358 },
		["Shroombino Seed"] = { Plant = "Shroombino", Price = 200000000, ProductID = 3415156577 },
		["Strawberry Seed"] = { Plant = "Strawberry", Price = 1250, ProductID = 3358537655 },
		["Sunflower Seed"] = { Plant = "Sunflower", Price = 25000, ProductID = 3367832538 },
		["Tomade Torelli Seed"] = { Plant = "Tomade Torelli", Price = 45000000, Hidden = true },
		["Tomatrio Seed"] = { Plant = "Tomatrio", Price = 125000000, ProductID = 3408789851 },
		["Watermelon Seed"] = { Plant = "Watermelon", Price = 1000000, ProductID = 3367832741 },
		["Don Fragola Seed"] = { Plant = "Don Fragola", Price = 2500, Hidden = true },
		["Aubie Seed"] = { Plant = "Aubie", Price = 25000, Hidden = true },
		["Sunzio Seed"] = { Plant = "Sunzio", Price = 40000, Hidden = true },
	}

	local buyRemote = remotes:WaitForChild("BuyItem", 5)
	local seedsGui = mainGui:WaitForChild("Seeds", 5)

	if not seedsGui or not buyRemote then
		return
	end

	local scrolling = seedsGui.Frame:WaitForChild("ScrollingFrame", 5)
	if not scrolling then
		return
	end

	local restockLabel = seedsGui:WaitForChild("Restock", 5)

	local function isIgnored(inst)
		if not inst or inst.Name == "Padding" then return true end
		local c = inst.ClassName
		return c == "UIPadding" or c == "UIListLayout"
	end

	local function findStockLabel(frame)
		for _, v in ipairs(frame:GetDescendants()) do
			if v:IsA("TextLabel") and v.Text and v.Text:lower():find("in stock") then
				return v
			end
		end
		return nil
	end

	local function parseStock(text)
		if not text then return 0 end
		local n = text:match("x%s*(%d+)") or text:match("(%d+)")
		return tonumber(n) or 0
	end

	local seedPrices = {}
	for seedName, seedInfo in pairs(seedRegistryTable) do
		if type(seedInfo) == "table" and seedInfo.Price then
			seedPrices[seedName] = tonumber(seedInfo.Price)
		end
	end

	local function canBuy(seedName)
		local price = seedPrices[seedName]
		if not price then
			return false
		end
		if price >= MIN_PRICE then
			return true
		else
			return false
		end
	end

	local function attemptBuy(seedName)
		local ok, err = pcall(function() buyRemote:FireServer(seedName) end)
		return ok
	end

	local function processFrame(frame)
		if isIgnored(frame) then return end
		local seedName = frame.Name
		if not canBuy(seedName) then return end
		local stockLabel = findStockLabel(frame)
		if not stockLabel then return end

		while task.wait(0.25) do
			local count = parseStock(stockLabel.Text)
			if count <= 0 then
				break
			end
			if not attemptBuy(seedName) then
				break
			end
		end
	end

	local function scanAll()
		for _, child in ipairs(scrolling:GetChildren()) do
			if not isIgnored(child) then
				coroutine.wrap(processFrame)(child)
			end
		end
	end

	local function parseTimeToSeconds(text)
		if not text then return 0 end
		local mm, ss = text:match("(%d+):(%d+)")
		if mm and ss then return tonumber(mm) * 60 + tonumber(ss) end
		return tonumber(text:match("(%d+)")) or 0
	end

	if restockLabel then
		local lastSeconds = parseTimeToSeconds(restockLabel.Text)
		restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
			local s = parseTimeToSeconds(restockLabel.Text)
			if s > lastSeconds then
				task.wait(0.5)
				scanAll()
			end
			lastSeconds = s
		end)
	end

	task.wait(1)
	scanAll()
end

coroutine.wrap(runSeedBuyer)()
