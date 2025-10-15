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
	print("DEBUG: Initializing Seed Buyer. Minimum Price: " .. MIN_PRICE)

	local buyRemote = remotes:WaitForChild("BuyItem", 5)
	local seedsRegistryScript = registries:WaitForChild("SeedRegistry", 5)
	local seedsGui = mainGui:WaitForChild("Seeds", 5)

	if not seedsGui or not buyRemote or not seedsRegistryScript then
		warn("DEBUG: Seed Buyer disabled. Missing critical components:", {
			seedsGui = tostring(seedsGui),
			buyRemote = tostring(buyRemote),
			seedsRegistryScript = tostring(seedsRegistryScript)
		})
		return
	end

	local scrolling = seedsGui.Frame:WaitForChild("ScrollingFrame", 5)
	if not scrolling then
		warn("DEBUG: Seed Buyer could not find ScrollingFrame.")
		return
	end

	local restockLabel = seedsGui:WaitForChild("Restock", 5)
	print("DEBUG: Seed Buyer components located successfully.")
	
	local function prettyEncode(val, indent)
		indent = indent or ""
		local nextIndent = indent .. "    "
		if type(val) == "string" then
			return '"' .. val:gsub('"', '\\"') .. '"'
		elseif type(val) == "number" or type(val) == "boolean" then
			return tostring(val)
		elseif type(val) == "table" then
			local isArray = #val > 0 and val[1] ~= nil and #val == select("#", pairs(val))
			
			local parts = {}
			if isArray then
				if #val == 0 then return "[]" end
				table.insert(parts, "[\n")
				for i, item in ipairs(val) do
					table.insert(parts, nextIndent .. prettyEncode(item, nextIndent))
					if i ~= #val then
						table.insert(parts, ",\n")
					else
						table.insert(parts, "\n")
					end
				end
				table.insert(parts, indent .. "]")
			else
				local keys = {}
				for k in pairs(val) do table.insert(keys, k) end
				if #keys == 0 then return "{}" end
				table.sort(keys)
				
				table.insert(parts, "{\n")
				for i, key in ipairs(keys) do
					local keyStr = '"' .. tostring(key) .. '"'
					local valStr = prettyEncode(val[key], nextIndent)
					table.insert(parts, nextIndent .. keyStr .. ": " .. valStr)
					if i ~= #keys then
						table.insert(parts, ",\n")
					else
						table.insert(parts, "\n")
					end
				end
				table.insert(parts, indent .. "}")
			end
			return table.concat(parts)
		end
		return "null"
	end

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

	local function logStockData()
		print("DEBUG: Logging current shop stock...")
		local stockItems = {}
		for _, itemFrame in ipairs(scrolling:GetChildren()) do
			if not isIgnored(itemFrame) then
				local stockLabel = findStockLabel(itemFrame)
				if stockLabel and stockLabel.Text then
					local stockCount = parseStock(stockLabel.Text)
					if stockCount > 0 then
						local cleanName = itemFrame.Name:gsub("%s*Seed$", "")
						stockItems[cleanName] = "x" .. tostring(stockCount)
					end
				end
			end
		end

		if next(stockItems) == nil then
			print("DEBUG: No items in stock to log.")
			return
		end

		local newLogEntry = {
			timestamp = os.date("%Y-%m-%d %H:%M:%S"),
			items = stockItems
		}

		local existingData = {}
		local success, fileContent = pcall(readfile, "stockdata.json")
		if success and fileContent and fileContent ~= "" then
			local decodeSuccess, decodedJson = pcall(HttpService.JSONDecode, HttpService, fileContent)
			if decodeSuccess and type(decodedJson) == "table" then
				existingData = decodedJson
			else
				warn("DEBUG: Could not decode existing stockdata.json. It may be corrupt. Creating a new log.")
			end
		end
		
		table.insert(existingData, newLogEntry)
		
		local encodeSuccess, encodedJson = pcall(prettyEncode, existingData)
		if encodeSuccess then
			writefile("stockdata.json", encodedJson)
			print("DEBUG: Successfully updated stockdata.json")
		else
			warn("DEBUG: Failed to encode stock data to JSON. Error: " .. tostring(encodedJson))
		end
	end

	local function parseSeedPrices(scriptObj)
		local data = {}
		if not scriptObj then
			warn("DEBUG: HARDCORE: SeedRegistry script object not found.")
			return data
		end

		local success, seedRegistryTable = pcall(require, scriptObj)

		if not success or type(seedRegistryTable) ~= "table" then
			warn("DEBUG: HARDCORE: FAILED to require() SeedRegistry or it did not return a table. Error: " .. tostring(seedRegistryTable))
			return data
		end

		local count = 0
		for seedName, seedInfo in pairs(seedRegistryTable) do
			if type(seedInfo) == "table" and seedInfo.Price then
				data[seedName] = tonumber(seedInfo.Price)
				count = count + 1
			end
		end
		
		print("DEBUG: HARDCORE: Seed Price Parser found " .. count .. " prices via require().")
		if count > 0 then
			print("DEBUG: HARDCORE: Successfully parsed the following seeds and prices:")
			for name, price in pairs(data) do
				print("  - SEED: '" .. name .. "', PRICE: " .. price)
			end
		else
			warn("DEBUG: HARDCORE: FAILED to extract any seed prices from the required module.")
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
			print("DEBUG: Target seed '" .. seedName .. "' identified. Price (" .. price .. ") is >= Minimum (" .. MIN_PRICE .. ").")
			return true
		else
			print("DEBUG: Ignoring seed '" .. seedName .. "'. Price (" .. price .. ") is < Minimum (" .. MIN_PRICE .. ").")
			return false
		end
	end

	local function attemptBuy(seedName)
		print("DEBUG: Attempting to buy seed '" .. seedName .. "'")
		local ok, err = pcall(function() buyRemote:FireServer(seedName) end)
		if not ok then
			warn("DEBUG: Purchase FAILED for seed: '" .. seedName .. "'. Error: " .. tostring(err))
		else
			print("DEBUG: Purchase SUCCEEDED for seed: '" .. seedName .. "'.")
		end
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
				print("DEBUG: Seed '" .. seedName .. "' is out of stock.")
				break
			end
			print("DEBUG: Stock for seed '" .. seedName .. "' is " .. count)
			if not attemptBuy(seedName) then
				warn("DEBUG: Breaking purchase loop for seed '" .. seedName .. "' due to failed buy attempt.")
				break
			end
		end
	end

	local function scanAll()
		print("DEBUG: Starting full scan of seed shop.")
		for _, child in ipairs(scrolling:GetChildren()) do
			if not isIgnored(child) then
				coroutine.wrap(processFrame)(child)
			end
		end
		print("DEBUG: Seed shop scan complete.")
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
				print("DEBUG: SEED RESTOCK DETECTED! Logging stock and rescanning shop.")
				task.wait(0.5)
				logStockData()
				scanAll()
			end
			lastSeconds = s
		end)
		print("DEBUG: Restock listener connected for Seed Buyer.")
	end

	task.wait(1)
	logStockData()
	scanAll()
end

coroutine.wrap(runSeedBuyer)()
