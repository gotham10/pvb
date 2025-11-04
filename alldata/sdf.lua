local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local vu = game:GetService("VirtualUser")
local workspace = game.Workspace
local LocalPlayer = Players.LocalPlayer

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local FIREBASE_URL = "https://game-stock-data-default-rtdb.firebaseio.com/"
local seedsScrolling
local gearsScrolling

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

local function parseTimeToSeconds(text)
	if not text then
		return 0
	end
	local mm, ss = text:match("(%d+):(%d+)")
	if mm and ss then
		return tonumber(mm) * 60 + tonumber(ss)
	end
	local ssOnly = text:match("(%d+)")
	return tonumber(ssOnly) or 0
end

local function getStockFromFrame(scrollingFrame)
	local stockItems = {}
	if not scrollingFrame then
		return stockItems
	end
	for _, itemFrame in ipairs(scrollingFrame:GetChildren()) do
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
	return stockItems
end

local function sendLogData()
	local plantItems = getStockFromFrame(seedsScrolling)
	local gearItems = getStockFromFrame(gearsScrolling)

	if not next(plantItems) and not next(gearItems) then
		return
	end

	local newLogEntry = {
		timestamp = os.date("%Y-%m-%d %I:%M:%S %p"),
		plants = plantItems,
		gears = gearItems
	}

	local success, encodedJson = pcall(HttpService.JSONEncode, HttpService, newLogEntry)
	if not success then
		return
	end

	local fullUrl = FIREBASE_URL .. "latest_stock.json"
	
	pcall(function()
		request({
			Url = fullUrl,
			Method = "PUT",
			Headers = {["Content-Type"] = "application/json"},
			Body = encodedJson
		})
	end)
end

local function runLogger()
	local seedsGui = mainGui:WaitForChild("Seeds")
	local gearsGui = mainGui:WaitForChild("Gears")
	
	if not seedsGui then
		return
	end

	if seedsGui then
		seedsScrolling = seedsGui.Frame:WaitForChild("ScrollingFrame")
		local restockLabel = seedsGui:WaitForChild("Restock")

		if restockLabel and seedsScrolling then
			local lastSeconds = parseTimeToSeconds(restockLabel.Text)
			restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
				local s = parseTimeToSeconds(restockLabel.Text)
				if s > lastSeconds then
					task.wait(0.5)
					sendLogData()
				end
				lastSeconds = s
			end)
		end
	end

	if gearsGui then
		gearsScrolling = gearsGui.Frame:WaitForChild("ScrollingFrame")
	end

	task.wait(5)
	sendLogData()
end

LocalPlayer.Idled:Connect(function()
	vu:CaptureController()
	vu:ClickButton2(Vector2.new())
end)

local FIREBASE_BASE_URL = "https://pvb-data-default-rtdb.firebaseio.com/"
local NODE_PATH = "attributes.json"

local ATTRIBUTES_TO_WATCH = {
	ActiveEvents = true,
	AdminLuck = true,
	ServerLuck = true
}

local function sendAttributeData()
	local attributeValues = {
		ActiveEvents = workspace:GetAttribute("ActiveEvents"),
		AdminLuck = workspace:GetAttribute("AdminLuck"),
		ServerLuck = workspace:GetAttribute("ServerLuck")
	}

	local encodeSuccess, encodedJson = pcall(HttpService.JSONEncode, HttpService, attributeValues)
	
	if not encodeSuccess then
		warn("Failed to encode attributes to JSON:", encodedJson)
		return
	end

	local fullUrl = FIREBASE_BASE_URL .. NODE_PATH

	local requestData = {
		Url = fullUrl,
		Method = "PUT",
		Headers = {["Content-Type"] = "application/json"},
		Body = encodedJson
	}

	local requestSuccess, errorMessage = pcall(request, requestData)

	if not requestSuccess then
		warn("HTTP request to Firebase failed:", errorMessage)
	end
end

workspace.AttributeChanged:Connect(function(attributeName)
	if ATTRIBUTES_TO_WATCH[attributeName] then
		task.spawn(sendAttributeData)
	end
end)

local VERSION_CHECK_URL = "https://misc-9ae22-default-rtdb.firebaseio.com/version.json"

local function checkAndUpdateVersion()
	local localVersionString = "v" .. tostring(game.PlaceVersion)
	local currentVersion = nil
	
	local getSuccess, getResponse = pcall(request, {Url = VERSION_CHECK_URL, Method = "GET"})
	
	if getSuccess and getResponse and getResponse.Success and getResponse.Body then
		local decodeSuccess, decodedData = pcall(HttpService.JSONDecode, HttpService, getResponse.Body)
		if decodeSuccess and typeof(decodedData) == "table" and decodedData.version then
			currentVersion = tostring(decodedData.version)
		end
	end
	
	if currentVersion ~= localVersionString then
		local payload = {version = localVersionString}
		local encodeSuccess, encodedPayload = pcall(HttpService.JSONEncode, HttpService, payload)
		
		if encodeSuccess then
			pcall(request, {
				Url = VERSION_CHECK_URL,
				Method = "PUT",
				Headers = {["Content-Type"] = "application/json"},
				Body = encodedPayload
			})
		end
	end
end

coroutine.wrap(runLogger)()
task.spawn(sendAttributeData)
task.spawn(checkAndUpdateVersion)

