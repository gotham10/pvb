local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local mainGui = playerGui:WaitForChild("Main")

local function runStockLogger()
	local seedsGui = mainGui:WaitForChild("Seeds", 5)
	if not seedsGui then
		return
	end

	local scrolling = seedsGui.Frame:WaitForChild("ScrollingFrame", 5)
	if not scrolling then
		return
	end

	local restockLabel = seedsGui:WaitForChild("Restock", 5)

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
				if #val == 0 then
					return "[]"
				end
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
				for k in pairs(val) do
					table.insert(keys, k)
				end
				if #keys == 0 then
					return "{}"
				end
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
		if not inst or inst.Name == "Padding" then
			return true
		end
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
		if not text then
			return 0
		end
		local n = text:match("x%s*(%d+)") or text:match("(%d+)")
		return tonumber(n) or 0
	end

	local function logStockData()
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
			return
		end

		local newLogEntry = {
			timestamp = os.date("%Y-%m-%d %I:%M:%S %p"),
			items = stockItems
		}

		local existingData = {}
		local success, fileContent = pcall(readfile, "stockdata.json")
		if success and fileContent and fileContent ~= "" then
			local decodeSuccess, decodedJson = pcall(HttpService.JSONDecode, HttpService, fileContent)
			if decodeSuccess and type(decodedJson) == "table" and (next(decodedJson) == nil or decodedJson[1] ~= nil) then
				existingData = decodedJson
			end
		end

		table.insert(existingData, newLogEntry)

		local encodeSuccess, encodedJson = pcall(prettyEncode, existingData)
		if encodeSuccess then
			writefile("stockdata.json", encodedJson)
		end
	end

	local function parseTimeToSeconds(text)
		if not text then
			return 0
		end
		local mm, ss = text:match("(%d+):(%d+)")
		if mm and ss then
			return tonumber(mm) * 60 + tonumber(ss)
		end
		return tonumber(text:match("(%d+)")) or 0
	end

	if restockLabel then
		local lastSeconds = parseTimeToSeconds(restockLabel.Text)
		restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
			local s = parseTimeToSeconds(restockLabel.Text)
			if s > lastSeconds then
				task.wait(0.5)
				logStockData()
			end
			lastSeconds = s
		end)
	end

	task.wait(1)
	logStockData()
end

coroutine.wrap(runStockLogger)()
