local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local mainGui = playerGui:WaitForChild("Main")
local modules = ReplicatedStorage:WaitForChild("Modules")
local registries = modules:WaitForChild("Registries")

local function runGearBuyer()
	print("DEBUG: Initializing Gear Buyer.")
	local buyRemote = remotes:FindFirstChild("BuyGear")
	local gearRegistryScript = registries:FindFirstChild("GearRegistry")
	local assetsGears = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Gears")
	local gearsGui = mainGui:FindFirstChild("Gears")

	if not gearsGui or not buyRemote or not gearRegistryScript then
		warn("DEBUG: Gear Buyer disabled. Missing critical components:", {
			gearsGui = tostring(gearsGui),
			buyRemote = tostring(buyRemote),
			gearRegistryScript = tostring(gearRegistryScript)
		})
		return
	end

	local scrolling = gearsGui:FindFirstChild("Frame") and gearsGui.Frame:FindFirstChild("ScrollingFrame")
	if not scrolling then
		warn("DEBUG: Gear Buyer could not find ScrollingFrame.")
		return
	end

	local restockLabel = gearsGui:FindFirstChild("Restock") or gearsGui.Frame:FindFirstChild("Restock")
	print("DEBUG: Gear Buyer components located successfully.")

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

	local function findStockLabel(frame)
		if not frame then return nil end
		local direct = frame:FindFirstChild("Stock") or frame:FindFirstChild("StockValue")
		if direct and direct:IsA("TextLabel") then return direct end
		for _, v in ipairs(frame:GetDescendants()) do
			if v:IsA("TextLabel") and v.Text and v.Text:lower():find("in stock") then
				return v
			end
		end
		return nil
	end
	
	local function isIgnored(i)
		if not i or i.Name == "Padding" then return true end
		local c = i.ClassName
		return c == "UIPadding" or c == "UIListLayout"
	end

	local function logStockData()
		print("DEBUG: Logging current gear shop stock...")
		local stockItems = {}
		for _, itemFrame in ipairs(scrolling:GetChildren()) do
			if not isIgnored(itemFrame) then
				local stockLabel = findStockLabel(itemFrame)
				if stockLabel and stockLabel.Text then
					local stockText = stockLabel.Text:match("x%s*%d+") or stockLabel.Text:match("%d+") or "x0"
					if not stockText:find("x") then stockText = "x" .. stockText end
					stockItems[itemFrame.Name] = stockText
				end
			end
		end

		local newLogEntry = {
			timestamp = os.date("%Y-%m-%d %H:%M:%S"),
			items = stockItems
		}

		local existingData = {}
		local success, fileContent = pcall(readfile, "gearstockdata.json")
		if success and fileContent and fileContent ~= "" then
			local decodeSuccess, decodedJson = pcall(HttpService.JSONDecode, HttpService, fileContent)
			if decodeSuccess and type(decodedJson) == "table" then
				existingData = decodedJson
			else
				warn("DEBUG: Could not decode existing gearstockdata.json. It may be corrupt. Creating a new log.")
			end
		end
		
		table.insert(existingData, newLogEntry)
		
		local encodeSuccess, encodedJson = pcall(prettyEncode, existingData)
		if encodeSuccess then
			writefile("gearstockdata.json", encodedJson)
			print("DEBUG: Successfully updated gearstockdata.json")
		else
			warn("DEBUG: Failed to encode gear stock data to JSON. Error: " .. tostring(encodedJson))
		end
	end

	local function parseRegistry(scriptObj)
		local out = {}
		if not scriptObj then return out end
		local src = tostring(scriptObj.Source or "")
		local count = 0
		for name in src:gmatch('%["([^"]-)"%]%s*=%s*{') do
			out[name] = true
			count = count + 1
		end
		if count == 0 then
			for k in src:gmatch('([%w%s%-%_%%]+)%s*=%s*{') do
				if #k > 1 then
					out[k] = true
					count = count + 1
				end
			end
		end
		print("DEBUG: Parsed " .. count .. " gears from registry.")
		return out
	end

	local gearList = parseRegistry(gearRegistryScript)
	if assetsGears then
		local added = 0
		for _, g in ipairs(assetsGears:GetChildren()) do
			if not gearList[g.Name] then
				gearList[g.Name] = true
				added = added + 1
			end
		end
		if added > 0 then
			print("DEBUG: Added " .. added .. " gears from Assets folder.")
		end
	end

	local function parseStock(text)
		if not text then return 0 end
		local n = text:match("x%s*(%d+)") or text:match("(%d+)")
		return tonumber(n) or 0
	end

	local function attemptBuy(gearName)
		print("DEBUG: Attempting to buy gear '" .. gearName .. "'")
		local success, err
		
		success, err = pcall(function() buyRemote:FireServer(gearName) end)
		if success then print("DEBUG: Gear Purchase Method 1 (string) SUCCEEDED for " .. gearName); return true end
		print("DEBUG: Gear Purchase Method 1 FAILED for " .. gearName .. ". Error: " .. tostring(err))
		task.wait(0.15)
		
		success, err = pcall(function() buyRemote:FireServer({ Name = gearName }) end)
		if success then print("DEBUG: Gear Purchase Method 2 ({Name}) SUCCEEDED for " .. gearName); return true end
		print("DEBUG: Gear Purchase Method 2 FAILED for " .. gearName .. ". Error: " .. tostring(err))
		task.wait(0.15)
		
		success, err = pcall(function() buyRemote:FireServer({ ID = gearName }) end)
		if success then print("DEBUG: Gear Purchase Method 3 ({ID}) SUCCEEDED for " .. gearName); return true end
		print("DEBUG: Gear Purchase Method 3 FAILED for " .. gearName .. ". Error: " .. tostring(err))
		
		warn("DEBUG: All gear purchase methods FAILED for " .. gearName)
		return false
	end

	local function processFrame(frame)
		if isIgnored(frame) then return end
		local gearName = frame.Name
		if not gearName or gearName == "" or not gearList[gearName] then return end
		local stockLabel = findStockLabel(frame)
		if not stockLabel then return end

		while task.wait(0.25) do
			local count = parseStock(stockLabel.Text)
			if count <= 0 then
				print("DEBUG: Gear '" .. gearName .. "' is out of stock.")
				break
			end
			print("DEBUG: Stock for gear '" .. gearName .. "' is " .. count)
			if not attemptBuy(gearName) then
				warn("DEBUG: Breaking purchase loop for gear '" .. gearName .. "' due to failed buy attempt.")
				break
			end
		end
	end

	local function scanAll()
		print("DEBUG: Starting full scan of gear shop.")
		for _, child in ipairs(scrolling:GetChildren()) do
			if not isIgnored(child) then
				coroutine.wrap(processFrame)(child)
				task.wait(0.1)
			end
		end
		print("DEBUG: Gear shop scan complete.")
	end

	local function parseTimeToSeconds(t)
		if not t then return 0 end
		local mm, ss = t:match("(%d+):(%d+)")
		if mm and ss then return tonumber(mm) * 60 + tonumber(ss) end
		local n = t:match("(%d+)")
		return tonumber(n) or 0
	end

	if restockLabel then
		local lastSeconds = parseTimeToSeconds(restockLabel.Text)
		restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
			local s = parseTimeToSeconds(restockLabel.Text)
			if s > lastSeconds then
				print("DEBUG: GEAR RESTOCK DETECTED! Logging stock and rescanning shop.")
				task.wait(0.5)
				logStockData()
				scanAll()
			end
			lastSeconds = s
		end)
		print("DEBUG: Restock listener connected for Gear Buyer.")
	end

	task.wait(1)
	logStockData()
	scanAll()
end

coroutine.wrap(runGearBuyer)()
