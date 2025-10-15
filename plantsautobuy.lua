local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local mainGui = playerGui:WaitForChild("Main")
local modules = ReplicatedStorage:WaitForChild("Modules")
local registries = modules:WaitForChild("Registries")

local function runSeedBuyer()
	local MIN_PRICE = 25000000

	local buyRemote = remotes:WaitForChild("BuyItem", 5)
	local seedsRegistryScript = registries:WaitForChild("SeedRegistry", 5)
	local seedsGui = mainGui:WaitForChild("Seeds", 5)

	if not seedsGui or not buyRemote or not seedsRegistryScript then
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

	local function parseSeedPrices(scriptObj)
		local data = {}
		if not scriptObj then
			return data
		end

		local success, seedRegistryTable = pcall(require, scriptObj)

		if not success or type(seedRegistryTable) ~= "table" then
			return data
		end

		for seedName, seedInfo in pairs(seedRegistryTable) do
			if type(seedInfo) == "table" and seedInfo.Price then
				data[seedName] = tonumber(seedInfo.Price)
			end
		end
		return data
	end

	local seedPrices = parseSeedPrices(seedsRegistryScript)

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
